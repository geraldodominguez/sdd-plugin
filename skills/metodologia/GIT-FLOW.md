# Git Flow no SDD

Todo projeto com o SDD usa o mesmo Git Flow, com os **mesmos nomes**. Não
adapte, não traduza, não invente variações (`development`, `master`,
`feat/`, `bugfix/`, `release-1.2`).

| Branch | Para quê | Sai de | Volta para |
|---|---|---|---|
| `main` | o que está em produção; cada versão é uma tag `vX.Y.Z` | | |
| `develop` | integração: as features prontas | `main` (uma vez) | |
| `feature/NNN-slug` | uma feature do SDD, com o mesmo id da pasta `specs/NNN-slug/` | `develop` | `develop` |
| `release/X.Y.Z` | uma release, da preparação ao go/no-go | `develop` | `main` (com a tag) e `develop` |
| `hotfix/X.Y.Z` | a correção de um incidente | `main` | `main` (com a tag) e `develop` |

Fluxos permitidos (o `sdd-verificar` recusa o resto nos pull requests):
`feature/*` para `develop`; `release/*` e `hotfix/*` para `main` ou `develop`;
`main` para `develop`.

## Cada evento do SDD e o que acontece no git

| Evento | Comando do SDD | Git Flow |
|---|---|---|
| preparar o repositório | `/sdd:iniciar` | `sdd-gitflow iniciar`: garante `main` e cria `develop`; o commit do SDD vai em `develop` |
| abrir uma feature | `/sdd:especificar` | `sdd-gitflow feature NNN-slug`: cria `feature/NNN-slug` a partir de `develop` e muda para ela |
| trabalhar na feature | todas as fases | commits em `feature/NNN-slug`, no formato `tipo(NNN): T-XXX descrição` |
| feature pronta | `/sdd:aprovar` | `sdd-gitflow integrar NNN-slug` (merge `--no-ff` em `develop`), ou pull request para `develop` |
| preparar a release | `/sdd:release preparar` | `sdd-gitflow release X.Y.Z`: cria `release/X.Y.Z` a partir de `develop`; a homologação usa esta branch |
| correção durante a homologação | `/sdd:release` (feature reprovada) | commits em `release/X.Y.Z` |
| go/no-go | `/sdd:release implantar` | depois do go: `sdd-gitflow finalizar X.Y.Z` (merge em `main`, tag `vX.Y.Z`, merge em `develop`); o push da tag dispara o deploy |
| incidente | `/sdd:incidente hotfix` | `sdd-gitflow hotfix X.Y.Z`: cria `hotfix/X.Y.Z` a partir de `main`; a release de correção tem a mesma versão |

## Regras

1. Nunca faça commit em `main`. Ela só recebe merge, pelo `sdd-gitflow finalizar`, depois do go.
2. Com uma feature ativa em construção ou revisão, o commit é na branch dela (`sdd-gitflow esperada` diz qual). O hook bloqueia o resto.
3. Nunca crie branch à mão com outro nome. Use `sdd-gitflow feature`, `release` ou `hotfix`.
4. Uma branch `feature/` só existe para uma feature que existe em `specs/`.
5. Nunca faça push, force-push, rebase de branch publicada ou exclusão de branch remota sem pedir ao usuário. O `sdd-gitflow` nunca faz push: ele diz o comando.
6. Antes de trocar de branch, as alterações precisam estar commitadas. O `sdd-gitflow` recusa se não estiverem.
7. Conflito num merge: pare, mostre os arquivos ao usuário e resolva com ele. Não escolha um lado sozinho.

## Integração local ou por pull request

A chave `integracao` do `.sdd/config.yml` diz como uma branch entra em outra:

| `integracao` | Feature pronta | Release com o go |
|---|---|---|
| `local` | `sdd-gitflow integrar NNN-slug` | `sdd-gitflow finalizar X.Y.Z` |
| `pr` | `gh pr create --base develop --head feature/NNN-slug` | `gh pr create --base main --head release/X.Y.Z`; depois do merge na plataforma e do `git pull` em `main`, `sdd-gitflow finalizar X.Y.Z --apos-pr` (tag e `develop`) |

Com `gitflow: desligado` no config, nada disto vale: o plugin não cria nem
confere branches.
