# O hotfix inverte a ordem do processo, sem dispensá-lo

Quando algo quebra em produção, ninguém escreve spec antes de corrigir. Sem um
caminho expresso, a correção pula o processo inteiro: não tem teste de
regressão, não aparece no quadro, não passa pela revisão de segurança e não
atualiza a spec do sistema.

## Decisão

- O incidente é registrado em `incidentes/INC-NNN.md`, com severidade e linha do tempo, pelo `sdd-incidente`. Mitigar vem antes de corrigir.
- `sdd-incidente hotfix` cria uma feature com `tipo=hotfix`, nível 1, origem no incidente, que **nasce na fase red**, sem tarefas.
- O primeiro artefato é o teste que reproduz o problema, aprovado como qualquer teste.
- A spec é escrita depois da correção (spec retroativa, template próprio) e precisa estar aprovada para a entrega: o `sdd-estado aprovar` recusa a passagem para pronta sem ela.
- Área sensível, consolidação e release valem como para qualquer feature. A release de hotfix (`--hotfix`) é patch e pode ter homologação expressa, mas continua com aceite e go.
- O incidente só é encerrado com post-mortem preenchido e ao menos uma ação.

## Por quê

A urgência justifica mudar a ordem, não pular os passos. O teste vem primeiro
porque é o que prova que a correção corrige; a spec vem antes da entrega porque
é o que impede o comportamento corrigido de ser desfeito pela próxima feature.

## Consequências

- O `sdd-rastrear` pula as checagens de tarefa num hotfix sem `tarefas.md`.
- Hotfix sem spec aprovada aparece como aviso no `sdd-verificar` e nas pendências.
- Incidentes S1 e S2 não encerrados aparecem como aviso no CI, até o post-mortem.
