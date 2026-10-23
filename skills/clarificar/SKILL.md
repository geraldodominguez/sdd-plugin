---
name: clarificar
description: Rodada de perguntas sobre a spec ativa. Encontra ambiguidades, lacunas e contradições, pergunta com opções e uma recomendação, e incorpora as respostas antes de qualquer decisão técnica.
argument-hint: "[foco opcional, por exemplo: regras de expiração]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Read, Edit, Grep, Glob
---

# /sdd:clarificar

Foco opcional: `$ARGUMENTS`

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Processo

1. **Pré-condições.** `sdd-estado ver`. É preciso uma feature ativa com
   `spec.md`. Sem isso, diga ao usuário para rodar `/sdd:especificar` e pare.
   Rode `sdd-estado definir fase=clarificacao`.

2. **Analise a spec** (`sdd-estado caminho spec.md`) e liste os problemas:

   | Tipo | O que procurar |
   |---|---|
   | Marcador | todo `[PRECISA ESCLARECER]` |
   | Ambiguidade | termo vago, requisito com mais de uma leitura |
   | Lacuna | RF sem CA de erro ou de borda, RNF sem número, escopo indefinido, papel sem permissão definida, falha externa sem comportamento |
   | Contradição | requisitos que se chocam entre si ou com a constituição |

3. **Priorize** pelo que mais muda o desenho da solução. No máximo **cinco
   perguntas por rodada**. Para cada uma:
   - contexto em uma linha (onde está e por que importa);
   - de duas a quatro opções concretas, quando fizer sentido, com a sua
     recomendação marcada;
   - espaço para resposta livre.

   Use a ferramenta de perguntas de múltipla escolha quando houver.

4. **Incorpore as respostas.**
   - Atualize os requisitos e critérios afetados. Crie IDs novos quando
     preciso; nunca reaproveite um ID.
   - Remova os marcadores resolvidos.
   - Registre cada resposta no "Histórico de clarificação".

5. **Repita** se as respostas abrirem dúvidas novas importantes, até três
   rodadas. Depois disso, pergunte se o usuário prefere seguir com as pendências
   menores registradas.

6. **Gate.** Mostre o que mudou, por seção, e o que ainda está em aberto.
   Próximo: `/sdd:planejar` no nível 2, `/sdd:tarefas` no nível 1.

## Não faça

- Não responda às próprias perguntas.
- Não discuta tecnologia: isso é o plano.
- Não apague o histórico de clarificação.

## Pronto quando

- Nenhum `[PRECISA ESCLARECER]` em aberto, ou o usuário aceitou seguir com os que restaram.
- Toda resposta está no histórico e refletida nos requisitos.
