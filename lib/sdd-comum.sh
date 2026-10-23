#!/usr/bin/env bash
# sdd-comum.sh: funções compartilhadas pelos utilitários de bin/ e pelos hooks.
#
# Este arquivo é carregado com `source`, não executado. Não usa `set -e`:
# quem carrega decide a política de erro. Tudo é bash puro, compatível com o
# bash 3.2 do macOS e com o Git Bash do Windows. jq ou python3 são usados para
# ler JSON quando presentes, e há uma reserva por expressão regular.

# Fases do ciclo SDD, em ordem.
SDD_FASES="especificacao clarificacao plano tarefas red green auditoria concluida"

# Globs padrão de arquivos de teste, usados quando a config não define outros.
# shellcheck disable=SC2034  # usado por quem carrega este arquivo
SDD_GLOBS_TESTE_PADRAO='tests/**,test/**,__tests__/**,spec/**,**/*.test.*,**/*.spec.*,**/*_test.*,**/test_*.py,**/*Test.java,**/*Tests.cs'

# ---------------------------------------------------------------------------
# Localização
# ---------------------------------------------------------------------------

# Raiz do plugin (pasta acima de lib/).
sdd_raiz_plugin() {
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '%s\n' "$CLAUDE_PLUGIN_ROOT"
    return
  fi
  local aqui
  aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  (cd "$aqui/.." && pwd)
}

# Raiz do projeto: CLAUDE_PROJECT_DIR, ou a pasta mais próxima (subindo) que
# contém .sdd/, ou a pasta atual.
sdd_raiz_projeto() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    printf '%s\n' "$CLAUDE_PROJECT_DIR"
    return
  fi
  local dir
  dir="$(pwd)"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/.sdd" ]; then
      printf '%s\n' "$dir"
      return
    fi
    dir="$(dirname "$dir")"
  done
  pwd
}

# ---------------------------------------------------------------------------
# Configuração (.sdd/config.yml, chaves planas "chave: valor")
# ---------------------------------------------------------------------------

# sdd_config <raiz> <chave> [padrão]
sdd_config() {
  local raiz="$1" chave="$2" padrao="${3:-}"
  local arquivo="$raiz/.sdd/config.yml"
  local valor=""
  if [ -f "$arquivo" ]; then
    valor="$(grep -E "^[[:space:]]*${chave}[[:space:]]*:" "$arquivo" | head -1 \
      | sed -E "s/^[[:space:]]*${chave}[[:space:]]*:[[:space:]]*//" \
      | sed -E 's/[[:space:]]+#.*$//' \
      | sed -E 's/^"(.*)"$/\1/' | sed -E "s/^'(.*)'$/\1/" \
      | tr -d '\r')"
  fi
  if [ -z "$valor" ]; then
    printf '%s\n' "$padrao"
  else
    printf '%s\n' "$valor"
  fi
}

# ---------------------------------------------------------------------------
# Estado (.sdd/estado, linhas "chave=valor")
# ---------------------------------------------------------------------------

# sdd_estado_ler <raiz> <chave>
sdd_estado_ler() {
  local raiz="$1" chave="$2"
  local arquivo="$raiz/.sdd/estado"
  [ -f "$arquivo" ] || return 0
  grep -E "^${chave}=" "$arquivo" | tail -1 | cut -d= -f2- | tr -d '\r'
}

# sdd_estado_gravar <raiz> <chave> <valor>
sdd_estado_gravar() {
  local raiz="$1" chave="$2" valor="$3"
  local arquivo="$raiz/.sdd/estado"
  mkdir -p "$raiz/.sdd"
  touch "$arquivo"
  local tmp="$arquivo.tmp.$$"
  grep -vE "^${chave}=" "$arquivo" > "$tmp" || true
  printf '%s=%s\n' "$chave" "$valor" >> "$tmp"
  mv "$tmp" "$arquivo"
}

sdd_fase_valida() {
  local f="$1" x
  for x in $SDD_FASES; do
    [ "$x" = "$f" ] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# JSON (entrada dos hooks)
# ---------------------------------------------------------------------------

# sdd_json_campo <json> <campo1> [campo2 ...]
# Devolve o primeiro campo não vazio dentre tool_input.<campo>.
# "tool_name", "cwd" e "hook_event_name" são lidos na raiz do objeto.
# SDD_JSON_PARSER=jq|python|grep força um leitor (usado nos testes).
sdd_json_campo() {
  local json="$1"; shift
  local campo leitor="${SDD_JSON_PARSER:-}"
  if [ -z "$leitor" ]; then
    if command -v jq >/dev/null 2>&1; then leitor="jq"
    elif command -v python3 >/dev/null 2>&1; then leitor="python"
    else leitor="grep"
    fi
  fi

  if [ "$leitor" = "jq" ]; then
    for campo in "$@"; do
      local v
      case "$campo" in
        tool_name|cwd|hook_event_name) v="$(printf '%s' "$json" | jq -r ".${campo} // empty" 2>/dev/null)" ;;
        *) v="$(printf '%s' "$json" | jq -r ".tool_input.${campo} // empty" 2>/dev/null)" ;;
      esac
      if [ -n "$v" ]; then printf '%s\n' "$v"; return; fi
    done
    return
  fi

  if [ "$leitor" = "python" ]; then
    printf '%s' "$json" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for f in sys.argv[1:]:
    src = d if f in ("tool_name", "cwd", "hook_event_name") else (d.get("tool_input") or {})
    v = src.get(f)
    if v:
        print(v)
        break
' "$@"
    return
  fi

  # Reserva por expressão regular. Aceita aspas e barras escapadas e desfaz
  # \" e \\ (suficiente para caminhos e comandos de shell comuns).
  for campo in "$@"; do
    local v
    v="$(printf '%s' "$json" \
      | grep -oE "\"${campo}\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 \
      | sed -E "s/^\"${campo}\"[[:space:]]*:[[:space:]]*\"//; s/\"$//" \
      | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g')"
    if [ -n "$v" ]; then printf '%s\n' "$v"; return; fi
  done
}

# ---------------------------------------------------------------------------
# Caminhos
# ---------------------------------------------------------------------------

# sdd_caminho_relativo <raiz> <caminho>: relativo à raiz, com "/" como separador.
sdd_caminho_relativo() {
  local raiz="$1" caminho="$2"
  caminho="${caminho//\\//}"
  raiz="${raiz//\\//}"
  raiz="${raiz%/}"
  case "$caminho" in
    "$raiz"/*) caminho="${caminho#"$raiz"/}" ;;
  esac
  caminho="${caminho#./}"
  printf '%s\n' "$caminho"
}

# sdd_casa_glob <caminho_relativo> <lista,de,globs>
# Retorna 0 se o caminho casa com algum glob. Um "**/" no início também casa
# arquivos na raiz do projeto.
sdd_casa_glob() {
  local caminho="$1" lista="$2" padrao
  [ -z "$lista" ] && return 1
  local IFS=','
  for padrao in $lista; do
    padrao="$(printf '%s' "$padrao" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -z "$padrao" ] && continue
    # shellcheck disable=SC2053
    if [[ "$caminho" == $padrao ]]; then return 0; fi
    case "$padrao" in
      '**/'*)
        local curto="${padrao#\*\*/}"
        # shellcheck disable=SC2053
        if [[ "$caminho" == $curto ]]; then return 0; fi
        ;;
    esac
  done
  return 1
}
