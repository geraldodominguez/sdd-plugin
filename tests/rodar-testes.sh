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
  cmd="${cmd//$'\n'/\\n}"
  printf '{"session_id":"t","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" "$cmd"
}
write_json() { # write_json <cwd> <arquivo>
  printf '{"session_id":"t","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$1" "$2"
}
guard_edit()   { edit_json "$1" "$2" | "$PLUGIN/scripts/guarda-edicoes.sh"; }
guard_write()  { write_json "$1" "$2" | "$PLUGIN/scripts/guarda-edicoes.sh"; }
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
  assert_exit 0 "fora de red/green/auditoria: permite (sem T-NNN)" guard_commit "$P" 'git commit -m "docs: spec inicial"'

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

echo "layout: classificador"
tipo_de() { (. "$PLUGIN/lib/sdd-comum.sh"; sdd_fora_do_layout "$TMP/nenhum" "$1" || echo nada); }
for par in "docs/specs/login.md:spec" "PRD.md:spec" "TODO.md:tarefas" "tasks.md:tarefas" \
           "docs/decisions/usar-pg.md:adr" "docs/adr/usar-pg.md:adr" ".kiro/specs/x/design.md:plano" \
           "ROADMAP.md:backlog" "CONVENTIONS.md:constituicao" "docs/architecture.md:arquitetura" \
           "README.md:nada" "src/a.spec.ts:nada" "docs/guia.md:nada" "docs/adr/0001-usar-pg.md:nada" \
           "docs/legado/x/spec.md:nada" "node_modules/x/TODO.md:nada" "docs/adr/0001-Usar_PG.md:adr"; do
  c="${par%%:*}"; e="${par#*:}"; o="$(tipo_de "$c")"
  [ "$o" = "$e" ] && ok "classifica $c como $e" || fail "classifica $c" "esperado $e, obtido $o"
done

echo "layout: adoção de projeto que não nasceu com o plugin"
L="$TMP/legado"
mkdir -p "$L/docs/specs/login" "$L/docs/decisions" "$L/.kiro/specs/pagamento" "$L/src"
printf '# Login\nrequisitos do login\n' > "$L/docs/specs/login/requirements.md"
printf -- '- [ ] fazer login\n' > "$L/docs/specs/login/tasks.md"
printf '# Usar Postgres\n' > "$L/docs/decisions/usar-postgres.md"
printf '# design\n' > "$L/.kiro/specs/pagamento/design.md"
printf '# req\n' > "$L/.kiro/specs/pagamento/requirements.md"
printf -- '- [ ] exportar csv\n' > "$L/TODO.md"
printf 'Veja docs/specs/login/requirements.md\n' > "$L/README.md"
printf 'x\n' > "$L/src/app.ts"
(cd "$L" && git init -q && git config user.name Teste && git config user.email t@t && git add -A && git commit -qm inicio)
[ "$(cd "$L" && sdd-adotar contar)" = "6" ] && ok "inventário encontra os 6 artefatos antes do .sdd/" || fail "inventário antes do .sdd" "$(cd "$L" && sdd-adotar inventario)"
out="$(cd "$L" && sdd-adotar inventario)"
echo "$out" | grep -q 'não foi preparado pelo SDD' && ok "inventário avisa que o projeto não nasceu com o plugin" || fail "aviso de projeto alheio"
printf 'TODO.md -> legado:TODO.md\n' > "$TMP/mapa-cedo.txt"
(cd "$L" && assert_exit 1 "aplicar exige .sdd/" sdd-adotar aplicar "$TMP/mapa-cedo.txt")
(cd "$L" && sdd-iniciar >/dev/null)
M="$TMP/mapa.txt"
printf 'docs/specs/login/nao-existe.md -> feature:login/spec.md\nTODO.md -> legado:TODO.md\n' > "$M"
(cd "$L" && assert_exit 1 "mapa com origem inexistente é recusado" sdd-adotar aplicar "$M")
[ -f "$L/TODO.md" ] && ok "mapa recusado não move nada" || fail "mapa recusado moveu arquivo"
printf 'TODO.md -> src/TODO.md\n' > "$M"
(cd "$L" && assert_exit 1 "destino fora do padrão é recusado" sdd-adotar aplicar "$M")
printf 'TODO.md -> feature:x/qualquer.md\n' > "$M"
(cd "$L" && assert_exit 1 "arquivo de feature inválido é recusado" sdd-adotar aplicar "$M")
printf 'TODO.md -> specs/050-inventada/spec.md\n' > "$M"
(cd "$L" && assert_exit 1 "feature nova só pelo atalho feature:" sdd-adotar aplicar "$M")
printf 'TODO.md -> legado:a.md\nREADME.md -> legado:a.md\n' > "$M"
(cd "$L" && assert_exit 1 "destino repetido é recusado" sdd-adotar aplicar "$M")
cat > "$M" <<'MAPA'
# login, em andamento
docs/specs/login/requirements.md -> feature:Login com e-mail/spec.md
docs/specs/login/tasks.md -> feature:login-com-e-mail/tarefas.md
# pagamento, do kiro
.kiro/specs/pagamento/requirements.md -> feature:pagamento/spec.md
.kiro/specs/pagamento/design.md -> feature:pagamento/plano.md
docs/decisions/usar-postgres.md -> adr:Usar Postgres
TODO.md -> legado:TODO.md
MAPA
out="$(cd "$L" && sdd-adotar aplicar "$M" --simular)"
echo "$out" | grep -q 'specs/001-login-com-e-mail/tarefas.md' && echo "$out" | grep -q 'specs/002-pagamento/plano.md' \
  && ok "simulação numera as features e junta pelo slug" || fail "simulação numera" "$out"
