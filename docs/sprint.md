# /sdd:sprint

## O que faz

Organiza o trabalho em **sprints**: períodos com um objetivo e um compromisso
(as features e os itens de backlog que o time pretende concluir). Planeja com
você, mostra o andamento de cada item e faz a revisão no fim, devolvendo ao
backlog o que ficou. Ele propõe, mas o compromisso só entra com a sua
concordância.

## Quando usar

Você digita `/sdd:sprint`; o agente não o usa por conta própria.

| Momento | Digite |
|---|---|
| ver se a sprint está no ritmo | `/sdd:sprint` |
| começar um período de trabalho | `/sdd:sprint planejar` |
| fim do período | `/sdd:sprint encerrar` |

## Pré-requisitos

O [`/sdd:iniciar`](iniciar.md) rodado. Um backlog com itens ajuda no planejamento.

## A sprint

Cada sprint é um arquivo em `.sdd/sprints/`, com id padrão na semana ISO do
início (`2026-S44`):

| Parte | Conteúdo |
|---|---|
| Objetivo | uma frase com o resultado ("clientes recuperam o acesso sozinhos") |
| Início e fim | as datas (padrão: duas semanas) |
| Situação | planejada, ativa ou encerrada |
| Compromisso | features (`NNN-slug`) e itens de backlog (`B-NNN`) |
| Revisão | o resultado gerado no encerramento e as conclusões |

O andamento é calculado na hora a partir das features: fase de cada uma,
tarefas concluídas, o que espera aprovação e o que ainda não tem spec.

## Perguntas frequentes

**Quantos itens colocar numa sprint?**

Menos do que parece. Uma feature de nível 2 passa por spec, plano, tarefas,
testes e auditoria, e costuma ocupar boa parte de uma sprint de duas semanas.
Menos itens concluídos valem mais que muitos itens começados.

**Sou só eu no projeto. Sprint faz sentido?**

Faz, como compromisso consigo mesmo e como ritmo de revisão. Se não fizer, não
use: o resto do SDD funciona sem sprint.

## Está funcionando se

- O [status](status.md) mostra a sprint com progresso e dias restantes.
- No encerramento, cada item pendente tem um destino (próxima sprint, backlog, descarte).
- A revisão registra por que algo não foi entregue, não só que não foi.

## Onde se encaixa

Planejamento periódico, acima do fluxo principal: escolhe o que entra no
[especificar](especificar.md) a partir do [backlog](backlog.md). O mapa está na
[ajuda](ajuda.md), e a rotina está no
[guia de acompanhamento](referencia/acompanhamento.md).
