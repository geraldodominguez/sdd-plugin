#!/usr/bin/env bash
# sdd-comum.sh: funções compartilhadas pelos utilitários de bin/ e pelos hooks.
#
# Este arquivo é carregado com `source`, não executado. Não usa `set -e`:
# quem carrega decide a política de erro. Tudo é bash puro, compatível com o
# bash 3.2 do macOS e com o Git Bash do Windows. jq ou python3 são usados para
# ler JSON quando presentes, e há uma reserva por expressão regular.

# Fases do ciclo de uma feature, em ordem. "cancelada" fica fora da ordem.
#   construção: especificacao clarificacao plano tarefas red green
#   revisão:    seguranca auditoria
#   entrega:    pronta homologacao producao  (as duas últimas, pela release)
SDD_FASES="especificacao clarificacao plano tarefas red green seguranca auditoria pronta homologacao producao cancelada"

# Fases que só os utilitários alcançam (aprovação, release, cancelamento):
# "sdd-estado definir fase=" recusa estas.
SDD_FASES_PROTEGIDAS="pronta homologacao producao cancelada"

# Globs padrão de arquivos de teste, usados quando a config não define outros.
# shellcheck disable=SC2034  # usado por quem carrega este arquivo
SDD_GLOBS_TESTE_PADRAO='tests/**,test/**,__tests__/**,spec/**,**/*.test.*,**/*.spec.*,**/*_test.*,**/test_*.py,**/*Test.java,**/*Tests.cs'

# ---------------------------------------------------------------------------
# Ajuda
# ---------------------------------------------------------------------------

# sdd_ajuda <script>: imprime o cabeçalho de uso do script (os comentários do
# topo, sem o "#"). Todo utilitário responde a -h, --ajuda e --help, dentro ou
# fora de um projeto com SDD.
sdd_ajuda() {
  awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$1"
}

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
      | sed -E 's/[[:space:]]+#.*$//' | sed -E 's/^#.*$//' \
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
#   fase, nivel, origem (B-NNN ou INC-NNN), tipo (normal ou hotfix),
#   seguranca (obrigatoria ou dispensada), capacidade (da spec do sistema),
#   release (versão em que entrou), adocao (transicao ou regularizada, só nas
#   features adotadas de outro processo), branch (a do Git Flow: feature/NNN-slug
#   ou, num hotfix, hotfix/X.Y.Z), atualizado
SDD_CHAVES_DA_FEATURE="fase nivel origem tipo seguranca capacidade release adocao branch atualizado"

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
sdd_pasta_sistema() { sdd_config "$1" pasta_sistema sistema; }
sdd_pasta_releases() { sdd_config "$1" pasta_releases releases; }
sdd_pasta_incidentes() { sdd_config "$1" pasta_incidentes incidentes; }

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

# sdd_blocos_de_teste <arquivo> <NNN>: só as linhas dos testes da feature.
# Um bloco começa na linha que tem a marca sdd:NNN: e vai até a linha com a
# marca de outra feature (exclusive) ou o fim do arquivo. Assim, testes que
# outra feature acrescenta no mesmo arquivo não mudam o hash desta.
sdd_blocos_de_teste() {
  awk -v n="$2" '
    {
      if (match($0, /sdd:[0-9][0-9][0-9]:/)) {
        dentro = (substr($0, RSTART + 4, 3) == n)
      }
      if (dentro) print
    }
  ' "$1"
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
      printf '%s\n' "$lista" | while IFS= read -r f; do
        printf '== %s\n' "$f"
        sdd_blocos_de_teste "$raiz/$f" "$num"
      done | sdd_hash_stdin
      ;;
    plano.md)
      [ -f "$dir/plano.md" ] || return 1
      { cat "$dir/plano.md"
        if [ -d "$dir/contratos" ]; then
          find "$dir/contratos" -type f | sort | while IFS= read -r f; do printf '== %s\n' "${f#"$dir"/}"; cat "$f"; done
        fi
      } | sdd_hash_stdin
      ;;
    tarefas.md)
      # Marcar uma tarefa como feita ([ ] para [x]) é progresso, não mudança do
      # que foi aprovado: as duas caixas entram iguais no hash. O [O] (feita
      # fora do plugin) continua contando.
      [ -f "$dir/tarefas.md" ] || return 1
      sed -E 's/^([[:space:]]*-[[:space:]]+)\[[xX ]\]/\1[ ]/' "$dir/tarefas.md" | sdd_hash_stdin
      ;;
    *)
      [ -f "$dir/$art" ] || return 1
      sdd_hash_stdin < "$dir/$art"
      ;;
  esac
}

