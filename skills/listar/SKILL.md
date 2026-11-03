---
name: listar
description: Lista o que o quadro só resume, de todas as features: as tarefas T-NNN, as specs, os planos, os critérios de aceitação (com a tarefa e o teste de cada um) e as ADRs, com filtros por feature, fase, sprint e o que espera a sua aprovação. Com `falta`, mostra o que ainda separa uma feature de ficar pronta.
argument-hint: "<tarefas|specs|planos|criterios|adrs> [--feature NNN] [--fase F] [--sprint] [--esperando-eu] [--abertas] | falta [NNN-slug]"
disable-model-invocation: true
allowed-tools: Bash(sdd-listar *), Bash(sdd-listar), Bash(sdd-status *), Bash(sdd-status), Bash(sdd-estado *), Read
---

# /sdd:listar

Argumentos: `$ARGUMENTS`

1. Sem argumentos, pergunte em uma linha qual lista o usuário quer
   (`tarefas`, `specs`, `planos`, `criterios`, `adrs` ou `falta`) e pare.

2. Se o primeiro argumento for `falta`, rode `sdd-status <NNN-slug> --falta`
   (ou `sdd-status --ativa --falta`, sem feature nos argumentos) e mostre a
   saída num bloco de código.

3. Nos demais casos, rode `sdd-listar $ARGUMENTS` e mostre a saída num bloco de
   código. Os filtros são `--feature <NNN>`, `--fase <fase>`, `--sprint`,
   `--esperando-eu` e `--abertas`.

4. Acrescente uma **leitura** de no máximo três linhas, só com o que a lista
   mostra:
   - **Tarefas:** quantas abertas e em qual feature estão concentradas.
   - **Critérios:** quais não têm tarefa ou teste (`✗`).
   - **Próximo passo:** **um** comando (`/sdd:implementar`, `/sdd:aprovar`,
     `/sdd:clarificar`, `/sdd:planejar`), escolhido como no `/sdd:status`.

5. Se a lista vier vazia ("nada com esses filtros"), diga isso em uma linha e
   sugira soltar um filtro.

Não altere nada, e não invente itens que a saída não trouxe.