echo "$out" | grep -q 'docs/adr/0001-usar-postgres.md' && ok "simulação numera o ADR" || fail "simulação ADR" "$out"
[ -f "$L/TODO.md" ] && [ ! -d "$L/specs/001-login-com-e-mail" ] && ok "simulação não move nada" || fail "simulação moveu"
out="$(cd "$L" && sdd-adotar aplicar "$M")"; code=$?
[ "$code" -eq 0 ] && ok "aplica o mapa aprovado" || fail "aplica" "$out"
[ -f "$L/specs/001-login-com-e-mail/spec.md" ] && grep -q 'requisitos do login' "$L/specs/001-login-com-e-mail/spec.md" \
  && ok "a spec chega com o conteúdo original" || fail "spec movida"
[ "$(sdd_feature_ler_t "$L" 001-login-com-e-mail fase)" = "especificacao" ] && ok "feature adotada nasce na especificacao" || fail "fase da adotada"
grep -q '| criada | .*adotada' "$L/specs/001-login-com-e-mail/historico.md" && grep -q '| adocao | docs/specs/login/tasks.md -> tarefas.md' "$L/specs/001-login-com-e-mail/historico.md" \
  && ok "histórico da feature registra a adoção" || fail "histórico da adotada"
grep -q '| adocao | TODO.md -> docs/legado/TODO.md' "$L/.sdd/historico.md" && ok "histórico do projeto registra cada movimento" || fail "histórico do projeto"
grep -q '`.kiro/specs/pagamento/design.md` | `specs/002-pagamento/plano.md`' "$L/.sdd/adocao.md" && ok "relatório em .sdd/adocao.md" || fail "relatório"
(cd "$L" && git status --short | grep -q '^R  TODO.md -> docs/legado/TODO.md') && ok "usa git mv (o histórico do arquivo segue)" || fail "git mv" "$(cd "$L" && git status --short)"
[ ! -d "$L/.kiro" ] && [ ! -d "$L/docs/specs" ] && [ ! -d "$L/docs/decisions" ] && ok "remove as pastas que ficaram vazias" || fail "pastas vazias"
echo "$out" | grep -q 'README.md cita docs/specs/login/requirements.md' && ok "aponta links para o caminho antigo" || fail "links antigos" "$out"
echo "$out" | grep -qE '! (CLAUDE\.md|AGENTS\.md|\.sdd/[^ ]*|[^ ]*transicao\.md) cita' && fail "links: falso positivo" "$out" || ok "links: ignora o bloco do SDD, a transição e o .sdd/"
[ "$(cd "$L" && sdd-adotar contar)" = "0" ] && ok "depois da adoção, nada fora do padrão" || fail "contar depois" "$(cd "$L" && sdd-adotar inventario)"
out="$(cd "$L" && sdd-status)"
echo "$out" | grep -q '001-login-com-e-mail' && ok "o quadro mostra as features adotadas" || fail "quadro com adotadas"
printf 'README.md -> legado:README.md\n' > "$M"; printf 'x' > "$L/docs/legado/README.md"
(cd "$L" && assert_exit 1 "não sobrescreve destino existente" sdd-adotar aplicar "$M")

echo "layout: hook"
assert_exit 2 "bloqueia criar spec em docs/specs/" guard_write "$L" "$L/docs/specs/nova.md"
assert_exit 2 "bloqueia criar TODO.md na raiz" guard_write "$L" "$L/TODO.md"
assert_exit 2 "bloqueia criar pasta tasks/" guard_write "$L" "$L/tasks/fazer.md"
assert_exit 2 "bloqueia ADR sem numeração" guard_write "$L" "$L/docs/adr/usar-redis.md"
assert_exit 0 "permite ADR numerado" guard_write "$L" "$L/docs/adr/0002-usar-redis.md"
assert_exit 2 "bloqueia pasta de feature criada à mão" guard_write "$L" "$L/specs/009-feita-a-mao/spec.md"
out="$(guard_write "$L" "$L/specs/009-feita-a-mao/spec.md" 2>&1)"
echo "$out" | grep -q 'sdd-estado nova' && ok "a mensagem ensina a criar a feature" || fail "mensagem da feature à mão" "$out"
assert_exit 0 "permite arquivo novo numa feature que existe" guard_write "$L" "$L/specs/001-login-com-e-mail/contexto.md"
assert_exit 0 "permite código novo" guard_write "$L" "$L/src/novo.ts"
assert_exit 0 "permite documento comum" guard_write "$L" "$L/docs/guia.md"
printf 'x\n' > "$L/PLAN.md"
assert_exit 0 "editar arquivo antigo fora do padrão continua livre" guard_edit "$L" "$L/PLAN.md"
assert_exit 0 "reescrever arquivo que já existe continua livre" guard_write "$L" "$L/PLAN.md"
assert_exit 2 "registro de adoção só pelo utilitário" guard_edit "$L" "$L/.sdd/adocao.md"
subst 's#^excecoes_de_layout:.*#excecoes_de_layout: docs/manual/**#' "$L/.sdd/config.yml"
assert_exit 0 "excecoes_de_layout libera o caminho" guard_write "$L" "$L/docs/manual/tasks.md"
subst 's/^protecao: .*/protecao: desligada/' "$L/.sdd/config.yml"
assert_exit 0 "proteção desligada não bloqueia o layout" guard_write "$L" "$L/docs/specs/nova.md"
subst 's/^protecao: .*/protecao: leve/' "$L/.sdd/config.yml"

