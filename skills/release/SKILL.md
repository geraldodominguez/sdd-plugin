---
name: release
description: Leva as features prontas até a produção. Prepara a release (versão, testes de sistema, roteiro de homologação), registra o aceite do negócio, conduz o go/no-go com plano de implantação e rollback, acompanha a implantação e encerra com as notas de versão.
argument-hint: "[ver | preparar | homologar | aceitar | implantar | concluir | reverter]"
disable-model-invocation: true
allowed-tools: Bash(sdd-release *), Bash(sdd-release), Bash(sdd-estado *), Bash(sdd-sistema *), Bash(sdd-status *), Bash(sdd-verificar *), Bash(sdd-rastrear *), Bash(git log *), Bash(git tag *), Bash(git status *), Read, Write, Edit, Glob, Grep
---

# /sdd:release

Pedido: `$ARGUMENTS` (vazio significa ver a release em andamento)

Uma release agrupa features **prontas** e as leva por quatro gates humanos:
testes de sistema, aceite do negócio, go/no-go e verificação em produção. Tudo
fica em `releases/<versão>/`. A situação muda só pelo `sdd-release`.

```
preparacao -> homologacao -> aceita -> implantacao -> producao
```

## Ver (padrão)

Rode `sdd-release ver` (ou `sdd-release listar` sem release em andamento) e
mostre num bloco de código. Acrescente o próximo passo em uma linha.

## Preparar

1. **Escolha as features.** Liste as prontas fora de release
   (`sdd-estado listar`, fase `pronta`). Confira que cada uma está consolidada na
   spec do sistema (`sdd-sistema pendentes`); se não, diga para rodar
   `/sdd:sistema consolidar` antes. Proponha o conjunto ao usuário.
2. **Proponha a versão** com `sdd-release proxima <tipo>`:

   | Mudança | Tipo |
   |---|---|
   | algum contrato público quebrou (API, evento, schema consumido por outros) | major |
   | há capacidade nova ou comportamento novo | minor |
   | só correções | patch |

3. Com a confirmação: `sdd-release nova <versão> --objetivo "..."` e
   `sdd-release incluir <versão> <features...>`.
   Se a release leva a correção de um incidente (um hotfix), acrescente
   `--hotfix` ao `nova`: a versão é patch e a homologação pode ser expressa
   (um passo por critério do hotfix), mas continua com aceite e go.
4. **Testes de sistema.** Chame a ferramenta Agent com o subagent
   `testador-de-sistema`, passando: a pasta da release, as features incluídas
   (pastas em `specs/`), a pasta `sistema/`, o `comando_teste` e o
   `comando_teste_sistema`. Ele escreve e roda a regressão, os testes ponta a
   ponta dos fluxos afetados e as medições dos RNFs com número, e preenche
   `testes.md`. Com falha, mostre ao usuário e decida com ele: corrigir a feature
   (`sdd-release remover` e `sdd-estado reabrir --fase green`) ou seguir sem ela.
5. **Roteiro de homologação.** Escreva `homologacao.md` a partir dos critérios
   de aceitação de cada feature, **em linguagem de quem usa o sistema** (sem
   termos técnicos, sem nome de rota), um passo `H-NNN` por critério relevante,
   todos com resultado `pendente`. Preencha o ambiente e o responsável pelo
   aceite (pergunte quem é).
6. **Rascunhe as notas** (`notas.md`), em linguagem de negócio.
7. Diga ao usuário: "Rode `/sdd:release homologar` quando o ambiente de
   homologação estiver com esta versão."

## Homologar

1. Se houver `comando_deploy_homologacao`, pergunte se pode rodar e rode com
   confirmação. Senão, diga como implantar segundo a constituição.
2. `sdd-release homologar <versão>`. Ele recusa se faltar teste de sistema
   aprovado ou roteiro.
3. Entregue ao usuário o roteiro: quem homologa executa cada passo e marca
   `aprovado` ou `reprovado` em `homologacao.md` (você pode ajudar a marcar
   enquanto ele relata).

## Aceitar (o aceite do negócio)

| Resultado do roteiro | O que fazer |
|---|---|
| tudo aprovado | `sdd-release aceitar <versão> --por "Nome, papel"` com o nome de quem homologou, depois de confirmar com o usuário |
| algum passo reprovado | `sdd-release reprovar <versão> <feature> --motivo "..."`: a feature volta ao green e a release, à preparação. Pergunte antes se a release segue sem ela |

Nunca registre o aceite em nome de quem não homologou.

## Implantar (o go/no-go)

1. Escreva `implantacao.md` com o usuário: pré-requisitos (backup, segredos,
   migrations), passos, **verificação pós-implantação** e **rollback com
   critério objetivo de acionamento**. Use a seção "Ambientes e entrega" da
   constituição.
2. Revise as notas.
3. Apresente o plano e pergunte: **"Go ou no-go?"**. Só com "go":
   `sdd-release autorizar <versão> --nota "..."`.
4. Conduza a implantação seguindo o plano. Se houver `comando_deploy_producao`,
   rode **só com confirmação explícita** neste momento; se o deploy é feito pelo
   pipeline (tag `vX.Y.Z`), diga ao usuário para criar a tag: o pipeline confere
   o go com `sdd-release pode-implantar`.
5. Rode a verificação (`comando_verificacao_producao` ou os passos do plano).

## Concluir ou reverter

| Verificação | O que fazer |
|---|---|
| passou | `sdd-release concluir <versão> --verificacao "o que foi verificado"`; sugira `git tag v<versão>` se ainda não existir |
| falhou, critério de rollback atingido | execute o rollback do plano com confirmação, `sdd-release reverter <versão> --motivo "..."` e sugira `/sdd:incidente abrir` |

## Não faça

- Não implante sem o go registrado.
- Não marque passos de homologação como aprovados sem o relato de quem homologou.
- Não pule os testes de sistema "porque cada feature já tem testes".

## Pronto quando

- A release está em produção, com testes de sistema, aceite, go e verificação no `historico.md` da release, e as notas publicadas; ou foi revertida com o motivo e um incidente aberto.
