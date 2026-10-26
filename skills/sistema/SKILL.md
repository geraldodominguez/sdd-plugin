---
name: sistema
description: A spec viva do sistema, por capacidade. Mostra o que o sistema faz hoje, consolida nela os requisitos das features prontas e, em projetos existentes, ajuda a descrever as capacidades a partir do código.
argument-hint: "[ver <capacidade> | consolidar [NNN-slug] | mapear]"
disable-model-invocation: true
allowed-tools: Bash(sdd-sistema *), Bash(sdd-sistema), Bash(sdd-estado *), Read, Write, Edit, Glob, Grep
---

# /sdd:sistema

Pedido: `$ARGUMENTS` (vazio significa listar as capacidades e as consolidações pendentes)

As specs das features contam **o que mudou**. A spec do sistema, em
`sistema/<capacidade>.md`, diz **o que o sistema faz hoje**. Sem ela, depois de
dez features ninguém sabe qual spec descreve o cadastro: cada uma descreve uma
mudança. Ela é a primeira leitura de quem vai mexer numa área.

## Listar (padrão)

Rode `sdd-sistema listar` e `sdd-sistema pendentes` e mostre. Se houver
pendentes, recomende consolidar.

## Ver

`sdd-sistema ver <capacidade>` e um resumo em três linhas do que ela cobre.

## Consolidar

Para cada feature pronta (ou além) ainda não consolidada, ou a informada:

1. Leia a `spec.md` da feature (requisitos, critérios, seção "Impacto na spec
   do sistema", e a delta spec aprovada, se houver) e a capacidade
   (`sdd-estado` com a feature ativa, campo `capacidade`).
2. Sem capacidade definida: proponha uma a partir das existentes
   (`sdd-sistema listar`) ou uma nova, confirme e rode
   `sdd-estado usar <feature>` e `sdd-estado definir capacidade=<nome>`.
   Capacidade nova: `sdd-sistema nova <nome> "Título"`.
3. **Edite `sistema/<capacidade>.md`** para que ela descreva o comportamento
   vigente:
   - requisitos **novos** entram na seção certa, com `(origem: NNN/RF-NNN)`;
   - requisitos **alterados** substituem o texto antigo, e a origem passa a ser
     a feature nova (a antiga continua no histórico de consolidação);
   - requisitos **removidos** saem;
   - contratos públicos novos entram na tabela de contratos.

   Escreva no presente, como o sistema é, não como a feature mudou.
4. Mostre o diff ao usuário e peça confirmação.
5. `sdd-sistema consolidar <feature>`. Ele recusa se a capacidade não citar a
   feature. Para uma feature que não muda comportamento descrito (ex.: correção
   que só faz o sistema cumprir o que já estava escrito), use
   `--sem-mudanca --nota "motivo"`.

## Mapear (projetos existentes)

Para descrever capacidades que já existiam antes do SDD:

1. Pergunte qual área mapear primeiro (comece pela que mais muda).
2. Leia o código, as rotas, os testes e a documentação da área. Descreva só o
   que observou, com a origem `(origem: código, caminho:linha)`.
3. Crie com `sdd-sistema nova`, preencha, e mostre ao usuário para validar.
   Ele conhece regras de negócio que o código não mostra.

Não mapeie o sistema inteiro de uma vez: mapas grandes envelhecem antes de
serem lidos.

## Não faça

- Não copie a spec da feature inteira: a capacidade descreve o vigente, sem
  histórico de decisão, contexto ou critérios de aceitação.
- Não consolide uma feature que ainda não está pronta.

## Pronto quando

- `sdd-sistema pendentes` não lista nada, e cada capacidade tocada descreve o comportamento atual com a origem de cada item.