echo "layout: verificar e pendências"
out="$(cd "$L" && sdd-verificar 2>&1)"; code=$?
[ "$code" -eq 0 ] && echo "$out" | grep -q '1 artefato(s) de processo fora do lugar do padrão' && ok "verificar: artefato fora do padrão é aviso" || fail "verificar aviso layout" "$out"
(cd "$L" && assert_exit 3 "verificar --estrito falha com artefato fora do padrão" sdd-verificar --estrito)
out="$(cd "$L" && sdd-pendencias)"
echo "$out" | grep -q 'Fora do padrão (1) · /sdd:iniciar --adotar' && echo "$out" | grep -q 'PLAN.md (plano)' && ok "pendências listam o que está fora do padrão" || fail "pendências layout" "$out"
printf 'PLAN.md -> legado:PLAN.md\n' > "$M"
(cd "$L" && sdd-adotar aplicar "$M" >/dev/null)
out="$(cd "$L" && sdd-verificar 2>&1)"
echo "$out" | grep -q 'fora do lugar do padrão' && fail "aviso some depois da adoção" "$out" || ok "aviso some depois da adoção"

echo "adoção: transição e tarefas [O]"
A=001-login-com-e-mail
TR="$L/specs/$A/transicao.md"
[ "$(sdd_feature_ler_t "$L" $A adocao)" = "transicao" ] && ok "feature adotada nasce em transição" || fail "adocao=transicao"
grep -q "^# Transição $A" "$TR" && ok "transicao.md vem do modelo" || fail "transicao.md do modelo"
grep -qE '^\| `docs/specs/login/tasks.md` \| [0-9a-f]{12} \| `tarefas.md` \|$' "$TR" && ok "o como era traz o caminho original e o hash" || fail "como era" "$(grep '^| `' "$TR")"
grep -qE '\| adocao \| docs/specs/login/tasks.md -> tarefas.md \| hash=[0-9a-f]{12}' "$L/specs/$A/historico.md" && ok "histórico guarda o hash do original" || fail "hash no histórico"
out="$(cd "$L" && sdd-pendencias)"
echo "$out" | grep -q "$A veio de outro processo" && ok "pendências cobram a transição" || fail "pendência da transição" "$out"
out="$(cd "$L" && sdd-status)"
echo "$out" | grep -q "$A .*em transição" && ok "o quadro mostra a transição" || fail "quadro transição" "$out"
(cd "$L" && sdd-estado usar $A >/dev/null)
(cd "$L" && assert_exit 1 "transicao.md com lacunas não se aprova" sdd-estado aprovar)
(cd "$L" && assert_exit 1 "outro artefato não se aprova antes da transição" sdd-estado aprovar spec.md)
(cd "$L" && assert_exit 1 "a fase não muda à mão durante a transição" sdd-estado definir fase=red)
# A conversão: o agente reescreve no padrão e preenche o como vai ficar.
printf '# Spec %s\n- **RF-001**: O SISTEMA DEVE autenticar por e-mail.\n- **RF-002**: O SISTEMA DEVE redefinir a senha.\n- **CA-001** (valida RF-001)\n- **CA-002** (valida RF-002)\n' "$A" > "$L/specs/$A/spec.md"
printf -- '- [O] T-001 login por e-mail (atende: RF-001, CA-001; depende de: nada)\n- [ ] T-002 redefinir a senha (atende: RF-002, CA-002; depende de: T-001)\n' > "$L/specs/$A/tarefas.md"
awk '{ s = s $0 "\n" } END { while (match(s, /\{\{[^}]*\}\}/)) s = substr(s, 1, RSTART - 1) "x" substr(s, RSTART + RLENGTH); printf "%s", s }' "$TR" > "$TR.tmp" && mv "$TR.tmp" "$TR"
subst 's/^| Fase de destino | .* |$/| Fase de destino | plano |/' "$TR"
(cd "$L" && assert_exit 1 "destino plano no nível 1 é recusado" sdd-estado aprovar)
subst 's/^| Fase de destino | .* |$/| Fase de destino | codar |/' "$TR"
(cd "$L" && assert_exit 1 "destino inválido é recusado" sdd-estado aprovar)
subst 's/^| Fase de destino | .* |$/| Fase de destino | red |/' "$TR"
mv "$L/specs/$A/tarefas.md" "$TMP/tarefas.bak"
(cd "$L" && assert_exit 1 "destino red sem tarefas.md é recusado" sdd-estado aprovar)
mv "$TMP/tarefas.bak" "$L/specs/$A/tarefas.md"
out="$(cd "$L" && sdd-estado aprovar 2>&1)"; code=$?
[ "$code" -eq 0 ] && echo "$out" | grep -q 'segue no SDD a partir da fase red' && ok "aprovar a transição leva à fase de destino" || fail "aprova transição" "$out"
echo "$out" | grep -q 'Tarefas feitas fora do plugin (\[O\]): 1' && ok "a aprovação conta as tarefas [O]" || fail "conta [O]" "$out"
[ "$(sdd_feature_ler_t "$L" $A fase)" = "red" ] && [ "$(sdd_feature_ler_t "$L" $A adocao)" = "regularizada" ] && ok "feature regularizada, na fase red" || fail "regularizada red"
for art in spec.md tarefas.md transicao.md; do
  grep -qE "\| aprovacao \| $art \| hash=[0-9a-f]{12} \| decisao: transicao" "$L/specs/$A/historico.md" && ok "transição registra $art com hash" || fail "registro $art"
