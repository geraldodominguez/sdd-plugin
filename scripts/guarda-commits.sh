#!/usr/bin/env bash
# guarda-commits.sh: hook PreToolUse para Bash.
#
# Nas fases red, green, seguranca e auditoria de uma feature, exige que `git commit` com
# mensagem inline cite uma tarefa (T-NNN) ou o número da feature no formato
# "(NNN)". Exemplo: "feat(004): T-002 valida token expirado".
#
# Com commits convencionais (commits: convencional no config, o padrão), nas
# proteções leve e estrita, a mensagem inline segue o Conventional Commits:
# "tipo(escopo)!: descrição", com tipo feat, fix, docs, chore, refactor, test,
# perf, build, ci, style ou revert. É dela que sai a próxima versão SemVer
# (sdd-release proxima) e o CHANGELOG.md (sdd-release changelog).
#
# Com o Git Flow ativo (gitflow: ativo no config, o padrão), nas proteções leve
# e estrita:
#   - criar ou renomear uma branch (git checkout -b, git switch -c, git branch,
#     git branch -m) só com um nome do padrão: main, develop, feature/NNN-slug
#     (de uma feature que existe), release/X.Y.Z ou hotfix/X.Y.Z;
#   - nada de commit direto em main (que só recebe merge, pelo sdd-gitflow);
#   - nada de commit numa branch fora do padrão;
#   - com uma feature ativa em construção ou revisão, o commit é na branch
#     dela (feature/NNN-slug ou hotfix/X.Y.Z), ou numa release/ ou hotfix/ em
#     homologação; não em develop nem na branch de outra feature. (Exceção: um
#     hotfix cuja branch ainda não existe aceita, em develop, o commit do
#     registro do incidente.)
#   Um merge em andamento (resolução de conflito) não é bloqueado.
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

# Só interessa git commit e a criação ou renomeação de branch.
E_COMMIT=0
printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' && E_COMMIT=1
E_BRANCH=0
printf '%s' "$CMD" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+(checkout|switch|branch)([[:space:]]|$)' && E_BRANCH=1
[ "$E_COMMIT" -eq 1 ] || [ "$E_BRANCH" -eq 1 ] || exit 0

RAIZ="${CLAUDE_PROJECT_DIR:-}"
[ -n "$RAIZ" ] || RAIZ="$(sdd_json_campo "$ENTRADA" cwd)"
[ -n "$RAIZ" ] || exit 0
RAIZ="${RAIZ//\\//}"
[ -d "$RAIZ/.sdd" ] || exit 0

PROTECAO="$(sdd_config "$RAIZ" protecao leve)"
[ "$PROTECAO" = "desligada" ] && exit 0

FEATURE="$(sdd_estado_ler "$RAIZ" feature)"
FASE="$(sdd_estado_ler "$RAIZ" fase)"
PASTA_SPECS="$(sdd_pasta_specs "$RAIZ")"

bloquear() {
  {
    printf '%s\n' "$@"
    echo "Não contorne este bloqueio. Explique a situação ao usuário e pergunte como seguir."
  } >&2
  exit 2
}

# O nome da branch que o comando cria ou para o qual renomeia, se houver.
branch_nova() {
  local c="$1" n
  n="$(printf '%s' "$c" | sed -nE 's/.*git[[:space:]]+(checkout|switch)[[:space:]]+(-b|-B|-c|-C|--create|--force-create)[[:space:]]+([^[:space:];&|]+).*/\3/p' | head -1)"
  [ -n "$n" ] || n="$(printf '%s' "$c" | sed -nE 's/.*git[[:space:]]+branch[[:space:]]+(-m|-M|--move)[[:space:]]+[^[:space:];&|]+[[:space:]]+([^-[:space:];&|][^[:space:];&|]*).*/\2/p' | head -1)"
  [ -n "$n" ] || n="$(printf '%s' "$c" | sed -nE 's/.*git[[:space:]]+branch[[:space:]]+(-m|-M|--move)[[:space:]]+([^-[:space:];&|][^[:space:];&|]*)[[:space:]]*([;&|].*)?$/\2/p' | head -1)"
  [ -n "$n" ] || n="$(printf '%s' "$c" | sed -nE 's/.*git[[:space:]]+branch[[:space:]]+([^-[:space:];&|][^[:space:];&|]*).*/\1/p' | head -1)"
  printf '%s' "$n" | tr -d "\"'"
}

