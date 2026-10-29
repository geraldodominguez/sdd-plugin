---
name: auditar
description: Auditoria independente da feature ativa. Um subagent com contexto limpo compara o diff com a spec, os contratos, a constituição e os testes, aponta o drift e propõe a delta spec. A decisão final é sua.
argument-hint: "[ref git base, por exemplo develop]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(git diff *), Bash(git log *), Bash(git merge-base *), Read, Glob, Grep, Edit
---

# /sdd:auditar

Ref base: `$ARGUMENTS`

## Processo

1. **Pré-condições.** `sdd-estado ver`.
   - A feature precisa ter terminado a fase green (todas as tarefas concluídas).
   - Se a revisão de segurança é obrigatória (`seguranca=obrigatoria`, sempre no
     nível 2), ela precisa estar aprovada: `sdd-estado aprovado seguranca.md`
     deve sair com 0. Senão, diga ao usuário para rodar `/sdd:seguranca` e pare.
   - Rode `sdd-estado definir fase=auditoria`.

2. **Defina a base da comparação.** Use `$ARGUMENTS`, se veio. Senão, tente
   `git merge-base HEAD develop` com o Git Flow ativo (a feature nasceu de `develop`; contra `main`, o diff traria as features de `develop` ainda não lançadas), ou `git merge-base HEAD main` com `gitflow: desligado`. Sem resultado, pergunte ao usuário.

3. **Chame a ferramenta Agent com o subagent `auditor-de-drift`**, passando
   **apenas**:
   - a pasta da feature;
   - a ref base;
   - os caminhos da constituição e dos templates de auditoria e de delta spec
     (`sdd-estado template auditoria.md`, `sdd-estado template delta-spec.md`);
   - o `comando_teste` e o `comando_lint`.

   **Não resuma a implementação nem justifique decisões.** O auditor forma o
   próprio julgamento a partir dos artefatos e do diff.

4. **Apresente o veredito** da `auditoria.md`: o veredito, os desvios por
   gravidade, a seção de processo (aprovações e testes alterados) e a delta spec
   proposta em `delta-spec.md`, se houver.

5. **Decisão do usuário**, registrada com `/sdd:aprovar`:

   | Opção | Efeito |
   |---|---|
   | Aprovar | a feature fica pronta e é consolidada na spec do sistema; sugira o commit final e o merge |
   | Aprovar a delta spec | a spec absorve a mudança, é reaprovada, e a feature fica pronta |
   | Corrigir o código | a feature volta ao green; depois, `/sdd:implementar` e `/sdd:auditar` de novo |

   Diga ao usuário para rodar `/sdd:aprovar` com a decisão. Não registre a
   decisão você mesmo.

## Não faça

- Não aplique a delta spec nem encerre a feature: isso é o `/sdd:aprovar`.
- Não "corrija" o relatório do auditor. Se discordar, diga isso ao usuário e
  deixe a decisão com ele.

## Pronto quando

- `auditoria.md` existe, com veredito e a seção de processo preenchida.
- O usuário sabe as três saídas e que a decisão se registra com `/sdd:aprovar`.