done
(cd "$L" && assert_exit 0 "spec convertida conta como aprovada" sdd-estado aprovado spec.md)
(cd "$L" && assert_exit 0 "tarefas convertidas contam como aprovadas" sdd-estado aprovado tarefas.md)
out="$(cd "$L" && sdd-status --ativa)"
echo "$out" | grep -q 'tarefas: 1/2 concluídas (1 feitas fora do plugin, marcadas \[O\])' && ok "o detalhe separa as tarefas [O]" || fail "detalhe [O]" "$out"
echo "$out" | grep -q 'próxima: T-002' && ok "o plugin continua pela primeira tarefa aberta" || fail "próxima tarefa" "$out"
echo "$out" | grep -q 'adoção: regularizada' && ok "o detalhe mostra a adoção" || fail "detalhe adoção" "$out"
mkdir -p "$L/tests"
printf '// sdd:001:CA-001\nit("entra com e-mail", () => {})\n// sdd:001:CA-002\nit("redefine a senha", () => {})\n' > "$L/tests/login.test.ts"
(cd "$L" && assert_exit 0 "rastrear lê as tarefas [O]" sdd-rastrear --silencioso)
(cd "$L" && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$L" $A fase)" = "green" ] && ok "testes aprovados: green" || fail "green da adotada"
subst 's/^- \[ \] T-002/- [x] T-002/' "$L/specs/$A/tarefas.md"
(cd "$L" && assert_exit 0 "entrega com [O] e [x]" sdd-estado aprovar)
[ "$(sdd_feature_ler_t "$L" $A fase)" = "pronta" ] && ok "a feature adotada chega a pronta" || fail "adotada pronta"
grep -q '^- \[O\] T-001' "$L/specs/$A/tarefas.md" && ok "a marca [O] fica como registro" || fail "marca [O] mantida"
out="$(cd "$L" && sdd-verificar 2>&1)"
echo "$out" | grep -q '002-pagamento: adotada de outro processo, ainda em transição' && ok "verificar avisa transição pendente" || fail "aviso transição" "$out"

echo "git flow: nomes"
gf_tipo() { (. "$PLUGIN/lib/sdd-comum.sh"; sdd_branch_tipo "$1" || echo fora); }
for par in "main:producao" "develop:integracao" "feature/001-login:feature" "release/1.2.0:release" "hotfix/1.2.1:hotfix" \
           "master:fora" "development:fora" "feat/login:fora" "feature/login:fora" "release/1.2:fora" "bugfix/001-x:fora" "feature/001-Login:fora"; do
  b="${par%%:*}"; e="${par#*:}"; o="$(gf_tipo "$b")"
  [ "$o" = "$e" ] && ok "branch $b: $e" || fail "branch $b" "esperado $e, obtido $o"
done
assert_exit 0 "fluxo feature -> develop" sdd-gitflow pode-integrar feature/001-a develop
assert_exit 0 "fluxo release -> main" sdd-gitflow pode-integrar release/1.0.0 main
assert_exit 0 "fluxo hotfix -> develop" sdd-gitflow pode-integrar hotfix/1.0.1 develop
assert_exit 3 "fluxo feature -> main recusado" sdd-gitflow pode-integrar feature/001-a main
assert_exit 3 "fluxo develop -> main recusado" sdd-gitflow pode-integrar develop main
assert_exit 3 "fluxo de branch fora do padrão recusado" sdd-gitflow pode-integrar feat-x develop

echo "git flow: preparar o repositório"
G="$TMP/gitflow"
mkdir -p "$G/src" "$G/tests"
(cd "$G" && git init -q && git symbolic-ref HEAD refs/heads/master && git config user.name Teste && git config user.email t@t \
  && printf 'x\n' > src/a.js && git add -A && git commit -qm inicio && git branch development && git branch feat-login)
out="$(cd "$G" && sdd-gitflow conferir 2>&1)"; code=$?
[ "$code" -eq 3 ] && echo "$out" | grep -q 'master está fora do padrão: renomeie para main' && echo "$out" | grep -q 'development está fora do padrão: renomeie para develop' \
  && ok "conferir aponta master e development com o nome certo" || fail "conferir nomes antigos" "$out"
