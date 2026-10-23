---
name: ajuda
description: Pergunte qual comando ou fluxo do SDD serve para a sua situação. Um roteador sobre os comandos deste plugin.
disable-model-invocation: true
---

# Ajuda do SDD

Ninguém lembra de todos os comandos, então pergunte.

Antes de afirmar o que um comando faz, ou recomendar pular uma etapa, leia o
`SKILL.md` daquele comando: os resumos aqui servem só para orientar. Rode
`sdd-status` para saber onde o projeto está antes de recomendar qualquer coisa.

Há dois tipos de comando: os de **fluxo**, que levam uma feature do pedido à
entrega, e os de **acompanhamento**, que mostram a situação e organizam o
trabalho.

## Antes de tudo: o projeto usa SDD?

Sem pasta `.sdd/`, o primeiro passo é **`/sdd:iniciar`**, uma vez por
repositório. Ele cria a estrutura, rascunha a **constituição** a partir do
código e injeta as regras no `CLAUDE.md` e no `AGENTS.md`.

## O fluxo de uma feature: pedido até a entrega

1. **`/sdd:especificar <mudança>`** (ou `/sdd:especificar B-NNN`, a partir do
   backlog) classifica o nível e escreve a spec: o quê e por quê. Tudo que não
   sabe vira `[PRECISA ESCLARECER]`.
2. **Bifurcação: há marcadores em aberto?** Sim: **`/sdd:clarificar`**. Não: siga.
3. **`/sdd:aprovar`** registra a aprovação da spec. Todo gate passa por ele.
4. **Bifurcação: qual o nível?** Nível 2: **`/sdd:planejar`** (plano e
   **contratos**, no subagent `arquiteto-de-contratos`) e **`/sdd:aprovar`**.
   Nível 1: pule.
5. **`/sdd:tarefas`** quebra em tarefas rastreáveis, e **`/sdd:aprovar`**.
6. **`/sdd:implementar`** faz a fase **red** (o `escritor-de-testes` escreve
   os testes a partir dos critérios) e para; **`/sdd:aprovar`** registra os
   testes; **`/sdd:implementar`** de novo faz a fase **green**, com os testes
   congelados.
7. **`/sdd:auditar`** passa a feature pelo `auditor-de-drift`. Obrigatório no
   nível 2. A decisão (aprovar, aprovar a **delta spec**, corrigir) se registra
   com **`/sdd:aprovar`**. No nível 1, dá para encerrar com `/sdd:aprovar`
   direto, sem auditoria.

## O acompanhamento: a situação e a organização do trabalho

| Pergunta | Comando |
|---|---|
| Como está o projeto? | **`/sdd:status`**: quadro com sprint, colunas, backlog e pendências |
| O que está esperando por mim? | **`/sdd:pendencias`**: aprovações, dúvidas, ADRs, deltas, backlog a triar |
| O que aconteceu enquanto eu estava fora? | **`/sdd:retomar`**: a história da feature desde a última vez |
| Onde guardo uma ideia para depois? | **`/sdd:backlog adicionar <ideia>`** |
| O que fazemos agora e o que fica para depois? | **`/sdd:backlog priorizar`** |
| O que entra nesta rodada de trabalho? | **`/sdd:sprint planejar`** |
| A sprint está no ritmo? | **`/sdd:sprint`** |
| Terminou o período | **`/sdd:sprint encerrar`** |

A rotina recomendada (começo do dia, planejamento, fim de sprint) está no guia
de acompanhamento do repositório do plugin (`docs/referencia/acompanhamento.md`).

## Qual nível?

| Sua mudança | Nível | Fluxo |
|---|---|---|
| Typo, formatação, refatoração coberta por testes | 0 | nenhum comando: faça direto |
| Correção de bug, mudança localizada | 1 | especificar, aprovar, tarefas, aprovar, implementar, aprovar |
| Feature nova, domínio, schema, contrato, segurança | 2 | o fluxo inteiro, com plano e auditoria |

## Situações comuns

| Situação | Comando |
|---|---|
| Não sei onde parei | `/sdd:retomar` |
| Quero mudar algo e não sei se precisa de spec | `/sdd:especificar`, que classifica o nível e diz se precisa |
| O agente parou dizendo que um teste está errado | volte à spec: corrija o critério, `/sdd:aprovar` de novo, e `/sdd:implementar` |
| Mudei a spec depois de aprovada | `/sdd:aprovar` de novo; os comandos seguintes recusam artefato alterado sem nova aprovação |
| Descobri no meio que a mudança é maior | `sdd-estado definir nivel=2`, depois `/sdd:clarificar` e `/sdd:planejar` |
| Tenho duas features em andamento | `sdd-estado usar NNN-slug` para alternar; `/sdd:status` mostra todas |
| A auditoria achou um desvio que eu quero manter | `/sdd:aprovar` com a decisão "aprovar a delta spec" |
| O agente achou um problema fora do escopo | ele já registrou no backlog; veja em `/sdd:backlog` |

## Vocabulário

Os termos (fonte de verdade, gate, aprovação, drift, delta spec, backlog,
sprint, constituição, contrato, rastreabilidade) estão definidos no
`GLOSSARIO.md` do repositório do plugin e na skill `metodologia`.
