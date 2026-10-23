---
name: planejar
description: Gera o plano técnico e os contratos da feature ativa (nível 2), num subagent isolado, checados contra a constituição, com ADRs para as decisões duráveis.
argument-hint: "[restrições técnicas adicionais]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Read, Glob, Grep
---

# /sdd:planejar

Restrições adicionais: `$ARGUMENTS`

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Processo

1. **Pré-condições.** `sdd-estado ver`.
   - Nível 1: explique que o nível 1 dispensa plano e sugira `/sdd:tarefas`.
     Se o usuário insistir, siga.
   - A spec não pode ter `[PRECISA ESCLARECER]` em aberto. Se tiver, liste os
     marcadores e recomende `/sdd:clarificar`. Só siga com autorização explícita.
   - Rode `sdd-estado definir fase=plano`.

2. **Chame a ferramenta Agent com o subagent `arquiteto-de-contratos`**,
   passando no prompt:
   - a pasta da feature (`sdd-estado caminho`);
   - os caminhos da constituição e dos templates de plano e de ADR
     (`sdd-estado template plano.md`, `sdd-estado template adr.md`);
   - o `globs_de_contrato` do `.sdd/config.yml`, se definido;
   - as restrições adicionais do usuário;
   - a instrução de gravar `plano.md`, `contratos/` e, se preciso, ADRs em
     `docs/adr/` com situação "proposta", e devolver um resumo.

   O subagent trabalha em contexto próprio e você recebe só o resumo, o que
   mantém a sua janela limpa para as próximas fases.

3. **Revise o resultado** antes de mostrar:

   | Pergunta | Se falhar |
   |---|---|
   | Toda decisão aponta para um RF ou RNF? | devolva ao subagent |
   | A checagem da constituição está completa e sem violação injustificada? | devolva ao subagent |
   | Algum RF ficou sem componente? | devolva ao subagent |
   | Há regra de negócio nos contratos? | devolva ao subagent |

4. **Gate.** Apresente a abordagem em três a cinco linhas, os contratos
   principais, as dependências novas, os ADRs propostos e os riscos. Peça
   aprovação. Com ela, mude os ADRs para "aceita". Próximo: `/sdd:tarefas`.

## Não faça

- Não escreva o plano você mesmo quando o subagent estiver disponível: o
  isolamento é o ponto.
- Não implemente nada.

## Pronto quando

- `plano.md` e `contratos/` existem e todo RF tem componente responsável.
- A checagem da constituição está preenchida.
- O usuário aprovou o plano e os ADRs.