(cd "$G" && assert_exit 1 "iniciar recusa produção chamada master" sdd-gitflow iniciar)
(cd "$G" && assert_exit 1 "renomear recusa nome fora do padrão" sdd-gitflow renomear feat-login feat/login)
(cd "$G" && sdd-gitflow renomear master main >/dev/null && sdd-gitflow renomear development develop >/dev/null)
(cd "$G" && git branch -q -D feat-login)
(cd "$G" && sdd-iniciar >/dev/null)
grep -q '^specs/\*/historico.md merge=union$' "$G/.gitattributes" && ok "iniciar põe o merge por união dos históricos" || fail ".gitattributes"
(cd "$G" && sdd-iniciar >/dev/null)
[ "$(grep -c '# sdd:inicio' "$G/.gitattributes")" = "1" ] && ok ".gitattributes não se duplica" || fail ".gitattributes duplicado"
(cd "$G" && git switch -q main)
out="$(cd "$G" && sdd-gitflow iniciar 2>&1)"
[ "$(cd "$G" && git branch --show-current)" = "develop" ] && ok "iniciar com o .sdd/ novo: muda para develop" || fail "iniciar develop" "$out"
(cd "$G" && git add -A && git commit -qm "chore: sdd")
(cd "$G" && assert_exit 0 "conferir: tudo no padrão" sdd-gitflow conferir)

echo "git flow: hook"
(cd "$G" && assert_exit 2 "commit em main bloqueado" bash -c "git switch -q main && $(printf '%q' "$PLUGIN/scripts/guarda-commits.sh") < <(printf '%s' '$(bash_json "$G" 'git commit -m "x"')'); r=\$?; git switch -q develop; exit \$r")
assert_exit 2 "criar branch fora do padrão bloqueado" guard_commit "$G" 'git checkout -b feat-x'
assert_exit 2 "renomear para fora do padrão bloqueado" guard_commit "$G" 'git branch -m develop2'
assert_exit 2 "feature/ de feature que não existe bloqueada" guard_commit "$G" 'git switch -c feature/009-nada'
assert_exit 0 "release/X.Y.Z permitida" guard_commit "$G" 'git switch -c release/1.0.0'
assert_exit 0 "commit em develop sem feature ativa" guard_commit "$G" 'git commit -m "chore: ajuste"'
(cd "$G" && sdd-estado nova "Login com e-mail" >/dev/null)
GF=001-login-com-e-mail
[ "$(sdd_feature_ler_t "$G" $GF branch)" = "feature/$GF" ] && ok "a feature registra a branch" || fail "branch no estado"
assert_exit 2 "commit da feature ativa em develop bloqueado" guard_commit "$G" 'git commit -m "docs(001): spec"'
out="$(guard_commit "$G" 'git commit -m "docs(001): spec"' 2>&1)"
echo "$out" | grep -q "sdd-gitflow feature $GF" && ok "a mensagem diz como ir para a branch" || fail "mensagem da branch" "$out"
assert_exit 0 "feature/ de feature que existe permitida" guard_commit "$G" "git switch -c feature/$GF"
printf 'y\n' >> "$G/src/a.js"
(cd "$G" && assert_exit 1 "feature: recusa trocar de branch com alteração pendente" sdd-gitflow feature $GF)
(cd "$G" && git checkout -q -- src/a.js)
(cd "$G" && assert_exit 0 "feature: cria a branch a partir de develop" sdd-gitflow feature $GF)
[ "$(cd "$G" && git branch --show-current)" = "feature/$GF" ] && ok "agora na branch da feature" || fail "branch da feature"
[ -f "$G/specs/$GF/spec.md" ] && ok "a spec nova vai junto para a branch" || fail "spec na branch"
assert_exit 0 "commit da feature na branch dela" guard_commit "$G" 'git commit -m "docs(001): spec"'
(cd "$G" && git add -A && git commit -qm "docs(001): spec")
out="$(cd "$G" && sdd-status)"
echo "$out" | grep -q "Git Flow: em feature/$GF" && ok "o quadro mostra a branch" || fail "quadro branch" "$out"
(cd "$G" && assert_exit 1 "integrar recusa feature que não está pronta" sdd-gitflow integrar $GF)
assert_exit 0 "merge em andamento não é bloqueado" bash -c "cd '$G' && git switch -q develop && printf 'a\n' > m.txt && git add m.txt && git commit -qm m && git switch -q feature/$GF && printf 'b\n' > m.txt && git add m.txt && git commit -qm 'docs(001): m' && ! git merge -q develop >/dev/null 2>&1; $(printf '%q' "$PLUGIN/scripts/guarda-commits.sh") < <(printf '%s' '$(bash_json "$G" 'git commit -m "x"')')"
(cd "$G" && git merge --abort && git reset -q --hard HEAD~1)
subst 's/^gitflow: .*/gitflow: desligado/' "$G/.sdd/config.yml"
assert_exit 0 "gitflow desligado: nada é conferido" guard_commit "$G" 'git checkout -b qualquer-nome'
subst 's/^gitflow: .*/gitflow: ativo/' "$G/.sdd/config.yml"

