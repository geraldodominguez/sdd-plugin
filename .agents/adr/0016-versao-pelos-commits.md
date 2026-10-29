# A versão sai dos commits: SemVer, Conventional Commits e Keep a Changelog

## Decisão

- As versões seguem o SemVer 2.0.0, com a tag `vX.Y.Z` em `main` (ver [ADR 0015](0015-git-flow-com-nomes-fixos.md)).
- As mensagens de commit seguem o Conventional Commits 1.0.0, com o número da feature como escopo: `tipo(NNN): T-XXX descrição`. O hook `guarda-commits` bloqueia mensagem inline fora do formato, com `commits: convencional` (o padrão) no config.
- O `sdd-release proxima` calcula a próxima versão pelos commits desde a última release em produção (ou a última tag final): `!` ou `BREAKING CHANGE:` é major, minor antes da 1.0.0; `feat` é minor; o resto é patch. O `sdd-release analisar` mostra a conta e o motivo. A versão é uma **sugestão**: a pessoa decide no `/sdd:release`.
- O `sdd-release changelog` gera a seção da versão no formato Keep a Changelog 1.1.0, com uma linha por feature (pelo título, no maior impacto) e as demais por commit, deixando de fora o que não muda o que o usuário vê.
- Pré-lançamentos (`X.Y.Z-rc.N`) contam as tags existentes e não viram a base do cálculo.

## Por quê

- São os padrões de mercado (os do semantic-release e do release-please), e o formato de commit do plugin (`tipo(NNN): T-XXX`) já era quase este.
- Escolher a versão de memória falha justamente no caso caro: uma quebra de contrato que sai como minor. Com o tipo no commit, a informação está onde a mudança foi feita.
- A decisão continua humana porque um commit mal classificado existe, e o `/sdd:release` confere a sugestão contra as features da release.
- O changelog técnico (`CHANGELOG.md`) e as notas de negócio (`notas.md`) têm leitores diferentes; os dois ficam.

## Consequências

- `commits` é uma chave nova do `.sdd/config.yml`, e o formato da mensagem de commit entra no contrato público.
- Commits fora do padrão não contam para a versão; o `analisar` os lista. Em projeto adotado, os commits anteriores à tag da versão em produção não importam, e o `sdd-gitflow conferir` avisa quando nenhuma tag segue `vX.Y.Z`.
- O `sdd-release proxima` sem argumento passou de "minor" para "auto".
