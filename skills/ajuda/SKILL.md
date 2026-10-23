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

Um **fluxo** é um caminho pelos comandos. Quase todo trabalho segue o **fluxo
principal**. Os **níveis de rigor** decidem quanto desse fluxo percorrer.

## Antes de tudo: o projeto usa SDD?

Sem pasta `.sdd/`, o primeiro passo é **`/sdd:iniciar`**, uma vez por
repositório. Ele cria a estrutura, rascunha a **constituição** a partir do
código e injeta as regras no `CLAUDE.md` e no `AGENTS.md`.

## O fluxo principal: pedido até a entrega

1. **`/sdd:especificar <mudança>`** classifica o nível e escreve a spec: o quê
   e por quê, com requisitos, critérios de aceitação e escopo. Tudo que não
   sabe vira `[PRECISA ESCLARECER]`.
2. **Bifurcação: há marcadores em aberto?**
   - **Sim:** **`/sdd:clarificar`** pergunta, com opções e uma recomendação,
     e atualiza a spec.
   - **Não:** siga.
3. **Bifurcação: qual o nível?**
   - **Nível 2:** **`/sdd:planejar`** desenha o como e os **contratos**, no
     subagent `arquiteto-de-contratos`.
   - **Nível 1:** pule o plano.
4. **`/sdd:tarefas`** quebra em tarefas pequenas e rastreáveis.
5. **`/sdd:implementar`** roda o TDD em duas fases: **red**, em que o
   subagent `escritor-de-testes` escreve os testes só a partir dos critérios,
   e **green**, em que a sessão principal implementa com os testes congelados.
6. **`/sdd:auditar`** passa a feature por um auditor independente, o
   `auditor-de-drift`. Obrigatório no nível 2, opcional no nível 1. Você decide:
   aprovar, aprovar a **delta spec** ou corrigir o código.

Cada passo termina num **gate**: o agente apresenta o artefato e para.

## Qual nível?

| Sua mudança | Nível | Fluxo |
|---|---|---|
| Typo, formatação, refatoração coberta por testes | 0 | Nenhum comando: faça direto |
| Correção de bug, mudança localizada | 1 | especificar, tarefas, implementar |
| Feature nova, domínio, schema, contrato, segurança | 2 | o fluxo inteiro |

## Situações comuns

| Situação | Comando |
|---|---|
| Não sei onde parei | `/sdd:status` |
| Quero mudar algo e não sei se precisa de spec | `/sdd:especificar`, que classifica o nível e diz se precisa |
| O agente parou dizendo que um teste está errado | Volte à spec: corrija o critério, aprove, e rode `/sdd:implementar` de novo |
| Descobri no meio que a mudança é maior | `sdd-estado definir nivel=2`, depois `/sdd:clarificar` e `/sdd:planejar` |
| Tenho duas features em andamento | `sdd-estado usar NNN-slug` para alternar |
| A auditoria achou um desvio que eu quero manter | Aprove a delta spec proposta em `auditoria.md` |

## Vocabulário

Os termos (fonte de verdade, gate, drift, delta spec, constituição, contrato,
rastreabilidade) estão definidos no `GLOSSARY.md` do repositório do plugin e na
skill `metodologia`.
