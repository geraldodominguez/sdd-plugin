---
name: implementar
description: Executa as tarefas da feature ativa em TDD. Na fase red, um subagent escreve os testes só a partir dos critérios; na green, a sessão principal implementa com os testes congelados.
argument-hint: "[T-NNN para executar só uma tarefa ou grupo]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(sdd-status *), Bash(sdd-backlog *), Read, Write, Edit, Glob, Grep
---

# /sdd:implementar

Escopo: `$ARGUMENTS` (vazio significa todas as tarefas abertas, na ordem)

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Pré-condições

Rode `sdd-estado ver` e decida por onde começar:

| Situação | O que fazer |
|---|---|
| hotfix (`tipo=hotfix`) na fase `red`, sem testes marcados ainda | comece pela fase red, com o incidente como entrada (não há tarefas nem spec ainda) |
| `sdd-estado aprovado tarefas.md` não sai com 0 (exceto hotfix) | diga ao usuário para rodar `/sdd:aprovar` (ou `/sdd:tarefas`) e pare |
| fase `red` e testes já aprovados (`sdd-estado aprovado testes` sai com 0) | a aprovação deveria ter levado ao green: rode `sdd-estado definir fase=green` e vá para a fase green |
| fase `red`, testes marcados existem e não estão aprovados | os testes já foram escritos: mostre-os e diga para rodar `/sdd:aprovar` |
| fase `green` | vá direto para a fase green, continuando da primeira tarefa aberta |
| fase `tarefas` | comece pela fase red |

Leia `comando_teste` e `protecao` no `.sdd/config.yml`. Sem `comando_teste`, descubra o comando de testes do projeto
e confirme com o usuário.

Pergunte uma vez, no início, se o usuário quer **um commit por tarefa**, no
formato `tipo(NNN): T-XXX descrição`. Respeite a resposta até o fim.

## Fase red: os testes primeiro

1. `sdd-estado definir fase=red` (um hotfix já nasce nesta fase)
2. **Chame a ferramenta Agent com o subagent `escritor-de-testes`**, passando:
   - os caminhos de `spec.md`, `tarefas.md` e `contratos/`, se existir;
   - o número da feature (NNN), para as marcas `sdd:NNN:CA-XXX`;
   - o `comando_teste` e os `globs_de_teste`;
   - as tarefas no escopo;
   - **num hotfix** (feature com `tipo=hotfix`, sem tarefas nem spec ainda): o
     caminho de `incidentes/INC-NNN.md` (a origem) e a instrução de escrever o
     teste de regressão que reproduz o incidente, com a marca `sdd:NNN:CA-001`.

   **Não passe código de produção nem a sua ideia de implementação.** O valor
   do escritor-de-testes está em conhecer só o comportamento especificado.
3. Ao receber o resumo, confirme que:
   - todo CA do escopo tem teste com marca (o `sdd-rastrear` ajuda);
   - os testes **falham pelo motivo certo**: comportamento ausente, não erro de
     sintaxe nem configuração quebrada.
4. **Gate.** Mostre os testes criados (nome e CA) e a execução falhando, e
   **pare**. Diga ao usuário para rodar `/sdd:aprovar`, que registra o hash dos
   testes (qualquer mudança neles depois disso fica visível para o auditor), e
   depois `/sdd:implementar` de novo, que continua na fase green.

## Fase green: implementar

1. A fase já é `green` (a aprovação dos testes leva a ela). A partir daqui, o
   hook bloqueia edições em arquivos de teste, nas proteções `leve` e `estrita`.
2. Para cada tarefa aberta, na ordem das dependências:
   1. leia a tarefa e os CAs que ela atende;
   2. implemente **só** o necessário para esses testes passarem, respeitando a
      constituição, o plano e os contratos;
   3. rode os testes e itere até ficarem verdes, sem quebrar os anteriores;
   4. marque `[x]` em `tarefas.md`;
   5. faça o commit, se o usuário pediu.
3. **Se um teste parecer errado** (contradiz a spec, depende de detalhe interno,
   é impossível de satisfazer): **pare.** Explique o problema e as opções:
   corrigir a spec com uma delta, ou devolver ao escritor-de-testes. Nunca edite
   o teste para passar.
4. **Se surgir algo fora do escopo** (bug alheio, melhoria tentadora,
   requisito implícito): não implemente. Registre no backlog com
   `sdd-backlog adicionar "título" --nivel ? --origem "pendência da NNN"` e
   cite o item no resumo final.
5. **Se um contrato precisar mudar:** pare e proponha a mudança. Voltar ao plano
   exige aprovação.

## Encerramento

1. Rode a suíte completa, o `comando_lint` (se houver) e o `sdd-rastrear`.
2. Rode `sdd-estado sensivel <ref base>` (a base é o `git merge-base HEAD main`).
   Se a mudança tocou uma área sensível, ele torna a revisão de segurança
   obrigatória para esta feature, e você avisa o usuário.
3. Apresente as tarefas concluídas, o resultado dos testes, as lacunas
   restantes e os itens que você registrou no backlog.
4. Diga o próximo passo:

   | Feature | Próximo |
   |---|---|
   | nível 2 | `/sdd:seguranca`, depois `/sdd:auditar` |
   | nível 1 com revisão de segurança obrigatória | `/sdd:seguranca` |
   | nível 1 sem revisão obrigatória | `/sdd:aprovar` (entrega), ou `/sdd:auditar` antes, se quiser |
   | hotfix | preencher a spec retroativa e `/sdd:aprovar` (aprova a spec, depois a entrega) |

## Pronto quando

- Toda tarefa do escopo está `[x]` e a suíte está verde.
- O `sdd-rastrear` não aponta lacunas.
- Nenhum teste foi alterado na fase green.
- A obrigatoriedade da revisão de segurança foi conferida com `sdd-estado sensivel`.
