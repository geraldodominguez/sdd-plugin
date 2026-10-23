---
name: aprovar
description: O gate formal. Mostra o que está sendo aprovado na fase atual, pede a sua confirmação e registra a aprovação no histórico (quem, quando e o hash do artefato), avançando a feature para a próxima fase.
argument-hint: "[artefato] [nota]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(sdd-status *), Read, Glob, Grep, Edit
---

# /sdd:aprovar

Argumentos: `$ARGUMENTS`

A aprovação é o ato humano que transforma um artefato em fonte de verdade. Ela
fica registrada no `historico.md` da feature com o hash do artefato: se ele
mudar depois, o `sdd-estado aprovado` e o auditor percebem.

## Processo

1. **Veja a fase.** Rode `sdd-estado ver`. Sem feature ativa, diga ao usuário
   para escolher uma (`sdd-estado usar NNN-slug`) e pare.

2. **Descubra o que está em jogo:**

   | Fase | O que se aprova | Para onde vai |
   |---|---|---|
   | `especificacao` ou `clarificacao` | `spec.md` | `plano` (nível 2) ou `tarefas` (nível 1) |
   | `plano` | `plano.md` e `contratos/` | `tarefas` |
   | `tarefas` | `tarefas.md` | `red` |
   | `red` | os testes marcados `sdd:NNN:` | `green` |
   | `green`, nível 1 | a entrega, sem auditoria | `concluida` |
   | `green`, nível 2 | nada: diga para rodar `/sdd:auditar` | |
   | `auditoria` | a decisão sobre a `auditoria.md` | ver passo 5 |

3. **Apresente um resumo para a decisão**, curto e honesto, sem repetir o
   arquivo inteiro:
   - **spec:** objetivo, quantidade de RFs e CAs, fora do escopo, e um alerta
     se houver `[PRECISA ESCLARECER]` em aberto;
   - **plano:** abordagem, contratos, dependências novas, ADRs propostos;
   - **tarefas:** lista de IDs e títulos, e o resultado do `sdd-rastrear`;
   - **testes:** os testes e o CA que cada um cobre, e o resultado da execução
     (falhando pelo motivo certo);
   - **entrega de nível 1:** tarefas concluídas, suíte verde, `sdd-rastrear` sem lacunas.

   Se algo impede uma aprovação responsável (marcador em aberto, lacuna de
   rastreabilidade, teste passando antes da implementação), diga isso antes de
   pedir a confirmação.

4. **Peça a confirmação explícita** ("Aprova a spec da 004?"). Só com um "sim"
   claro, rode `sdd-estado aprovar`, com `--nota "..."` se o usuário quiser
   registrar algo. Sem confirmação, não registre nada.

5. **Na fase `auditoria`**, apresente as três saídas e registre a escolhida:

   | Decisão | O que fazer |
   |---|---|
   | Aprovar | `sdd-estado aprovar --decisao aprovar` (conclui a feature) |
   | Aprovar a delta spec | aplique as mudanças de `delta-spec.md` na `spec.md`, mude a situação da delta para "aprovada", rode `sdd-estado aprovar spec.md --sem-avancar --nota "delta da auditoria"` e depois `sdd-estado aprovar --decisao delta` |
   | Corrigir o código | `sdd-estado aprovar --decisao corrigir` (volta ao green); depois o usuário roda `/sdd:implementar` |

6. **Mostre o resultado**: a linha registrada, a fase nova e o próximo comando.

## Não faça

- Nunca registre uma aprovação sem um "sim" explícito do usuário nesta conversa.
- Não edite o `historico.md` à mão.
- Não aprove em nome de outra pessoa.

## Pronto quando

- O `historico.md` da feature tem a linha de aprovação com o hash.
- A fase avançou (ou não, se o usuário recusou).
- O usuário sabe qual é o próximo comando.
