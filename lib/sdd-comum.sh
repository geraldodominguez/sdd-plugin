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

# Raiz do plugin (pasta acima de lib/). Vem sempre da localização deste
# arquivo: CLAUDE_PLUGIN_ROOT pode apontar para outro plugin quando os
# utilitários são chamados de fora de uma sessão com o SDD.
sdd_raiz_plugin() {
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
# Estado
#
# O estado mora em dois lugares:
#   .sdd/estado            ponteiros pessoais: feature ativa e sprint ativa
#   specs/NNN-slug/estado  estado da feature: fase, nivel, origem, atualizado
# O estado da feature é versionado (o time inteiro vê o quadro); os ponteiros
# podem ficar fora do git, para cada pessoa ter a sua feature ativa.
# ---------------------------------------------------------------------------

# Chaves que pertencem à feature, não aos ponteiros.
SDD_CHAVES_DA_FEATURE="fase nivel origem atualizado"

sdd_e_chave_da_feature() {
  local c="$1" x
  for x in $SDD_CHAVES_DA_FEATURE; do [ "$x" = "$c" ] && return 0; done
  return 1
}

# sdd_kv_ler <arquivo> <chave>
sdd_kv_ler() {
  local arquivo="$1" chave="$2"
  [ -f "$arquivo" ] || return 0
  { grep -E "^${chave}=" "$arquivo" || true; } | tail -1 | cut -d= -f2- | tr -d '\r'
}

# sdd_kv_gravar <arquivo> <chave> <valor>
sdd_kv_gravar() {
  local arquivo="$1" chave="$2" valor="$3"
  mkdir -p "$(dirname "$arquivo")"
  touch "$arquivo"
  local tmp="$arquivo.tmp.$$"
  grep -vE "^${chave}=" "$arquivo" > "$tmp" || true
  printf '%s=%s\n' "$chave" "$valor" >> "$tmp"
  mv "$tmp" "$arquivo"
}

# sdd_pasta_specs <raiz>
sdd_pasta_specs() { sdd_config "$1" pasta_specs specs; }

# sdd_arquivo_estado_feature <raiz> <feature>
sdd_arquivo_estado_feature() { printf '%s\n' "$1/$(sdd_pasta_specs "$1")/$2/estado"; }

# sdd_feature_ler <raiz> <feature> <chave>
sdd_feature_ler() { sdd_kv_ler "$(sdd_arquivo_estado_feature "$1" "$2")" "$3"; }

# sdd_feature_gravar <raiz> <feature> <chave> <valor>
sdd_feature_gravar() { sdd_kv_gravar "$(sdd_arquivo_estado_feature "$1" "$2")" "$3" "$4"; }

# sdd_estado_ler <raiz> <chave>
# fase, nivel, origem e atualizado vêm da feature ativa; o resto, de .sdd/estado.
sdd_estado_ler() {
  local raiz="$1" chave="$2"
  if sdd_e_chave_da_feature "$chave"; then
    local f v
    f="$(sdd_kv_ler "$raiz/.sdd/estado" feature)"
    if [ -n "$f" ] && [ -f "$(sdd_arquivo_estado_feature "$raiz" "$f")" ]; then
      sdd_feature_ler "$raiz" "$f" "$chave"
      return
    fi
  fi
  sdd_kv_ler "$raiz/.sdd/estado" "$chave"
}

# sdd_estado_gravar <raiz> <chave> <valor>
sdd_estado_gravar() {
  local raiz="$1" chave="$2" valor="$3"
  if sdd_e_chave_da_feature "$chave"; then
    local f
    f="$(sdd_kv_ler "$raiz/.sdd/estado" feature)"
    if [ -n "$f" ]; then
      sdd_feature_gravar "$raiz" "$f" "$chave" "$valor"
      return
    fi
  fi
  sdd_kv_gravar "$raiz/.sdd/estado" "$chave" "$valor"
}

# sdd_features <raiz>: lista os ids das features (NNN-slug), em ordem.
sdd_features() {
  local raiz="$1" d
  for d in "$raiz/$(sdd_pasta_specs "$raiz")"/[0-9][0-9][0-9]-*; do
    [ -d "$d" ] && basename "$d"
  done
  return 0
}

# ---------------------------------------------------------------------------
# Histórico
#
# specs/NNN-slug/historico.md  eventos da feature
# .sdd/historico.md            eventos do projeto (backlog, sprint)
# Linha: "- AAAA-MM-DDTHH:MM:SSZ | evento | detalhe | por: Nome"
# ---------------------------------------------------------------------------

sdd_agora() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# Quem fez a ação: SDD_AUTOR, o nome no git ou o usuário do sistema.
sdd_autor() {
  if [ -n "${SDD_AUTOR:-}" ]; then printf '%s\n' "$SDD_AUTOR"; return; fi
  local n
  n="$(git config user.name 2>/dev/null || true)"
  [ -n "$n" ] || n="${USER:-desconhecido}"
  printf '%s\n' "$n"
}

# sdd_arquivo_historico <raiz> [feature]
sdd_arquivo_historico() {
  if [ -n "${2:-}" ]; then
    printf '%s\n' "$1/$(sdd_pasta_specs "$1")/$2/historico.md"
  else
    printf '%s\n' "$1/.sdd/historico.md"
  fi
}

# sdd_registrar <raiz> <feature ou vazio> <evento> <detalhe>
sdd_registrar() {
  local raiz="$1" feature="$2" evento="$3" detalhe="$4"
  local arquivo
  arquivo="$(sdd_arquivo_historico "$raiz" "$feature")"
  mkdir -p "$(dirname "$arquivo")"
  if [ ! -s "$arquivo" ]; then
    if [ -n "$feature" ]; then
      printf '# Histórico %s\n\n' "$feature" > "$arquivo"
    else
      printf '# Histórico do projeto\n\n' > "$arquivo"
    fi
    printf '> Gerado pelos utilitários do SDD. Não edite à mão.\n\n' >> "$arquivo"
  fi
  printf -- '- %s | %s | %s | por: %s\n' "$(sdd_agora)" "$evento" "$detalhe" "$(sdd_autor)" >> "$arquivo"
}

# ---------------------------------------------------------------------------
# Hash e arquivos
# ---------------------------------------------------------------------------

# sdd_hash_stdin: 12 primeiros caracteres do sha256 da entrada.
sdd_hash_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -c1-12
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 | cut -c1-12
  elif command -v python3 >/dev/null 2>&1; then python3 -c 'import hashlib,sys;print(hashlib.sha256(sys.stdin.buffer.read()).hexdigest()[:12])'
  else cksum | awk '{printf "%012d\n", $1}'
  fi
}