# sdd_hash_bruto <raiz> <feature> <artefato>: o hash do arquivo como está, sem a
# normalização das caixas do tarefas.md. Aprovações feitas antes da 1.0.1
# gravaram este hash; ele continua aceito.
sdd_hash_bruto() {
  local dir
  dir="$1/$(sdd_pasta_specs "$1")/$2"
  [ -f "$dir/$3" ] || return 1
  sdd_hash_stdin < "$dir/$3"
}

# sdd_indice_fase <fase>: posição na ordem (cancelada fica de fora).
sdd_indice_fase() {
  local i=0 x
  for x in $SDD_FASES; do
    [ "$x" = "$1" ] && { echo "$i"; return; }
    i=$((i + 1))
  done
  echo 99
}

# sdd_fase_do_artefato <artefato>: a fase em que o artefato é aprovado.
sdd_fase_do_artefato() {
  case "$1" in
    spec.md) echo especificacao ;;
    plano.md) echo plano ;;
    tarefas.md) echo tarefas ;;
    testes) echo red ;;
    entrega) echo green ;;
    seguranca.md) echo seguranca ;;
    auditoria.md) echo auditoria ;;
    *) echo especificacao ;;
  esac
}

# sdd_ultima_aprovacao <raiz> <feature> <artefato>: imprime o hash aprovado.
# Uma reabertura ("| reabertura | fase=X |") invalida as aprovações dos
# artefatos da fase X em diante.
sdd_ultima_aprovacao() {
  local arquivo alvo idx_art
  arquivo="$(sdd_arquivo_historico "$1" "$2")"
  [ -f "$arquivo" ] || return 0
  alvo="$3"
  idx_art="$(sdd_indice_fase "$(sdd_fase_do_artefato "$alvo")")"
  local ordem="$SDD_FASES"
  awk -v alvo="$alvo" -v idx_art="$idx_art" -v ordem="$ordem" '
    BEGIN { n = split(ordem, f, " "); for (i = 1; i <= n; i++) pos[f[i]] = i - 1 }
    index($0, "| aprovacao | " alvo " | hash=") {
      # A decisão "corrigir" registra a leitura, mas não aprova: anula a anterior.
      if (index($0, "| decisao: corrigir")) { hash = ""; next }
      h = $0; sub(/.*\| hash=/, "", h); sub(/[^0-9a-f].*/, "", h); hash = h; next
    }
    index($0, "| reabertura | fase=") {
      r = $0; sub(/.*\| reabertura \| fase=/, "", r); sub(/[^a-z].*/, "", r)
      if ((r in pos) && pos[r] <= idx_art) hash = ""
    }
    END { if (hash != "") print hash }
  ' "$arquivo"
}

# sdd_aprovado_ok <raiz> <feature> <artefato>: 0 se aprovado e inalterado.
sdd_aprovado_ok() {
  local atual aprovado
  aprovado="$(sdd_ultima_aprovacao "$1" "$2" "$3")"
  [ -n "$aprovado" ] || return 1
  [ "$3" = "entrega" ] && return 0
  atual="$(sdd_hash_artefato "$1" "$2" "$3" 2>/dev/null || true)"
  [ "$aprovado" = "$atual" ] && return 0
  [ "$3" = "tarefas.md" ] && [ "$aprovado" = "$(sdd_hash_bruto "$1" "$2" "$3" 2>/dev/null || true)" ]
}

# sdd_pendencias_para_pronta <raiz> <feature>: imprime o que impede a feature
# de ficar pronta (uma linha por motivo). Nada impresso significa liberada.
sdd_pendencias_para_pronta() {
  local raiz="$1" f="$2" nivel seg art
  nivel="$(sdd_feature_ler "$raiz" "$f" nivel)"
  seg="$(sdd_feature_ler "$raiz" "$f" seguranca)"
  for art in spec.md testes; do
    sdd_aprovado_ok "$raiz" "$f" "$art" || echo "$art não está aprovado ou mudou depois da aprovação"
  done
  if [ "$nivel" = "2" ]; then
    sdd_aprovado_ok "$raiz" "$f" plano.md || echo "plano.md não está aprovado ou mudou depois da aprovação"
  fi
  if [ "$seg" = "obrigatoria" ]; then
    sdd_aprovado_ok "$raiz" "$f" seguranca.md || echo "seguranca.md não está aprovado (a revisão de segurança é obrigatória nesta feature)"
  fi
  return 0
}

