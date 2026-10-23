---
name: tarefas
description: Quebra a spec, e o plano no nível 2, em tarefas pequenas, ordenadas e ligadas aos requisitos e critérios, e confere a rastreabilidade com o sdd-rastrear.
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Read, Write, Edit, Glob, Grep
---

# /sdd:tarefas

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto, e siga o `DECOMPOSICAO-DE-TAREFAS.md` dela.

## Processo

1. **Pré-condições.** `sdd-estado ver`.
   - Nível 2: `sdd-estado aprovado plano.md` deve sair com 0. Sem plano, diga
     ao usuário para rodar `/sdd:planejar`; com plano não aprovado ou alterado,
     `/sdd:aprovar`. E pare.
   - Nível 1: `sdd-estado aprovado spec.md` deve sair com 0. Senão, `/sdd:aprovar`.
   - Rode `sdd-estado definir fase=tarefas`.

2. **Escreva `tarefas.md`** a partir do template (`sdd-estado template tarefas.md`),
   em `sdd-estado caminho tarefas.md`:
   - grupos nesta ordem: contratos e fundação, domínio, aplicação e
     integração, acabamento;
   - cada tarefa com `T-NNN`, uma descrição de comportamento e
     `(atende: ...; depende de: ...)`;
   - `[P]` só onde não há dependência mútua;
   - troque `{{NUM}}` pelo número da feature na definição de pronto;
   - nível 1: tipicamente de duas a cinco tarefas.

3. **Confira** com `sdd-rastrear`. Corrija agora as lacunas de tarefa
   (requisito sem tarefa, tarefa sem referência, ID inexistente). Lacunas de
   **teste** são esperadas nesta fase: somem no `/sdd:implementar`.

4. **Gate.** Mostre a lista de tarefas (só IDs e descrições), as dependências
   críticas e o que pode rodar em paralelo. Próximo: `/sdd:aprovar`, para
   aprovar as tarefas. Depois vem o `/sdd:implementar`.

## Não faça

- Não crie tarefa para algo fora do escopo da spec.
- Não junte requisitos sem relação numa só tarefa.

## Pronto quando

- O `sdd-rastrear` só aponta lacunas de teste.
- O usuário aprovou a lista.