# sdd_listar_arquivos <raiz>: arquivos do projeto, relativos à raiz.
sdd_listar_arquivos() {
  local raiz="$1"
  if git -C "$raiz" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$raiz" ls-files --cached --others --exclude-standard
  else
    (cd "$raiz" && find . -type f -not -path './.git/*' -not -path './node_modules/*' | sed 's#^\./##')
  fi
}

# sdd_testes_da_feature <raiz> <NNN>: arquivos de teste com a marca sdd:NNN:.
sdd_testes_da_feature() {
  local raiz="$1" num="$2" f globs specs
  globs="$(sdd_config "$raiz" globs_de_teste "$SDD_GLOBS_TESTE_PADRAO")"
  specs="$(sdd_pasta_specs "$raiz")"
  sdd_listar_arquivos "$raiz" | sort | while IFS= read -r f; do
    case "$f" in "$specs"/*|.sdd/*) continue ;; esac
    if sdd_casa_glob "$f" "$globs" && grep -q "sdd:${num}:" "$raiz/$f" 2>/dev/null; then
      printf '%s\n' "$f"
    fi
  done
}

# sdd_hash_artefato <raiz> <feature> <artefato>
# Artefatos: spec.md, plano.md (inclui contratos/), tarefas.md, testes, auditoria.md
sdd_hash_artefato() {
  local raiz="$1" feature="$2" art="$3"
  local dir
  dir="$raiz/$(sdd_pasta_specs "$raiz")/$feature"
  case "$art" in
    testes)
      local num="${feature%%-*}" f lista
      lista="$(sdd_testes_da_feature "$raiz" "$num")"
      [ -n "$lista" ] || return 1
      printf '%s\n' "$lista" | while IFS= read -r f; do printf '== %s\n' "$f"; cat "$raiz/$f"; done | sdd_hash_stdin
      ;;
    plano.md)
      [ -f "$dir/plano.md" ] || return 1
      { cat "$dir/plano.md"
        if [ -d "$dir/contratos" ]; then
          find "$dir/contratos" -type f | sort | while IFS= read -r f; do printf '== %s\n' "${f#"$dir"/}"; cat "$f"; done
        fi
      } | sdd_hash_stdin
      ;;
    *)
      [ -f "$dir/$art" ] || return 1
      sdd_hash_stdin < "$dir/$art"
      ;;
  esac
}

# sdd_ultima_aprovacao <raiz> <feature> <artefato>: imprime o hash aprovado.
sdd_ultima_aprovacao() {
  local arquivo
  arquivo="$(sdd_arquivo_historico "$1" "$2")"
  [ -f "$arquivo" ] || return 0
  { grep -F "| aprovacao | $3 | hash=" "$arquivo" || true; } | tail -1 | sed -E 's/.*\| hash=([0-9a-f]+).*/\1/'
}

