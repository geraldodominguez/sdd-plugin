# Exemplos

Os arquivos que o SDD produz num projeto de verdade, para servir de referência
de **nível de detalhe**: specs curtas e precisas, planos que apontam para
requisitos, tarefas rastreáveis, uma auditoria com um achado real e o
acompanhamento (histórico, backlog e sprint).

## A feature

[`001-redefinicao-de-senha/`](001-redefinicao-de-senha/) é uma feature de
**nível 2** depois de passar por todas as fases, do jeito que fica em `specs/`.

| Arquivo | Fase | Escrito por |
|---|---|---|
| `contexto.md` | especificação | `mapeador-de-contexto` |
| `spec.md` | especificação e clarificação | sessão principal e usuário |
| `plano.md` | plano | `arquiteto-de-contratos` |
| `contratos/` | plano | `arquiteto-de-contratos` |
| `adr-0007-hash-do-token.md` | plano | `arquiteto-de-contratos`, aceito pelo usuário |
| `tarefas.md` | tarefas | sessão principal |
| `auditoria.md` | auditoria | `auditor-de-drift` |
| `estado` | todas | `sdd-estado` |
| `historico.md` | todas | `sdd-estado`, a cada aprovação e troca de fase |

Num projeto de verdade, o ADR ficaria em `docs/adr/0007-hash-do-token.md`. Aqui
ele está junto dos outros arquivos para facilitar a leitura.

Leia o `historico.md` de cima para baixo: ele conta a vida da feature, com cada
aprovação e o hash do que foi aprovado. Repare na reaprovação da spec no fim,
depois da delta spec da auditoria.

## O acompanhamento

| Arquivo | No projeto fica em | O que mostra |
|---|---|---|
| [`backlog.md`](backlog.md) | `.sdd/backlog.md` | itens abertos, promovidos (`[x]`), descartados (`[-]`) e uma pendência registrada pelo agente durante a implementação |
| [`sprint-2026-S44.md`](sprint-2026-S44.md) | `.sdd/sprints/2026-S44.md` | uma sprint encerrada, com o resultado gerado e as conclusões |

O projeto fictício é uma API em Node e TypeScript com PostgreSQL.
