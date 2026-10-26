# Guia do desenvolvedor: do zero à produção

Este guia é para quem vai trabalhar num projeto com SDD. Ele cobre a instalação,
a primeira configuração, o dia a dia de uma feature, a entrega e o que fazer
quando algo quebra em produção. Cada seção diz **quando** usar cada comando e
**o que você decide** em cada momento.

## Sumário

1. [Antes de começar: o modelo mental](#1-antes-de-começar-o-modelo-mental)
2. [Instalação](#2-instalação)
3. [Preparar o repositório](#3-preparar-o-repositório)
4. [O dia a dia de uma feature](#4-o-dia-a-dia-de-uma-feature)
5. [Entregando: a release](#5-entregando-a-release)
6. [Quando algo quebra em produção](#6-quando-algo-quebra-em-produção)
7. [Organizando o trabalho: backlog e sprint](#7-organizando-o-trabalho-backlog-e-sprint)
8. [Comandos por momento](#8-comandos-por-momento)
9. [O que o plugin impede, e por quê](#9-o-que-o-plugin-impede-e-por-quê)
10. [Problemas comuns](#10-problemas-comuns)

---

## 1. Antes de começar: o modelo mental

Quatro ideias explicam o plugin inteiro.

**A spec é a fonte de verdade.** Antes de mudar comportamento, você escreve (ou
aprova) o que deve mudar. O código vem depois e é conferido contra a spec. Se
os dois divergem, a correção começa na spec.

**Cada etapa termina num gate.** O agente prepara o artefato e para. Você
aprova (`/sdd:aprovar`, ou `/sdd:release` na entrega) e só então o fluxo segue.
A aprovação fica registrada com o hash do que você aprovou: se o artefato mudar
depois, o processo percebe.

**Quem faz não revisa.** Os testes são escritos por um subagent que não vê o
código; a segurança e a auditoria são feitas por subagents que não
participaram da implementação. Cada um roda com contexto próprio.

**O rigor acompanha o risco.** Corrigir um typo não exige spec; uma feature de
pagamento exige o fluxo inteiro. O nível de rigor (0, 1 ou 2) decide quanto do
processo uma mudança percorre.

E duas pastas que você vai consultar sempre:

| Pasta | Responde |
|---|---|
| `specs/NNN-slug/` | o que uma mudança alterou, por quê, e quem aprovou |
| `sistema/<capacidade>.md` | o que o sistema faz **hoje** |

## 2. Instalação

No Claude Code:

```bash
claude plugin marketplace add geraldodominguez/sdd-plugin
claude plugin install sdd@sdd-plugin
```

Confira com `/sdd:status` dentro de um projeto qualquer: deve responder que o
projeto ainda não usa SDD.

Requisitos: `bash` e `git`. No Windows, o Git for Windows (o Claude Code roda os
hooks no Git Bash). `jq` ou `python3` são opcionais. Detalhes em
[instalação e portabilidade](portabilidade.md).

**Configure seu nome no git** (`git config user.name`) em cada máquina: ele é o
autor registrado nas suas aprovações.

## 3. Preparar o repositório

Uma vez por repositório, normalmente feito pelo tech lead:

```
/sdd:iniciar
```

| O agente faz | Você decide |
|---|---|
| cria `.sdd/`, `specs/`, `sistema/`, `docs/adr/` | o nível padrão (1 ou 2) e a proteção (`leve` ou `estrita`) |
| lê o código e rascunha a **constituição** só com o que observou | revisa e completa as regras: stack, arquitetura, testes, segurança, ambientes, operação |
| propõe as **áreas sensíveis** e os comandos (teste, lint, segurança, deploy) | confirma ou corrige no `.sdd/config.yml` |
| injeta as regras do SDD no `CLAUDE.md` e no `AGENTS.md` | nada |

Depois, ainda uma vez:

```
/sdd:pipeline
```

gera o CI/CD que confere o processo em todo push e só implanta em produção com
o go registrado. Num sistema que já está em produção, comece também a
**spec do sistema** pela área que mais muda: `/sdd:sistema mapear`.

Faça commit de tudo. O `.sdd/estado` (sua feature ativa) já fica fora do git.

## 4. O dia a dia de uma feature

### 4.1 Começar: especificar

**Quando:** você vai mudar comportamento observável.

```
/sdd:especificar permitir exportar o relatório de vendas em CSV
/sdd:especificar B-014                 # a partir de um item do backlog
```

O agente classifica o nível e pede sua confirmação, escolhe a capacidade
(`sistema/`), decide se a revisão de segurança será obrigatória, e escreve a
spec. Tudo que ele não sabe vira `[PRECISA ESCLARECER]`.

**Sua parte:** ler a spec e responder "é isso que eu quero?". Se o agente disse
"nível 0", ele faz a mudança direto, sem feature.

### 4.2 Esclarecer e aprovar a spec

**Quando:** a spec tem marcadores, ou você sente que está ambígua.

```
/sdd:clarificar
/sdd:aprovar
```

O `/sdd:clarificar` faz até cinco perguntas por rodada, com opções e uma
recomendação. O `/sdd:aprovar` mostra o resumo e pede seu "sim".

### 4.3 Planejar (só nível 2)

```
/sdd:planejar
/sdd:aprovar
```

Você recebe a abordagem, os contratos, as dependências novas, as **ameaças
previstas** e o **plano de rollback**. Aprove ou peça ajustes.

### 4.4 Tarefas

```
/sdd:tarefas
/sdd:aprovar
```

Tarefas pequenas, cada uma ligada aos requisitos que atende.

### 4.5 Implementar: duas rodadas

```
/sdd:implementar      # fase red: o escritor-de-testes escreve os testes
/sdd:aprovar          # você aprova os testes (eles ficam congelados)
/sdd:implementar      # fase green: o código, tarefa por tarefa
```

| Durante a fase green, se... | O agente |
|---|---|
| um teste parece errado | para e pergunta: corrigir a spec ou devolver ao escritor de testes |
| aparece algo fora do escopo | registra no backlog e segue |
| um contrato precisa mudar | para e propõe voltar ao plano |
| a mudança tocou uma área sensível | avisa que a revisão de segurança passou a ser obrigatória |

Commits citam a tarefa: `feat(004): T-002 valida token expirado`. O hook
recusa commit sem isso nas fases de construção e revisão.

### 4.6 Revisar

```
/sdd:seguranca        # nível 2, ou área sensível
/sdd:aprovar          # aprovar, aceitar o risco, ou corrigir
/sdd:auditar          # nível 2 (opcional no 1)
/sdd:aprovar          # aprovar, aprovar a delta spec, ou corrigir
```

No nível 1 sem segurança obrigatória, a entrega é direta: `/sdd:aprovar` no green.

### 4.7 Pronta

Quando a feature fica pronta, o `/sdd:aprovar` conduz a **consolidação** na spec
do sistema: o agente atualiza `sistema/<capacidade>.md` para descrever o
comportamento vigente e mostra o diff para você confirmar. A feature agora
espera a próxima release.

### 4.8 Resumo do fluxo de uma feature

| Nível 1 | Nível 2 |
|---|---|
| `/sdd:especificar` | `/sdd:especificar` |
| (`/sdd:clarificar`) | `/sdd:clarificar` |
| `/sdd:aprovar` | `/sdd:aprovar` |
| | `/sdd:planejar`, `/sdd:aprovar` |
| `/sdd:tarefas`, `/sdd:aprovar` | `/sdd:tarefas`, `/sdd:aprovar` |
| `/sdd:implementar`, `/sdd:aprovar`, `/sdd:implementar` | `/sdd:implementar`, `/sdd:aprovar`, `/sdd:implementar` |
| (`/sdd:seguranca`, se área sensível) | `/sdd:seguranca`, `/sdd:aprovar` |
| `/sdd:aprovar` (entrega) | `/sdd:auditar`, `/sdd:aprovar` |

## 5. Entregando: a release

**Quando:** há features prontas e é hora de levá-las à produção.

```
/sdd:release preparar
```

| O agente faz | Você decide |
|---|---|
| lista as prontas e propõe o conjunto | quais entram |
| sugere a versão (major, minor ou patch) | a versão |
| chama o `testador-de-sistema`: regressão, ponta a ponta, RNFs | o que fazer com falhas: corrigir ou tirar a feature |
| escreve o roteiro de homologação em linguagem de negócio e as notas | quem vai homologar |

```
/sdd:release homologar     # implanta em homologação e entrega o roteiro
/sdd:release aceitar       # quem homologou aprova (ou reprova uma feature)
/sdd:release implantar     # plano de implantação e rollback; você diz go ou no-go
/sdd:release concluir      # depois da verificação em produção
```

Se a implantação der errado: `/sdd:release reverter`, que executa o rollback do
plano com sua confirmação, e `/sdd:incidente abrir`.

Com o pipeline gerado, a implantação em produção acontece pela tag `vX.Y.Z`, e
o CI se recusa a implantar sem o go registrado.

## 6. Quando algo quebra em produção

```
/sdd:incidente abrir o link de redefinição está sendo aceito duas vezes
```

| Passo | O que acontece |
|---|---|
| Registrar | o agente propõe a severidade (S1 a S4) e tenta achar a feature e a release de origem |
| Mitigar | em S1 e S2, primeiro parar o impacto: rollback, desligar a função, contorno |
| Hotfix | `/sdd:incidente hotfix`: uma feature de correção que **começa na fase red**, com o teste que reproduz o incidente; a spec é escrita depois, mas a feature não fica pronta sem ela |
| Entregar | release de correção (versão patch), com homologação expressa |
| Post-mortem | sem culpados: causa raiz, qual etapa do processo deixou passar, ações no backlog |

## 7. Organizando o trabalho: backlog e sprint

| Quando | Comando |
|---|---|
| surgiu uma ideia ou pedido para depois | `/sdd:backlog adicionar <ideia>` |
| toda semana, ou antes de planejar | `/sdd:backlog priorizar` |
| começo do período | `/sdd:sprint planejar` |
| meio do período | `/sdd:sprint` |
| fim do período | `/sdd:sprint encerrar` |

Regra útil: ideia nova vai para o backlog, não para a sprint em andamento.

## 8. Comandos por momento

| Momento | Comando |
|---|---|
| começo do dia | `/sdd:status`, `/sdd:pendencias` |
| voltar a uma feature depois de um tempo | `/sdd:retomar` |
| não sei qual comando usar | `/sdd:ajuda` |
| quero mudar comportamento | `/sdd:especificar` |
| terminou uma fase | `/sdd:aprovar` |
| quero saber o que o sistema faz numa área | `/sdd:sistema ver <capacidade>` |
| hora de entregar | `/sdd:release` |
| quebrou em produção | `/sdd:incidente` |
| configurar o CI/CD | `/sdd:pipeline` |

Comandos de terminal para casos pontuais (todos aceitam `--ajuda`):

| Caso | Comando |
|---|---|
| trocar de feature | `sdd-estado usar NNN-slug` |
| desistir de uma feature | `sdd-estado cancelar --motivo "..."` |
| reabrir uma feature pronta | `sdd-estado reabrir --motivo "..." [--fase green]` |
| subir o nível no meio do caminho | `sdd-estado definir nivel=2` |
| conferir uma aprovação | `sdd-estado aprovado spec.md` |
| ver a história de uma feature | `sdd-estado historico` |
| rodar o que o CI roda | `sdd-verificar` |

Referência completa em [utilitários](utilitarios.md).

## 9. O que o plugin impede, e por quê

| Tentativa | O que acontece | Por quê |
|---|---|---|
| editar um teste depois da fase red | o hook bloqueia | um teste "consertado" para passar não prova nada |
| editar o `historico.md` ou o `estado` | o hook bloqueia | seria forjar uma aprovação |
| `sdd-estado definir fase=pronta` | recusado | só a aprovação leva a pronta, e ela confere tudo |
| deixar pronta uma feature com a spec alterada depois de aprovada | recusado, com a lista do que reaprovar | a spec aprovada é a que vale |
| entregar um hotfix sem spec | recusado | o hotfix é rápido, mas deixa rastro |
| reabrir uma feature em produção | recusado | mudança nova é feature nova; defeito é incidente |
| implantar pela tag sem go | o pipeline falha | a decisão de ir para produção é humana |
| commit sem `T-XXX` durante a implementação | o hook bloqueia | rastreabilidade do commit à tarefa |

Os hooks são trilhos contra deslizes, não um sandbox; o pipeline é a garantia
determinística. Ver [proteção por hooks](protecao-por-hooks.md).

## 10. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| "spec.md não está aprovado ou mudou depois da aprovação" | alguém editou a spec depois de aprovar | `git diff` para ver a mudança; aprove de novo ou reverta |
| "teste alterado depois da aprovação" | um teste da feature mudou depois da fase red | se foi intencional, volte à spec, corrija o critério e reaprove os testes |
| o hook bloqueou um arquivo que não é teste | `globs_de_teste` amplo demais | ajuste no `.sdd/config.yml` |
| `sdd-rastrear` diz que um CA não tem teste | marca sem o número da feature | use `sdd:004:CA-003`, não `sdd:CA-003` |
| "a feature X está em pronta" ao tentar mudar a fase | ela já saiu da construção | `sdd-estado reabrir --motivo` |
| o CI falha em `sdd-verificar` | aprovação invalidada ou lacuna | rode `sdd-verificar` localmente e siga a lista |
| `sdd-*: command not found` | plugin fora da sessão | `/reload-plugins`; no Windows, confirme o Git Bash |

Mais em [FAQ e projetos existentes](projetos-existentes.md).
