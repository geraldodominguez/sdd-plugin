---
name: auditar
description: Auditoria independente da feature ativa. Um subagent com contexto limpo compara o diff com a spec, os contratos, a constituição e os testes, aponta o drift e propõe a delta spec. A decisão final é sua.
argument-hint: "[ref git base, por exemplo main]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(git diff *), Bash(git log *), Bash(git merge-base *), Read, Glob, Grep, Edit
---

# /sdd:auditar

Ref base: `$ARGUMENTS`

## Processo

1. **Pré-condições.** `sdd-estado ver`. A feature precisa ter passado pela
   fase green. Rode `sdd-estado definir fase=auditoria`.

2. **Defina a base da comparação.** Use `$ARGUMENTS`, se veio. Senão, tente
   `git merge-base HEAD main` (ou `master`). Sem resultado, pergunte ao usuário.

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
   gravidade e a delta spec proposta, se houver.

5. **Decisão do usuário:**

   | Opção | O que fazer |
   |---|---|
   | Aprovar | `sdd-estado encerrar`; sugira o commit final e o merge |
   | Aprovar a delta spec | aplique as alterações na `spec.md`, marque a delta como aprovada, rode `sdd-rastrear` e depois `sdd-estado encerrar` |
   | Corrigir o código | `sdd-estado definir fase=green`, corrija só os desvios apontados e rode `/sdd:auditar` de novo |

## Não faça

- Não aplique a delta spec sem aprovação explícita.
- Não "corrija" o relatório do auditor. Se discordar, diga isso ao usuário e
  deixe a decisão com ele.

## Pronto quando

- `auditoria.md` existe, com veredito.
- O usuário escolheu uma das três saídas e ela foi aplicada.
