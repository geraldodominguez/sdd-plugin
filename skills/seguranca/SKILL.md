---
name: seguranca
description: Revisão de segurança independente da feature ativa. Um subagent com contexto limpo modela as ameaças, roda as varreduras (dependências, segredos, análise estática), confere a LGPD e grava seguranca.md; a decisão (aprovar, aceitar o risco ou corrigir) é sua.
argument-hint: "[ref git base, por exemplo develop]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(git diff *), Bash(git log *), Bash(git merge-base *), Read, Glob, Grep
---

# /sdd:seguranca

Ref base: `$ARGUMENTS`

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Quando esta revisão é exigida

| Situação | Revisão |
|---|---|
| Feature de nível 2 | sempre |
| Feature de nível 1 que tocou `areas_sensiveis` do `.sdd/config.yml` | obrigatória (o `sdd-estado sensivel` marca sozinho) |
| Feature de nível 1 marcada com `seguranca=obrigatoria` na especificação | obrigatória |
| Outras de nível 1 | opcional: rode se o usuário pedir |

## Processo

1. **Pré-condições.** `sdd-estado ver`. A feature precisa estar na fase
   `green`, com todas as tarefas concluídas e a suíte verde. Se ainda houver
   tarefas abertas, diga ao usuário para terminar o `/sdd:implementar` e pare.
   Rode `sdd-estado definir fase=seguranca`.

2. **Defina a base da comparação.** Use `$ARGUMENTS`, se veio. Senão,
   `git merge-base HEAD develop` com o Git Flow ativo (a feature nasceu de `develop`; contra `main`, o diff traria as features de `develop` ainda não lançadas), ou `git merge-base HEAD main` com `gitflow: desligado`. Sem resultado, pergunte.

3. **Chame a ferramenta Agent com o subagent `revisor-de-seguranca`**,
   passando **apenas**:
   - a pasta da feature (`sdd-estado caminho`);
   - a ref base;
   - os caminhos da constituição e do template (`sdd-estado template seguranca.md`);
   - o `comando_seguranca` e o `areas_sensiveis` do `.sdd/config.yml`.

   Não explique a implementação nem antecipe o que você acha seguro. O revisor
   forma o próprio julgamento a partir do código e dos artefatos.

4. **Apresente o resultado** da `seguranca.md`: o veredito, os achados por
   gravidade (crítica e alta primeiro), os dados pessoais tratados e as
   varreduras que não puderam rodar (sem `comando_seguranca`, diga isso).

5. **Decisão do usuário**, registrada com `/sdd:aprovar`:

   | Decisão | Quando | Efeito |
   |---|---|---|
   | Aprovar | nenhum achado crítico ou alto | segue para a auditoria (nível 2) ou fica pronta (nível 1) |
   | Aceitar o risco | há achado, e o negócio aceita conviver com ele | igual a aprovar, com o risco registrado; exija no `--nota` quem aceitou, o porquê e o prazo para tratar, e registre a correção no backlog |
   | Corrigir | há achado que precisa ser resolvido antes | a feature volta ao green; depois, `/sdd:implementar` e `/sdd:seguranca` de novo |

   Diga ao usuário para rodar `/sdd:aprovar` com a decisão. Não registre você.

## Não faça

- Não corrija achados durante esta fase: na proteção estrita o hook bloqueia, e
  em qualquer proteção isso misturaria quem revisa com quem implementa.
- Não suavize o relatório nem descarte achados por conta própria.

## Pronto quando

- `seguranca.md` existe, com veredito, ameaças, varreduras e achados.
- O usuário sabe as três saídas e que a decisão se registra com `/sdd:aprovar`.
