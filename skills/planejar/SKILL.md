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
   - A spec precisa estar **aprovada e inalterada**: `sdd-estado aprovado spec.md`
     deve sair com 0. Saída 5 (nunca aprovada) ou 4 (alterada depois da
     aprovação): diga ao usuário para rodar `/sdd:aprovar` e pare.
   - Rode `sdd-estado definir fase=plano` (a aprovação da spec já costuma ter
     deixado a feature nessa fase).

2. **Chame a ferramenta Agent com o subagent `arquiteto-de-contratos`**,
   passando no prompt:
   - a pasta da feature (`sdd-estado caminho`);
   - os caminhos da constituição e dos templates de plano e de ADR
     (`sdd-estado template plano.md`, `sdd-estado template adr.md`);
   - o `globs_de_contrato` do `sdd/config.yml`, se definido;
   - as restrições adicionais do usuário;
   - a instrução de gravar `plano.md`, `contratos/` e, se preciso, ADRs em
     `sdd/adr/` com situação "proposta", e devolver um resumo.

   O subagent trabalha em contexto próprio e você recebe só o resumo, o que
   mantém a sua janela limpa para as próximas fases.

3. **Revise o resultado** antes de mostrar:

   | Pergunta | Se falhar |
   |---|---|
   | Toda decisão aponta para um RF ou RNF? | devolva ao subagent |
   | A checagem da constituição está completa e sem violação injustificada? | devolva ao subagent |
   | Algum RF ficou sem componente? | devolva ao subagent |
   | Há regra de negócio nos contratos? | devolva ao subagent |
   | As seções de ameaças, implantação e rollback e observabilidade estão preenchidas? | devolva ao subagent |
   | A seção 14 traz toda lacuna da spec que o subagent citou no resumo, e as de regra de negócio estão marcadas para voltar à spec? | devolva ao subagent |

4. **Gate.** Apresente a abordagem em três a cinco linhas, os contratos
   principais, as dependências novas, os ADRs propostos, os riscos e as lacunas da spec (seção 14 do plano). Se houver
   lacuna de **regra de negócio**, diga que o caminho correto é `/sdd:clarificar` e
   nova aprovação da spec, e não aprovar a regra só no plano. Próximo:
   `/sdd:aprovar`, para aprovar o plano e os contratos. Quando o usuário
   aprovar, mude os ADRs da feature para "aceita". Depois vêm as `/sdd:tarefas`.

## Não faça

- Não escreva o plano você mesmo quando o subagent estiver disponível: o
  isolamento é o ponto.
- Não implemente nada.

## Pronto quando

- `plano.md` e `contratos/` existem e todo RF tem componente responsável.
- A checagem da constituição está preenchida.
- O usuário aprovou o plano e os ADRs.
