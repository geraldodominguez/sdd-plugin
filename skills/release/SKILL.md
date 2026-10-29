---
name: release
description: Leva as features prontas até a produção. Prepara a release (versão, testes de sistema, roteiro de homologação), registra o aceite do negócio, conduz o go/no-go com plano de implantação e rollback, acompanha a implantação e encerra com as notas de versão.
argument-hint: "[ver | preparar | homologar | aceitar | implantar | concluir | reverter | cancelar]"
disable-model-invocation: true
allowed-tools: Bash(sdd-gitflow *), Bash(sdd-release *), Bash(sdd-release), Bash(sdd-estado *), Bash(sdd-sistema *), Bash(sdd-status *), Bash(sdd-verificar *), Bash(sdd-rastrear *), Bash(git log *), Bash(git tag *), Bash(git status *), Read, Write, Edit, Glob, Grep, Bash(gh pr create *), Bash(git branch -d *), Bash(git switch develop), Bash(git merge --no-ff release/*)
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
   dá a versão de um tipo explícito. Para homologar um release candidate
   antes de fechar a versão, veja **Release candidate** (abaixo). Commits fora
   do padrão (`analisar` lista) não contam: avise.

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
| algum passo reprovado | Pergunte antes se a release espera a correção ou segue sem a feature. Nos dois casos, `sdd-release reprovar <versão> <feature> --motivo "..."`: a feature sai da release e volta ao green, e a release volta à preparação |

**A release espera a correção.** Com o Git Flow, o `reprovar` grava a
`release/<versão>` como a branch da feature: a correção é feita nela.
1. `sdd-estado usar <feature>` e `/sdd:implementar` (o `sdd-gitflow feature
   <feature>` leva à `release/<versão>`). Os commits da correção vão nela.
2. `/sdd:aprovar` até a feature ficar pronta de novo. Ele não integra em
   `develop`: a correção chega a `develop` pelo `finalizar` da release.
3. `sdd-release incluir <versão> <feature>` e o commit
   `chore(release): <versão> volta à homologação`.
4. Refaça os testes de sistema (o `testes.md`) e o roteiro, e
   `/sdd:release homologar`.

**A release segue sem a feature.** Siga com as outras (`sdd-release
homologar` de novo, com os testes refeitos). A correção espera a release
terminar: depois do `finalizar`, `sdd-gitflow feature <feature>` cria
`feature/<feature>` a partir de `develop`, e ela segue o fluxo normal até
uma próxima release.

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
   `sdd-release autorizar <versão> --nota "..."`. Ele grava o go nos registros
   da release: faça o commit na branch da release
   (`chore(release): <versão> autorizada`), porque o `finalizar` exige tudo
   commitado.
4. **Git Flow: a release vai para `main`.** Só depois do go, e perguntando,
   conforme a chave `integracao` do config:

   | `integracao` | O que fazer |
   |---|---|
   | `local` | `sdd-gitflow finalizar <versão>`: merge `--no-ff` de `release/<versão>` (ou `hotfix/<versão>`) em `main`, tag `v<versão>` e merge de volta em `develop`. Depois, peça ao usuário para publicar: `git push origin main develop v<versão>` |
   | `pr` | Peça ao usuário para publicar a branch (`git push -u origin release/<versão>`, ou `hotfix/<versão>`), e abra `gh pr create --base main --head release/<versão>` (ou `--head hotfix/<versão>`). Depois do merge na plataforma e do `git pull` em `main`, `sdd-gitflow finalizar <versão> --apos-pr` cria a tag e faz o merge de `main` em `develop`. Peça o push da tag (`git push origin v<versão>`) e de `develop`; se `develop` só aceita pull request, em vez do push dela, `gh pr create --base develop --head main` |

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

## Release candidate

Para homologar uma versão antes de fechá-la (`X.Y.Z-rc.N`). Um release
candidate é só homologado: ele **nunca** vai para produção.

1. `sdd-release proxima --pre rc` dá a versão (`1.3.0-rc.1`, depois `rc.2`).
   Prepare como no **Preparar**, com essa versão: `sdd-gitflow release
   1.3.0-rc.1`, `nova`, `incluir`, testes de sistema, roteiro.
2. Homologue e registre o aceite como numa release normal. Não rode
   `autorizar`, `finalizar` nem `concluir` num release candidate.
3. Com o aceite, substitua o candidate pela versão final:
   - `sdd-release cancelar 1.3.0-rc.1 --motivo "substituída pela 1.3.0"`: as
     features voltam a `pronta`. Faça o commit desses registros na branch do
     candidate (`chore(release): 1.3.0-rc.1 substituída pela 1.3.0`);
   - leve a branch do candidate a `develop`, perguntando: `git switch develop`
     e `git merge --no-ff release/1.3.0-rc.1`. Isso traz as correções feitas
     nela e o registro do candidate (sem ele, `develop` não sabe que a `rc.1`
     existiu, e o próximo `--pre rc` repetiria o número);
   - prepare a `1.3.0` com as mesmas features, a partir de `develop`. A
     homologação dela pode ser expressa: o conteúdo já foi aceito no candidate.

## Cancelar

Quando a release não vai sair (o negócio desistiu, ou ela foi substituída):
`sdd-release cancelar <versão> --motivo "..."`, só antes do go. As features
dela voltam a `pronta` e podem entrar noutra release. Faça o commit dos
registros na branch da release (`chore(release): <versão> cancelada`). Depois,
recomende levar a branch a `develop` (`git switch develop` e `git merge --no-ff
release/<versão>`): vão o registro do cancelamento e as correções commitadas
nela. Se o usuário preferir descartar as correções, o registro da release
também fica só na branch. Depois, ofereça apagar a branch local. Depois do go, não se cancela: o caminho é
`reverter`.

## Não faça

- Não implante sem o go registrado.
- Não marque passos de homologação como aprovados sem o relato de quem homologou.
- Não pule os testes de sistema "porque cada feature já tem testes".

## Pronto quando

- A release está em produção, com testes de sistema, aceite, go e verificação no `historico.md` da release, e as notas publicadas; ou foi revertida com o motivo e um incidente aberto.
