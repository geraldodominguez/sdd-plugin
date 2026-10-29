# Git Flow com nomes fixos, ligado ao ciclo do SDD

## Decisão

- Todo projeto usa o mesmo Git Flow: `main` (produção, só por merge, com a tag `vX.Y.Z`), `develop` (integração), `feature/NNN-slug` (o id da pasta `specs/NNN-slug/`), `release/X.Y.Z` e `hotfix/X.Y.Z`. Os nomes **não** são configuráveis. O config só escolhe `gitflow: ativo|desligado` e `integracao: local|pr`.
- Cada momento do ciclo tem o seu passo no git, feito pelo `sdd-gitflow` a pedido das skills: `/sdd:iniciar` cria `develop`; `/sdd:especificar` cria a branch da feature; `/sdd:aprovar` integra a feature pronta em `develop`; `/sdd:release` cria `release/X.Y.Z` e, depois do go, a leva a `main` com a tag e de volta a `develop`; `/sdd:incidente` cria `hotfix/X.Y.Z` a partir de `main`.
- O estado da feature guarda a branch (`branch=`), porque a do hotfix (`hotfix/X.Y.Z`) não se deduz do id.
- O hook `guarda-commits` bloqueia criar branch com nome fora do padrão, commit em `main`, commit numa branch fora do padrão e commit da feature ativa fora da branch dela. O `sdd-verificar` falha com pull request num fluxo que o padrão não permite.
- O `sdd-gitflow` nunca faz push, nunca apaga branch remota, nunca reescreve histórico, recusa trocar de branch com alterações pendentes, recusa levar uma release a `main` sem o go registrado e não escreve nos históricos do SDD.
- O `/sdd:iniciar` põe os históricos do SDD com `merge=union` no `.gitattributes`.

## Por quê

- O problema que motivou o layout de pastas (cada agente com a sua estrutura) se repete nas branches: `develop` num projeto, `development` noutro, `feat/` aqui, `feature-` ali. Nomes fixos deixam os scripts, o CI e as regras de proteção da plataforma iguais em todo projeto.
- Ligar o Git Flow às fases dá significado a cada branch: `develop` só tem features prontas, `main` só tem o que passou pelo go, e a tag é o que o pipeline implanta, conferindo o go.
- Os históricos só recebem linhas. Sem o `union`, todo merge entre uma branch de hotfix e `develop` daria conflito neles.
- Push, exclusão remota e reescrita afetam outras pessoas; ficam com o humano.

## Consequências

- `branch` é uma chave nova em `specs/NNN/estado`, e `gitflow` e `integracao` são chaves novas do `.sdd/config.yml`: entram no contrato público.
- Um projeto que não pode usar estes nomes desliga o Git Flow (`gitflow: desligado`) e perde a conferência de branches, não o resto do SDD.
- Correção de bug que não é urgente é uma feature como outra (`feature/`); não existe `bugfix/`.
- O hook só lê as formas comuns de criar branch (`checkout -b`, `switch -c`, `branch`, `branch -m`); o resto aparece no `sdd-gitflow conferir`, no `/sdd:pendencias` e no CI.
