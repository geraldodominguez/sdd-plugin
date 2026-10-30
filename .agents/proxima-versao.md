# Para a próxima versão

Pontos levantados na auditoria por cenários da 1.0.1 e deixados de propósito
para depois. Cada um entra numa versão quando for feito, com teste.

| Ponto | O que fazer |
|---|---|
| `✗` no quadro do `sdd-status` | Hoje um artefato alterado depois de aprovado aparece com `✗` no detalhe da feature e no `sdd-pendencias`, e no quadro só conta em "ESPERANDO VOCÊ". Mostrar a marca na linha da feature no quadro. |
| "Seguir sem a feature" com a release em andamento | Quando a release segue sem uma feature reprovada, a correção deve esperar a release terminar. Hoje isso está só na skill: o `sdd-gitflow feature` levaria a correção para a `release/` se rodado antes do `finalizar`. Travar no código (por exemplo, uma opção no `sdd-release reprovar` que não grava a `release/` como branch da feature). |
| Hashes do exemplo da feature 001 | Os hashes do `exemplos/001-redefinicao-de-senha/historico.md` são ilustrativos (o código e os testes não estão no repositório). Avaliar gerar o exemplo de um projeto real, para os hashes baterem. |
| Commits nas `allowed-tools` | As skills prescrevem commits, mas `git add` e `git commit` não estão liberados, e cada commit pede permissão. Decidir se continua assim (o commit como ponto de conferência) e registrar a decisão num ADR. |
| Verificação independente da última rodada da 1.0.1 | As correções da terceira rodada (versão de referência pela tag mais nova, versões usadas não se repetem, ordem dos pré-lançamentos, feature só no remoto, pathspec do hotfix) foram conferidas só pelos testes. Refazer os cenários por execução. |