echo "git flow: integrar, release e finalizar"
printf '# Spec\n- **RF-001**: entra\n- **CA-001** (valida RF-001)\n' > "$G/specs/$GF/spec.md"
printf -- '- [x] T-001 entra (atende: RF-001, CA-001; depende de: nada)\n' > "$G/specs/$GF/tarefas.md"
printf 'it("entra") // sdd:001:CA-001\n' > "$G/tests/login.test.js"
(cd "$G" && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null && sdd-estado aprovar >/dev/null)
[ "$(sdd_feature_ler_t "$G" $GF fase)" = "pronta" ] && ok "feature pronta na branch dela" || fail "pronta"
(cd "$G" && git add -A && git commit -qm "feat(001): T-001 login")
out="$(cd "$G" && sdd-pendencias)"
echo "$out" | grep -q "$GF está pronta e feature/$GF ainda não foi integrada em develop" && ok "pendências cobram a integração" || fail "pendência integração" "$out"
(cd "$G" && assert_exit 0 "integrar a feature pronta" sdd-gitflow integrar $GF --apagar)
(cd "$G" && git merge-base --is-ancestor HEAD develop && [ "$(git branch --show-current)" = "develop" ]) && ok "feature em develop, e de volta em develop" || fail "integrada"
(cd "$G" && git show-ref --verify --quiet "refs/heads/feature/$GF") && fail "branch local apagada" || ok "--apagar remove a branch local"
[ "$(cd "$G" && git log -1 --format=%P | wc -w | tr -d ' ')" = "2" ] && ok "merge --no-ff (commit de merge)" || fail "no-ff"
(cd "$G" && assert_exit 0 "release cria release/X.Y.Z" sdd-gitflow release 0.1.0)
[ "$(cd "$G" && git branch --show-current)" = "release/0.1.0" ] && ok "agora em release/0.1.0" || fail "release branch"
(cd "$G" && sdd-release nova 0.1.0 >/dev/null && sdd-release incluir 0.1.0 $GF >/dev/null && git add -A && git commit -qm "chore(release): 0.1.0")
(cd "$G" && assert_exit 1 "finalizar recusa sem o go" sdd-gitflow finalizar 0.1.0)
GR="$G/releases/0.1.0"
subst 's/{{[^}]*}}/ok/g; s/| Resultado | ok |/| Resultado | aprovado |/' "$GR/testes.md" "$GR/homologacao.md"
(cd "$G" && sdd-release homologar 0.1.0 >/dev/null)
subst 's/| pendente |/| aprovado |/' "$GR/homologacao.md"; subst 's/{{[^}]*}}/ok/g' "$GR/implantacao.md" "$GR/notas.md"
(cd "$G" && sdd-release aceitar 0.1.0 --por "Bia" >/dev/null && sdd-release autorizar 0.1.0 >/dev/null && git add -A && git commit -qm "chore(release): go")
out="$(cd "$G" && sdd-pendencias)"
echo "$out" | grep -q 'a release 0.1.0 tem o go e ainda não foi para main' && ok "pendências cobram a ida para main" || fail "pendência finalizar" "$out"
(cd "$G" && assert_exit 0 "finalizar com o go" sdd-gitflow finalizar 0.1.0)
[ "$(cd "$G" && git describe --tags --exact-match main 2>/dev/null)" = "v0.1.0" ] && ok "tag v0.1.0 em main" || fail "tag"
(cd "$G" && git merge-base --is-ancestor release/0.1.0 main && git merge-base --is-ancestor main develop) && ok "release em main, e main de volta em develop" || fail "merges da release"
[ "$(cd "$G" && git branch --show-current)" = "develop" ] && ok "termina em develop" || fail "termina em develop"
(cd "$G" && assert_exit 0 "finalizar de novo não repete nada" sdd-gitflow finalizar 0.1.0)

echo "git flow: hotfix"
(cd "$G" && sdd-release concluir 0.1.0 --verificacao ok >/dev/null && sdd-incidente abrir "Login falha" --severidade S2 >/dev/null && git add -A && git commit -qm "docs: INC-001")
(cd "$G" && sdd-incidente hotfix INC-001 "Corrigir login" >/dev/null)
HF=002-corrigir-login
[ "$(sdd_feature_ler_t "$G" $HF branch)" = "hotfix/0.1.1" ] && ok "o hotfix reserva hotfix/X.Y.Z (próxima patch)" || fail "branch do hotfix" "$(sdd_feature_ler_t "$G" $HF branch)"
assert_exit 0 "registro do incidente em develop antes da branch do hotfix" guard_commit "$G" 'git commit -m "docs(002): INC-001 hotfix aberto"'
(cd "$G" && git add -A ':!specs/' && git commit -qm "docs(002): INC-001 hotfix aberto")
(cd "$G" && assert_exit 0 "feature do hotfix cria a branch a partir de main" sdd-gitflow feature $HF)
(cd "$G" && [ "$(git branch --show-current)" = "hotfix/0.1.1" ] && [ "$(git merge-base HEAD main)" = "$(git rev-parse main)" ]) && ok "hotfix/0.1.1 nasce de main" || fail "hotfix de main"
assert_exit 2 "com a branch criada, develop volta a ser bloqueada" bash -c "cd '$G' && git switch -q develop && $(printf '%q' "$PLUGIN/scripts/guarda-commits.sh") < <(printf '%s' '$(bash_json "$G" 'git commit -m "fix(002): x"')'); r=\$?; git switch -q hotfix/0.1.1; exit \$r"
(cd "$G" && assert_exit 1 "integrar recusa hotfix (vai pela release)" sdd-gitflow integrar $HF)

