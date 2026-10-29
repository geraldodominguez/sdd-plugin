---
name: ajuda
description: Pergunte qual comando ou fluxo do SDD serve para a sua situação, do pedido à manutenção em produção. Um roteador sobre os comandos deste plugin.
disable-model-invocation: true
---

# Ajuda do SDD

Ninguém lembra de todos os comandos, então pergunte.

Antes de afirmar o que um comando faz, ou recomendar pular uma etapa, leia o
`SKILL.md` daquele comando: os resumos aqui servem só para orientar. Rode
`sdd-status` para saber onde o projeto está antes de recomendar qualquer coisa.

Os comandos se dividem em quatro grupos: **fluxo da feature** (do pedido à
feature pronta), **entrega** (da feature pronta à produção), **manutenção**
(o que acontece em produção) e **acompanhamento** (a situação e a organização
do trabalho).

## Antes de tudo: o projeto usa SDD?

Sem pasta `.sdd/`, o primeiro passo é **`/sdd:iniciar`**, uma vez por
repositório. Ele cria a estrutura, rascunha a **constituição** a partir do
código e injeta as regras no `CLAUDE.md` e no `AGENTS.md`. Logo depois, vale
rodar **`/sdd:pipeline`** para o CI conferir o processo.

Projeto que não nasceu com o plugin, ou com specs, planos, tarefas e ADRs
espalhados por outros agentes (`docs/specs/`, `tasks/`, `TODO.md`, `.kiro/`,
`.specify/`)? O mesmo **`/sdd:iniciar`** detecta, lê tudo e, com a sua
aprovação, traz para o padrão. Com o projeto já preparado, rode
**`/sdd:iniciar --adotar`** sempre que o `/sdd:pendencias` mostrar artefatos
"Fora do padrão". Cada feature adotada fica em transição até o usuário aprovar
o `transicao.md` com **`/sdd:aprovar`**; depois, continua de onde parou.

Todo projeto usa o mesmo **Git Flow**: `main`, `develop`, `feature/NNN-slug`,
`release/X.Y.Z` e `hotfix/X.Y.Z`. Os comandos criam as branches sozinhos
(`/sdd:especificar`, `/sdd:release`, `/sdd:incidente`); a situação aparece no
`/sdd:status`, e o `sdd-gitflow conferir` mostra o que está fora do padrão.
Detalhes em `docs/referencia/git-flow.md`.

Para quem pede um passo a passo, aponte o guia da situação:
`docs/referencia/projeto-novo.md` (repositório novo) ou
`docs/referencia/projeto-em-andamento.md` (projeto que já existe).

## Fluxo da feature: do pedido à feature pronta

1. **`/sdd:especificar <mudança>`** (ou `/sdd:especificar B-NNN`) classifica o
   nível, define a capacidade e escreve a spec. Dúvidas viram `[PRECISA ESCLARECER]`.
2. **`/sdd:clarificar`**, se houver dúvidas. Depois, **`/sdd:aprovar`** a spec.
3. Nível 2: **`/sdd:planejar`** (plano, contratos, ameaças, implantação) e **`/sdd:aprovar`**.
4. **`/sdd:tarefas`** e **`/sdd:aprovar`**.
5. **`/sdd:implementar`** faz a fase **red** e para; **`/sdd:aprovar`** os testes;
   **`/sdd:implementar`** de novo faz a fase **green**, com os testes congelados.
6. **`/sdd:seguranca`**, obrigatória no nível 2 e em área sensível, e **`/sdd:aprovar`** a decisão.
7. **`/sdd:auditar`**, obrigatória no nível 2, e **`/sdd:aprovar`** a decisão.
   No nível 1 sem segurança obrigatória, dá para entregar direto com `/sdd:aprovar` no green.
8. A feature fica **pronta**: o `/sdd:aprovar` conduz a consolidação na spec do
   sistema (**`/sdd:sistema`**).

## Entrega: da feature pronta à produção

