#!/usr/bin/env bash
# Testes dos utilitários de bin/ e dos hooks do plugin SDD.
# Uso: tests/rodar-testes.sh
# Não depende do Claude Code: simula a entrada JSON que os hooks recebem.
set -uo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$PLUGIN/bin:$PATH"
unset CLAUDE_PROJECT_DIR CLAUDE_PLUGIN_ROOT

PASS=0
FAIL=0
ok()   { PASS=$((PASS + 1)); printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31m✗\033[0m %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; }

assert_exit() { # assert_exit <esperado> <descrição> <comando...>
  local expected="$1" desc="$2"; shift 2
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [ "$code" -eq "$expected" ]; then ok "$desc"; else fail "$desc" "esperado exit $expected, obtido $code: $out"; fi
}

edit_json() { # edit_json <cwd> <arquivo>
  printf '{"session_id":"t","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a","new_string":"b"}}' "$1" "$2"
}
bash_json() { # bash_json <cwd> <comando>
  local cmd="${2//\"/\\\"}"
  printf '{"session_id":"t","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" "$cmd"
}
guard_edit()   { edit_json "$1" "$2" | "$PLUGIN/scripts/guarda-edicoes.sh"; }
guard_commit() { bash_json "$1" "$2" | "$PLUGIN/scripts/guarda-commits.sh"; }

sdd_feature_ler_t() { grep -E "^$3=" "$1/specs/$2/estado" | tail -1 | cut -d= -f2-; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
P="$TMP/projeto"
mkdir -p "$P/src" "$P/tests"

echo "sdd-iniciar"
(cd "$P" && assert_exit 0 "inicializa projeto novo" sdd-iniciar)
[ -f "$P/.sdd/config.yml" ] && ok "cria .sdd/config.yml" || fail "cria .sdd/config.yml"
[ -f "$P/.sdd/constituicao.md" ] && ok "cria constituição" || fail "cria constituição"
[ -f "$P/.sdd/templates/spec.md" ] && ok "copia templates" || fail "copia templates"
[ ! -f "$P/.sdd/templates/bloco-agentes.md" ] && ok "não copia agents-block para templates" || fail "não copia agents-block"
grep -q '<!-- sdd:inicio -->' "$P/CLAUDE.md" && ok "injeta bloco no CLAUDE.md" || fail "injeta bloco no CLAUDE.md"
grep -q '<!-- sdd:inicio -->' "$P/AGENTS.md" && ok "injeta bloco no AGENTS.md" || fail "injeta bloco no AGENTS.md"
printf '# Meu projeto\n\nTexto do usuário.\n' > "$P/CLAUDE.md.user"
cat "$P/CLAUDE.md.user" "$P/CLAUDE.md" > "$P/CLAUDE.md.tmp" && mv "$P/CLAUDE.md.tmp" "$P/CLAUDE.md"
(cd "$P" && sdd-iniciar >/dev/null 2>&1)
n="$(grep -c '<!-- sdd:inicio -->' "$P/CLAUDE.md")"
[ "$n" = "1" ] && ok "reexecução é idempotente (um único bloco)" || fail "reexecução idempotente" "blocos: $n"
grep -q 'Texto do usuário.' "$P/CLAUDE.md" && ok "preserva conteúdo do usuário no CLAUDE.md" || fail "preserva conteúdo do usuário"
(cd "$P" && assert_exit 1 "rejeita proteção inválida" sdd-iniciar --protecao talvez)

echo "sdd-estado"
(cd "$P" && assert_exit 0 "cria feature nível 2" sdd-estado nova "Redefinição de senha" --nivel 2)
F="$(cd "$P" && sdd-estado ver feature)"
[ "$F" = "001-redefinicao-de-senha" ] && ok "slug com acentos removidos ($F)" || fail "slug" "obtido: $F"
[ "$(cd "$P" && sdd-estado ver fase)" = "especificacao" ] && ok "fase inicial = especificacao" || fail "fase inicial"
grep -q 'Spec 001-redefinicao-de-senha: Redefinição de senha' "$P/specs/$F/spec.md" && ok "spec preenchida com id e título" || fail "spec preenchida"
(cd "$P" && assert_exit 1 "rejeita fase inválida" sdd-estado definir fase=codar)
(cd "$P" && assert_exit 1 "rejeita nível inválido" sdd-estado definir nivel=7)
(cd "$P" && assert_exit 0 "muda fase válida" sdd-estado definir fase=clarificacao)
[ "$(cd "$P" && sdd-estado caminho tarefas.md)" = "specs/$F/tarefas.md" ] && ok "path da feature" || fail "path da feature"
(cd "$P/src" && [ "$(sdd-estado ver feature)" = "$F" ]) && ok "encontra .sdd/ a partir de subpasta" || fail "encontra .sdd a partir de subpasta"

echo "sdd-rastrear"
cat > "$P/specs/$F/spec.md" <<'EOF'
# Spec
- **RF-001**: QUANDO pedir, O SISTEMA DEVE enviar link.
- **RF-002**: SE expirado, ENTÃO O SISTEMA DEVE recusar.
- **RNF-001**: em até 500 ms.
- **CA-001** (valida RF-001)
- **CA-002** (valida RF-002)
EOF
(cd "$P" && assert_exit 3 "aponta lacuna sem tarefas.md" sdd-rastrear --silencioso)
cat > "$P/specs/$F/tarefas.md" <<'EOF'
- [ ] T-001 gera token (atende: RF-001, CA-001; depende de: nada)
- [ ] T-002 valida expiração (atende: RF-002, CA-002; depende de: T-001)
EOF
out="$(cd "$P" && sdd-rastrear 2>&1)"
echo "$out" | grep -q 'RNF-001 está na spec, mas nenhuma tarefa' && ok "detecta RNF sem tarefa" || fail "detecta RNF sem tarefa" "$out"
echo "$out" | grep -q 'Nenhum arquivo de teste encontrado' && ok "avisa quando não há arquivos de teste" || fail "avisa sem arquivos de teste" "$out"
printf '// sdd:001:CA-001\nit("envia link", () => {})\n' > "$P/tests/parcial.test.ts"
out="$(cd "$P" && sdd-rastrear 2>&1)"
echo "$out" | grep -q 'CA-002 não tem teste' && ok "detecta CA sem teste" || fail "detecta CA sem teste" "$out"
echo "$out" | grep -q 'CA-001 não tem teste' && fail "CA-001 tem teste e não deveria ser apontado" || ok "reconhece CA com teste marcado"
rm -f "$P/tests/parcial.test.ts"
cat >> "$P/specs/$F/tarefas.md" <<'EOF'
- [ ] T-003 mede latência (atende: RNF-001; depende de: T-002)
- [ ] T-004 tarefa solta sem referência
- [ ] T-005 fantasma (atende: RF-009)
EOF
out="$(cd "$P" && sdd-rastrear 2>&1)"
echo "$out" | grep -q 'T-004 não referencia' && ok "detecta tarefa sem referência" || fail "tarefa sem referência" "$out"
echo "$out" | grep -q 'cita RF-009, que não existe' && ok "detecta ID inexistente" || fail "ID inexistente" "$out"
sed -i.bak '/T-004/d; /T-005/d' "$P/specs/$F/tarefas.md" && rm -f "$P/specs/$F/tarefas.md.bak"
cat > "$P/tests/reset.test.ts" <<'EOF'
// sdd:001:CA-001
it('envia link', () => {})
it('recusa expirado', () => {}) // sdd:001:CA-002
EOF
(cd "$P" && assert_exit 0 "sem lacunas quando tudo está ligado" sdd-rastrear --silencioso)

echo "sdd-status"
out="$(cd "$P" && sdd-status --ativa 2>&1)"
echo "$out" | grep -q 'tarefas: 0/3' && ok "conta tarefas" || fail "conta tarefas" "$out"
echo "$out" | grep -q '\[clarificacao\]' && ok "destaca fase atual" || fail "destaca fase" "$out"

for parser in jq python grep; do
  if [ "$parser" = "jq" ] && ! command -v jq >/dev/null; then continue; fi
  if [ "$parser" = "python" ] && ! command -v python3 >/dev/null; then continue; fi
  export SDD_JSON_PARSER="$parser"
  echo "guarda-edicoes (leitor: $parser)"

  sed -i.bak 's/^protecao: .*/protecao: leve/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"
  (cd "$P" && sdd-estado definir fase=green >/dev/null)
  assert_exit 2 "leve/green: bloqueia teste" guard_edit "$P" "$P/tests/reset.test.ts"
  assert_exit 2 "leve/green: bloqueia *.spec.ts fora de tests/" guard_edit "$P" "$P/src/auth/token.spec.ts"
  assert_exit 0 "leve/green: permite código" guard_edit "$P" "$P/src/auth/token.ts"
  assert_exit 0 "leve/green: permite spec.md da feature" guard_edit "$P" "$P/specs/$F/spec.md"
  assert_exit 0 "leve/green: permite arquivo fora do projeto" guard_edit "$P" "/tmp/outra-coisa/tests/x.test.ts"
  (cd "$P" && sdd-estado definir fase=red >/dev/null)
  assert_exit 0 "leve/red: permite código (só a estrita restringe)" guard_edit "$P" "$P/src/auth/token.ts"

  sed -i.bak 's/^protecao: .*/protecao: estrita/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"
  (cd "$P" && sdd-estado definir fase=especificacao >/dev/null)
  assert_exit 2 "estrita/spec: bloqueia código" guard_edit "$P" "$P/src/auth/token.ts"
  assert_exit 0 "estrita/spec: permite spec" guard_edit "$P" "$P/specs/$F/spec.md"
  assert_exit 0 "estrita/spec: permite .sdd/" guard_edit "$P" "$P/.sdd/constituicao.md"
  (cd "$P" && sdd-estado definir fase=red >/dev/null)
  assert_exit 0 "estrita/red: permite teste" guard_edit "$P" "$P/tests/reset.test.ts"
  assert_exit 2 "estrita/red: bloqueia código" guard_edit "$P" "$P/src/auth/token.ts"
  (cd "$P" && sdd-estado definir fase=green >/dev/null)
  assert_exit 2 "estrita/green: bloqueia teste" guard_edit "$P" "tests/reset.test.ts"
  assert_exit 0 "estrita/green: permite código" guard_edit "$P" "src/auth/token.ts"
  (cd "$P" && sdd-estado definir fase=auditoria >/dev/null)
  assert_exit 2 "estrita/audit: bloqueia código" guard_edit "$P" "$P/src/auth/token.ts"
  assert_exit 0 "estrita/auditoria: permite auditoria.md" guard_edit "$P" "$P/specs/$F/auditoria.md"
  (cd "$P" && sdd-estado definir fase=concluida >/dev/null)
  assert_exit 0 "estrita/done: permite tudo" guard_edit "$P" "$P/tests/reset.test.ts"

  sed -i.bak 's#^globs_de_contrato:.*#globs_de_contrato: src/domain/contracts/**#' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"
  (cd "$P" && sdd-estado definir fase=plano >/dev/null)
  assert_exit 0 "estrita/plan: permite globs_de_contrato" guard_edit "$P" "$P/src/domain/contracts/user.ts"
  assert_exit 2 "estrita/plan: bloqueia outro código" guard_edit "$P" "$P/src/domain/user.ts"
  (cd "$P" && sdd-estado definir fase=green >/dev/null)
  assert_exit 2 "estrita/green: contratos congelados" guard_edit "$P" "$P/src/domain/contracts/user.ts"
  sed -i.bak 's#^globs_de_contrato:.*#globs_de_contrato:#' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"

  sed -i.bak 's/^protecao: .*/protecao: desligada/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"
  assert_exit 0 "desligada: nada é bloqueado" guard_edit "$P" "$P/tests/reset.test.ts"
  sed -i.bak 's/^protecao: .*/protecao: leve/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"

  WIN_P="C:\\\\Users\\\\dev\\\\proj"
  printf '{"cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"%s\\\\tests\\\\a.test.ts"}}' "$WIN_P" "$WIN_P" \
    | "$PLUGIN/scripts/guarda-edicoes.sh" >/dev/null 2>&1
  [ $? -eq 0 ] && ok "caminho Windows sem .sdd/: permite" || fail "caminho Windows sem .sdd"

  echo "guarda-commits (leitor: $parser)"
  (cd "$P" && sdd-estado definir fase=green >/dev/null)
  assert_exit 2 "bloqueia commit sem tarefa" guard_commit "$P" 'git commit -m "ajustes"'
  assert_exit 0 "permite commit com T-NNN" guard_commit "$P" 'git commit -m "feat(001): T-002 valida expiração"'
  assert_exit 0 "permite commit com (NNN)" guard_commit "$P" 'git commit -m "docs(001): atualiza spec"'
  assert_exit 0 "permite git add && commit com T-NNN" guard_commit "$P" 'git add -A && git commit -am "fix: T-001 corrige token"'
  assert_exit 2 "bloqueia -am sem tarefa" guard_commit "$P" 'git add . && git commit -am "wip"'
  assert_exit 0 "ignora commit sem -m (editor)" guard_commit "$P" 'git commit --amend --no-edit'
  assert_exit 0 "ignora outros comandos" guard_commit "$P" 'npm test'
  assert_exit 0 "ignora git log" guard_commit "$P" 'git log --oneline'
  (cd "$P" && sdd-estado definir fase=especificacao >/dev/null)
  assert_exit 0 "fora de red/green/auditoria: permite" guard_commit "$P" 'git commit -m "spec inicial"'

  echo "projeto sem SDD (leitor: $parser)"
  Q="$TMP/sem-sdd"; mkdir -p "$Q/tests"
  assert_exit 0 "hook de edição não interfere" guard_edit "$Q" "$Q/tests/a.test.ts"
  assert_exit 0 "hook de commit não interfere" guard_commit "$Q" 'git commit -m "qualquer"'
  unset SDD_JSON_PARSER
done

echo "estado por feature e histórico"
Q2="$TMP/fluxo"; mkdir -p "$Q2/tests"
(cd "$Q2" && git init -q && git config user.name "Pessoa Teste" && git config user.email t@t.t && sdd-iniciar >/dev/null)
[ -f "$Q2/.sdd/backlog.md" ] && ok "sdd-iniciar cria backlog.md" || fail "sdd-iniciar cria backlog.md"
[ -d "$Q2/.sdd/sprints" ] && ok "sdd-iniciar cria sprints/" || fail "sdd-iniciar cria sprints/"
grep -qx 'estado' "$Q2/.sdd/.gitignore" && ok "ponteiros pessoais ficam fora do git" || fail ".sdd/.gitignore"
(cd "$Q2" && sdd-estado nova "Primeira" --nivel 1 >/dev/null && sdd-estado nova "Segunda" --nivel 2 >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver feature)" = "002-segunda" ] && ok "nova ativa a feature criada" || fail "nova ativa a feature"
(cd "$Q2" && sdd-estado usar 001-primeira >/dev/null && sdd-estado definir fase=tarefas >/dev/null)
[ "$(sdd_feature_ler_t "$Q2" 002-segunda fase)" = "especificacao" ] && ok "cada feature guarda a própria fase" || fail "fase por feature"
[ "$(cd "$Q2" && sdd-estado ver fase)" = "tarefas" ] && ok "ver fase lê a feature ativa" || fail "ver fase"
grep -q '| fase | especificacao para tarefas |' "$Q2/specs/001-primeira/historico.md" && ok "troca de fase vai para o histórico" || fail "histórico de fase"
grep -q '| criada | nível 1: Primeira | por: Pessoa Teste' "$Q2/specs/001-primeira/historico.md" && ok "histórico registra autor pelo git" || fail "autor no histórico"
n="$(cd "$Q2" && sdd-estado listar | wc -l | tr -d ' ')"
[ "$n" = "2" ] && ok "listar mostra todas as features" || fail "listar" "linhas: $n"
(cd "$Q2" && sdd-estado historico 001-primeira --desde 2999-01-01 | grep -q .) && fail "historico --desde filtra" || ok "historico --desde filtra"

echo "aprovação"
(cd "$Q2" && sdd-estado usar 002-segunda >/dev/null)
(cd "$Q2" && assert_exit 5 "spec nunca aprovada: saída 5" sdd-estado aprovado spec.md)
(cd "$Q2" && sdd-estado aprovar >/dev/null)
(cd "$Q2" && assert_exit 0 "spec aprovada: saída 0" sdd-estado aprovado spec.md)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "plano" ] && ok "nível 2: spec aprovada leva ao plano" || fail "próxima fase n2"
echo "mudou" >> "$Q2/specs/002-segunda/spec.md"
(cd "$Q2" && assert_exit 4 "spec alterada depois de aprovada: saída 4" sdd-estado aprovado spec.md)
(cd "$Q2" && assert_exit 1 "aprovar plano inexistente falha" sdd-estado aprovar)
mkdir -p "$Q2/specs/002-segunda/contratos"; echo "plano" > "$Q2/specs/002-segunda/plano.md"; echo "type A" > "$Q2/specs/002-segunda/contratos/a.ts"
(cd "$Q2" && sdd-estado aprovar >/dev/null)
echo "type B" > "$Q2/specs/002-segunda/contratos/a.ts"
(cd "$Q2" && assert_exit 4 "mudar um contrato invalida a aprovação do plano" sdd-estado aprovado plano.md)
(cd "$Q2" && sdd-estado definir fase=red >/dev/null)
(cd "$Q2" && assert_exit 1 "aprovar testes sem testes marcados falha" sdd-estado aprovar)
printf 'it("a") // sdd:002:CA-001\n' > "$Q2/tests/seg.test.js"
(cd "$Q2" && sdd-estado aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "testes aprovados levam ao green" || fail "red para green"
echo "// mexi" >> "$Q2/tests/seg.test.js"
(cd "$Q2" && assert_exit 4 "teste alterado depois da red é detectado" sdd-estado aprovado testes)
(cd "$Q2" && assert_exit 1 "nível 2 não encerra sem auditoria" sdd-estado aprovar)
(cd "$Q2" && sdd-estado definir fase=auditoria >/dev/null); echo "aud" > "$Q2/specs/002-segunda/auditoria.md"
(cd "$Q2" && assert_exit 1 "auditoria exige --decisao" sdd-estado aprovar)
(cd "$Q2" && sdd-estado aprovar --decisao corrigir >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "decisão corrigir volta ao green" || fail "corrigir"
(cd "$Q2" && sdd-estado definir fase=auditoria >/dev/null && sdd-estado aprovar --decisao aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "concluida" ] && ok "decisão aprovar conclui" || fail "aprovar auditoria"
(cd "$Q2" && sdd-estado usar 001-primeira >/dev/null && sdd-estado definir fase=green >/dev/null && sdd-estado aprovar --nota "ok" >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "concluida" ] && ok "nível 1 pode encerrar no green" || fail "entrega n1"

echo "backlog"
(cd "$Q2" && sdd-backlog adicionar "Item baixo" --prioridade baixa --nivel 1 >/dev/null && sdd-backlog adicionar "Item alto (urgente)" --prioridade alta --nivel 2 --origem "cliente; X" >/dev/null && sdd-backlog adicionar "Sem nível" >/dev/null)
primeiro="$(cd "$Q2" && sdd-backlog listar | head -1 | cut -c1-5)"
[ "$primeiro" = "B-002" ] && ok "listar ordena por prioridade" || fail "ordem do backlog" "$primeiro"
grep -q 'B-002 Item alto urgente (prioridade: alta; nivel: 2; origem: cliente X;' "$Q2/.sdd/backlog.md" && ok "parênteses e ponto e vírgula não quebram o formato" || fail "sanitização"
(cd "$Q2" && sdd-backlog prioridade B-001 alta >/dev/null)
grep -q 'B-001 Item baixo (prioridade: alta' "$Q2/.sdd/backlog.md" && ok "muda prioridade" || fail "prioridade"
(cd "$Q2" && assert_exit 1 "rejeita prioridade inválida" sdd-backlog prioridade B-001 urgente)
(cd "$Q2" && assert_exit 1 "rejeita item inexistente" sdd-backlog ver B-099)
(cd "$Q2" && sdd-estado nova "Do backlog" --nivel 2 --origem B-002 >/dev/null)
grep -q '^- \[x\] B-002 .*feature: 003-do-backlog)' "$Q2/.sdd/backlog.md" && ok "nova --origem promove o item" || fail "promover"
grep -q '| Origem | B-002 |' "$Q2/specs/003-do-backlog/spec.md" && ok "spec registra a origem" || fail "origem na spec"
(cd "$Q2" && sdd-backlog descartar B-003 "fora da estratégia" >/dev/null)
grep -q '^- \[-\] B-003 .*descartado: fora da estratégia)' "$Q2/.sdd/backlog.md" && ok "descarta com motivo" || fail "descartar"
[ "$(cd "$Q2" && sdd-backlog contar)" = "1" ] && ok "contar só os abertos" || fail "contar"
grep -q '| backlog | B-002 promovido a 003-do-backlog' "$Q2/.sdd/historico.md" && ok "eventos de backlog vão para o histórico do projeto" || fail "histórico do projeto"

echo "sprint"
(cd "$Q2" && sdd-sprint nova 2026-S50 --objetivo "Objetivo / com barra & e" --inicio 2026-12-07 --dias 14 >/dev/null)
grep -q '| Fim | 2026-12-20 |' "$Q2/.sdd/sprints/2026-S50.md" && ok "calcula o fim pela duração" || fail "data de fim"
grep -q '| Objetivo | Objetivo / com barra & e |' "$Q2/.sdd/sprints/2026-S50.md" && ok "objetivo com caracteres especiais" || fail "objetivo"
(cd "$Q2" && sdd-sprint incluir 2026-S50 003-do-backlog B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50 | tr '\n' ' ')" = "003-do-backlog B-001 " ] && ok "inclui itens" || fail "incluir"
(cd "$Q2" && assert_exit 1 "rejeita item inexistente na sprint" sdd-sprint incluir 2026-S50 999-nada)
(cd "$Q2" && sdd-sprint incluir 2026-S50 B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50 | wc -l | tr -d ' ')" = "2" ] && ok "não duplica item" || fail "duplicado"
(cd "$Q2" && sdd-sprint iniciar 2026-S50 >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver sprint)" = "2026-S50" ] && ok "iniciar define a sprint atual" || fail "sprint atual"
out="$(cd "$Q2" && sdd-sprint ver)"
echo "$out" | grep -q 'Progresso: 0/2 itens' && ok "ver mostra o progresso" || fail "progresso da sprint" "$out"
echo "$out" | grep -q 'B-001 .*no backlog, ainda sem spec' && ok "ver aponta item sem spec" || fail "item sem spec" "$out"
(cd "$Q2" && sdd-sprint remover 2026-S50 B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50)" = "003-do-backlog" ] && ok "remove item" || fail "remover"
(cd "$Q2" && sdd-sprint encerrar 2026-S50 >/dev/null)
grep -q 'Entregue: 0 de 1 itens' "$Q2/.sdd/sprints/2026-S50.md" && ok "encerrar grava o resultado" || fail "resultado"
[ -z "$(cd "$Q2" && sdd-estado ver sprint)" ] && ok "encerrar limpa a sprint atual" || fail "limpa sprint"

echo "histórico e estado protegidos"
assert_exit 2 "hook bloqueia edição do histórico" guard_edit "$Q2" "$Q2/specs/001-primeira/historico.md"
assert_exit 2 "hook bloqueia edição do estado da feature" guard_edit "$Q2" "$Q2/specs/001-primeira/estado"
assert_exit 2 "hook bloqueia edição do histórico do projeto" guard_edit "$Q2" "$Q2/.sdd/historico.md"
assert_exit 0 "hook permite editar a spec" guard_edit "$Q2" "$Q2/specs/001-primeira/spec.md"
sed -i.bak 's/^protecao: .*/protecao: desligada/' "$Q2/.sdd/config.yml"; rm -f "$Q2/.sdd/config.yml.bak"
assert_exit 0 "proteção desligada libera o histórico" guard_edit "$Q2" "$Q2/specs/001-primeira/historico.md"
sed -i.bak 's/^protecao: .*/protecao: leve/' "$Q2/.sdd/config.yml"; rm -f "$Q2/.sdd/config.yml.bak"

echo "pendências e quadro"
(cd "$Q2" && sdd-sprint nova 2026-S51 --objetivo "Próxima" --inicio 2026-12-21 --fim 2027-01-03 >/dev/null && sdd-sprint incluir 2026-S51 B-001 >/dev/null && sdd-sprint iniciar 2026-S51 >/dev/null)
out="$(cd "$Q2" && sdd-pendencias)"
echo "$out" | grep -q '003-do-backlog: spec.md espera aprovação' && ok "pendência de aprovação" || fail "pendência de aprovação" "$out"
echo "$out" | grep -q 'B-001 está na sprint 2026-S51 e ainda não tem spec' && ok "pendência de sprint sem spec" || fail "sprint sem spec" "$out"
mkdir -p "$Q2/docs/adr"; printf '# ADR-0001: algo\n\n| Campo | Valor |\n|---|---|\n| Situação | proposta |\n' > "$Q2/docs/adr/0001-algo.md"
(cd "$Q2" && sdd-pendencias) | grep -q 'docs/adr/0001-algo.md: ADR-0001: algo' && ok "pendência de ADR proposto" || fail "ADR proposto"
n="$(cd "$Q2" && sdd-pendencias --contar)"
[ "$n" -ge 3 ] && ok "contar pendências ($n)" || fail "contar pendências" "$n"
out="$(cd "$Q2" && sdd-status)"
echo "$out" | grep -q 'Sprint 2026-S51 (ativa)' && ok "quadro mostra a sprint" || fail "quadro sprint" "$out"
echo "$out" | grep -qE '▶ 003-do-backlog +n2 · especificacao' && ok "quadro marca a feature ativa" || fail "feature ativa no quadro" "$out"
echo "$out" | grep -q 'Concluída: 2 feature' && ok "quadro conta concluídas" || fail "concluídas" "$out"
echo "$out" | grep -q 'ESPERANDO VOCÊ:' && ok "quadro resume pendências" || fail "pendências no quadro"
out="$(cd "$Q2" && sdd-status 002-segunda)"
echo "$out" | grep -q '\[concluida\]' && ok "detalhe de uma feature" || fail "detalhe" "$out"

echo "entradas inválidas"
assert_exit 0 "stdin vazio: permite" bash -c "printf '' | '$PLUGIN/scripts/guarda-edicoes.sh'"
assert_exit 0 "JSON inválido: permite" bash -c "printf 'não é json' | '$PLUGIN/scripts/guarda-edicoes.sh'"

echo
echo "Resultado: $PASS passaram, $FAIL falharam."
[ "$FAIL" -eq 0 ]
