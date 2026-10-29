---
name: release
description: Leva as features prontas até a produção. Prepara a release (versão, testes de sistema, roteiro de homologação), registra o aceite do negócio, conduz o go/no-go com plano de implantação e rollback, acompanha a implantação e encerra com as notas de versão.
argument-hint: "[ver | preparar | homologar | aceitar | implantar | concluir | reverter]"
disable-model-invocation: true
allowed-tools: Bash(sdd-gitflow *), Bash(sdd-release *), Bash(sdd-release), Bash(sdd-estado *), Bash(sdd-sistema *), Bash(sdd-status *), Bash(sdd-verificar *), Bash(sdd-rastrear *), Bash(git log *), Bash(git tag *), Bash(git status *), Read, Write, Edit, Glob, Grep, Bash(gh pr create *), Bash(git branch -d *)
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
2. **Proponha a versão.** A versão segue o SemVer e é **calculada pelos
   commits** (Conventional Commits) desde a última versão. Rode, em `develop`,
   `sdd-release analisar` e mostre ao usuário a sugestão e o motivo:

   | Os commits têm | Versão | Exemplo a partir da 1.4.2 |
   |---|---|---|
   | `!` no tipo, ou o rodapé `BREAKING CHANGE:` (contrato público quebrado) | major (antes da 1.0.0, minor) | 2.0.0 |
   | `feat` | minor | 1.5.0 |
   | só `fix` ou `perf` | patch | 1.4.3 |
   | só manutenção (`docs`, `chore`, `refactor`, `test`...) | patch | 1.4.3 |

   Confira a sugestão contra as features da release: uma feature que quebra
   contrato público e não tem commit com `!` é um commit mal classificado, e a
   versão certa é a major. O usuário decide; `sdd-release proxima major|minor|patch`
   dá a versão de um tipo explícito. Para homologar um release candidate,
   `sdd-release proxima --pre rc` dá `X.Y.Z-rc.N`. Commits fora do padrão
   (`analisar` lista) não contam: avise.

3. **Git Flow, primeiro a branch.** Confira que cada feature incluída já está
   em `develop` (o `/sdd:status` da feature diz "integrada em develop"; se não,
   integre como no `/sdd:aprovar`). Com a confirmação da versão,
   `sdd-gitflow release <versão>` cria `release/<versão>` a partir de `develop`
   e muda para ela: é esta branch que vai para homologação, e as correções da
   homologação são commitadas nela. Numa release de hotfix, a branch já existe
   (`hotfix/<versão>`): `sdd-gitflow feature <NNN-slug do hotfix>` muda para
   ela; não crie outra.
   Depois, já na branch: `sdd-release nova <versão> --objetivo "..."` e
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
   confirmação, a partir de `release/<versão>` (ou `hotfix/<versão>`). Senão,
   diga como implantar segundo a constituição. Com o pipeline do Git Flow, o
   push da branch `release/<versão>` já implanta em homologação.
2. `sdd-release homologar <versão>`. Ele recusa se faltar teste de sistema
   aprovado ou roteiro.
3. Entregue ao usuário o roteiro: quem homologa executa cada passo e marca
   `aprovado` ou `reprovado` em `homologacao.md` (você pode ajudar a marcar
   enquanto ele relata).

## Aceitar (o aceite do negócio)

| Resultado do roteiro | O que fazer |
|---|---|
| tudo aprovado | `sdd-release aceitar <versão> --por "Nome, papel"` com o nome de quem homologou, depois de confirmar com o usuário |
| algum passo reprovado | `sdd-release reprovar <versão> <feature> --motivo "..."`: a feature volta ao green e a release, à preparação. Pergunte antes se a release segue sem ela. A correção é commitada em `release/<versão>` (o hook aceita commits da feature ativa em `release/`), não na branch antiga da feature |

Nunca registre o aceite em nome de quem não homologou.

## Implantar (o go/no-go)

1. Escreva `implantacao.md` com o usuário: pré-requisitos (backup, segredos,
   migrations), passos, **verificação pós-implantação** e **rollback com
   critério objetivo de acionamento**. Use a seção "Ambientes e entrega" da
   constituição.
2. Revise as notas (`notas.md`, em linguagem de negócio) e gere a seção da
   versão no **CHANGELOG.md** (formato Keep a Changelog, a partir dos commits):
   `sdd-release changelog <versão>` mostra; com a aprovação do usuário,
   `sdd-release changelog <versão> --escrever` grava. Revise o texto com ele
   (as linhas vêm das descrições dos commits e dos títulos das features) e faça
   o commit na branch da release: `docs(release): changelog <versão>`.
3. Apresente o plano e pergunte: **"Go ou no-go?"**. Só com "go":
   `sdd-release autorizar <versão> --nota "..."`.
4. **Git Flow: a release vai para `main`.** Só depois do go, e perguntando,
   conforme a chave `integracao` do config:

   | `integracao` | O que fazer |
   |---|---|
   | `local` | `sdd-gitflow finalizar <versão>`: merge `--no-ff` de `release/<versão>` (ou `hotfix/<versão>`) em `main`, tag `v<versão>` e merge de volta em `develop`. Depois, peça ao usuário para publicar: `git push origin main develop v<versão>` |
   | `pr` | `gh pr create --base main --head release/<versão>`; depois do merge na plataforma e do `git pull` em `main`, `sdd-gitflow finalizar <versão> --apos-pr` (tag e `develop`) e o push da tag |

   O `sdd-gitflow finalizar` recusa sem o go registrado. Conflito: pare e
   resolva com o usuário.
5. Conduza a implantação seguindo o plano. Com o pipeline do Git Flow, o push
   da tag `v<versão>` implanta em produção, e o pipeline confere o go com
   `sdd-release pode-implantar`. Se houver `comando_deploy_producao` fora do
   pipeline, rode **só com confirmação explícita** neste momento.
6. Rode a verificação (`comando_verificacao_producao` ou os passos do plano).

## Concluir ou reverter

| Verificação | O que fazer |
|---|---|
| passou | `sdd-release concluir <versão> --verificacao "o que foi verificado"`. Ele roda em `develop` (o `finalizar` terminou lá) e muda os registros da release e das features: proponha o commit `chore(release): <versão> em produção` e ofereça apagar a branch local (`git branch -d release/<versão>`) |
| falhou, critério de rollback atingido | execute o rollback do plano com confirmação, `sdd-release reverter <versão> --motivo "..."` e sugira `/sdd:incidente abrir`. O rollback é do ambiente; no git, `main` não se reescreve: a correção vem por um hotfix (`hotfix/X.Y.Z`) |

## Não faça

- Não implante sem o go registrado.
- Não marque passos de homologação como aprovados sem o relato de quem homologou.
- Não pule os testes de sistema "porque cada feature já tem testes".

## Pronto quando

- A release está em produção, com testes de sistema, aceite, go e verificação no `historico.md` da release, e as notas publicadas; ou foi revertida com o motivo e um incidente aberto.