# sdd_artefato_da_fase <fase>: o que /sdd:aprovar aprova em cada fase.
# (Na fase green, a aprovação é da "entrega", tratada à parte.)
sdd_artefato_da_fase() {
  case "$1" in
    especificacao|clarificacao) echo spec.md ;;
    plano) echo plano.md ;;
    tarefas) echo tarefas.md ;;
    red) echo testes ;;
    seguranca) echo seguranca.md ;;
    auditoria) echo auditoria.md ;;
    *) echo "" ;;
  esac
}

# sdd_proxima_fase <fase> <nivel> [tipo]: para onde a aprovação leva.
# Depois da revisão de segurança: auditoria no nível 2, pronta no nível 1.
sdd_proxima_fase() {
  case "$1" in
    especificacao|clarificacao)
      if [ "${3:-}" = "hotfix" ]; then echo ""; elif [ "$2" = "2" ]; then echo plano; else echo tarefas; fi ;;
    plano) echo tarefas ;;
    tarefas) echo red ;;
    red) echo green ;;
    seguranca) if [ "$2" = "2" ]; then echo auditoria; else echo pronta; fi ;;
    auditoria) echo pronta ;;
    *) echo "" ;;
  esac
}

sdd_fase_protegida() {
  local x
  for x in $SDD_FASES_PROTEGIDAS; do [ "$x" = "$1" ] && return 0; done
  return 1
}

# Fases em que a feature já saiu da construção (entregue ou a caminho).
sdd_fase_entregue() { case "$1" in pronta|homologacao|producao) return 0 ;; esac; return 1; }

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
  local caminho="$1" lista="$2" padrao padroes
  [ -z "$lista" ] && return 1
  # read -a não expande os globs contra os arquivos do diretório atual (um
  # "for p in $lista" expandiria, e o resultado mudaria conforme o cwd).
  IFS=',' read -r -a padroes <<< "$lista"
  for padrao in "${padroes[@]}"; do
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

# Linha de tarefa: "- [ ] T-NNN" aberta, "- [x] T-NNN" feita no plugin e
# "- [O] T-NNN" feita fora do plugin, antes da adoção, sem gate.
# shellcheck disable=SC2034  # usado por quem carrega este arquivo
SDD_RE_TAREFA='^[[:space:]]*- \[[ xXoO]\][[:space:]]*\*{0,2}T-[0-9]{3}'

# sdd_tarefas_progresso <raiz> <feature>: "feitas total" (0 0 sem tarefas.md).
# As feitas incluem as [O]; sdd_tarefas_fora conta só essas.
sdd_tarefas_progresso() {
  local arq feitas abertas
  arq="$1/$(sdd_pasta_specs "$1")/$2/tarefas.md"
  if [ ! -f "$arq" ]; then echo "0 0"; return; fi
  feitas="$(grep -cE '^[[:space:]]*- \[[xXoO]\][[:space:]]*\*{0,2}T-[0-9]{3}' "$arq" || true)"
  abertas="$(grep -cE '^[[:space:]]*- \[ \][[:space:]]*\*{0,2}T-[0-9]{3}' "$arq" || true)"
  echo "$feitas $((feitas + abertas))"
}

