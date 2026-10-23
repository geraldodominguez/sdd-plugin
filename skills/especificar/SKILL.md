---
name: especificar
description: Abre uma feature e escreve a spec (o quê e por quê), a partir de um pedido ou de um item do backlog. Classifica o nível de rigor, mapeia o código afetado e lista o que precisa ser esclarecido, sem decidir regra de negócio por você.
argument-hint: "<descrição da mudança> | B-NNN"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-backlog *), Bash(sdd-status *), Bash(sdd-rastrear *), Read, Glob, Grep, Edit, Write
---

# /sdd:especificar

Pedido: `$ARGUMENTS`

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Processo

1. **Pré-condições.** Rode `sdd-estado ver`.
   - Sem `.sdd/`: diga ao usuário para rodar `/sdd:iniciar` e pare.
   - Pedido vazio: pergunte o que deve mudar, ou mostre `sdd-backlog listar`
     para ele escolher um item, e pare.
   - Se o pedido é um item do backlog (`B-NNN`), leia-o com `sdd-backlog ver B-NNN`:
     o título, os detalhes e o nível estimado são o ponto de partida. Se o item
     já foi promovido, diga qual feature ele virou e pare.
   - Se o pedido não é um item do backlog, mas parece algo para depois e não
     para agora, ofereça registrá-lo com `/sdd:backlog adicionar` em vez de
     abrir a feature.

2. **Classifique o nível** com o `NIVEIS-DE-RIGOR.md` da skill metodologia.
   Apresente a classificação com uma linha de justificativa e confirme.
   - **Nível 0:** explique que não precisa de spec, faça a mudança se o usuário
     quiser e encerre. Se veio do backlog, descarte o item com o motivo
     "resolvido como nível 0". Não crie feature.
   - **Nível 1 ou 2:** siga.

3. **Crie a feature** com `sdd-estado nova "<título curto>" --nivel <N>`,
   acrescentando `--origem B-NNN` quando vier do backlog (isso promove o item).
   A feature nasce na fase `especificacao` e vira a feature ativa.

4. **Contexto, em projeto existente.**
   - Nível 2: chame a ferramenta Agent com o subagent `mapeador-de-contexto`,
     passando o pedido e o destino `specs/NNN-slug/contexto.md`. Ele grava o
     mapa e devolve um resumo curto.
   - Nível 1: uma busca sua (Grep, Glob) basta. Cite os arquivos afetados no
     objetivo.

5. **Escreva a spec** seguindo a metodologia:
   - só o quê e por quê, sem tecnologia;
   - requisitos em EARS, com IDs `RF-NNN` e `RNF-NNN`;
   - critérios em Dado, Quando, Então, com IDs `CA-NNN`, cobrindo caminho
     feliz, erro e borda de cada RF;
   - fora do escopo explícito;
   - **tudo que você não sabe vira `[PRECISA ESCLARECER: ...]`**; não presuma
     regra de negócio;
   - apague os campos `{{...}}` e os exemplos não usados.

6. **Revise** com o `QUALIDADE-DA-SPEC.md` e corrija o que falhar.

7. **Gate.** Apresente:
   - um resumo de três a cinco linhas (objetivo, quantos RFs e CAs, escopo);
   - os marcadores em aberto;
   - o próximo comando:

     | Situação | Próximo |
     |---|---|
     | Há marcadores | `/sdd:clarificar` |
     | Sem marcadores | `/sdd:aprovar`, para aprovar a spec |

   **Não aprove nem avance a fase.** Quem aprova é o usuário, com `/sdd:aprovar`.

## Não faça

- Não escreva código, testes nem plano técnico.
- Não decida regra de negócio pelo usuário.
- Não copie detalhe de implementação para a spec: isso fica no `contexto.md`.

## Pronto quando

- `specs/NNN-slug/spec.md` existe, sem campos `{{...}}`.
- Todo RF tem pelo menos um CA.
- Toda dúvida está marcada, não presumida.
- O usuário sabe qual é o próximo comando.
