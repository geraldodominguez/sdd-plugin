---
name: incidente
description: Trilha de incidentes em produção. Registra o incidente com severidade, ajuda a mitigar, abre o hotfix (correção expressa com teste de regressão e spec retroativa obrigatória) e conduz o post-mortem sem culpados, transformando as ações em itens de backlog.
argument-hint: "[abrir <o que aconteceu> | ver | mitigar | hotfix | resolver | post-mortem]"
disable-model-invocation: true
allowed-tools: Bash(git switch develop), Bash(sdd-gitflow *), Bash(sdd-incidente *), Bash(sdd-incidente), Bash(sdd-estado *), Bash(sdd-backlog *), Bash(sdd-release *), Bash(sdd-status *), Bash(git log *), Bash(git diff *), Bash(git show *), Read, Write, Edit, Glob, Grep, Bash(git status *)
---

# /sdd:incidente

Pedido: `$ARGUMENTS` (vazio significa listar os incidentes em aberto)

Um incidente é um problema **em produção**. Ele não espera a próxima sprint, mas
também não justifica furar o processo: o hotfix é rápido e deixa rastro.

```
aberto -> mitigado -> resolvido -> encerrado
```

## Abrir

1. Entenda o que aconteceu: o sintoma, desde quando, quem é afetado.
2. Proponha a **severidade** e confirme:

   | Severidade | Quando |
   |---|---|
   | S1 | sistema fora do ar ou perda ou vazamento de dados |
   | S2 | função crítica indisponível, sem contorno |
   | S3 | função degradada, com contorno |
   | S4 | incômodo sem impacto relevante (em geral vira item de backlog, não incidente) |

3. Tente identificar a feature e a release de origem (`git log`, `sdd-release
   listar`, as capacidades em `sistema/`). Na dúvida, deixe em branco.
4. `sdd-incidente abrir "título" --severidade SN [--feature NNN-slug] [--release X.Y.Z]`.
5. Preencha **Impacto** no arquivo com o que o usuário relatou.

## Mitigar (S1 e S2: antes de corrigir)

Mitigar é parar o impacto, não corrigir a causa. Proponha a opção mais rápida e
reversível, e só execute com confirmação:

| Opção | Quando |
|---|---|
| Rollback da release | o problema começou com a última implantação; use o rollback de `releases/<versão>/implantacao.md` e `sdd-release reverter` |
| Desligar a função | há feature flag ou configuração |
| Contorno operacional | um procedimento manual resolve por ora |

Depois: `sdd-incidente situacao INC-NNN mitigado --nota "o que foi feito"`.

## Hotfix (a correção expressa)

1. `sdd-incidente hotfix INC-NNN "título da correção" [--capacidade nome]`. Ele
   cria uma feature de nível 1, tipo hotfix, **já na fase red**, sem exigir spec
   antes, e reserva a branch `hotfix/X.Y.Z` (a próxima versão patch).
   **Git Flow:** o registro do incidente é commitado em `develop`. Se você está
   em outra branch (a de uma feature em andamento, por exemplo), confira com
   `git status` que não há código pendente e rode `git switch develop`: o
   registro e a pasta nova vão junto. Em `develop`, faça o commit do registro
   (`docs(NNN): INC-NNN hotfix aberto`, com o número do hotfix), **sem** a
   pasta nova do hotfix em `specs/` (`git add -A ':!specs/'`): o hook aceita
   este commit em `develop` enquanto a branch do hotfix não existe. Depois,
   rode `sdd-gitflow feature NNN-slug`, que cria `hotfix/X.Y.Z` a partir de
   `main` (não de `develop`: a correção parte do que está em produção) e muda
   para ela, levando a pasta do hotfix. Todo o hotfix é commitado ali.

   Na `hotfix/X.Y.Z`, os registros que só existem em `develop` não aparecem:
   o incidente (leia com `git show develop:incidentes/INC-NNN.md`) e o estado
   das releases e features mais recentes. As atualizações do incidente
   (`sdd-incidente nota`, `situacao`) são feitas em `develop`, antes da troca
   ou depois do `finalizar`. Uma feature que estava em andamento continua na
   branch dela: depois, `sdd-gitflow feature <NNN-slug dela>` volta para lá.
2. Diga ao usuário para rodar `/sdd:implementar`: o escritor-de-testes escreve
   primeiro o **teste de regressão que reproduz o incidente** (ele deve falhar).
   Depois de `/sdd:aprovar` dos testes, vem a correção, com os testes congelados.
3. **Spec retroativa:** enquanto o contexto está fresco, preencha a `spec.md` do
   hotfix (comportamento incorreto, correto, critério do teste de regressão,
   causa). Ela precisa ser aprovada (`/sdd:aprovar`, que aprova a spec) antes da
   entrega: sem isso a feature não fica pronta.
4. Revisão de segurança se tocar área sensível, entrega (`/sdd:aprovar`) e uma
   **release de hotfix** (`/sdd:release` com `--hotfix`, **com a mesma versão
   da branch** `hotfix/X.Y.Z`). A
   homologação pode ser expressa, mas o aceite continua sendo de uma pessoa.
5. Em produção: `sdd-incidente situacao INC-NNN resolvido --nota "release X.Y.Z"`.

## Post-mortem e encerramento

1. Conduza o post-mortem **sem culpados**, perguntando "por quê" até chegar ao
   processo: o que aconteceu, causa raiz e **qual etapa do processo deveria ter
   pegado e não pegou** (spec, testes, segurança, auditoria, homologação,
   monitoramento).
2. Transforme cada ação em item de backlog:
   `sdd-backlog adicionar "ação" --prioridade P --nivel N --origem "INC-NNN"`, e
   escreva o `B-NNN` na tabela de ações.
3. Se a causa foi uma lacuna na constituição (ex.: "migrations sem rollback"),
   proponha a regra nova ao usuário.
4. `sdd-incidente encerrar INC-NNN` (ele recusa com o post-mortem incompleto).

## Não faça

- Não aplique mitigação, rollback ou implantação sem confirmação explícita.
- Não aponte culpados no post-mortem.
- Não feche o incidente com o hotfix sem spec aprovada.

## Pronto quando

- O impacto parou, a causa foi corrigida em produção com teste de regressão e spec, o post-mortem diz o que o processo deixou passar, e as ações estão no backlog.