# sdd_tarefas_fora <raiz> <feature>: quantas tarefas [O], feitas fora do plugin.
sdd_tarefas_fora() {
  local arq
  arq="$1/$(sdd_pasta_specs "$1")/$2/tarefas.md"
  [ -f "$arq" ] || { echo 0; return; }
  grep -cE '^[[:space:]]*- \[[oO]\][[:space:]]*\*{0,2}T-[0-9]{3}' "$arq" || true
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
  # Feature adotada de outro processo: antes de tudo, a transição.
  if [ "$(sdd_feature_ler "$raiz" "$f" adocao)" = "transicao" ]; then
    printf 'transicao.md\n'
    return 0
  fi
  art="$(sdd_artefato_da_fase "$fase")"
  # Hotfix: a spec é retroativa e precisa ser aprovada antes da entrega.
  if [ "$(sdd_feature_ler "$raiz" "$f" tipo)" = "hotfix" ] && [ "$fase" = "green" ]; then
    sdd_aprovado_ok "$raiz" "$f" spec.md || { printf 'spec.md\n'; return 0; }
  fi
  [ -n "$art" ] || return 0
  atual="$(sdd_hash_artefato "$raiz" "$f" "$art" 2>/dev/null || true)"
  [ -n "$atual" ] || return 0
  sdd_aprovado_ok "$raiz" "$f" "$art" || printf '%s\n' "$art"
}

# ---------------------------------------------------------------------------
# Áreas sensíveis
# ---------------------------------------------------------------------------

# sdd_arquivos_sensiveis <raiz> [ref]: arquivos alterados (desde ref, ou só os
# não commitados) que casam com areas_sensiveis do config.
sdd_arquivos_sensiveis() {
  local raiz="$1" ref="${2:-}" globs f
  globs="$(sdd_config "$raiz" areas_sensiveis "")"
  [ -n "$globs" ] || return 0
  git -C "$raiz" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  {
    [ -n "$ref" ] && git -C "$raiz" diff --name-only "$ref...HEAD" 2>/dev/null
    git -C "$raiz" diff --name-only HEAD 2>/dev/null
    git -C "$raiz" ls-files --others --exclude-standard 2>/dev/null
  } | sort -u | while IFS= read -r f; do
    [ -n "$f" ] && sdd_casa_glob "$f" "$globs" && printf '%s\n' "$f"
  done
  return 0
}

# ---------------------------------------------------------------------------
# Campos de tabela em markdown ("| Campo | valor |")
# ---------------------------------------------------------------------------

# sdd_md_campo <arquivo> <campo>
sdd_md_campo() {
  [ -f "$1" ] || return 0
  { grep -E "^\| $2 \|" "$1" || true; } | head -1 | sed -E "s/^\| $2 \| (.*) \|$/\1/"
}

# sdd_md_gravar_campo <arquivo> <campo> <valor>
sdd_md_gravar_campo() {
  local tmp="$1.tmp.$$"
  awk -v n="$2" -v v="$3" '$0 ~ ("^\\| " n " \\|") && !feito { print "| " n " | " v " |"; feito = 1; next } { print }' "$1" > "$tmp"
  mv "$tmp" "$1"
}

# sdd_md_sem_lacunas <arquivo>: 0 se não há campos {{...}} por preencher.
sdd_md_sem_lacunas() { [ -f "$1" ] && ! grep -q '{{' "$1"; }

# sdd_template <raiz> <nome>: template local do projeto ou o do plugin.
sdd_template() {
  if [ -f "$1/.sdd/templates/$2" ]; then
    printf '%s\n' "$1/.sdd/templates/$2"
  else
    printf '%s\n' "$(sdd_raiz_plugin)/skills/metodologia/templates/$2"
  fi
}