if sdd_gitflow_ativo "$RAIZ"; then
  MSG_PADRAO="Padrão do Git Flow: main, develop, feature/NNN-slug, release/X.Y.Z, hotfix/X.Y.Z. Use o sdd-gitflow (feature, release, hotfix), que cria a branch certa."

  if [ "$E_BRANCH" -eq 1 ]; then
    NOVA="$(branch_nova "$CMD")"
    if [ -n "$NOVA" ]; then
      TIPO_NOVA="$(sdd_branch_tipo "$NOVA")" || bloquear "SDD (Git Flow) bloqueou a branch '$NOVA': o nome está fora do padrão." "$MSG_PADRAO"
      if [ "$TIPO_NOVA" = "feature" ] && [ ! -f "$RAIZ/$PASTA_SPECS/${NOVA#feature/}/estado" ]; then
        bloquear "SDD (Git Flow) bloqueou a branch '$NOVA': a feature ${NOVA#feature/} não existe em $PASTA_SPECS/." "Uma feature nasce pelo /sdd:especificar; depois, sdd-gitflow feature NNN-slug cria a branch dela."
      fi
    fi
  fi

  if [ "$E_COMMIT" -eq 1 ] && ! sdd_merge_em_andamento "$RAIZ"; then
    ATUAL="$(sdd_branch_atual "$RAIZ")"
    if [ -n "$ATUAL" ]; then
      [ "$ATUAL" = "$SDD_BRANCH_PRODUCAO" ] && bloquear "SDD (Git Flow) bloqueou um commit direto em $SDD_BRANCH_PRODUCAO." \
        "$SDD_BRANCH_PRODUCAO só recebe merge de release/X.Y.Z e hotfix/X.Y.Z, depois do go/no-go (sdd-gitflow finalizar). Faça o trabalho em develop ou na branch da feature."
      TIPO_ATUAL="$(sdd_branch_tipo "$ATUAL")" || bloquear "SDD (Git Flow) bloqueou um commit na branch '$ATUAL', fora do padrão." \
        "Renomeie a branch (sdd-gitflow renomear $ATUAL <nome do padrão>) ou mude para a branch certa." "$MSG_PADRAO"
      if [ -n "$FEATURE" ] && [ -f "$RAIZ/$PASTA_SPECS/$FEATURE/estado" ]; then
        case "$FASE" in pronta|homologacao|producao|cancelada|"") ;; *)
          ESPERADA="$(sdd_branch_da_feature "$RAIZ" "$FEATURE")"
          # Um hotfix recém-aberto ainda não tem a branch: o registro do
          # incidente é commitado em develop antes de ela nascer de main.
          HOTFIX_SEM_BRANCH=0
          case "$ESPERADA" in hotfix/*)
            [ "$TIPO_ATUAL" = "integracao" ] && ! git -C "$RAIZ" show-ref --verify --quiet "refs/heads/$ESPERADA" && HOTFIX_SEM_BRANCH=1 ;;
          esac
          if [ "$HOTFIX_SEM_BRANCH" -eq 0 ] && [ "$ATUAL" != "$ESPERADA" ] && [ "$TIPO_ATUAL" != "release" ] && [ "$TIPO_ATUAL" != "hotfix" ]; then
            bloquear "SDD (Git Flow) bloqueou o commit em '$ATUAL': a feature ativa $FEATURE é feita em $ESPERADA." \
              "Mude para ela com sdd-gitflow feature $FEATURE. Se o commit não é desta feature, troque a feature ativa (sdd-estado usar NNN-slug) ou deixe nenhuma ativa (sdd-estado definir feature=)."
          fi
          ;;
        esac
      fi
    fi
  fi
fi

# O assunto da mensagem inline (-m, -am, --message), também quando ela vem de um
# heredoc ("$(cat <<'EOF' ... EOF)"). Vazio quando não dá para ler: aí não se
# confere nada.
assunto_commit() {
  printf '%s' "$1" | awk -v ap="'" '
    { t = t $0 "\n" }
    END {
      if (!match(t, /(^|[[:space:]])(-[a-zA-Z]*m|--message)([[:space:]]+|=)/)) exit
      r = substr(t, RSTART + RLENGTH)
      q = substr(r, 1, 1)
      if (q == "\"" || q == ap) r = substr(r, 2); else q = ""
      if (substr(r, 1, 2) == "$(") {
        n = index(r, "\n"); if (!n) exit
        r = substr(r, n + 1); sub(/^[[:space:]]+/, "", r)
        q = ""
      }
      n = index(r, "\n"); if (n) r = substr(r, 1, n - 1)
      if (q != "") { e = index(r, q); if (e) r = substr(r, 1, e - 1) }
      else if (r !~ /^[a-z]+(\([^)]*\))?!?: /) sub(/[[:space:]].*/, "", r)
      print r
    }'
}

