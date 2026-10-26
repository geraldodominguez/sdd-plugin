#!/usr/bin/env bash
# Testes dos utilitários de bin/ e dos hooks do plugin SDD.
# Uso: tests/rodar-testes.sh
# Não depende do Claude Code: simula a entrada JSON que os hooks recebem.
set -uo pipefail

PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$PLUGIN/bin:$PATH"
unset CLAUDE_PROJECT_DIR CLAUDE_PLUGIN_ROOT

# Os resultados vão para um arquivo, porque muitas asserções rodam em subshell
# (cd "$X" && ...) e uma variável incrementada lá dentro se perderia.
RESULTADOS="$(mktemp)"
trap 'rm -f "$RESULTADOS"' EXIT
ok()   { echo p >> "$RESULTADOS"; printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { echo f >> "$RESULTADOS"; printf '  \033[31m✗\033[0m %s\n' "$1"; [ -n "${2:-}" ] && printf '      %s\n' "$2"; }

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

sdd_kv_ler_t() { grep -E "^$2=" "$1" | tail -1 | cut -d= -f2-; }
sdd_md_campo_t() { grep -E "^\| $2 \|" "$1" | head -1 | sed -E "s/^\| $2 \| (.*) \|$/\1/"; }
# subst <expressão sed> <arquivos...>: edita no lugar sem depender de sed -i.
subst() { local e="$1" f; shift; for f in "$@"; do sed "$e" "$f" > "$f.tmp" && mv "$f.tmp" "$f"; done; }
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

Q3="$TMP/outro-plugin"; mkdir -p "$Q3"
(cd "$Q3" && CLAUDE_PLUGIN_ROOT=/caminho/de/outro/plugin sdd-iniciar >/dev/null 2>&1)
[ -f "$Q3/.sdd/constituicao.md" ] && ok "ignora CLAUDE_PLUGIN_ROOT de outro plugin" || fail "CLAUDE_PLUGIN_ROOT de outro plugin"

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
  sed -i.bak 's/^fase=.*/fase=pronta/' "$P/specs/$F/estado"; rm -f "$P/specs/$F/estado.bak"
  assert_exit 0 "estrita/pronta: a fase não restringe mais nada" guard_edit "$P" "$P/tests/reset.test.ts"
  (cd "$P" && assert_exit 1 "definir fase recusa sair de pronta" sdd-estado definir fase=green)
  sed -i.bak 's/^fase=.*/fase=seguranca/' "$P/specs/$F/estado"; rm -f "$P/specs/$F/estado.bak"
  assert_exit 2 "estrita/seguranca: bloqueia código" guard_edit "$P" "$P/src/auth/token.ts"
  sed -i.bak 's/^protecao: .*/protecao: leve/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"
  assert_exit 2 "leve/seguranca: testes continuam congelados" guard_edit "$P" "$P/tests/reset.test.ts"
  assert_exit 0 "leve/seguranca: código liberado" guard_edit "$P" "$P/src/auth/token.ts"
  sed -i.bak 's/^protecao: .*/protecao: estrita/' "$P/.sdd/config.yml"; rm -f "$P/.sdd/config.yml.bak"

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
grep -q '| criada | nível 1, normal: Primeira | por: Pessoa Teste' "$Q2/specs/001-primeira/historico.md" && ok "histórico registra autor pelo git" || fail "autor no histórico"
n="$(cd "$Q2" && sdd-estado listar | wc -l | tr -d ' ')"
[ "$n" = "2" ] && ok "listar mostra todas as features" || fail "listar" "linhas: $n"
out="$(cd "$Q2" && sdd-estado historico 001-primeira --desde 2999-01-01)"
[ -z "$out" ] && ok "historico --desde filtra" || fail "historico --desde filtra" "$out"

echo "aprovação e ciclo da feature"
(cd "$Q2" && sdd-estado usar 002-segunda >/dev/null)
[ "$(sdd_feature_ler_t "$Q2" 002-segunda seguranca)" = "obrigatoria" ] && ok "nível 2 nasce com segurança obrigatória" || fail "segurança n2"
[ "$(sdd_feature_ler_t "$Q2" 001-primeira seguranca)" = "dispensada" ] && ok "nível 1 nasce com segurança dispensada" || fail "segurança n1"
(cd "$Q2" && assert_exit 5 "spec nunca aprovada: saída 5" sdd-estado aprovado spec.md)
(cd "$Q2" && sdd-estado aprovar >/dev/null)
(cd "$Q2" && assert_exit 0 "spec aprovada: saída 0" sdd-estado aprovado spec.md)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "plano" ] && ok "nível 2: spec aprovada leva ao plano" || fail "próxima fase n2"
echo "mudou" >> "$Q2/specs/002-segunda/spec.md"
(cd "$Q2" && assert_exit 4 "spec alterada depois de aprovada: saída 4" sdd-estado aprovado spec.md)
(cd "$Q2" && sdd-estado aprovar spec.md --sem-avancar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "plano" ] && ok "--sem-avancar reaprova sem mudar a fase" || fail "sem-avancar"
(cd "$Q2" && assert_exit 1 "aprovar plano inexistente falha" sdd-estado aprovar)
mkdir -p "$Q2/specs/002-segunda/contratos"; echo "plano" > "$Q2/specs/002-segunda/plano.md"; echo "type A" > "$Q2/specs/002-segunda/contratos/a.ts"
(cd "$Q2" && sdd-estado aprovar >/dev/null)
echo "type B" > "$Q2/specs/002-segunda/contratos/a.ts"
(cd "$Q2" && assert_exit 4 "mudar um contrato invalida a aprovação do plano" sdd-estado aprovado plano.md)
echo "type A" > "$Q2/specs/002-segunda/contratos/a.ts"
(cd "$Q2" && assert_exit 0 "desfazer a mudança restaura a aprovação" sdd-estado aprovado plano.md)
printf -- '- [x] T-001 a (atende: CA-001; depende de: nada)\n' > "$Q2/specs/002-segunda/tarefas.md"
(cd "$Q2" && sdd-estado aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "red" ] && ok "tarefas aprovadas levam ao red" || fail "tarefas para red"
(cd "$Q2" && assert_exit 1 "aprovar testes sem testes marcados falha" sdd-estado aprovar)
printf 'it("a") // sdd:002:CA-001\n' > "$Q2/tests/seg.test.js"
(cd "$Q2" && sdd-estado aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "testes aprovados levam ao green" || fail "red para green"
printf '// sdd:009:CA-001\nit("outra feature")\n' >> "$Q2/tests/seg.test.js"
(cd "$Q2" && assert_exit 0 "teste de outra feature no mesmo arquivo não muda o hash" sdd-estado aprovado testes)
printf 'it("antes") // sdd:002:CA-002\n' | cat - "$Q2/tests/seg.test.js" > "$Q2/tests/x.tmp" && mv "$Q2/tests/x.tmp" "$Q2/tests/seg.test.js"
(cd "$Q2" && assert_exit 4 "teste novo da própria feature muda o hash" sdd-estado aprovado testes)
printf 'it("a") // sdd:002:CA-001\n// sdd:009:CA-001\nit("outra feature")\n' > "$Q2/tests/seg.test.js"
(cd "$Q2" && assert_exit 0 "voltar ao conteúdo aprovado restaura" sdd-estado aprovado testes)
(cd "$Q2" && assert_exit 1 "nível 2 não entrega no green" sdd-estado aprovar)
(cd "$Q2" && assert_exit 1 "definir fase=pronta é recusado" sdd-estado definir fase=pronta)
(cd "$Q2" && sdd-estado definir fase=seguranca >/dev/null); echo "seg" > "$Q2/specs/002-segunda/seguranca.md"
(cd "$Q2" && assert_exit 1 "segurança exige --decisao" sdd-estado aprovar)
(cd "$Q2" && sdd-estado aprovar --decisao corrigir >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "segurança: corrigir volta ao green" || fail "segurança corrigir"
(cd "$Q2" && assert_exit 5 "corrigir não conta como aprovação da revisão" sdd-estado aprovado seguranca.md)
(cd "$Q2" && sdd-estado definir fase=seguranca >/dev/null && sdd-estado aprovar --decisao aceitar-risco --nota "PO aceita" >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "auditoria" ] && ok "nível 2: segurança aprovada leva à auditoria" || fail "segurança para auditoria"
echo "aud" > "$Q2/specs/002-segunda/auditoria.md"
(cd "$Q2" && assert_exit 1 "auditoria exige --decisao" sdd-estado aprovar)
(cd "$Q2" && sdd-estado aprovar --decisao corrigir >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "auditoria: corrigir volta ao green" || fail "auditoria corrigir"
(cd "$Q2" && sdd-estado definir fase=auditoria >/dev/null)
echo "mudança tardia" >> "$Q2/specs/002-segunda/spec.md"
(cd "$Q2" && assert_exit 1 "não fica pronta com spec alterada depois da aprovação" sdd-estado aprovar --decisao aprovar)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "auditoria" ] && ok "a fase não avança quando falta aprovação" || fail "fase não avança"
(cd "$Q2" && sdd-estado aprovar spec.md --sem-avancar >/dev/null && sdd-estado aprovar --decisao delta >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "pronta" ] && ok "auditoria aprovada leva a pronta" || fail "auditoria para pronta"
(cd "$Q2" && assert_exit 1 "aprovar numa feature pronta é recusado" sdd-estado aprovar)
(cd "$Q2" && assert_exit 1 "reabrir exige motivo" sdd-estado reabrir)
(cd "$Q2" && sdd-estado reabrir --fase green --motivo "ajuste" >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "green" ] && ok "reabrir na fase green" || fail "reabrir green"
(cd "$Q2" && assert_exit 5 "reabrir invalida a aprovação da segurança" sdd-estado aprovado seguranca.md)
(cd "$Q2" && assert_exit 0 "reabrir no green mantém a spec aprovada" sdd-estado aprovado spec.md)
grep -q '| reabertura | fase=green | motivo: ajuste' "$Q2/specs/002-segunda/historico.md" && ok "reabertura vai para o histórico" || fail "histórico de reabertura"
(cd "$Q2" && sdd-estado definir fase=seguranca >/dev/null && sdd-estado aprovar --decisao aprovar >/dev/null && sdd-estado aprovar --decisao aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "pronta" ] && ok "volta a ficar pronta depois de revisada de novo" || fail "pronta de novo"

echo "nível 1: entrega e área sensível"
(cd "$Q2" && sdd-estado usar 001-primeira >/dev/null && sdd-estado definir fase=green >/dev/null)
(cd "$Q2" && assert_exit 1 "entrega recusada sem spec e testes aprovados" sdd-estado aprovar)
(cd "$Q2" && sdd-estado aprovar spec.md --sem-avancar >/dev/null)
printf 'it("p") // sdd:001:CA-001\n' > "$Q2/tests/prim.test.js"
(cd "$Q2" && sdd-estado aprovar testes --sem-avancar >/dev/null)
sed -i.bak 's#^areas_sensiveis:.*#areas_sensiveis: src/auth/**#' "$Q2/.sdd/config.yml"; rm -f "$Q2/.sdd/config.yml.bak"
mkdir -p "$Q2/src/auth"; echo "x" > "$Q2/src/auth/login.js"
(cd "$Q2" && assert_exit 0 "sensivel detecta área sensível alterada" sdd-estado sensivel)
[ "$(sdd_feature_ler_t "$Q2" 001-primeira seguranca)" = "obrigatoria" ] && ok "área sensível torna a segurança obrigatória" || fail "sensível obrigatória"
(cd "$Q2" && assert_exit 1 "entrega recusada com segurança obrigatória" sdd-estado aprovar)
(cd "$Q2" && sdd-estado definir fase=seguranca >/dev/null); echo "seg" > "$Q2/specs/001-primeira/seguranca.md"
(cd "$Q2" && sdd-estado aprovar --decisao aprovar >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "pronta" ] && ok "nível 1: segurança aprovada leva a pronta" || fail "n1 segurança para pronta"
(cd "$Q2" && sdd-estado nova "Terceira" --nivel 1 >/dev/null)
(cd "$Q2" && assert_exit 1 "cancelar exige motivo" sdd-estado cancelar)
(cd "$Q2" && sdd-estado cancelar --motivo "mudou a prioridade" >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "cancelada" ] && ok "cancela a feature" || fail "cancelar"
(cd "$Q2" && sdd-estado reabrir --motivo "voltou" >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver fase)" = "especificacao" ] && ok "cancelada reabre na especificação" || fail "reabrir cancelada"
(cd "$Q2" && sdd-estado cancelar --motivo "de novo" >/dev/null)
(cd "$Q2" && assert_exit 1 "encerrar não existe mais" sdd-estado encerrar)

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
grep -q '^- \[x\] B-002 .*feature: 004-do-backlog)' "$Q2/.sdd/backlog.md" && ok "nova --origem promove o item" || fail "promover"
grep -q '| Origem | B-002 |' "$Q2/specs/004-do-backlog/spec.md" && ok "spec registra a origem" || fail "origem na spec"
(cd "$Q2" && sdd-backlog descartar B-003 "fora da estratégia" >/dev/null)
grep -q '^- \[-\] B-003 .*descartado: fora da estratégia)' "$Q2/.sdd/backlog.md" && ok "descarta com motivo" || fail "descartar"
[ "$(cd "$Q2" && sdd-backlog contar)" = "1" ] && ok "contar só os abertos" || fail "contar"
grep -q '| backlog | B-002 promovido a 004-do-backlog' "$Q2/.sdd/historico.md" && ok "eventos de backlog vão para o histórico do projeto" || fail "histórico do projeto"

echo "sprint"
(cd "$Q2" && sdd-sprint nova 2026-S50 --objetivo "Objetivo / com barra & e" --inicio 2026-12-07 --dias 14 >/dev/null)
grep -q '| Fim | 2026-12-20 |' "$Q2/.sdd/sprints/2026-S50.md" && ok "calcula o fim pela duração" || fail "data de fim"
grep -q '| Objetivo | Objetivo / com barra & e |' "$Q2/.sdd/sprints/2026-S50.md" && ok "objetivo com caracteres especiais" || fail "objetivo"
(cd "$Q2" && sdd-sprint incluir 2026-S50 004-do-backlog B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50 | tr '\n' ' ')" = "004-do-backlog B-001 " ] && ok "inclui itens" || fail "incluir"
(cd "$Q2" && assert_exit 1 "rejeita item inexistente na sprint" sdd-sprint incluir 2026-S50 999-nada)
(cd "$Q2" && sdd-sprint incluir 2026-S50 B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50 | wc -l | tr -d ' ')" = "2" ] && ok "não duplica item" || fail "duplicado"
(cd "$Q2" && sdd-sprint iniciar 2026-S50 >/dev/null)
[ "$(cd "$Q2" && sdd-estado ver sprint)" = "2026-S50" ] && ok "iniciar define a sprint atual" || fail "sprint atual"
out="$(cd "$Q2" && sdd-sprint ver)"
echo "$out" | grep -q 'Progresso: 0/2 itens' && ok "ver mostra o progresso" || fail "progresso da sprint" "$out"
echo "$out" | grep -q 'B-001 .*no backlog, ainda sem spec' && ok "ver aponta item sem spec" || fail "item sem spec" "$out"
(cd "$Q2" && sdd-sprint remover 2026-S50 B-001 >/dev/null)
[ "$(cd "$Q2" && sdd-sprint itens 2026-S50)" = "004-do-backlog" ] && ok "remove item" || fail "remover"
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
echo "$out" | grep -q '004-do-backlog: spec.md espera aprovação' && ok "pendência de aprovação" || fail "pendência de aprovação" "$out"
echo "$out" | grep -q 'B-001 está na sprint 2026-S51 e ainda não tem spec' && ok "pendência de sprint sem spec" || fail "sprint sem spec" "$out"
mkdir -p "$Q2/docs/adr"; printf '# ADR-0001: algo\n\n| Campo | Valor |\n|---|---|\n| Situação | proposta |\n' > "$Q2/docs/adr/0001-algo.md"
out="$(cd "$Q2" && sdd-pendencias)"
echo "$out" | grep -q 'docs/adr/0001-algo.md: ADR-0001: algo' && ok "pendência de ADR proposto" || fail "ADR proposto" "$out"
n="$(cd "$Q2" && sdd-pendencias --contar)"
[ "$n" -ge 3 ] && ok "contar pendências ($n)" || fail "contar pendências" "$n"
out="$(cd "$Q2" && sdd-status)"
echo "$out" | grep -q 'Sprint 2026-S51 (ativa)' && ok "quadro mostra a sprint" || fail "quadro sprint" "$out"
echo "$out" | grep -qE '▶ 004-do-backlog +n2 · especificacao' && ok "quadro marca a feature ativa" || fail "feature ativa no quadro" "$out"
echo "$out" | grep -qE '^Pronta$' && echo "$out" | grep -qE '002-segunda +n2 · pronta' && ok "quadro mostra a coluna Pronta" || fail "coluna pronta" "$out"
echo "$out" | grep -q 'Cancelada: 1' && ok "quadro conta canceladas" || fail "canceladas" "$out"
echo "$out" | grep -q 'ESPERANDO VOCÊ:' && ok "quadro resume pendências" || fail "pendências no quadro"
out="$(cd "$Q2" && sdd-status 002-segunda)"
echo "$out" | grep -q '\[pronta\]' && ok "detalhe de uma feature" || fail "detalhe" "$out"
echo "$out" | grep -q 'spec do sistema: NÃO consolidada' && ok "detalhe aponta consolidação pendente" || fail "consolidação no detalhe" "$out"

echo "spec do sistema"
Q4="$TMP/ciclo"; mkdir -p "$Q4/tests"
(cd "$Q4" && git init -q && git config user.name "Dev Teste" && git config user.email d@d.d && sdd-iniciar >/dev/null)
[ -f "$Q4/sistema/README.md" ] && ok "sdd-iniciar cria sistema/" || fail "sistema/"
[ -f "$Q4/.sdd/templates/release/homologacao.md" ] && ok "sdd-iniciar copia os templates da release" || fail "templates da release"
(cd "$Q4" && sdd-estado nova "Cadastro de clientes" --nivel 1 --capacidade clientes >/dev/null)
grep -q '| Capacidade | clientes |' "$Q4/specs/001-cadastro-de-clientes/spec.md" && ok "a spec registra a capacidade" || fail "capacidade na spec"
printf '# Spec\n- **RF-001**: cadastra\n- **CA-001** (valida RF-001)\n' > "$Q4/specs/001-cadastro-de-clientes/spec.md"
(cd "$Q4" && sdd-estado aprovar >/dev/null)
printf -- '- [x] T-001 cadastra (atende: RF-001, CA-001; depende de: nada)\n' > "$Q4/specs/001-cadastro-de-clientes/tarefas.md"
(cd "$Q4" && sdd-estado aprovar >/dev/null)
printf 'it("cadastra") // sdd:001:CA-001\n' > "$Q4/tests/cli.test.js"
(cd "$Q4" && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" 001-cadastro-de-clientes fase)" = "pronta" ] && ok "nível 1 chega a pronta" || fail "n1 pronta"
(cd "$Q4" && assert_exit 1 "consolidar exige a capacidade criada" sdd-sistema consolidar 001-cadastro-de-clientes)
(cd "$Q4" && sdd-sistema nova clientes "Clientes" >/dev/null)
(cd "$Q4" && assert_exit 1 "consolidar exige a capacidade citando a feature" sdd-sistema consolidar 001-cadastro-de-clientes)
printf -- '- QUANDO o cliente se cadastra, O SISTEMA DEVE guardar o CPF. (origem: 001/RF-001)\n' >> "$Q4/sistema/clientes.md"
(cd "$Q4" && assert_exit 0 "consolida a feature" sdd-sistema consolidar 001-cadastro-de-clientes)
grep -q '| Última feature | 001-cadastro-de-clientes |' "$Q4/sistema/clientes.md" && ok "a capacidade registra a última feature" || fail "última feature"
grep -qE '^\| [0-9-]+ \| 001 \|' "$Q4/sistema/clientes.md" && ok "a capacidade ganha a linha de histórico" || fail "histórico da capacidade"
grep -qE '^\| [0-9-]+ \| 001 \| [^S]' "$Q4/sistema/clientes.md" && ok "a linha de histórico traz o título sem o prefixo Spec" || fail "título na consolidação" "$(tail -2 "$Q4/sistema/clientes.md")"
(cd "$Q4" && assert_exit 0 "consolidada responde 0" sdd-sistema consolidada 001-cadastro-de-clientes)
[ -z "$(cd "$Q4" && sdd-sistema pendentes)" ] && ok "nada pendente de consolidação" || fail "pendentes"
(cd "$Q4" && assert_exit 1 "nome de capacidade inválido" sdd-sistema nova "Clientes VIP" "x")

echo "release"
[ "$(cd "$Q4" && sdd-release proxima)" = "0.1.0" ] && ok "primeira versão sugerida" || fail "proxima"
(cd "$Q4" && assert_exit 1 "versão precisa ser SemVer" sdd-release nova 1.0)
(cd "$Q4" && sdd-release nova 1.0.0 --objetivo "Primeira entrega" >/dev/null)
R="$Q4/releases/1.0.0"
[ "$(sdd_kv_ler_t "$R/estado" fase)" = "preparacao" ] && ok "release nasce em preparação" || fail "preparacao"
(cd "$Q4" && sdd-estado nova "Em construção" --nivel 1 >/dev/null)
(cd "$Q4" && assert_exit 1 "só entram features prontas" sdd-release incluir 1.0.0 002-em-construcao)
(cd "$Q4" && sdd-release incluir 1.0.0 001-cadastro-de-clientes >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" 001-cadastro-de-clientes release)" = "1.0.0" ] && ok "a feature guarda a release" || fail "release na feature"
(cd "$Q4" && assert_exit 1 "homologar exige testes de sistema" sdd-release homologar 1.0.0)
subst 's/{{[^}]*}}/x/g; s/| Resultado | x |/| Resultado | aprovado |/' "$R/testes.md"
subst 's/{{[^}]*}}/x/g' "$R/homologacao.md"
(cd "$Q4" && assert_exit 0 "homologar com testes e roteiro" sdd-release homologar 1.0.0)
[ "$(sdd_feature_ler_t "$Q4" 001-cadastro-de-clientes fase)" = "homologacao" ] && ok "features vão para homologação" || fail "features em homologação"
(cd "$Q4" && assert_exit 1 "aceite exige --por" sdd-release aceitar 1.0.0)
(cd "$Q4" && assert_exit 1 "aceite recusa roteiro pendente" sdd-release aceitar 1.0.0 --por "Bia, PO")
subst 's/| pendente |/| aprovado |/' "$R/homologacao.md"
(cd "$Q4" && assert_exit 1 "go antes do aceite é recusado" sdd-release autorizar 1.0.0)
(cd "$Q4" && sdd-release aceitar 1.0.0 --por "Bia, PO" >/dev/null)
grep -q '| aceite | por: Bia, PO | hash=' "$R/historico.md" && ok "aceite registrado com quem homologou" || fail "aceite"
(cd "$Q4" && assert_exit 1 "go recusa plano de implantação incompleto" sdd-release autorizar 1.0.0)
(cd "$Q4" && assert_exit 1 "pode-implantar falha sem go" sdd-release pode-implantar v1.0.0)
subst 's/{{[^}]*}}/x/g' "$R/implantacao.md" "$R/notas.md"
(cd "$Q4" && sdd-release autorizar 1.0.0 --nota "janela ok" >/dev/null)
(cd "$Q4" && assert_exit 0 "pode-implantar aceita a tag com v" sdd-release pode-implantar v1.0.0)
(cd "$Q4" && assert_exit 1 "concluir exige a verificação" sdd-release concluir 1.0.0)
(cd "$Q4" && sdd-release concluir 1.0.0 --verificacao "health 200" >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" 001-cadastro-de-clientes fase)" = "producao" ] && ok "features vão para produção" || fail "produção"
[ "$(cd "$Q4" && sdd-release proxima patch)" = "1.0.1" ] && ok "próxima patch depois da 1.0.0" || fail "proxima patch"
[ "$(cd "$Q4" && sdd-release proxima minor)" = "1.1.0" ] && ok "próxima minor depois da 1.0.0" || fail "proxima minor"
(cd "$Q4" && sdd-estado usar 001-cadastro-de-clientes >/dev/null)
(cd "$Q4" && assert_exit 1 "feature em produção não se reabre" sdd-estado reabrir --motivo "x")
(cd "$Q4" && assert_exit 1 "feature em produção não se cancela" sdd-estado cancelar --motivo "x")
assert_exit 2 "hook protege o histórico da release" guard_edit "$Q4" "$Q4/releases/1.0.0/historico.md"
assert_exit 2 "hook protege o estado da release" guard_edit "$Q4" "$Q4/releases/1.0.0/estado"
(cd "$Q4" && sdd-estado usar 002-em-construcao >/dev/null)
printf '# Spec\n- **RF-001**: x\n- **CA-001** (valida RF-001)\n' > "$Q4/specs/002-em-construcao/spec.md"
printf -- '- [x] T-001 x (atende: RF-001, CA-001; depende de: nada)\n' > "$Q4/specs/002-em-construcao/tarefas.md"
printf 'it("x") // sdd:002:CA-001\n' > "$Q4/tests/x.test.js"
(cd "$Q4" && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null)
(cd "$Q4" && sdd-release nova 1.1.0 >/dev/null && sdd-release incluir 1.1.0 002-em-construcao >/dev/null)
R2="$Q4/releases/1.1.0"
subst 's/{{[^}]*}}/x/g; s/| Resultado | x |/| Resultado | aprovado |/' "$R2/testes.md" "$R2/homologacao.md"
(cd "$Q4" && sdd-release homologar 1.1.0 >/dev/null)
(cd "$Q4" && sdd-release reprovar 1.1.0 002-em-construcao --motivo "texto errado" >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" 002-em-construcao fase)" = "green" ] && ok "reprovada na homologação volta ao green" || fail "reprovar"
[ "$(sdd_kv_ler_t "$R2/estado" fase)" = "preparacao" ] && ok "a release volta à preparação" || fail "release preparacao"
out="$(cd "$Q4" && sdd-release ver 1.1.0)"
case "$out" in *002-em-construcao*) fail "sai da release" "$out" ;; *) ok "a feature reprovada sai da release" ;; esac
(cd "$Q4" && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" 002-em-construcao fase)" = "pronta" ] && ok "corrigida, a feature fica pronta de novo" || fail "pronta de novo"
(cd "$Q4" && sdd-release incluir 1.1.0 002-em-construcao >/dev/null && sdd-release homologar 1.1.0 >/dev/null)
subst 's/| pendente |/| aprovado |/' "$R2/homologacao.md"
subst 's/{{[^}]*}}/x/g' "$R2/implantacao.md" "$R2/notas.md"
(cd "$Q4" && sdd-release aceitar 1.1.0 --por "Bia" >/dev/null && sdd-release autorizar 1.1.0 >/dev/null && sdd-release reverter 1.1.0 --motivo "erro 500" >/dev/null)
[ "$(sdd_kv_ler_t "$R2/estado" fase)" = "revertida" ] && ok "release revertida" || fail "revertida"
[ "$(sdd_feature_ler_t "$Q4" 002-em-construcao fase)" = "pronta" ] && ok "reverter devolve as features a pronta" || fail "reverter features"

