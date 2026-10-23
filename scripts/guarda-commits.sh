#!/usr/bin/env bash
# guarda-commits.sh: hook PreToolUse para Bash.
#
# Nas fases red, green e auditoria de uma feature, exige que `git commit` com
# mensagem inline cite uma tarefa (T-NNN) ou o número da feature no formato
# "(NNN)". Exemplo: "feat(004): T-002 valida token expirado".
#
# Saída: 0 permite, 2 bloqueia (o stderr é mostrado ao agente).
# Qualquer situação inesperada permite o comando.

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/sdd-comum.sh
. "$AQUI/../lib/sdd-comum.sh" || exit 0

ENTRADA="$(cat 2>/dev/null || true)"
[ -n "$ENTRADA" ] || exit 0

CMD="$(sdd_json_campo "$ENTRADA" command)"
[ -n "$CMD" ] || exit 0

# Só interessa git commit.
printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' || exit 0

RAIZ="${CLAUDE_PROJECT_DIR:-}"
[ -n "$RAIZ" ] || RAIZ="$(sdd_json_campo "$ENTRADA" cwd)"
[ -n "$RAIZ" ] || exit 0
RAIZ="${RAIZ//\\//}"
[ -d "$RAIZ/.sdd" ] || exit 0

PROTECAO="$(sdd_config "$RAIZ" protecao leve)"
[ "$PROTECAO" = "desligada" ] && exit 0

FEATURE="$(sdd_estado_ler "$RAIZ" feature)"
FASE="$(sdd_estado_ler "$RAIZ" fase)"
[ -n "$FEATURE" ] || exit 0
case "$FASE" in red|green|auditoria) ;; *) exit 0 ;; esac

# Sem mensagem inline (-m, -am, --message, -F, --file), o editor abre ou a
# mensagem vem de --amend/--no-edit: não há o que inspecionar.
printf '%s' "$CMD" | grep -qE '(^|[[:space:]])(-m|-[a-zA-Z]*m|--message|-F|--file)([[:space:]=]|$)' || exit 0

NUM="${FEATURE%%-*}"
if printf '%s' "$CMD" | grep -qE "T-[0-9]{3}|\(${NUM}\)"; then
  exit 0
fi

{
  echo "SDD: os commits durante a implementação da feature $FEATURE precisam citar a tarefa."
  echo "Formato: tipo($NUM): T-XXX descrição. Exemplo: feat($NUM): T-002 valida token expirado"
  echo "Reescreva a mensagem com a tarefa correspondente de tarefas.md."
} >&2
exit 2
