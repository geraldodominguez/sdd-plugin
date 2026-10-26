# /sdd:ajuda

## O que faz

Diz qual comando ou fluxo do SDD serve para a situação em que você está, entre
os comandos do fluxo da feature, da entrega, da manutenção em produção e do
acompanhamento do trabalho. Ela
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

Quatro grupos de comandos: o **fluxo da feature** (especificar, clarificar,
planejar, tarefas, implementar, segurança, auditar, com o aprovar em cada
gate), a **entrega** (sistema e release), a **manutenção** (incidente) e o
**acompanhamento** (status, pendências, retomar, backlog, sprint), mais o
pipeline. E uma tabela de situações comuns com o comando para cada uma.

## Está funcionando se

- A recomendação considera a fase em que o projeto está de fato, não uma suposição.
- Ela indica um comando, não três.
- Quando a resposta é "não precisa de comando" (nível 0), ela diz isso.

## Onde se encaixa

Uso avulso, a qualquer momento. É o roteador sobre todos os outros comandos e
o ponto de partida quando você está perdido. Vizinha: [status](status.md),
porque a ajuda começa olhando o estado.
