# Mapa global e permanente da arquitetura

Pedidos para manter um `ARCHITECTURE_MAP.md` (ou equivalente) do sistema
inteiro, atualizado a cada feature, estão fora do escopo.

## Por que está fora do escopo

Um mapa global vira uma segunda fonte de verdade que envelhece mais rápido do
que o código e que ninguém revisa. É mais um lugar para o drift morar.

O plugin gera contexto **por feature** (`contexto.md`), restrito ao que a
mudança toca, com caminho e linha. O que dura vai para a constituição e para os
ADRs, que são revisados quando mudam.
