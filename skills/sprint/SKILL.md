---
name: sprint
description: Planeja, acompanha e encerra sprints. Propõe um objetivo e um compromisso que cabem no período, mostra o andamento de cada item e faz a revisão no fim, devolvendo ao backlog o que ficou.
argument-hint: "[ver | planejar | encerrar]"
disable-model-invocation: true
allowed-tools: Bash(sdd-sprint *), Bash(sdd-sprint), Bash(sdd-backlog *), Bash(sdd-estado *), Bash(sdd-status *), Bash(sdd-pendencias *), Read, Edit
---

# /sdd:sprint

Pedido: `$ARGUMENTS` (vazio significa ver a sprint atual)

Uma sprint fica em `.sdd/sprints/<id>.md`: objetivo, datas, situação
(`planejada`, `ativa`, `encerrada`), o **compromisso** (features e itens de
backlog) e a **revisão**. O id padrão é a semana ISO do início (`2026-S44`).

## Ver (padrão)

1. Rode `sdd-sprint ver`. Sem sprint atual, rode `sdd-sprint listar` e
   sugira `/sdd:sprint planejar`.
2. Mostre a saída num bloco de código e acrescente uma leitura de três linhas:
   - **No ritmo?** Compare o progresso com o tempo decorrido.
   - **Em risco:** itens sem spec, itens parados esperando aprovação, itens com dúvidas.
   - **Próximo passo:** um comando.

## Planejar

1. **Revise a sprint anterior**, se houver uma ativa: proponha encerrá-la
   primeiro (ver "Encerrar").
2. **Pergunte o período** (padrão: duas semanas a partir de hoje) e o
   **objetivo**, uma frase que diga o resultado, não a lista de tarefas
   ("clientes conseguem recuperar o acesso sozinhos").
3. **Monte a proposta de compromisso** a partir de:
   - features em andamento (`sdd-estado listar`, fases antes de `pronta`);
   - itens de prioridade alta do backlog (`sdd-backlog listar`);
   - o que serve ao objetivo.

   Mostre a proposta numa tabela (item, nível, situação, por que entra) e diga o
   que ficou de fora e por quê. Prefira **menos itens concluídos a muitos itens
   começados**: um item de nível 2 costuma ocupar boa parte de uma sprint.
4. Com a aprovação do usuário:
   - `sdd-sprint nova [id] --objetivo "..." --inicio AAAA-MM-DD --fim AAAA-MM-DD`
   - `sdd-sprint incluir <id> <itens...>`
   - `sdd-sprint iniciar <id>`, quando o usuário quiser começar
5. Termine dizendo o primeiro passo: em geral, `/sdd:especificar B-NNN` para os
   itens que ainda não têm spec.

## Encerrar

1. Rode `sdd-sprint ver` e mostre o planejado contra o entregue.
2. Para cada item não concluído, pergunte o destino: **próxima sprint**,
   **volta ao backlog** ou **descartar**. Itens de backlog que nunca viraram
   feature continuam no backlog.
3. Rode `sdd-sprint encerrar <id>`. Ele grava o resultado no arquivo da sprint.
4. Preencha a seção **Revisão** do arquivo com o usuário, em poucas linhas:
   o que foi entregue, o que ficou e por quê, e o que muda na próxima sprint.
5. Sugira `/sdd:sprint planejar` para a próxima.

## Não faça

- Não inclua item na sprint sem a concordância do usuário.
- Não conte como entregue o que não chegou a `pronta` (ou além). Combine com o
  time se "entregue" na sprint significa pronta ou em produção, e diga isso no
  objetivo.

## Pronto quando

- Ver: o usuário sabe se a sprint está no ritmo e o que a ameaça.
- Planejar: a sprint existe, com objetivo, datas e compromisso aprovados.
- Encerrar: o resultado e a revisão estão no arquivo, e cada item pendente tem destino.