**`/sdd:release`** conduz tudo, em gates:

| Passo | Comando | Gate |
|---|---|---|
| Agrupar prontas, versão, testes de sistema, roteiro, notas | `/sdd:release preparar` | testes de sistema aprovados |
| Implantar em homologação e entregar o roteiro | `/sdd:release homologar` | |
| Registrar o aceite de quem homologou | `/sdd:release aceitar` | aceite do negócio |
| Plano de implantação, rollback, go/no-go | `/sdd:release implantar` | go/no-go |
| Verificar e encerrar | `/sdd:release concluir` (ou `reverter`) | verificação |

## Manutenção: o que acontece em produção

| Situação | Comando |
|---|---|
| Algo quebrou em produção | **`/sdd:incidente abrir`**: severidade, mitigação, hotfix com spec retroativa, post-mortem |
| Mudança de comportamento numa feature que já está em produção | feature nova (`/sdd:especificar`), nunca reabrir |
| "O que o sistema faz em X?" | **`/sdd:sistema ver <capacidade>`** |
| Sistema antigo sem specs | **`/sdd:sistema mapear`**, área por área |

## Acompanhamento

| Pergunta | Comando |
|---|---|
| Como está o projeto? | **`/sdd:status`**: quadro com sprint, colunas, release, incidentes, backlog |
| O que está esperando por mim? | **`/sdd:pendencias`** |
| O que aconteceu enquanto eu estava fora? | **`/sdd:retomar`** |
| Onde guardo uma ideia para depois? | **`/sdd:backlog adicionar <ideia>`** |
| O que vem primeiro? | **`/sdd:backlog priorizar`** |
| O que entra neste período? | **`/sdd:sprint planejar`**, e **`/sdd:sprint`** para acompanhar |

O guia de rotina (diária, semanal, de sprint, de release) está em
`docs/referencia/acompanhamento.md` no repositório do plugin, e o ciclo inteiro
em `docs/referencia/ciclo-de-vida.md`.

## Qual nível?

| Sua mudança | Nível | Caminho |
|---|---|---|
| Typo, formatação, refatoração coberta por testes | 0 | faça direto; vai na próxima release |
| Correção de bug, mudança localizada | 1 | especificar, tarefas, implementar, (segurança), aprovar, release |
| Feature nova, domínio, schema, contrato, segurança | 2 | o fluxo inteiro |
| Problema em produção | hotfix | `/sdd:incidente` |

## Situações comuns

| Situação | O que fazer |
|---|---|
| Não sei onde parei | `/sdd:retomar` |
| O agente parou dizendo que um teste está errado | corrija o critério na spec, `/sdd:aprovar`, e `/sdd:implementar` |
| Mudei a spec depois de aprovada | `/sdd:aprovar` de novo |
| A mudança cresceu no meio | `sdd-estado definir nivel=2`, `/sdd:clarificar`, `/sdd:planejar` |
| Desisti de uma feature | `sdd-estado cancelar --motivo "..."` |
| A homologação reprovou uma feature | `/sdd:release aceitar` mostra como reprovar: ela volta ao green |
| Uma feature pronta precisa mudar antes da release | `sdd-estado reabrir --motivo "..."` |
| A auditoria achou um desvio que eu quero manter | `/sdd:aprovar` com a decisão "aprovar a delta spec" |
| A revisão de segurança achou um risco que o negócio aceita | `/sdd:aprovar` com a decisão "aceitar o risco", com dono e prazo |
| A implantação deu errado | `/sdd:release reverter` e `/sdd:incidente abrir` |
| O agente achou um problema fora do escopo | ele registrou no backlog; veja em `/sdd:backlog` |

## Vocabulário

Os termos (fonte de verdade, gate, aprovação, drift, delta spec, capacidade,
spec do sistema, release, homologação, go/no-go, hotfix, post-mortem) estão no
`GLOSSARIO.md` do repositório do plugin e na skill `metodologia`.