# sdd_semver_valida <versão>
sdd_semver_valida() { printf '%s' "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; }

# ---------------------------------------------------------------------------
# Nomes e numeração
# ---------------------------------------------------------------------------

# sdd_slug <texto>: minúsculas, sem acento, palavras unidas por "-", até 50
# caracteres. Transliteração explícita: não depende de locale nem de iconv.
sdd_slug() {
  printf '%s' "$1" \
    | sed -e 's/á/a/g; s/à/a/g; s/â/a/g; s/ã/a/g; s/ä/a/g' \
          -e 's/Á/a/g; s/À/a/g; s/Â/a/g; s/Ã/a/g; s/Ä/a/g' \
          -e 's/é/e/g; s/è/e/g; s/ê/e/g; s/ë/e/g; s/É/e/g; s/È/e/g; s/Ê/e/g' \
          -e 's/í/i/g; s/ì/i/g; s/î/i/g; s/ï/i/g; s/Í/i/g; s/Î/i/g' \
          -e 's/ó/o/g; s/ò/o/g; s/ô/o/g; s/õ/o/g; s/ö/o/g; s/Ó/o/g; s/Ô/o/g; s/Õ/o/g' \
          -e 's/ú/u/g; s/ù/u/g; s/û/u/g; s/ü/u/g; s/Ú/u/g; s/Ü/u/g' \
          -e 's/ç/c/g; s/Ç/c/g; s/ñ/n/g; s/Ñ/n/g' \
    | LC_ALL=C tr '[:upper:]' '[:lower:]' \
    | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -c1-50 \
    | sed -E 's/-+$//'
}

# sdd_proximo_numero_feature <raiz>: próximo NNN livre em specs/.
sdd_proximo_numero_feature() {
  local maior=0 id n
  for id in $(sdd_features "$1"); do
    n="$(printf '%s' "$id" | cut -c1-3)"
    n=$((10#$n))
    [ "$n" -gt "$maior" ] && maior="$n"
  done
  printf '%03d\n' $((maior + 1))
}

# sdd_proximo_numero_adr <raiz>: próximo NNNN livre em docs/adr/.
sdd_proximo_numero_adr() {
  local maior=0 a n
  for a in "$1"/docs/adr/[0-9][0-9][0-9][0-9]-*.md; do
    [ -f "$a" ] || continue
    n="$(basename "$a" | cut -c1-4)"
    n=$((10#$n))
    [ "$n" -gt "$maior" ] && maior="$n"
  done
  printf '%04d\n' $((maior + 1))
}

# ---------------------------------------------------------------------------
# Layout: onde cada artefato mora
#
# O layout é o da tabela do README ("Onde fica cada coisa"), com as pastas
# configuráveis do .sdd/config.yml. Um artefato de processo (spec, plano,
# tarefas, ADR, backlog, sprint, arquitetura, regras do projeto) fora dele é
# o rastro de outro processo ou de um agente que inventou a própria estrutura.
# As mesmas funções servem ao hook (arquivo novo), ao sdd-adotar (inventário e
# destino) e ao sdd-verificar (aviso no CI), para que os três concordem.
# ---------------------------------------------------------------------------

# Pastas que nunca são examinadas: dependências, saídas de build, ferramentas.
sdd_caminho_ignorado() {
  case "/$1" in
    */node_modules/*|*/vendor/*|*/.git/*|*/dist/*|*/build/*|*/target/*|*/.venv/*|*/venv/*|*/.next/*|*/coverage/*|*/.claude/*|*/.github/*|*/.gitlab/*|*/.idea/*|*/.vscode/*) return 0 ;;
  esac
  return 1
}

# sdd_tipo_de_artefato <caminho relativo>: imprime o tipo do artefato de
# processo (spec, plano, tarefas, adr, backlog, sprint, arquitetura,
# constituicao) ou nada, se o arquivo não parece um. Só olha o nome e as
# pastas: é barato o bastante para rodar num hook.
sdd_tipo_de_artefato() {
  local rel base nome dirs ext
  rel="$(printf '%s' "$1" | LC_ALL=C tr '[:upper:]' '[:lower:]')"
  sdd_caminho_ignorado "$rel" && return 1
  base="${rel##*/}"
  case "$base" in
    *.md|*.mdx|*.markdown) ext=md ;;
    *.dsl|*.puml|*.plantuml) ext=diagrama ;;
    *) return 1 ;;
  esac
  nome="${base%.*}"
  case "$rel" in */*) dirs="/${rel%/*}/" ;; *) dirs="/" ;; esac

  case "$nome" in
    readme|changelog|license|licenca|contributing|contribuindo|code_of_conduct|claude|agents|gemini|copilot-instructions|index) return 1 ;;
  esac

  case "$nome:$dirs" in
    adr:*|adr-*:*|adr_*:*|*:*/adr/*|*:*/adrs/*|*:*/decisions/*|*:*/decisoes/*)
      echo adr; return 0 ;;
  esac
  if [ "$ext" = diagrama ]; then echo arquitetura; return 0; fi
  case "$nome:$dirs" in
    architecture*:*|arquitetura*:*|c4*:*|*-c4:*|*:*/architecture/*|*:*/arquitetura/*|*:*/c4/*)
      echo arquitetura; return 0 ;;
  esac
  case "$nome" in
    constitution*|constituicao*|conventions*|convencoes*|guidelines*|diretrizes*|principles*|principios*|standards*|padroes*)
      echo constituicao; return 0 ;;
    backlog*|roadmap*|ideias*|ideas*|wishlist*)
      echo backlog; return 0 ;;
    sprint*|iteration*|iteracao*)
      echo sprint; return 0 ;;
    tasks|tasks[-_.]*|task[-_]*|tarefas*|todo|todo[-_.]*|to-do*|checklist*)
      echo tarefas; return 0 ;;
    plan|plan[-_.]*|*[-_]plan|plano|plano[-_.]*|implementation*|implementacao*)
      echo plano; return 0 ;;
    spec|spec[-_.]*|*[-_.]spec|specification*|especificacao*|requirements*|requisitos*|prd|prd[-_.]*|*[-_]prd)
      echo spec; return 0 ;;
  esac
  case "$nome:$dirs" in
    design:*/specs/*|design:*/spec/*|design:*/.kiro/*|design:*/.specify/*|design:*/openspec/*|design:*/features/*)
      echo plano; return 0 ;;
  esac
  case "$dirs" in
    */tasks/*|*/tarefas/*|*/todo/*|*/.taskmaster/*) echo tarefas; return 0 ;;
    */plans/*|*/planos/*) echo plano; return 0 ;;
    */backlog/*) echo backlog; return 0 ;;
    */sprints/*) echo sprint; return 0 ;;
    */specs/*|*/spec/*|*/specifications/*|*/features/*|*/requirements/*|*/requisitos/*|*/prd/*|*/prds/*|*/.specify/*|*/.kiro/*|*/openspec/*)
      echo spec; return 0 ;;
  esac
  return 1
}

# sdd_no_layout <raiz> <caminho relativo>: 0 se o arquivo está num lugar do
# padrão (ou casa com excecoes_de_layout do config).
# As pastas e as exceções são lidas do config uma vez por raiz: o inventário
# chama esta função para cada arquivo do projeto.
SDD__LAYOUT_RAIZ=""
sdd__carregar_layout() {
  [ "$SDD__LAYOUT_RAIZ" = "$1" ] && return 0
  SDD__LAYOUT_SPECS="$(sdd_pasta_specs "$1")"
  SDD__LAYOUT_SISTEMA="$(sdd_pasta_sistema "$1")"
  SDD__LAYOUT_RELEASES="$(sdd_pasta_releases "$1")"
  SDD__LAYOUT_INCIDENTES="$(sdd_pasta_incidentes "$1")"
  SDD__LAYOUT_EXCECOES="$(sdd_config "$1" excecoes_de_layout "")"
  SDD__LAYOUT_RAIZ="$1"
}

sdd_no_layout() {
  local raiz="$1" rel="$2" specs sistema releases incidentes excecoes resto pasta
  sdd__carregar_layout "$raiz"
  specs="$SDD__LAYOUT_SPECS"; sistema="$SDD__LAYOUT_SISTEMA"
  releases="$SDD__LAYOUT_RELEASES"; incidentes="$SDD__LAYOUT_INCIDENTES"
  case "$rel" in
    .sdd/*|"$sistema"/*|"$releases"/*|"$incidentes"/*|docs/legado/*|docs/arquitetura/*) return 0 ;;
    docs/adr/*)
      printf '%s' "${rel#docs/adr/}" | grep -qE '^[0-9]{4}-[a-z0-9]+(-[a-z0-9]+)*\.md$' && return 0 ;;
    "$specs"/*/*)
      resto="${rel#"$specs"/}"
      pasta="${resto%%/*}"
      # Pasta com nome de feature, mas sem estado, foi criada à mão: não conta.
      printf '%s' "$pasta" | grep -qE '^[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$' \
        && [ -f "$raiz/$specs/$pasta/estado" ] && return 0 ;;
  esac
  excecoes="$SDD__LAYOUT_EXCECOES"
  [ -n "$excecoes" ] && sdd_casa_glob "$rel" "$excecoes" && return 0
  return 1
}

