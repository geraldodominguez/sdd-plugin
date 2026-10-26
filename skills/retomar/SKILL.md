---
name: retomar
description: Para voltar ao trabalho depois de uma pausa ou numa sessão nova. Conta o que aconteceu na feature desde a última vez (aprovações, fases, tarefas, commits), onde ela está agora e qual é o próximo passo.
argument-hint: "[NNN-slug] [desde AAAA-MM-DD]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-status *), Bash(sdd-rastrear *), Bash(sdd-pendencias), Bash(sdd-sprint *), Bash(sdd-release *), Bash(sdd-incidente *), Bash(git log *), Bash(git status *), Bash(git diff *), Read, Glob, Grep
---

# /sdd:retomar

Argumentos: `$ARGUMENTS` (vazio significa a feature ativa, desde o último evento relevante)

## Processo

1. **Escolha a feature.** Use a informada nos argumentos ou a ativa
   (`sdd-estado ver`). Sem nenhuma, rode `sdd-status` e pergunte qual retomar.

2. **Junte os fatos, sem inventar nada:**
   - `sdd-estado historico <feature>` (com `--desde` se o usuário deu uma data);
   - `sdd-status <feature>`: fase, artefatos, aprovações, tarefas;
   - `git log --oneline --since=<data do evento mais antigo considerado>` filtrando pelo número da feature (`(NNN)` ou `T-`);
   - `git status --short`: trabalho não commitado;
   - `sdd-sprint ver`, se houver sprint atual, para situar a feature no compromisso.
   - se a feature está numa release (campo `release`), `sdd-release ver <versão>`;
   - se ela é um hotfix ou tem incidentes ligados, `sdd-incidente ver INC-NNN`.

3. **Conte a história em até 15 linhas**, nesta estrutura:

   **Onde paramos:** fase atual, nível, tipo (hotfix?), se a feature está na
   sprint e em qual release.

   **O que aconteceu:** os eventos do histórico em ordem (aprovações, mudanças
   de fase), as tarefas concluídas e os commits correspondentes.

   **O que está pela metade:** arquivos não commitados, tarefa em andamento,
   artefato alterado depois de aprovado (`sdd-estado aprovado`).

   **Próximo passo:** **um** comando, com o motivo.

4. Se o histórico e o git discordarem (por exemplo, tarefas marcadas sem commit
   correspondente), aponte a divergência em vez de escolher um lado.

Não altere nada. Esta skill só lê e resume.

## Pronto quando

- O usuário sabe, sem abrir nenhum arquivo, onde a feature está e o que fazer em seguida.
