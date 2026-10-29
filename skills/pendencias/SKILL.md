---
name: pendencias
description: A sua caixa de entrada no SDD. Lista tudo que espera uma decisão humana (incidentes, releases paradas, aprovações, revisões de segurança, dúvidas, delta specs, consolidações, ADRs, backlog a triar, itens da sprint sem spec, artefatos fora do padrão, Git Flow) e sugere por onde começar.
disable-model-invocation: true
allowed-tools: Bash(sdd-gitflow *), Bash(sdd-pendencias *), Bash(sdd-pendencias), Bash(sdd-status *), Bash(sdd-estado *), Bash(sdd-release *), Bash(sdd-incidente *), Read, Grep
---

# /sdd:pendencias

1. Rode `sdd-pendencias` e mostre a saída num bloco de código.
2. Se não houver nada, diga isso em uma linha e pare.
3. Recomende **por onde começar**, nesta ordem de prioridade:

   | Ordem | Tipo | Por quê |
   |---|---|---|
   | 1 | Incidentes S1 e S2 | produção afetada agora |
   | 2 | Releases esperando aceite, go/no-go ou conclusão | há entrega parada no meio do caminho |
   | 3 | Aprovação de artefato alterado depois de aprovado | é sinal de drift em andamento |
   | 4 | Aprovações, dúvidas e revisões de segurança de features da sprint | travam o compromisso da sprint |
   | 5 | Delta specs propostas | a spec está desatualizada até você decidir |
   | 6 | Spec do sistema não consolidada | quem ler `sistema/` vai ver um comportamento antigo |
   | 7 | Prontas fora de release, itens da sprint sem spec | trabalho feito ou combinado que não anda |
   | 8 | Git Flow: feature pronta não integrada em `develop`, release com o go fora de `main`, branch fora do padrão | trabalho pronto que não chega a quem vai usá-lo |
   | 9 | ADRs propostos, incidentes sem post-mortem | decisões e lições que outras features herdam |
   | 10 | Artefatos fora do padrão | cada agente que inventa um lugar espalha a verdade; `/sdd:iniciar --adotar` os traz de volta |
   | 11 | Backlog a triar | importante, mas raramente urgente |

   Para cada recomendação, diga o comando exato (`/sdd:aprovar` com a feature
   ativa certa, `/sdd:clarificar`, `/sdd:especificar B-NNN`, `/sdd:backlog priorizar`,
   `sdd-gitflow integrar NNN-slug`, `/sdd:iniciar --adotar`).
   Se for preciso trocar de feature, diga o `sdd-estado usar NNN-slug` antes.

Não altere nada.
