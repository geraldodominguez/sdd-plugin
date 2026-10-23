# /sdd:clarificar

## O que faz

Faz uma rodada de perguntas sobre a spec ativa e incorpora as respostas antes
de qualquer decisão técnica. Ela não responde às próprias perguntas. Cada
pergunta vem com contexto, de duas a quatro opções e uma recomendação, mas a
escolha é sua.

## Quando usar

Você digita `/sdd:clarificar`; o agente não a usa por conta própria. Use quando
a spec tiver `[PRECISA ESCLARECER]` em aberto, ou quando você sentir que ela está
ambígua. Pode passar um foco: `/sdd:clarificar regras de expiração`.

## O que ela procura

| Tipo | Exemplo |
|---|---|
| Marcador | `[PRECISA ESCLARECER: quanto tempo o link vale?]` |
| Ambiguidade | "o sistema deve responder rápido" |
| Lacuna | um requisito sem critério para o caso de erro |
| Contradição | dois requisitos que não podem valer juntos, ou um que viola a constituição |

São no máximo cinco perguntas por rodada, priorizadas pelo que mais muda o
desenho da solução, e até três rodadas. Toda resposta fica no "Histórico de
clarificação" da spec.

## Perguntas frequentes

**Ela fez perguntas demais.**

Muitas rodadas costumam significar que a feature é grande demais. Considere
dividir em duas features menores.

## Está funcionando se

- As perguntas são as que um bom analista faria, não as óbvias.
- A recomendação vem com o porquê, em uma linha.
- Depois da rodada, os requisitos refletem as respostas, e o histórico mostra de onde veio cada mudança.

## Onde se encaixa

Segundo passo do fluxo principal, entre [especificar](especificar.md) e
[aprovar](aprovar.md). Se a spec já estava aprovada, qualquer mudança feita aqui
exige uma nova aprovação. O mapa está na [ajuda](ajuda.md).
