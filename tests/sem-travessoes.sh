#!/usr/bin/env bash
# Falha se encontrar travessão (U+2014) em qualquer arquivo de texto do repositório.
# Uso: tests/sem-travessoes.sh
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ" || exit 1
TRAVESSAO="$(printf '\342\200\224')"
achados="$(grep -rnI --exclude-dir=.git -F "$TRAVESSAO" . || true)"
if [ -n "$achados" ]; then
  echo "Travessões encontrados. Reescreva as frases (ver CLAUDE.md, seção Sem travessões):"
  printf '%s\n' "$achados"
  exit 1
fi
echo "Nenhum travessão encontrado."