# sdd_fora_do_layout <raiz> <caminho relativo>: imprime o tipo e devolve 0 se
# o arquivo é um artefato de processo fora do lugar do padrão.
sdd_fora_do_layout() {
  local tipo
  tipo="$(sdd_tipo_de_artefato "$2")" || return 1
  sdd_no_layout "$1" "$2" && return 1
  printf '%s\n' "$tipo"
}

# sdd_artefatos_fora_do_layout <raiz>: "tipo<TAB>caminho", um por linha, em ordem.
sdd_artefatos_fora_do_layout() {
  local raiz="$1" f tipo
  sdd__carregar_layout "$raiz"
  # Filtra pela extensão antes: só os candidatos passam pelo classificador.
  sdd_listar_arquivos "$raiz" | grep -iE '\.(md|mdx|markdown|dsl|puml|plantuml)$' | sort | while IFS= read -r f; do
    [ -n "$f" ] && [ -f "$raiz/$f" ] || continue
    case "$f" in .sdd/*) continue ;; esac
    tipo="$(sdd_fora_do_layout "$raiz" "$f")" || continue
    printf '%s\t%s\n' "$tipo" "$f"
  done
  return 0
}

# Onde cada tipo de artefato mora no padrão (texto curto, para mensagens).
sdd_destino_do_tipo() {
  case "$1" in
    spec|plano|tarefas) echo "$(sdd_pasta_specs "${2:-.}")/NNN-slug/ (crie a feature com sdd-estado nova; nunca crie a pasta à mão)" ;;
    adr) echo "docs/adr/NNNN-slug.md (numeração sequencial de 4 dígitos, a partir do template de ADR)" ;;
    backlog) echo ".sdd/backlog.md (sdd-backlog adicionar)" ;;
    sprint) echo ".sdd/sprints/ (sdd-sprint)" ;;
    arquitetura) echo "docs/arquitetura/" ;;
    constituicao) echo ".sdd/constituicao.md (regras do projeto inteiro)" ;;
    *) echo "o lugar do padrão (ver /sdd:ajuda)" ;;
  esac
}

# ---------------------------------------------------------------------------
# Git Flow
#
# Os nomes são fixos e iguais em todo projeto: nada de "develop" num e
# "development" noutro. Ver docs/referencia/git-flow.md.
#
#   main              produção; só recebe merge de release/ e hotfix/, com tag
#   develop           integração; recebe as features prontas
#   feature/NNN-slug  uma por feature do SDD, de develop para develop
#   release/X.Y.Z     uma por release, de develop para main (e de volta)
#   hotfix/X.Y.Z      uma por hotfix, de main para main (e para develop)
#   vX.Y.Z            a tag de cada versão em main
# ---------------------------------------------------------------------------

# shellcheck disable=SC2034  # usados por quem carrega este arquivo
SDD_BRANCH_PRODUCAO=main
# shellcheck disable=SC2034
SDD_BRANCH_INTEGRACAO=develop

# sdd_gitflow_ativo <raiz>: 0 se o Git Flow vale neste projeto (config
# gitflow, ativo por padrão, e um repositório git).
sdd_gitflow_ativo() {
  [ "$(sdd_config "$1" gitflow ativo)" = "ativo" ] || return 1
  git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# sdd_branch_tipo <nome>: imprime producao, integracao, feature, release ou
# hotfix. Devolve 1 se o nome está fora do padrão.
sdd_branch_tipo() {
  local b="$1"
  case "$b" in
    main) echo producao; return 0 ;;
    develop) echo integracao; return 0 ;;
    feature/*)
      printf '%s' "${b#feature/}" | grep -qE '^[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$' && { echo feature; return 0; } ;;
    release/*) sdd_semver_valida "${b#release/}" && { echo release; return 0; } ;;
    hotfix/*) sdd_semver_valida "${b#hotfix/}" && { echo hotfix; return 0; } ;;
  esac
  return 1
}

# sdd_branch_atual <raiz>: o nome da branch atual; vazio em HEAD destacado.
sdd_branch_atual() {
  local b
  b="$(git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [ "$b" = "HEAD" ] && b=""
  printf '%s\n' "$b"
}

# sdd_branch_da_feature <raiz> <feature>: a branch em que a feature é feita.
sdd_branch_da_feature() {
  local b
  b="$(sdd_feature_ler "$1" "$2" branch)"
  [ -n "$b" ] || b="feature/$2"
  printf '%s\n' "$b"
}

# sdd_merge_em_andamento <raiz>: 0 se há um merge à espera do commit.
sdd_merge_em_andamento() { git -C "$1" rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; }

# sdd_branch_sugerida <nome>: o nome do padrão para uma branch antiga, quando
# é óbvio; vazio quando a decisão é do usuário (ex.: a feature ainda não existe).
sdd_branch_sugerida() {
  case "$1" in
    master|production|producao|prod) echo main ;;
    development|dev|devel|desenvolvimento|integracao|integration) echo develop ;;
    *) echo "" ;;
  esac
}

# sdd_pode_integrar <origem> <destino>: 0 se o Git Flow permite levar a
# origem ao destino (merge ou pull request).
sdd_pode_integrar() {
  local to td
  to="$(sdd_branch_tipo "$1")" || return 1
  td="$(sdd_branch_tipo "$2")" || return 1
  case "$to:$td" in
    feature:integracao|release:producao|release:integracao|hotfix:producao|hotfix:integracao|producao:integracao) return 0 ;;
  esac
  return 1
}

# ---------------------------------------------------------------------------
# Conventional Commits e versão
#
# A mensagem de commit segue https://www.conventionalcommits.org:
#   tipo(escopo)!: descrição
# O escopo, no SDD, é o número da feature (NNN). O tipo decide o impacto na
# versão SemVer: "!" ou um rodapé BREAKING CHANGE é major, feat é minor, fix e
# perf são patch, o resto (docs, chore, refactor, test, build, ci, style,
# revert) não muda a versão. Ver docs/referencia/versionamento.md.
# ---------------------------------------------------------------------------

# shellcheck disable=SC2034  # usado por quem carrega este arquivo
SDD_CC_TIPOS="feat fix docs chore refactor test perf build ci style revert"

# sdd_cc_valida <assunto>: 0 se o assunto segue o Conventional Commits do SDD.
sdd_cc_valida() {
  printf '%s' "$1" | grep -qE '^(feat|fix|docs|chore|refactor|test|perf|build|ci|style|revert)(\([A-Za-z0-9._/-]+\))?!?: [^[:space:]]'
}

# sdd_cc_commits <raiz> <base ou vazio>: um commit por linha, sem os merges,
# no formato "impacto<TAB>tipo<TAB>escopo<TAB>descrição", com impacto major,
# minor, patch ou nenhum, e escopo "-" quando não há (um campo vazio sumiria
# na leitura com IFS de tabulação). Sem base, lê o histórico inteiro de HEAD.
sdd_cc_commits() {
  local raiz="$1" base="${2:-}" faixa=HEAD
  [ -n "$base" ] && faixa="$base..HEAD"
  git -C "$raiz" log --no-merges --format='%s%x1f%b%x1e' "$faixa" 2>/dev/null | awk '
    BEGIN { RS = "\036"; FS = "\037" }
    {
      s = $1; b = $2
      sub(/^[\n\r]+/, "", s)
      if (s == "") next
      tipo = "outro"; escopo = ""; bang = 0; desc = s
      if (match(s, /^[a-z]+(\([^)]*\))?!?: /)) {
        cab = substr(s, 1, RLENGTH - 2); desc = substr(s, RLENGTH + 1)
        if (substr(cab, length(cab), 1) == "!") { bang = 1; cab = substr(cab, 1, length(cab) - 1) }
        p = index(cab, "(")
        if (p) { tipo = substr(cab, 1, p - 1); escopo = substr(cab, p + 1, length(cab) - p - 1) } else { tipo = cab }
      }
      imp = "nenhum"
      if (match(b, /BREAKING[ -]CHANGE: [^\n]*/)) {
        nota = substr(b, RSTART, RLENGTH); sub(/^BREAKING[ -]CHANGE: /, "", nota)
        desc = desc " (incompatível: " nota ")"
        bang = 1
      }
      if (bang) imp = "major"
      else if (tipo == "feat") imp = "minor"
      else if (tipo == "fix" || tipo == "perf") imp = "patch"
      if (escopo == "") escopo = "-"
      printf "%s\t%s\t%s\t%s\n", imp, tipo, escopo, desc
    }'
}

# sdd_semver_somar <versão> <major|minor|patch>: a versão seguinte, sem o
# sufixo de pré-lançamento.
sdd_semver_somar() {
  local base="${1%%[-+]*}" tipo="$2" ma mi pa
  IFS=. read -r ma mi pa <<< "$base"
  case "$tipo" in
    major) echo "$((ma + 1)).0.0" ;;
    minor) echo "$ma.$((mi + 1)).0" ;;
    *) echo "$ma.$mi.$((pa + 1))" ;;
  esac
}
