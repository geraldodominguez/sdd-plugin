---
name: status
description: A situação do projeto num quadro. Mostra a sprint atual e o progresso, as features em cada coluna (especificação, planejamento, implementação, auditoria), o topo do backlog e quanto está esperando por você, e diz qual comando rodar em seguida.
argument-hint: "[NNN-slug para o detalhe de uma feature]"
disable-model-invocation: true
allowed-tools: Bash(sdd-status *), Bash(sdd-status), Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(sdd-sprint *), Bash(sdd-pendencias *)
---

# /sdd:status

Argumentos: `$ARGUMENTS`

1. Rode `sdd-status` (ou `sdd-status <NNN-slug>` se veio uma feature nos
   argumentos) e mostre a saída num bloco de código.

2. Acrescente uma **leitura** de no máximo quatro linhas:
   - **Sprint:** no ritmo ou atrasada, comparando o progresso com os dias que faltam.
   - **Gargalo:** a coluna onde as features estão paradas, e por quê (esperando
     aprovação, com dúvidas, sem spec).
   - **Esperando você:** a quantidade, com `/sdd:pendencias` para o detalhe.
   - **Próximo passo:** **um** comando.

3. Para escolher o próximo passo, use esta ordem:

| Situação | Próximo comando |
|---|---|
| sem `.sdd/` | `/sdd:iniciar` |
| artefato alterado depois de aprovado | `/sdd:aprovar` na feature (ou reverter a mudança) |
| feature ativa esperando aprovação | `/sdd:aprovar` |
| feature ativa em `especificacao` com dúvidas | `/sdd:clarificar` |
| feature ativa em `plano` sem `plano.md` | `/sdd:planejar` |
| feature ativa em `tarefas` sem `tarefas.md` | `/sdd:tarefas` |
| feature ativa em `red` ou `green` | `/sdd:implementar` |
| feature ativa em `green` com todas as tarefas feitas | `/sdd:auditar` (ou `/sdd:aprovar` no nível 1) |
| item da sprint sem spec | `/sdd:especificar B-NNN` |
| nenhuma sprint e backlog com itens | `/sdd:sprint planejar` |
| nada em andamento | `/sdd:especificar <mudança>` ou `/sdd:backlog` |

Não altere nada.
