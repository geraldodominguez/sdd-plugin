# Exemplos

[`001-redefinicao-de-senha/`](001-redefinicao-de-senha/) mostra os artefatos
completos de uma feature de **nível 2**, do jeito que ficam em `specs/` depois de
passar por todas as fases.

| Arquivo | Fase | Escrito por |
|---|---|---|
| `contexto.md` | especificação | `mapeador-de-contexto` |
| `spec.md` | especificação e clarificação | sessão principal e usuário |
| `plano.md` | plano | `arquiteto-de-contratos` |
| `contratos/` | plano | `arquiteto-de-contratos` |
| `adr-0007-hash-do-token.md` | plano | `arquiteto-de-contratos`, aceito pelo usuário |
| `tarefas.md` | tarefas | sessão principal |
| `auditoria.md` | auditoria | `auditor-de-drift` |

O projeto fictício é uma API em Node e TypeScript com PostgreSQL. Use os
arquivos como referência de **nível de detalhe**: specs curtas e precisas,
planos que apontam para requisitos, tarefas rastreáveis e uma auditoria com um
achado real.

Num projeto de verdade, o ADR ficaria em `docs/adr/0007-hash-do-token.md`. Aqui
ele está junto dos outros arquivos para facilitar a leitura.
