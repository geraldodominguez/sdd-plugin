---
name: pendencias
description: A sua caixa de entrada no SDD. Lista tudo que espera uma decisão humana em todas as features (aprovações, dúvidas, ADRs, delta specs, backlog a triar, itens da sprint sem spec) e sugere por onde começar.
disable-model-invocation: true
allowed-tools: Bash(sdd-pendencias *), Bash(sdd-pendencias), Bash(sdd-status *), Bash(sdd-estado *), Read, Grep
---

# /sdd:pendencias

1. Rode `sdd-pendencias` e mostre a saída num bloco de código.
2. Se não houver nada, diga isso em uma linha e pare.
3. Recomende **por onde começar**, nesta ordem de prioridade:

   | Ordem | Tipo | Por quê |
   |---|---|---|
   | 1 | Aprovação de artefato alterado depois de aprovado | é um sinal de drift em andamento |
   | 2 | Aprovações e dúvidas de features da sprint atual | travam o compromisso da sprint |
   | 3 | Delta specs propostas | a spec está desatualizada até você decidir |
   | 4 | Itens da sprint sem spec | não há como implementar sem spec |
   | 5 | ADRs propostos | decisões que outras features podem herdar |
   | 6 | Backlog a triar | importante, mas raramente urgente |

   Para cada recomendação, diga o comando exato (`/sdd:aprovar` com a feature
   ativa certa, `/sdd:clarificar`, `/sdd:especificar B-NNN`, `/sdd:backlog priorizar`).
   Se for preciso trocar de feature, diga o `sdd-estado usar NNN-slug` antes.

Não altere nada.