echo "git flow: CI"
(cd "$G" && assert_exit 3 "verificar recusa PR feature -> main" env GITHUB_HEAD_REF=feature/$GF GITHUB_BASE_REF=main sdd-verificar --silencioso)
out="$(cd "$G" && env CI_MERGE_REQUEST_SOURCE_BRANCH_NAME=feat-x CI_MERGE_REQUEST_TARGET_BRANCH_NAME=develop sdd-verificar 2>&1)"
echo "$out" | grep -q 'o pull request feat-x -> develop não é permitido' && ok "verificar lê o merge request do GitLab" || fail "verificar gitlab" "$out"

echo "versão: Conventional Commits e SemVer"
cc_ok() { (. "$PLUGIN/lib/sdd-comum.sh"; sdd_cc_valida "$1"); }
for m in "feat(001): T-001 exporta" "fix: corrige" "feat(api)!: remove campo" "chore(release): 1.0.0" "docs(001): spec"; do
  cc_ok "$m" && ok "mensagem válida: $m" || fail "mensagem válida: $m"
done
for m in "ajustes" "Feat: x" "feat:x" "feature(001): x" "feat(001) x" "wip"; do
  cc_ok "$m" && fail "mensagem inválida aceita: $m" || ok "mensagem inválida: $m"
done
VR="$TMP/versao"
mkdir -p "$VR"
(cd "$VR" && git init -q && git symbolic-ref HEAD refs/heads/main && git config user.name T && git config user.email t@t \
  && git commit -q --allow-empty -m "chore: início" && sdd-iniciar >/dev/null && git add -A && git commit -qm "chore: sdd")
[ "$(cd "$VR" && sdd-release proxima)" = "0.1.0" ] && ok "sem versão anterior: 0.1.0" || fail "primeira versão"
[ "$(cd "$VR" && sdd-release proxima major)" = "1.0.0" ] && ok "sem versão anterior, major: 1.0.0" || fail "primeira major"
(cd "$VR" && git tag v1.2.0)
(cd "$VR" && sdd-estado nova "Exportar pedidos" >/dev/null && git add -A && git commit -qm "docs(001): spec")
(cd "$VR" && git commit -q --allow-empty -m "fix(001): T-002 data errada")
[ "$(cd "$VR" && sdd-release proxima)" = "1.2.1" ] && ok "só fix: patch (1.2.1)" || fail "auto patch" "$(cd "$VR" && sdd-release proxima)"
(cd "$VR" && git commit -q --allow-empty -m "feat(001): T-001 exportar CSV" && git commit -q --allow-empty -m "atualiza coisas")
[ "$(cd "$VR" && sdd-release proxima)" = "1.3.0" ] && ok "com feat: minor (1.3.0)" || fail "auto minor"
[ "$(cd "$VR" && sdd-release proxima patch)" = "1.2.1" ] && ok "o tipo explícito vale" || fail "explícito"
[ "$(cd "$VR" && sdd-release proxima --pre rc)" = "1.3.0-rc.1" ] && ok "pré-lançamento rc.1" || fail "rc.1"
(cd "$VR" && git tag v1.3.0-rc.1)
[ "$(cd "$VR" && sdd-release proxima --pre rc)" = "1.3.0-rc.2" ] && ok "o próximo rc conta as tags" || fail "rc.2"
[ "$(cd "$VR" && sdd-release proxima)" = "1.3.0" ] && ok "tag de pré-lançamento não vira a base" || fail "base sem rc"
out="$(cd "$VR" && sdd-release analisar)"
echo "$out" | grep -q 'Sugestão: 1.3.0 (minor: há feat e nenhuma mudança incompatível)' && ok "analisar explica a sugestão" || fail "analisar" "$out"
echo "$out" | grep -q 'fora do Conventional Commits (não contam): 1' && ok "analisar aponta commit fora do padrão" || fail "analisar fora" "$out"
(cd "$VR" && git commit -q --allow-empty -m "refactor: troca o formato" -m "BREAKING CHANGE: o CSV muda de colunas")
[ "$(cd "$VR" && sdd-release proxima)" = "2.0.0" ] && ok "BREAKING CHANGE no rodapé: major" || fail "breaking rodapé"
(cd "$VR" && git tag v2.0.0 && git commit -q --allow-empty -m "feat(api)!: remove o campo total")
[ "$(cd "$VR" && sdd-release proxima)" = "3.0.0" ] && ok "feat! : major" || fail "bang major"
V0="$TMP/versao0"; mkdir -p "$V0"
(cd "$V0" && git init -q && git config user.name T && git config user.email t@t && git commit -q --allow-empty -m "chore: x" && sdd-iniciar >/dev/null && git tag v0.4.0 && git commit -q --allow-empty -m "feat!: muda tudo")
[ "$(cd "$V0" && sdd-release proxima)" = "0.5.0" ] && ok "antes da 1.0.0, incompatível sobe o minor" || fail "0.x"
out="$(cd "$VR" && sdd-release changelog 3.0.0)"
echo "$out" | grep -q '^## \[3.0.0\] - ' && echo "$out" | grep -q '^- \*\*Incompatível:\*\* remove o campo total (api)$' && ok "changelog: seção e incompatível" || fail "changelog" "$out"
(cd "$VR" && git tag -d v2.0.0 >/dev/null)
out="$(cd "$VR" && sdd-release changelog 3.0.0)"
echo "$out" | grep -q '^- Exportar pedidos (001)$' && ok "changelog: a feature aparece uma vez, pelo título" || fail "changelog feature" "$out"
[ "$(echo "$out" | grep -c 'Exportar pedidos')" = "1" ] && ok "changelog: os commits da feature não se repetem" || fail "changelog repetido" "$out"
echo "$out" | grep -q 'o CSV muda de colunas' && ok "changelog: a nota do BREAKING CHANGE" || fail "nota breaking" "$out"
echo "$out" | grep -q 'docs(001)\|spec$' && fail "changelog sem docs" "$out" || ok "changelog deixa docs de fora"
(cd "$VR" && assert_exit 0 "changelog --escrever cria o CHANGELOG.md" sdd-release changelog 3.0.0 --escrever)
grep -q '^## \[Não lançado\]$' "$VR/CHANGELOG.md" && grep -q '^## \[3.0.0\]' "$VR/CHANGELOG.md" && ok "CHANGELOG.md no formato Keep a Changelog" || fail "formato changelog"
(cd "$VR" && assert_exit 1 "changelog não duplica a versão" sdd-release changelog 3.0.0 --escrever)
(cd "$VR" && sdd-release changelog 3.1.0 --escrever >/dev/null)
[ "$(grep -n '^## \[' "$VR/CHANGELOG.md" | cut -d: -f2 | tr '\n' ' ')" = "## [Não lançado] ## [3.1.0] - $(date +%Y-%m-%d) ## [3.0.0] - $(date +%Y-%m-%d) " ] \
  && ok "a versão nova entra acima das anteriores" || fail "ordem changelog" "$(grep '^## \[' "$VR/CHANGELOG.md")"