# A mensagem vinda de arquivo (-F arquivo, --file arquivo): o hook lê o
# arquivo, relativo à raiz do projeto. Com "-" (entrada padrão), não há o que ler.
MSG_ARQ="$(printf '%s' "$CMD" | sed -nE 's/.*(^|[[:space:]])(-F|--file)([[:space:]]+|=)("([^"]+)"|'"'"'([^'"'"']+)'"'"'|([^[:space:];&|]+)).*/\5\6\7/p' | head -1)"
MSG_TEXTO=""
if [ -n "$MSG_ARQ" ] && [ "$MSG_ARQ" != "-" ]; then
  case "$MSG_ARQ" in /*) ;; *) MSG_ARQ="$RAIZ/$MSG_ARQ" ;; esac
  [ -f "$MSG_ARQ" ] && MSG_TEXTO="$(grep -v '^#' "$MSG_ARQ" 2>/dev/null || true)"
fi

if [ "$E_COMMIT" -eq 1 ] && [ "$(sdd_config "$RAIZ" commits convencional)" = "convencional" ] && ! sdd_merge_em_andamento "$RAIZ"; then
  ASSUNTO="$(assunto_commit "$CMD")"
  [ -n "$ASSUNTO" ] || ASSUNTO="$(printf '%s\n' "$MSG_TEXTO" | grep -m1 -v '^[[:space:]]*$' || true)"
  if [ -n "$ASSUNTO" ] && ! sdd_cc_valida "$ASSUNTO"; then
    case "$ASSUNTO" in
      Merge\ *|Revert\ *) ;;
      *)
        NUM_EX="${FEATURE%%-*}"; [ -n "$NUM_EX" ] || NUM_EX="004"
        bloquear "SDD bloqueou o commit: a mensagem \"$ASSUNTO\" não segue o Conventional Commits." \
          "Formato: tipo(escopo): descrição. Tipos: feat (funcionalidade, sobe o minor), fix (correção, sobe o patch), perf, docs, chore, refactor, test, build, ci, style, revert." \
          "Mudança incompatível: tipo(escopo)!: descrição, ou o rodapé BREAKING CHANGE: (sobe o major)." \
          "O escopo é o número da feature. Exemplo: feat($NUM_EX): T-002 valida token expirado." ;;
    esac
  fi
fi

[ "$E_COMMIT" -eq 1 ] || exit 0
[ -n "$FEATURE" ] || exit 0
case "$FASE" in red|green|seguranca|auditoria) ;; *) exit 0 ;; esac

# Sem mensagem inline (-m, -am, --message, -F, --file), o editor abre ou a
# mensagem vem de --amend/--no-edit: não há o que inspecionar.
printf '%s' "$CMD" | grep -qE '(^|[[:space:]])(-m|-[a-zA-Z]*m|--message|-F|--file)([[:space:]=]|$)' || exit 0

NUM="${FEATURE%%-*}"
if printf '%s\n%s' "$CMD" "$MSG_TEXTO" | grep -qE "T-[0-9]{3}|\(${NUM}\)"; then
  exit 0
fi

{
  echo "SDD: os commits durante a implementação da feature $FEATURE precisam citar a tarefa."
  echo "Formato: tipo($NUM): T-XXX descrição. Exemplo: feat($NUM): T-002 valida token expirado"
  echo "Reescreva a mensagem com a tarefa correspondente de tarefas.md."
} >&2
exit 2