# sdd_artefato_da_fase <fase>: o que /sdd:aprovar aprova em cada fase.
sdd_artefato_da_fase() {
  case "$1" in
    especificacao|clarificacao) echo spec.md ;;
    plano) echo plano.md ;;
    tarefas) echo tarefas.md ;;
    red) echo testes ;;
    auditoria) echo auditoria.md ;;
    *) echo "" ;;
  esac
}

# sdd_proxima_fase <fase> <nivel>: para onde a aprovação leva.
sdd_proxima_fase() {
  case "$1" in
    especificacao|clarificacao) if [ "$2" = "2" ]; then echo plano; else echo tarefas; fi ;;
    plano) echo tarefas ;;
    tarefas) echo red ;;
    red) echo green ;;
    green|auditoria) echo concluida ;;
    *) echo "" ;;
  esac
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

# ---------------------------------------------------------------------------
# Datas (GNU date, BSD date ou python3)
# ---------------------------------------------------------------------------

# sdd_data_mais <AAAA-MM-DD> <dias>: data somada de N dias.
sdd_data_mais() {
  local d="$1" n="$2"
  date -d "$d + $n days" +%Y-%m-%d 2>/dev/null && return
  date -j -v+"${n}"d -f %Y-%m-%d "$d" +%Y-%m-%d 2>/dev/null && return
  python3 -c "import datetime,sys;print((datetime.date.fromisoformat(sys.argv[1])+datetime.timedelta(days=int(sys.argv[2]))).isoformat())" "$d" "$n" 2>/dev/null
}

# sdd_dias_entre <AAAA-MM-DD> <AAAA-MM-DD>: dias da primeira até a segunda.
sdd_dias_entre() {
  local a="$1" b="$2" sa sb
  sa="$(date -d "$a" +%s 2>/dev/null || date -j -f %Y-%m-%d "$a" +%s 2>/dev/null || true)"
  sb="$(date -d "$b" +%s 2>/dev/null || date -j -f %Y-%m-%d "$b" +%s 2>/dev/null || true)"
  if [ -n "$sa" ] && [ -n "$sb" ]; then
    echo $(( (sb - sa) / 86400 ))
    return
  fi
  python3 -c "import datetime,sys;print((datetime.date.fromisoformat(sys.argv[2])-datetime.date.fromisoformat(sys.argv[1])).days)" "$a" "$b" 2>/dev/null
}

# sdd_semana_iso <AAAA-MM-DD>: identificador AAAA-SNN da semana ISO.
sdd_semana_iso() {
  date -d "$1" +%G-S%V 2>/dev/null && return
  date -j -f %Y-%m-%d "$1" +%G-S%V 2>/dev/null && return
  python3 -c "import datetime,sys;y,w,_=datetime.date.fromisoformat(sys.argv[1]).isocalendar();print(f'{y}-S{w:02d}')" "$1" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Progresso de uma feature
# ---------------------------------------------------------------------------

# sdd_tarefas_progresso <raiz> <feature>: "feitas total" (0 0 sem tarefas.md).
sdd_tarefas_progresso() {
  local arq feitas abertas
  arq="$1/$(sdd_pasta_specs "$1")/$2/tarefas.md"
  if [ ! -f "$arq" ]; then echo "0 0"; return; fi
  feitas="$(grep -cE '^[[:space:]]*- \[[xX]\][[:space:]]*\*{0,2}T-[0-9]{3}' "$arq" || true)"
  abertas="$(grep -cE '^[[:space:]]*- \[ \][[:space:]]*\*{0,2}T-[0-9]{3}' "$arq" || true)"
  echo "$feitas $((feitas + abertas))"
}

# sdd_duvidas_abertas <raiz> <feature>: marcadores PRECISA ESCLARECER reais na spec.
sdd_duvidas_abertas() {
  local arq
  arq="$1/$(sdd_pasta_specs "$1")/$2/spec.md"
  [ -f "$arq" ] || { echo 0; return; }
  grep -F '[PRECISA ESCLARECER' "$arq" | grep -v '{{' | grep -vc '^[[:space:]]*>' || true
}

# sdd_aguarda_aprovacao <raiz> <feature>: imprime o artefato que espera aprovação, se houver.
sdd_aguarda_aprovacao() {
  local raiz="$1" f="$2" fase art atual aprovado
  fase="$(sdd_feature_ler "$raiz" "$f" fase)"
  art="$(sdd_artefato_da_fase "$fase")"
  [ -n "$art" ] || return 0
  atual="$(sdd_hash_artefato "$raiz" "$f" "$art" 2>/dev/null || true)"
  [ -n "$atual" ] || return 0
  aprovado="$(sdd_ultima_aprovacao "$raiz" "$f" "$art")"
  [ "$aprovado" = "$atual" ] || printf '%s\n' "$art"
}
