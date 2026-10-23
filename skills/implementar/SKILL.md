---
name: implementar
description: Executa as tarefas da feature ativa em TDD. Na fase red, um subagent escreve os testes só a partir dos critérios; na green, a sessão principal implementa com os testes congelados.
argument-hint: "[T-NNN para executar só uma tarefa ou grupo]"
disable-model-invocation: true
allowed-tools: Bash(sdd-estado *), Bash(sdd-rastrear *), Bash(sdd-status), Read, Write, Edit, Glob, Grep
---

# /sdd:implementar

Escopo: `$ARGUMENTS` (vazio significa todas as tarefas abertas, na ordem)

Chame a ferramenta Skill com `sdd:metodologia` se ela ainda não estiver no
contexto.

## Pré-condições

Rode `sdd-estado ver`. A feature precisa ter `tarefas.md` aprovado (fase
`tarefas` ou posterior). Leia `comando_teste` e `protecao` no
`.sdd/config.yml`. Sem `comando_teste`, descubra o comando de testes do projeto
e confirme com o usuário.

Pergunte uma vez, no início, se o usuário quer **um commit por tarefa**, no
formato `tipo(NNN): T-XXX descrição`. Respeite a resposta até o fim.

## Fase red: os testes primeiro

1. `sdd-estado definir fase=red`
2. **Chame a ferramenta Agent com o subagent `escritor-de-testes`**, passando:
   - os caminhos de `spec.md`, `tarefas.md` e `contratos/`, se existir;
   - o número da feature (NNN), para as marcas `sdd:NNN:CA-XXX`;
   - o `comando_teste` e os `globs_de_teste`;
   - as tarefas no escopo.

   **Não passe código de produção nem a sua ideia de implementação.** O valor
   do escritor-de-testes está em conhecer só o comportamento especificado.
3. Ao receber o resumo, confirme que:
   - todo CA do escopo tem teste com marca (o `sdd-rastrear` ajuda);
   - os testes **falham pelo motivo certo**: comportamento ausente, não erro de
     sintaxe nem configuração quebrada.
4. **Gate rápido.** Mostre os testes criados (nome e CA) e a execução falhando.
   Peça um "ok" para seguir.

## Fase green: implementar

1. `sdd-estado definir fase=green`. A partir daqui, o hook bloqueia edições em
   arquivos de teste, nas proteções `leve` e `estrita`.
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
   requisito implícito): anote em "Pendências" no fim. Não implemente.
5. **Se um contrato precisar mudar:** pare e proponha a mudança. Voltar ao plano
   exige aprovação.

## Encerramento

1. Rode a suíte completa, o `comando_lint` (se houver) e o `sdd-rastrear`.
2. Apresente as tarefas concluídas, o resultado dos testes, as lacunas
   restantes e as pendências.
3. Próximo: `/sdd:auditar`, obrigatório no nível 2 e opcional no nível 1. No
   nível 1 sem auditoria, com aprovação do usuário, `sdd-estado encerrar`.

## Pronto quando

- Toda tarefa do escopo está `[x]` e a suíte está verde.
- O `sdd-rastrear` não aponta lacunas.
- Nenhum teste foi alterado na fase green.
