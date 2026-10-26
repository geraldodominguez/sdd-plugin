---
name: pipeline
description: Gera ou confere o pipeline de CI/CD do projeto a partir da constituição. Inclui lint, testes, verificação do processo SDD (rastreabilidade e aprovações), varreduras de segurança, implantação em homologação e implantação em produção condicionada ao go/no-go da release.
argument-hint: "[gerar | conferir] [github | gitlab]"
disable-model-invocation: true
allowed-tools: Bash(sdd-verificar *), Bash(sdd-estado *), Bash(git remote *), Bash(git ls-files *), Read, Write, Edit, Glob, Grep
---

# /sdd:pipeline

Pedido: `$ARGUMENTS` (vazio significa conferir se já existe, ou gerar se não existir)

O pipeline é onde o processo deixa de depender da boa vontade de quem está
digitando: o que o hook não pega na hora, o CI pega antes do merge.

## Os estágios

| Estágio | Quando roda | O que faz | Falha se |
|---|---|---|---|
| verificar | todo push e pull request | lint, testes, `sdd-verificar` | qualquer falha |
| seguranca | todo push e pull request | `comando_seguranca` | vulnerabilidade alta ou crítica, segredo |
| homologacao | push na branch de integração (ex.: `main`) | `comando_deploy_homologacao` | deploy falha |
| producao | tag `vX.Y.Z` | `sdd-release pode-implantar X.Y.Z`, depois `comando_deploy_producao` e `comando_verificacao_producao` | a release não tem o go registrado, ou o deploy ou a verificação falham |

O estágio de produção **confere o go/no-go**: sem `sdd-release autorizar`, a
tag não implanta nada.

## Gerar

1. **Descubra a plataforma.** `git remote -v`, `.github/`, `.gitlab-ci.yml`.
   Na dúvida, pergunte.
2. **Leia a constituição** (stack, seção "Ambientes e entrega", segurança) e o
   `.sdd/config.yml`. Para cada comando vazio (`comando_lint`, `comando_teste`,
   `comando_seguranca`, `comando_deploy_*`, `comando_verificacao_producao`),
   proponha um valor a partir da stack e confirme. Grave no config.
3. **Parta do template** da plataforma (`sdd-estado template pipeline/github-actions.yml`
   ou `pipeline/gitlab-ci.yml`) e adapte: instalação da stack, comandos, nomes de
   ambiente, branch de integração. A versão do plugin usada no CI fica fixa
   (`SDD_VERSAO`) para o pipeline não mudar sozinho.
4. **Mostre o arquivo** e explique cada estágio em uma linha. Escreva só com
   aprovação. Avise o que precisa ser configurado fora do repositório
   (segredos, proteção dos ambientes, revisores obrigatórios do ambiente de
   produção).
5. Rode `sdd-verificar` localmente e mostre o resultado: é o que o CI vai ver.

## Conferir

Leia o pipeline existente e compare com a tabela de estágios. Aponte, sem
alterar: estágios ausentes, produção implantando sem conferir o go, comandos
divergentes do config, segredos expostos no arquivo. Ofereça gerar a correção.

## Não faça

- Não grave segredos no arquivo do pipeline.
- Não ative implantação em produção sem o passo `sdd-release pode-implantar`.

## Pronto quando

- O pipeline tem os quatro estágios, o `.sdd/config.yml` tem os comandos, e o usuário sabe o que configurar na plataforma.