VT="$TMP/tags-antigas"; mkdir -p "$VT"
(cd "$VT" && git init -q && git symbolic-ref HEAD refs/heads/main && git config user.name T && git config user.email t@t && git commit -q --allow-empty -m "chore: x" && git tag 1.4.2 && git branch develop)
out="$(cd "$VT" && sdd-gitflow conferir 2>&1)"
echo "$out" | grep -q 'nenhuma tag segue vX.Y.Z (há 1.4.2' && ok "conferir avisa de tags fora de vX.Y.Z" || fail "aviso tags" "$out"

echo "versão: o hook confere a mensagem"
subst 's/^gitflow: .*/gitflow: desligado/' "$VR/.sdd/config.yml"
assert_exit 2 "commit fora do Conventional Commits bloqueado" guard_commit "$VR" 'git commit -m "ajustes"'
out="$(guard_commit "$VR" 'git commit -m "ajustes"' 2>&1)"
echo "$out" | grep -q 'feat (funcionalidade, sobe o minor)' && ok "a mensagem ensina os tipos" || fail "mensagem tipos" "$out"
assert_exit 0 "commit convencional permitido" guard_commit "$VR" 'git commit -m "chore: atualiza dependências"'
assert_exit 0 "heredoc convencional permitido" guard_commit "$VR" "$(printf 'git commit -m "$(cat <<%sEOF%s\nfix: corrige o login\n\nCorpo.\nEOF\n)"' "'" "'")"
assert_exit 2 "heredoc fora do padrão bloqueado" guard_commit "$VR" "$(printf 'git commit -m "$(cat <<%sEOF%s\nCorrige o login\nEOF\n)"' "'" "'")"
assert_exit 0 "mensagem do editor não é conferida" guard_commit "$VR" 'git commit'
subst 's/^commits: .*/commits: livre/' "$VR/.sdd/config.yml"
assert_exit 0 "commits: livre não confere o formato" guard_commit "$VR" 'git commit -m "ajustes"'
subst 's/^commits: .*/commits: convencional/' "$VR/.sdd/config.yml"

echo "entradas inválidas"
assert_exit 0 "stdin vazio: permite" bash -c "printf '' | '$PLUGIN/scripts/guarda-edicoes.sh'"
assert_exit 0 "JSON inválido: permite" bash -c "printf 'não é json' | '$PLUGIN/scripts/guarda-edicoes.sh'"

PASS="$(grep -c '^p$' "$RESULTADOS" || true)"
FAIL="$(grep -c '^f$' "$RESULTADOS" || true)"
echo
echo "Resultado: $PASS passaram, $FAIL falharam."
[ "$FAIL" -eq 0 ]