echo "incidente e hotfix"
(cd "$Q4" && assert_exit 1 "incidente exige severidade válida" sdd-incidente abrir "x" --severidade S9)
(cd "$Q4" && sdd-incidente abrir "CPF duplicado aceito" --severidade S2 --feature 001-cadastro-de-clientes --release 1.0.0 >/dev/null)
I="$Q4/incidentes/INC-001.md"
[ "$(sdd_md_campo_t "$I" Situação)" = "aberto" ] && ok "incidente aberto" || fail "incidente aberto"
grep -q '| incidente | INC-001 (S2)' "$Q4/specs/001-cadastro-de-clientes/historico.md" && ok "incidente aparece no histórico da feature" || fail "incidente na feature"
(cd "$Q4" && sdd-incidente situacao INC-001 mitigado --nota "validação manual" >/dev/null)
grep -qE '^- [0-9TZ:-]+ mitigado: validação manual$' "$I" && ok "linha do tempo recebe o evento" || fail "linha do tempo" "$(sed -n '/Linha do tempo/,/Mitigação/p' "$I")"
(cd "$Q4" && assert_exit 1 "hotfix só nasce de incidente" sdd-estado nova "x" --tipo hotfix --origem B-001)
(cd "$Q4" && sdd-incidente hotfix INC-001 "Bloquear CPF duplicado" --capacidade clientes >/dev/null)
H=003-bloquear-cpf-duplicado
[ "$(sdd_feature_ler_t "$Q4" $H fase)" = "red" ] && ok "hotfix começa no red" || fail "hotfix red"
[ "$(sdd_feature_ler_t "$Q4" $H tipo)" = "hotfix" ] && ok "feature marcada como hotfix" || fail "tipo hotfix"
grep -q '| Correção | 003-bloquear-cpf-duplicado (hotfix) |' "$I" && ok "o incidente aponta a correção" || fail "correção no incidente"
printf 'it("recusa duplicado") // sdd:003:CA-001\n' > "$Q4/tests/hotfix.test.js"
(cd "$Q4" && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" $H fase)" = "green" ] && ok "hotfix: testes aprovados levam ao green" || fail "hotfix green"
(cd "$Q4" && assert_exit 1 "hotfix não entrega sem spec retroativa" sdd-estado aprovar)
out="$(cd "$Q4" && sdd-pendencias)"
echo "$out" | grep -q "$H: spec.md espera aprovação" && ok "pendências cobram a spec retroativa" || fail "spec retroativa pendente" "$out"
printf '# Spec\n- **RF-001**: recusa CPF duplicado\n- **CA-001** (valida RF-001)\n' > "$Q4/specs/$H/spec.md"
(cd "$Q4" && sdd-estado aprovar spec.md >/dev/null && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$Q4" $H fase)" = "pronta" ] && ok "hotfix com spec retroativa fica pronto" || fail "hotfix pronto"
(cd "$Q4" && assert_exit 1 "encerrar exige incidente resolvido" sdd-incidente encerrar INC-001)
(cd "$Q4" && sdd-incidente situacao INC-001 resolvido --nota "release 1.0.1" >/dev/null)
(cd "$Q4" && assert_exit 1 "encerrar exige post-mortem" sdd-incidente encerrar INC-001)
awk '/^## Post-mortem/ { d = 1 } d { gsub(/\{\{[^}]*\}\}/, "x") } { print }' "$I" > "$I.tmp" && mv "$I.tmp" "$I"
subst 's/^| 1 | x | x | x |$/| 1 | validar CPF no banco | preventiva | B-001 |/' "$I"
(cd "$Q4" && assert_exit 0 "encerra com post-mortem completo" sdd-incidente encerrar INC-001)
n="$(cd "$Q4" && sdd-incidente listar --abertos | grep -c '^INC-' || true)"
[ "$n" = "0" ] && ok "listar --abertos ignora encerrados" || fail "abertos" "$n"

