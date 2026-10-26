# /sdd:pendencias

## O que faz

É a sua caixa de entrada: lista, em todas as features, tudo que está esperando
uma **decisão humana**, e diz por onde começar. O agente não decide nenhum
desses itens por você; o comando só junta o que está espalhado em vários
arquivos.

## Quando usar

Você digita `/sdd:pendencias`; o agente não o usa por conta própria. Use no
começo do dia, antes de uma reunião de planejamento, ou quando o `/sdd:status`
mostrar "ESPERANDO VOCÊ".

## O que ele junta

| Tipo | Onde mora | Como se resolve |
|---|---|---|
| Incidente em aberto ou sem post-mortem | `incidentes/INC-NNN.md` | `/sdd:incidente` |
| Release esperando aceite, go/no-go ou conclusão | `releases/<versão>/` | `/sdd:release` |
| Aprovação pendente | artefato da fase sem aprovação, ou alterado depois de aprovado | `/sdd:aprovar` |
| Revisão de segurança devida | feature com segurança obrigatória e tarefas concluídas | `/sdd:seguranca` |
| Dúvida na spec | `[PRECISA ESCLARECER]` na `spec.md` | `/sdd:clarificar` |
| Delta spec proposta | `specs/NNN/delta-spec.md` com situação "proposta" | `/sdd:aprovar`, na fase de auditoria |
| Spec do sistema desatualizada | feature pronta ou além, não consolidada | `/sdd:sistema consolidar` |
| Pronta fora de release | feature pronta sem release | `/sdd:release preparar` |
| ADR proposto | `docs/adr/*.md` com situação "proposta" | revisar e mudar para "aceita" |
| Backlog a triar | item sem nível estimado | `/sdd:backlog priorizar` |
| Sprint sem spec | item da sprint atual que ainda é `B-NNN` | `/sdd:especificar B-NNN` |

A ordem sugerida começa por incidentes e releases paradas (produção e entrega),
passa por artefatos alterados depois de aprovados (um sinal de drift em
andamento) e termina no backlog (importante, mas raramente urgente).

## Está funcionando se

- Você não precisa abrir nenhum arquivo para saber o que depende de você.
- A lista diminui conforme você aprova, esclarece e prioriza.

## Onde se encaixa

Uso avulso, parte da rotina de acompanhamento (ver o
[guia de acompanhamento](referencia/acompanhamento.md)). Vizinhas:
[status](status.md), que mostra só a contagem, e [aprovar](aprovar.md), que
resolve a maior parte dos itens. O mapa está na [ajuda](ajuda.md).
