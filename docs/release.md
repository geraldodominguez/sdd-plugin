# /sdd:release

## O que faz

Leva features prontas à produção, em quatro gates humanos: testes de sistema,
aceite do negócio, go/no-go e verificação em produção. Cuida da versão SemVer,
chama o `testador-de-sistema`, escreve o roteiro de homologação em linguagem de
negócio, o plano de implantação com rollback e as notas da versão. Ele nunca
implanta sem o go registrado, e nunca registra um aceite em nome de quem não
homologou.

## Quando usar

Você digita `/sdd:release`; o agente não o usa por conta própria.

| Momento | Digite |
|---|---|
| há features prontas e é hora de entregar | `/sdd:release preparar` |
| a versão está no ambiente de homologação | `/sdd:release homologar` |
| quem homologou terminou o roteiro | `/sdd:release aceitar` |
| hora de decidir se vai para produção | `/sdd:release implantar` |
| a verificação em produção passou | `/sdd:release concluir` |
| a implantação deu errado | `/sdd:release reverter` |
| a release não vai sair (antes do go) | `/sdd:release cancelar` |
| ver a release em andamento | `/sdd:release` |

## Pré-requisitos

Features **prontas** e consolidadas na spec do sistema. Para implantar pelo
agente, os comandos de deploy no `.sdd/config.yml`; para implantar pelo CI, o
pipeline do [`/sdd:pipeline`](pipeline.md).

## A release passo a passo

```
preparacao -> homologacao -> aceita -> implantacao -> producao
```

| Situação | O que existe | O que falta para avançar |
|---|---|---|
| preparacao | `release.md` com as features | `testes.md` com resultado aprovado, roteiro em `homologacao.md` |
| homologacao | o roteiro sendo executado | nenhum passo pendente ou reprovado; o aceite de quem homologou |
| aceita | aceite registrado | `implantacao.md` (passos, verificação, rollback) e `notas.md` completos; o go |
| implantacao | go registrado; o pipeline aceita a tag | implantar e verificar |
| producao | tudo no `historico.md` da release | |

**Testes de sistema** são o que o TDD de cada feature não cobre: a regressão
completa, os fluxos ponta a ponta afetados e os requisitos não funcionais
medidos. **Homologação** é a validação de quem usa: o roteiro vem dos critérios
de aceitação, reescritos sem termos técnicos. **Go/no-go** é uma pergunta
explícita, respondida depois de ler o plano de implantação e o rollback.

## As branches

| Momento | No git (Git Flow) |
|---|---|
| `preparar` | `release/X.Y.Z` nasce de `develop`; o push dela vai para homologação |
| passo reprovado na homologação | a feature sai da release e passa a ser corrigida em `release/X.Y.Z`; pronta de novo, volta com `sdd-release incluir`, sem passar por `develop` |
| go no `implantar` | `sdd-release autorizar` e o commit `chore(release): X.Y.Z autorizada` (o `finalizar` exige tudo commitado); depois, `sdd-gitflow finalizar X.Y.Z`: merge em `main`, tag `vX.Y.Z`, merge de volta em `develop`. O push da tag dispara o deploy de produção |
| release de hotfix | a branch é a `hotfix/X.Y.Z` do incidente, com a mesma versão |

Com `integracao: pr`, você publica a branch, a release vai para `main` por
pull request, e o `sdd-gitflow finalizar X.Y.Z --apos-pr` faz a tag e o merge
de `main` em `develop`. Ver
[Git Flow](referencia/git-flow.md).

## A versão

SemVer, calculado pelos commits (Conventional Commits) desde a última release
em produção. O `sdd-release analisar` mostra a sugestão e o motivo; você decide.

| Os commits da release têm | Versão |
|---|---|
| `!` ou `BREAKING CHANGE:` (quebra um contrato público) | major (antes da 1.0.0, minor) |
| `feat` (comportamento novo) | minor |
| só `fix`, `perf` ou manutenção | patch |

Antes do go, o `sdd-release changelog X.Y.Z --escrever` grava a seção da versão
no `CHANGELOG.md` (formato Keep a Changelog). Detalhes em
[versionamento](referencia/versionamento.md).

**Release candidate** (`X.Y.Z-rc.N`, de `sdd-release proxima --pre rc`):
serve para homologar antes de fechar a versão. Ele passa por preparar,
homologar e aceitar, e **nunca** vai para produção (o `autorizar` e o
`finalizar` o recusam). Com o aceite, o agente cancela o candidate (as features
voltam a prontas), faz o commit e leva a branch dele a `develop`, com as
correções e o registro, e prepara a versão final com as mesmas features.

## Perguntas frequentes

**Uma feature foi reprovada na homologação. Perco a release?**

Não. `reprovar` tira a feature da release, devolve-a ao green e põe a release
de volta na preparação. Você decide:

- **esperar a correção:** ela é feita na própria `release/X.Y.Z`
  (`/sdd:implementar` vai para lá), a feature volta a ficar pronta com o
  `/sdd:aprovar`, entra de novo com `sdd-release incluir`, e os testes de
  sistema e a homologação são refeitos;
- **seguir sem ela:** a release refaz testes e homologação só com as outras, e
  a correção espera a release terminar, numa `feature/NNN-slug` nova a partir
  de `develop`.

**A release não vai mais sair. E agora?**

`/sdd:release cancelar`, antes do go: as features voltam a prontas e podem
entrar noutra release. O agente faz o commit do cancelamento na
`release/X.Y.Z` e recomenda levá-la a `develop`, com as correções e o registro
(você pode preferir descartar as correções). Depois do go, não se
cancela: o caminho é reverter.

**Sou eu mesmo que homologo. Faz sentido?**

Faz: o aceite separa o momento de construir do momento de validar como
usuário. Use o roteiro de verdade, no ambiente de homologação, e registre seu
nome.

**Posso implantar só uma feature, sem esperar as outras?**

Sim: uma release pode ter uma feature só. Releases pequenas e frequentes
reduzem o risco de cada implantação.

## Está funcionando se

- Cada release tem, no `historico.md`, testes aprovados, aceite com nome, go e verificação.
- O roteiro de homologação é legível por quem não é desenvolvedor.
- Nenhuma tag de produção implantou sem o go (o pipeline confere).

## Onde se encaixa

Etapa de entrega, depois que as features ficam prontas ([aprovar](aprovar.md),
[sistema](sistema.md)). Implantação automatizada pelo [pipeline](pipeline.md);
problemas depois da implantação seguem para o [incidente](incidente.md). O mapa
está na [ajuda](ajuda.md).
