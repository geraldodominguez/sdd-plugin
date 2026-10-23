#!/usr/bin/env bash
# guarda-edicoes.sh: hook PreToolUse para Edit, Write, MultiEdit e NotebookEdit.
#
# Decide, pela fase da feature ativa (.sdd/estado) e pela proteção configurada
# (.sdd/config.yml), se o arquivo pode ser editado agora.
#
# Saída: 0 permite, 2 bloqueia (o stderr é mostrado ao agente).
# Qualquer falha inesperada permite a edição: o hook protege contra deslizes,
# não é um mecanismo de segurança.
#
# Regras (detalhe em docs/referencia/protecao-por-hooks.md):
#   desligada  nada é bloqueado
#   leve       fase green: bloqueia arquivos de teste
#   estrita    especificacao, clarificacao, tarefas: só artefatos
#              plano: artefatos e globs_de_contrato
#              red: artefatos, testes e globs_de_contrato
#              green: bloqueia testes e globs_de_contrato
#              auditoria: só artefatos
#   Sem feature ativa, ou com a fase concluida, nada é bloqueado.
#   Em qualquer fase (proteção leve ou estrita), históricos e arquivos de estado
#   não podem ser editados à mão: só os utilitários os escrevem.

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/sdd-comum.sh
. "$AQUI/../lib/sdd-comum.sh" || exit 0

ENTRADA="$(cat 2>/dev/null || true)"
[ -n "$ENTRADA" ] || exit 0

RAIZ="${CLAUDE_PROJECT_DIR:-}"
[ -n "$RAIZ" ] || RAIZ="$(sdd_json_campo "$ENTRADA" cwd)"
[ -n "$RAIZ" ] || exit 0
RAIZ="${RAIZ//\\//}"

# Projeto sem SDD: o plugin não interfere.
[ -d "$RAIZ/.sdd" ] || exit 0

PROTECAO="$(sdd_config "$RAIZ" protecao leve)"
[ "$PROTECAO" = "desligada" ] && exit 0

ARQUIVO="$(sdd_json_campo "$ENTRADA" file_path notebook_path path)"
[ -n "$ARQUIVO" ] || exit 0
ARQUIVO="${ARQUIVO//\\//}"
REL="$(sdd_caminho_relativo "$RAIZ" "$ARQUIVO")"

# Arquivo fora do projeto (o caminho continua absoluto): não é da nossa conta.
case "$REL" in
  /*|[A-Za-z]:/*) exit 0 ;;
esac

PASTA_SPECS="$(sdd_config "$RAIZ" pasta_specs specs)"

# Histórico e estado são escritos só pelos utilitários. Editar à mão permitiria
# forjar uma aprovação ou pular uma fase, em qualquer fase.
case "$REL" in
  "$PASTA_SPECS"/*/historico.md|"$PASTA_SPECS"/*/estado|.sdd/historico.md|.sdd/estado)
    {
      echo "SDD (proteção $PROTECAO) bloqueou a edição de '$REL'."
      echo "Histórico e estado são gravados só pelos utilitários (sdd-estado, sdd-backlog, sdd-sprint). Aprovações passam pelo /sdd:aprovar, que é do usuário."
      echo "Não contorne este bloqueio. Explique a situação ao usuário e pergunte como seguir."
    } >&2
    exit 2
    ;;
esac

FEATURE="$(sdd_estado_ler "$RAIZ" feature)"
FASE="$(sdd_estado_ler "$RAIZ" fase)"
[ -n "$FEATURE" ] || exit 0
case "$FASE" in ""|concluida) exit 0 ;; esac

GLOBS_TESTE="$(sdd_config "$RAIZ" globs_de_teste "$SDD_GLOBS_TESTE_PADRAO")"
GLOBS_CONTRATO="$(sdd_config "$RAIZ" globs_de_contrato "")"

e_artefato() {
  case "$1" in
    .sdd/*|"$PASTA_SPECS"/*|docs/*|CLAUDE.md|AGENTS.md|.claude/*) return 0 ;;
  esac
  return 1
}
e_teste() { sdd_casa_glob "$1" "$GLOBS_TESTE"; }
e_contrato() { [ -n "$GLOBS_CONTRATO" ] && sdd_casa_glob "$1" "$GLOBS_CONTRATO"; }

bloquear() {
  {
    echo "SDD (proteção $PROTECAO) bloqueou a edição de '$REL' na fase '$FASE' da feature $FEATURE."
    echo "$1"
    echo "Não contorne este bloqueio. Explique a situação ao usuário e pergunte como seguir."
  } >&2
  exit 2
}

MSG_TESTES="Na fase green os testes estão congelados: implemente o código para fazê-los passar. Se o teste estiver errado, a correção começa pela spec, com aprovação humana."

# Artefatos SDD são sempre editáveis.
e_artefato "$REL" && exit 0

if [ "$PROTECAO" = "leve" ]; then
  if [ "$FASE" = "green" ] && e_teste "$REL"; then
    bloquear "$MSG_TESTES"
  fi
  exit 0
fi

# PROTECAO = estrita
case "$FASE" in
  especificacao|clarificacao|tarefas)
    bloquear "Antes da implementação só se editam artefatos (.sdd/, $PASTA_SPECS/, docs/). Termine a fase atual e siga o fluxo até /sdd:implementar."
    ;;
  plano)
    e_contrato "$REL" && exit 0
    bloquear "Na fase plano só se editam artefatos e contratos (globs_de_contrato). A implementação começa em /sdd:implementar."
    ;;
  red)
    e_teste "$REL" && exit 0
    e_contrato "$REL" && exit 0
    bloquear "Na fase red só se escrevem testes (e contratos). O código de produção vem na fase green."
    ;;
  green)
    e_teste "$REL" && bloquear "$MSG_TESTES"
    e_contrato "$REL" && bloquear "Os contratos ficam congelados durante a implementação. Mudar um contrato exige voltar ao plano, com aprovação humana."
    exit 0
    ;;
  auditoria)
    bloquear "Na fase auditoria nada é corrigido: o auditor só registra achados. Para corrigir, o usuário decide voltar à fase green."
    ;;
esac

exit 0
