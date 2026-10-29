# /sdd:pipeline

## O que faz

Gera, ou confere, o pipeline de CI/CD do projeto a partir da constituição e do
`.sdd/config.yml`, para GitHub Actions ou GitLab CI. O pipeline roda lint,
testes, a verificação do processo SDD (`sdd-verificar`) e as varreduras de
segurança em todo push, implanta em homologação na branch de integração, e só
implanta em produção pela tag `vX.Y.Z` **se a release tiver o go registrado**.
Ele não grava segredos no arquivo.

## Quando usar

Você digita `/sdd:pipeline`; o agente não o usa por conta própria. Use logo
depois do [`/sdd:iniciar`](iniciar.md), e de novo quando os ambientes ou os
comandos do projeto mudarem. `/sdd:pipeline conferir` revisa um pipeline que já
existe sem alterar nada.

## Pré-requisitos

A constituição com a seção "Ambientes e entrega" preenchida. O agente propõe os
comandos que faltarem no config.

## Os estágios

| Estágio | Quando roda | Falha se |
|---|---|---|
| verificar | todo push e pull request | lint, testes ou `sdd-verificar` falham |
| seguranca | todo push e pull request | vulnerabilidade alta ou crítica, segredo exposto |
| homologacao | push em `release/**` ou `hotfix/**` (Git Flow) | o deploy falha |
| producao | tag `vX.Y.Z` | a release não tem o go (`sdd-release pode-implantar`), ou o deploy ou a verificação falham |

## O que o `sdd-verificar` confere

| Falha (bloqueia o merge) | Aviso (bloqueia só com `--estrito`) |
|---|---|
| feature do green em diante com lacuna de rastreabilidade | feature pronta não consolidada na spec do sistema |
| feature pronta ou em homologação com spec, testes, plano ou revisão de segurança alterados depois da aprovação | incidente S1 ou S2 não encerrado |
| release em andamento com feature fora da fase esperada | hotfix sem spec aprovada |
| pull request fora do Git Flow (ex.: `feature/*` direto para `main`) | branch fora do padrão do Git Flow |
| | artefato de processo fora do lugar do padrão; feature adotada ainda em transição |

## Perguntas frequentes

**O hook já não protege isso?**

O hook protege na hora, na máquina de quem está trabalhando, e é fail-open. O
pipeline é a garantia determinística, igual para todo o time, antes do merge.

**De onde o CI tira os utilitários do SDD?**

Clona o repositório do plugin numa versão fixa (`SDD_VERSAO`), para o pipeline
não mudar sozinho quando o plugin for atualizado.

## Está funcionando se

- Um pull request com uma spec alterada depois de aprovada fica vermelho.
- Criar a tag de uma release sem go não implanta nada.
- Nenhum segredo aparece no arquivo do pipeline.

## Onde se encaixa

Configuração de uma vez, logo depois do [iniciar](iniciar.md). É a parte
automática da [release](release.md). O mapa está na [ajuda](ajuda.md).
