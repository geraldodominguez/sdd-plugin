# /sdd:ajuda

## O que faz

Diz qual comando ou fluxo do SDD serve para a situação em que você está, entre
os comandos de fluxo (que levam uma feature do pedido à entrega) e os de
acompanhamento (que mostram a situação e organizam o trabalho). Ela
lê o estado do projeto antes de recomendar e confere o `SKILL.md` de um comando
antes de afirmar o que ele faz, em vez de responder de memória.

## Quando usar

Você digita `/sdd:ajuda`; o agente não a usa por conta própria. Use quando não
lembrar qual comando vem agora, quando cair numa situação fora do comum (teste
que parece errado, mudança que cresceu no meio) ou para ver o mapa inteiro.

| Sua dúvida | Onde ir |
|---|---|
| "Onde eu parei?" | [status](status.md), que é mais direto |
| "Que comando serve para isto?" | `ajuda` |
| "Como se escreve um bom critério?" | [metodologia](metodologia.md) |
| "O que depende de mim?" | [pendencias](pendencias.md) |

## O mapa que ela carrega

O **fluxo principal** (especificar, clarificar, planejar, tarefas, implementar,
auditar, com o aprovar em cada gate), as **bifurcações** que encurtam esse
fluxo (há marcadores em aberto? qual o nível?), os **comandos de
acompanhamento** (status, pendencias, retomar, backlog, sprint) e uma tabela de
situações comuns com o comando para cada uma.

## Está funcionando se

- A recomendação considera a fase em que o projeto está de fato, não uma suposição.
- Ela indica um comando, não três.
- Quando a resposta é "não precisa de comando" (nível 0), ela diz isso.

## Onde se encaixa

Uso avulso, a qualquer momento. É o roteador sobre todos os outros comandos e
o ponto de partida quando você está perdido. Vizinha: [status](status.md),
porque a ajuda começa olhando o estado.
