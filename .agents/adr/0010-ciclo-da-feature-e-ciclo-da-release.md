# O ciclo da feature termina em "pronta"; a produção é do ciclo da release

Na primeira versão, a última fase da feature era `concluida`, alcançada quando a
auditoria era aprovada. Mas "concluída" misturava duas coisas diferentes: o
código está certo, e o código está em produção. Entre uma e outra ficavam, sem
registro, os testes do sistema inteiro, a homologação com o cliente, a decisão
de implantar, o plano de volta e a verificação depois do deploy.

## Decisão

- A feature termina em `pronta`: tudo aprovado e inalterado. Daí em diante, só a release muda a fase (`homologacao`, `producao`), e o `sdd-estado definir` não aceita essas fases.
- A release é uma entidade própria, em `releases/<versão>/`, com estado (`preparacao`, `homologacao`, `aceita`, `implantacao`, `producao`, ou `cancelada`, `revertida`) e histórico, mudados só pelo `sdd-release`.
- Cada passagem da release tem um gate humano com pré-condição verificada pelo utilitário: testes de sistema aprovados, roteiro de homologação sem passo pendente, aceite com nome, plano de implantação com rollback.
- Reprovar uma feature na homologação reabre a feature no green e devolve a release à preparação.
- A feature pode ser `cancelada` (com motivo) e reaberta; a reabertura invalida as aprovações da fase de reabertura em diante.

## Por quê

Features e entregas têm ritmos diferentes: várias features prontas saem numa
release, e uma feature pronta pode esperar a próxima janela. Juntar os dois
ciclos obrigaria a homologar feature por feature, ou deixaria a homologação fora
do processo, que é o que acontecia.

## Consequências

- "Pronta" é um estado estável, que o quadro mostra numa coluna própria, e as pendências avisam quando há prontas fora de release.
- O `sdd-sprint` conta como entregue a feature pronta, em homologação ou em produção: a sprint mede o trabalho do time, não a janela de deploy.
- `encerrar` e `concluida` deixaram de existir. Projetos que usavam a versão anterior (não publicada) precisam trocar `fase=concluida` por `fase=pronta`.