echo "verificação para o CI"
(cd "$Q4" && sdd-sistema consolidar 002-em-construcao --sem-mudanca --nota "teste" >/dev/null)
printf -- '- O SISTEMA DEVE recusar CPF duplicado. (origem: 003/RF-001)\n' >> "$Q4/sistema/clientes.md"
(cd "$Q4" && sdd-sistema consolidar $H >/dev/null)
out="$(cd "$Q4" && sdd-verificar 2>&1)"; code=$?
[ "$code" -eq 0 ] && ok "verificar: projeto em dia passa" || fail "verificar em dia" "$out"
echo "mudou depois" >> "$Q4/specs/$H/spec.md"
out="$(cd "$Q4" && sdd-verificar 2>&1)"; code=$?
[ "$code" -eq 3 ] && echo "$out" | grep -q "$H (pronta): spec.md" && ok "verificar: spec alterada numa feature pronta falha" || fail "verificar spec alterada" "$out"
subst '$d' "$Q4/specs/$H/spec.md"
(cd "$Q4" && sdd-estado nova "Sem consolidar" --nivel 1 >/dev/null)
F5="$(cd "$Q4" && sdd-estado ver feature)"
printf '# Spec\n- **RF-001**: y\n- **CA-001** (valida RF-001)\n' > "$Q4/specs/$F5/spec.md"
printf -- '- [x] T-001 y (atende: RF-001, CA-001; depende de: nada)\n' > "$Q4/specs/$F5/tarefas.md"
printf 'it("y") // sdd:004:CA-001\n' > "$Q4/tests/y.test.js"
(cd "$Q4" && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null)
out="$(cd "$Q4" && sdd-verificar 2>&1)"; code=$?
[ "$code" -eq 0 ] && echo "$out" | grep -q "$F5 (pronta): ainda não consolidada" && ok "verificar: consolidação pendente é aviso" || fail "aviso consolidação" "$out"
(cd "$Q4" && assert_exit 3 "verificar --estrito trata aviso como falha" sdd-verificar --estrito)
out="$(cd "$Q4" && sdd-pendencias)"
echo "$out" | grep -q "$F5 (pronta) ainda não foi consolidada" && ok "pendências cobram a consolidação" || fail "pendência consolidação" "$out"
echo "$out" | grep -q "$F5 está pronta e fora de qualquer release" && ok "pendências apontam prontas fora de release" || fail "prontas fora de release" "$out"
out="$(cd "$Q4" && sdd-status)"
echo "$out" | grep -q 'Produção: 1 feature' && ok "quadro conta produção" || fail "quadro produção" "$out"

echo "entradas inválidas"
assert_exit 0 "stdin vazio: permite" bash -c "printf '' | '$PLUGIN/scripts/guarda-edicoes.sh'"
assert_exit 0 "JSON inválido: permite" bash -c "printf 'não é json' | '$PLUGIN/scripts/guarda-edicoes.sh'"

PASS="$(grep -c '^p$' "$RESULTADOS" || true)"
FAIL="$(grep -c '^f$' "$RESULTADOS" || true)"
echo
echo "Resultado: $PASS passaram, $FAIL falharam."
[ "$FAIL" -eq 0 ]
