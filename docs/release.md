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

## A versão

| Mudança na release | Versão |
|---|---|
| quebra um contrato público (API, evento, schema consumido por outros) | major |
| traz capacidade ou comportamento novo | minor |
| só correções | patch |

`sdd-release proxima <tipo>` calcula a partir da última release em produção.

## Perguntas frequentes

**Uma feature foi reprovada na homologação. Perco a release?**

Não. `reprovar` devolve a feature ao green e a release à preparação; você
decide se ela segue sem a feature (refazendo testes e homologação) ou espera a
correção.

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
