# Utilitários

Treze scripts em bash, na pasta `bin/` do plugin. Nas sessões do Claude Code com
o plugin ativo, eles ficam no PATH. Fora delas (no terminal, no CI), chame pelo
caminho completo ou ponha `bin/` no PATH. Os comandos `/sdd:*` usam esses
utilitários por baixo; você raramente precisa chamá-los direto, mas eles servem
para scripts, para o CI e para conferir algo rápido. Todos aceitam `--ajuda`.

A configuração de cada projeto (todas as chaves do `.sdd/config.yml`) está em
[A configuração](#a-configuração-sddconfigyml).

| Utilitário | Para quê |
|---|---|
| [`sdd-iniciar`](#sdd-iniciar) | prepara o projeto |
| [`sdd-estado`](#sdd-estado) | features: criar, fases, aprovações, cancelar, reabrir, histórico |
| [`sdd-sistema`](#sdd-sistema) | spec viva do sistema, por capacidade |
| [`sdd-release`](#sdd-release) | releases: preparação, homologação, go/no-go, produção |
| [`sdd-incidente`](#sdd-incidente) | incidentes, hotfix e post-mortem |
| [`sdd-backlog`](#sdd-backlog) | itens sem spec |
| [`sdd-sprint`](#sdd-sprint) | sprints |
| [`sdd-status`](#sdd-status) | o quadro e o detalhe de uma feature |
| [`sdd-pendencias`](#sdd-pendencias) | o que espera decisão humana |
| [`sdd-rastrear`](#sdd-rastrear) | lacunas de rastreabilidade de uma feature |
| [`sdd-verificar`](#sdd-verificar) | o processo do projeto inteiro, para o CI |
| [`sdd-adotar`](#sdd-adotar) | artefatos de outros processos: inventário e mudança para o padrão |
| [`sdd-gitflow`](#sdd-gitflow) | o Git Flow: branches com nomes fixos, integração, release e hotfix |

## Onde o estado mora

| Arquivo | Conteúdo | Escrito por |
|---|---|---|
| `.sdd/estado` | ponteiros pessoais: `feature=` (ativa) e `sprint=` (atual); fora do git | `sdd-estado`, `sdd-sprint` |
| `specs/NNN-slug/estado` | `fase`, `nivel`, `origem`, `tipo`, `seguranca`, `capacidade`, `release`, `adocao` (só nas adotadas: `transicao` ou `regularizada`), `branch` (a do Git Flow: `feature/NNN-slug`, ou `hotfix/X.Y.Z` num hotfix), `atualizado` | `sdd-estado`, `sdd-release`, `sdd-adotar`, `sdd-incidente` |
| `specs/NNN-slug/historico.md` | eventos da feature: `criada`, `fase`, `aprovacao` (inclusive a da transição), `reabertura`, `cancelamento`, `nivel`, `seguranca`, `capacidade`, `release` (inclusão e remoção), `consolidacao`, `incidente` (os ligados a ela) e `adocao` (com o hash de cada original) | `sdd-estado`, `sdd-sistema`, `sdd-release`, `sdd-incidente`, `sdd-adotar` |
| `releases/<versão>/estado` | `fase` da release, `tipo` (normal ou hotfix), `atualizado` | `sdd-release` |
| `releases/<versão>/historico.md` | `criada`, `inclusao`, `remocao`, `testes`, `aceite`, `reprovacao`, `autorizacao` (o go), `verificacao` e `situacao` (cada mudança de situação, inclusive para `cancelada` e `revertida`) | `sdd-release` |
| `.sdd/historico.md` | eventos do projeto: `backlog`, `sprint`, `release`, `incidente`, `sistema` (capacidades) e `adocao` | `sdd-backlog`, `sdd-sprint`, `sdd-release`, `sdd-incidente`, `sdd-sistema`, `sdd-adotar` (o `sdd-gitflow` não escreve histórico) |
| `.sdd/backlog.md`, `.sdd/sprints/<id>.md` | itens e sprints | `sdd-backlog`, `sdd-sprint`, e você |
| `sistema/<capacidade>.md` | comportamento vigente | o agente, com a sua confirmação; `sdd-sistema` registra |
| `incidentes/INC-NNN.md` | um incidente | `sdd-incidente`, e você |
| `.sdd/adocao.md` | de onde veio cada artefato adotado | `sdd-adotar` |

Os arquivos `estado` e `historico.md` (de features e de releases), o
`.sdd/estado`, o `.sdd/historico.md` e o `.sdd/adocao.md` são protegidos pelo
hook: o agente não consegue editá-los à mão. O resto do `.sdd/` (config,
constituição, backlog, sprints, templates) é editável. Linha
do histórico:

```
- 2026-10-23T18:40:30Z | aprovacao | spec.md | hash=2533c54be22d | por: Geraldo Dominguez
```

O autor é o `git config user.name` (ou a variável `SDD_AUTOR`).

---

## A configuração: .sdd/config.yml

Uma chave por linha (`chave: valor`); `#` começa um comentário. Todas as
chaves, com o valor que o `/sdd:iniciar` grava:

| Chave | Valor inicial | Para quê | Detalhes |
|---|---|---|---|
| `nivel_padrao` | `1` | nível de rigor sugerido para feature nova (1 ou 2) | [níveis de rigor](niveis-de-rigor.md) |
| `protecao` | `leve` | o quanto os hooks impõem o fluxo: `desligada`, `leve` ou `estrita` | [proteção por hooks](protecao-por-hooks.md) |
| `gitflow` | `ativo` | Git Flow com nomes fixos: `ativo` ou `desligado` | [Git Flow](git-flow.md) |
| `integracao` | `local` | como uma branch entra em outra: `local` (merge pelo `sdd-gitflow`) ou `pr` (pull request) | [Git Flow](git-flow.md#5-integração-local-ou-por-pull-request) |
| `commits` | `convencional` | mensagens de commit em Conventional Commits (`convencional`) ou sem conferência (`livre`) | [versionamento](versionamento.md) |
| `pasta_specs` | `specs` | pasta das features | |
| `pasta_sistema` | `sistema` | pasta da spec viva do sistema | |
| `pasta_releases` | `releases` | pasta das releases | |
| `pasta_incidentes` | `incidentes` | pasta dos incidentes | |
| `globs_de_teste` | `tests/**,test/**,__tests__/**,spec/**,**/*.test.*,**/*.spec.*,**/*_test.*,**/test_*.py,**/*Test.java,**/*Tests.cs` | o que conta como arquivo de teste (hooks e `sdd-rastrear`) | [proteção por hooks](protecao-por-hooks.md#o-que-conta-como-teste) |
| `globs_de_contrato` | vazio | contratos em código que o `arquiteto-de-contratos` pode materializar na proteção estrita | [proteção por hooks](protecao-por-hooks.md#o-que-conta-como-contrato-em-código) |
| `areas_sensiveis` | vazio | código cuja mudança torna a revisão de segurança obrigatória, mesmo no nível 1 | [/sdd:seguranca](../seguranca.md) |
| `excecoes_de_layout` | vazio | arquivos com nome de artefato que não são do SDD (o hook e o inventário os ignoram) | [proteção por hooks](protecao-por-hooks.md#arquivos-novos-só-no-lugar-do-padrão) |
| `comando_teste` | vazio | a suíte de testes | |
| `comando_lint` | vazio | lint e checagem de tipos | |
| `comando_seguranca` | vazio | varreduras de dependências, segredos e código | |
| `comando_teste_sistema` | vazio | testes ponta a ponta e de carga (`testador-de-sistema`) | |
| `comando_deploy_homologacao` | vazio | implanta em homologação | [/sdd:release](../release.md) |
| `comando_deploy_producao` | vazio | implanta em produção (só depois do go) | [/sdd:release](../release.md) |
| `comando_verificacao_producao` | vazio | verificação pós-implantação | [/sdd:release](../release.md) |

Mudar `pasta_*` depois de ter features move a responsabilidade para você:
mova as pastas junto, ou os utilitários não as encontram.

## sdd-iniciar

```
sdd-iniciar [--forcar] [--nivel 1|2] [--protecao desligada|leve|estrita]
```

Cria `.sdd/` (config, constituição, estado, backlog, sprints, templates),
`specs/`, `sistema/` e `docs/adr/` no diretório atual (ou em
`$CLAUDE_PROJECT_DIR`), injeta o bloco de regras no `CLAUDE.md` e no
`AGENTS.md`, e acrescenta ao `.gitattributes` o merge por união dos históricos
(para os merges do Git Flow). Não sobrescreve nada sem `--forcar`.

**Num projeto que já usa o SDD**, rodar de novo sem `--forcar` é a
atualização: cria só o que falta (como um template novo), atualiza o bloco de
regras e o `.gitattributes`, e mantém config, constituição e templates. A saída
lista os templates que diferem dos do plugin (`~`), para você comparar antes de
trocar, e as chaves do config que o projeto ainda não tem (`?`), com o valor
padrão que vale enquanto elas faltam:

```
Templates diferentes dos do plugin (compare antes de trocar: o projeto pode tê-los customizado):
  ~ .sdd/templates/tarefas.md
Chaves que o .sdd/config.yml não tem (até serem acrescentadas, vale o padrão do plugin):
  ? gitflow: ativo
  ? commits: convencional

Projeto atualizado. Revise os templates e as chaves acima; a constituição e o config não foram alterados.
```

Com `--forcar`, config, constituição e templates são sobrescritos pelos do
plugin: só quando você quer recomeçar a configuração.

## sdd-estado

```
sdd-estado ver [chave]
sdd-estado definir chave=valor [...]      fase, nivel, seguranca, capacidade, feature, sprint
sdd-estado nova "título" [--nivel N] [--origem B-NNN|INC-NNN] [--tipo hotfix]
               [--capacidade nome] [--seguranca obrigatoria|dispensada]
sdd-estado usar NNN-slug
sdd-estado aprovar [artefato] [--decisao D] [--sem-avancar] [--nota "texto"]
sdd-estado aprovado <artefato> [NNN-slug]
sdd-estado cancelar --motivo "texto"
sdd-estado reabrir [NNN-slug] --motivo "texto" [--fase especificacao|green] [--origem X]
sdd-estado sensivel [ref]
sdd-estado listar
sdd-estado historico [NNN-slug|--projeto] [--desde AAAA-MM-DD]
sdd-estado caminho [arquivo]
sdd-estado template nome.md
sdd-estado template --plugin nome.md      (o do plugin, para comparar com a cópia do projeto)
sdd-estado transicionar NNN-slug <pronta|homologacao|producao> "nota"   (uso interno do sdd-release)
```

**Fases:** `especificacao clarificacao plano tarefas red green seguranca
auditoria pronta homologacao producao`, e `cancelada`. O `definir fase=` só
aceita as fases de construção e revisão, e recusa uma feature que já está em
`pronta`, `homologacao`, `producao` ou `cancelada` (para ela, `reabrir`, ou `sdd-release reprovar` em homologação);
`pronta` vem da aprovação, `homologacao` e `producao` vêm da release,
`cancelada` do `cancelar`.

**Definir** também muda: `nivel=1|2` (o nível 2 torna a revisão de segurança
obrigatória), `seguranca=obrigatoria|dispensada` (no nível 2, `dispensada` é
recusada), `capacidade=` (uma ou mais, separadas por vírgula, como
`cadastro,autenticacao`; vazio limpa), `feature=` (a feature ativa) e
`sprint=` (a sprint ativa). As três primeiras valem para a feature ativa.

**Aprovar** registra a aprovação do artefato da fase atual e avança:

| Fase | Artefato | Decisão | Próxima fase |
|---|---|---|---|
| `especificacao`, `clarificacao` | `spec.md` | | `plano` (nível 2) ou `tarefas` (nível 1); num hotfix, a aprovação é registrada e a fase não muda |
| `plano` | `plano.md` (o hash inclui `contratos/`) | | `tarefas` |
| `tarefas` | `tarefas.md` | | `red` |
| `red` | `testes` (os blocos marcados `sdd:NNN:`) | | `green` |
| `green` (nível 1, sem segurança obrigatória) | a entrega | | `pronta` |
| `seguranca` | `seguranca.md` | `aprovar`, `aceitar-risco`, `corrigir` | `auditoria` (nível 2), `pronta` (nível 1), `green` |
| `auditoria` | `auditoria.md` | `aprovar`, `delta`, `corrigir` | `pronta` ou `green` |

Com um artefato explícito que não é o da fase (ex.: `aprovar spec.md` no
green), ou com `--sem-avancar`, só registra a aprovação, sem mudar a fase.

**Transição** (feature adotada, `adocao=transicao`): antes de tudo, o
`aprovar` sem artefato aprova a transição. Ele lê a "Fase de destino" do
`transicao.md` e confere que nada ali ficou por preencher (`{{...}}`):

| Destino | Aprovados junto, com `decisao: transicao` |
|---|---|
| `especificacao` | só o `transicao.md` |
| `plano` (só nível 2) | `spec.md` |
| `tarefas` | `spec.md`, e `plano.md` no nível 2 |
| `red` | `spec.md`, `tarefas.md` (com pelo menos uma linha de tarefa), e `plano.md` no nível 2 |

Os artefatos precisam existir sem campos do modelo, e a spec sem dúvidas em
aberto (exceto no destino `especificacao`). Aprovada, a feature fica
`adocao=regularizada` e vai para a fase de destino. Enquanto está em
transição, aprovar outro artefato e `definir fase=` são recusados.

**Para ficar `pronta`**, o utilitário confere: `spec.md` e testes aprovados e
inalterados; no nível 2, `plano.md` também; com segurança obrigatória,
`seguranca.md` também. Se algo falhar, a aprovação do artefato atual fica
registrada, a fase não avança, e a saída lista o que reaprovar.

**Aprovado** responde pelo código de saída:

| Saída | Significado |
|---|---|
| 0 | aprovado e inalterado desde a aprovação |
| 4 | alterado depois da aprovação |
| 5 | não aprovado, ou aprovação invalidada por reabertura |
| 1 | o artefato não existe |

No `tarefas.md`, marcar uma tarefa como feita (`[ ]` para `[x]`) é progresso,
não alteração: as duas caixas entram iguais no hash. Mudar o texto, acrescentar
ou tirar uma tarefa, ou trocar uma marca `[O]`, conta como alteração.

**Hash dos testes por bloco:** um bloco começa na linha com a marca
`sdd:NNN:` e vai até a marca de outra feature (ou o fim do arquivo). Testes que
outra feature acrescenta no mesmo arquivo não mudam o hash desta.

**Cancelar** vale para qualquer fase antes da homologação. **Reabrir** vale
para features `pronta` ou `cancelada` (nunca `producao`), volta para
`especificacao` (padrão) ou `green`, e invalida as aprovações dos artefatos da
fase de reabertura em diante. Uma feature cancelada sempre volta para
`especificacao`. Uma feature em `homologacao` não se reabre por aqui: quem a
devolve é o `sdd-release reprovar`, que mantém a release coerente.

**Sensível** lista os arquivos alterados (desde `ref`, mais os não commitados)
que casam com `areas_sensiveis` e, se houver, marca `seguranca=obrigatoria`.
Sem `ref`, a base é o início da feature: com o Git Flow, o ponto em que a branch
dela saiu de `develop`; sem ele, o commit anterior ao que criou a pasta da
feature. Saída 0 quando encontrou, 1 quando não.

**Número da feature nova:** o próximo livre, contando as pastas em `specs/` e,
com o Git Flow, as features que só existem nas suas branches (`feature/NNN-*`,
locais e remotas, e as pastas de `hotfix/` e `release/`). Duas features criadas
em paralelo a partir de `develop` nunca recebem o mesmo número.

**Hotfix** (`--tipo hotfix`, normalmente pelo `sdd-incidente hotfix`): nível 1,
origem obrigatória num incidente, nasce na fase `red`, sem tarefas; a entrega
exige a spec (retroativa) aprovada.

## sdd-sistema

```
sdd-sistema listar
sdd-sistema nova <capacidade> "título"
sdd-sistema ver <capacidade>
sdd-sistema consolidar <NNN-slug> [--sem-mudanca] [--nota "texto"]
sdd-sistema consolidada <NNN-slug>
sdd-sistema pendentes
```

`consolidar` exige a feature pronta (ou além), a capacidade definida e o arquivo
da capacidade citando a feature (`origem: NNN/...`). Com `--sem-mudanca`, só a
fase pronta (ou além) é exigida: a feature não mudou o comportamento descrito. Registra no histórico da
feature, acrescenta a linha no histórico da capacidade e atualiza "Última
feature". O texto da capacidade é editado antes, pelo agente.

## sdd-release

```
sdd-release proxima [auto|major|minor|patch] [--pre alpha|beta|rc]
sdd-release analisar
sdd-release changelog <versão> [--escrever]
sdd-release nova <versão> [--objetivo "texto"] [--hotfix]
sdd-release incluir <versão> <NNN-slug> [...]
sdd-release remover <versão> <NNN-slug>
sdd-release homologar <versão>
sdd-release aceitar <versão> --por "Nome e papel" [--nota "texto"]
sdd-release reprovar <versão> <NNN-slug> --motivo "texto"
sdd-release autorizar <versão> [--nota "texto"]
sdd-release pode-implantar <versão>
sdd-release concluir <versão> --verificacao "texto"
sdd-release reverter <versão> --motivo "texto"
sdd-release cancelar <versão> --motivo "texto"
sdd-release ver [versão] | listar | atual
```

**Versão** (SemVer pelos Conventional Commits; ver [versionamento](versionamento.md)):

| Comando | Faz |
|---|---|
| `proxima` (ou `proxima auto`) | a próxima versão pelos commits desde a versão de referência (a maior entre a última release em produção ou com o go e a última tag `vX.Y.Z` final; pré-lançamentos nunca contam); uma versão já usada (pasta, tag ou branch reservada) não se repete: `!` ou `BREAKING CHANGE:` é major (minor antes da 1.0.0), `feat` é minor, o resto é patch. Sem versão anterior, 0.1.0 |
| `proxima major\|minor\|patch` | a versão de um tipo explícito |
| `proxima --pre rc` | o próximo pré-lançamento (`X.Y.Z-rc.N`, contando as tags existentes) |
| `analisar` | os commits desde a última versão, por impacto, os fora do padrão e a sugestão com o motivo |
| `changelog <versão>` | a seção da versão no formato Keep a Changelog: uma linha por feature (pelo título, no maior impacto), as demais por commit; `docs`, `chore`, `refactor`, `test`, `build`, `ci`, `style`, `revert` e os commits fora do padrão ficam de fora |
| `changelog <versão> --escrever` | grava a seção no `CHANGELOG.md` (cria o arquivo se faltar), abaixo de `## [Não lançado]`; recusa versão repetida |

| Comando | De | Para | Exige |
|---|---|---|---|
| `nova` | | `preparacao` | versão SemVer nova |
| `incluir` | `preparacao` | | features `pronta` |
| `remover` | `preparacao` | | a feature estar na release |
| `homologar` | `preparacao` | `homologacao` | features prontas e com aprovações em dia; `testes.md` completo com `Resultado: aprovado`; roteiro (`| H-NNN |`) em `homologacao.md` |
| `aceitar` | `homologacao` | `aceita` | roteiro com passos `H-NNN`, nenhum `pendente` ou `reprovado`, nenhum campo `{{...}}`; `--por` |
| `reprovar` | `homologacao`, `aceita` | `preparacao` | a feature reprovada sai da release e volta ao green (com o Git Flow, a `release/<versão>` passa a ser a branch dela, onde a correção é feita); as demais voltam a `pronta`. Pronta de novo, a feature volta com `incluir` |
| `autorizar` (go) | `aceita` | `implantacao` | `implantacao.md` (com Rollback) e `notas.md` completos; não vale para pré-lançamento (`X.Y.Z-rc.N`) |
| `concluir` | `implantacao` | `producao` | `--verificacao`; as features vão para `producao` |
| `reverter` | `implantacao`, `producao` | `revertida` | as features voltam a `pronta` |
| `cancelar` | `preparacao`, `homologacao`, `aceita` | `cancelada` | as features voltam a `pronta` |

`pode-implantar` sai com 0 se a release está em `implantacao` ou `producao`. É
o passo que o pipeline roda antes de implantar em produção (aceita `v1.2.0` ou
`1.2.0`).

## sdd-incidente

```
sdd-incidente abrir "título" --severidade S1|S2|S3|S4 [--feature NNN-slug] [--release X.Y.Z]
sdd-incidente situacao INC-NNN mitigado|resolvido [--nota "texto"]
sdd-incidente nota INC-NNN "texto"
sdd-incidente hotfix INC-NNN "título" [--capacidade nome]
sdd-incidente encerrar INC-NNN
sdd-incidente listar [--abertos]
sdd-incidente ver INC-NNN
```

Situações: `aberto`, `mitigado`, `resolvido`, `encerrado`. Cada mudança entra
na linha do tempo do arquivo. `encerrar` exige `resolvido` e o post-mortem sem
campos `{{...}}` e com ao menos uma ação.

## sdd-backlog

```
sdd-backlog listar [--todos]
sdd-backlog adicionar "título" [--prioridade alta|media|baixa] [--nivel 1|2|?] [--origem "texto"]
sdd-backlog ver B-NNN
sdd-backlog prioridade B-NNN alta|media|baixa
sdd-backlog promover B-NNN NNN-slug
sdd-backlog descartar B-NNN "motivo"
sdd-backlog contar
```

Formato da linha: `- [ ] B-NNN título (prioridade: alta; nivel: 2; origem: texto; criado: AAAA-MM-DD)`.

## sdd-sprint

```
sdd-sprint nova [id] --objetivo "texto" [--inicio AAAA-MM-DD] [--fim AAAA-MM-DD | --dias N]
sdd-sprint incluir <id> <NNN-slug|B-NNN> [...]
sdd-sprint remover <id> <item>
sdd-sprint iniciar <id>
sdd-sprint encerrar [id]
sdd-sprint ver [id] | listar | itens [id]
```

O id padrão é a semana ISO do início (`2026-S44`). Conta como entregue a feature
pronta, em homologação ou em produção.

## sdd-status

```
sdd-status               o quadro
sdd-status <NNN-slug>    o detalhe de uma feature
sdd-status --ativa       o detalhe da feature ativa
```

No detalhe, cada artefato aparece com `✓` (existe, com a situação da
aprovação), `✗` (alterado depois de aprovado) ou `·` (ainda não existe). Com o
Git Flow, a linha `branch:` de uma feature pronta diz se ela já está em
`develop`, inclusive quando a branch local foi apagada depois do `integrar`.

## sdd-pendencias

```
sdd-pendencias [--contar]
```

Incidentes, releases paradas, aprovações pendentes ou invalidadas (inclusive
a transição de uma feature adotada, e um artefato de fase anterior alterado
depois de aprovado, como a spec mexida durante o green), revisões de segurança devidas, dúvidas,
delta specs e ADRs propostos, consolidações pendentes, prontas fora de release,
backlog a triar, itens da sprint sem spec, artefatos **fora do padrão** (com
`/sdd:iniciar --adotar`) e problemas de **Git Flow** (falta de `develop`, branch
fora do padrão, feature pronta ainda não integrada em `develop`, release com o
go e sem a tag `vX.Y.Z`).

## sdd-rastrear

```
sdd-rastrear [NNN-slug] [--silencioso]
```

| Verifica | Lacuna apontada |
|---|---|
| todo RF e RNF tem tarefa | "RF-002 está na spec, mas nenhuma tarefa o atende" |
| todo CA tem tarefa | idem, para CA |
| todo CA tem teste com a marca `sdd:NNN:CA-XXX` | "CA-003 não tem teste com a marca 004:CA-003" |
| toda tarefa referencia algo | "T-005 não referencia nenhum requisito ou critério" |
| as tarefas só citam IDs que existem | "tarefas.md cita RF-009, que não existe na spec" |
| o `tarefas.md` existe | "tarefas.md ainda não existe" |
| há arquivos de teste (pelos `globs_de_teste`) | "Nenhum arquivo de teste encontrado" |

Num hotfix sem `tarefas.md`, só a ligação critério e teste é conferida. Saída:
`0` sem lacunas, `3` com lacunas, `1` erro de uso.

## sdd-verificar

```
sdd-verificar [--estrito] [--silencioso]
```

Feito para o CI. Falha (saída 3) com: lacuna de rastreabilidade numa feature da
fase green até a homologação (as em produção não são conferidas); feature pronta ou em homologação com spec, testes, plano
ou revisão de segurança sem aprovação ou alterados depois dela; release em
homologação, aceita ou em implantação com alguma feature fora de
`homologacao`. Avisos (falham só com
`--estrito`): artefato de processo fora do lugar do padrão, feature adotada
ainda em transição, consolidação pendente, incidente S1 ou S2 não encerrado, hotfix sem spec aprovada, branch
atual fora do padrão do Git Flow. Também falha com um pull request num fluxo
que o Git Flow não permite, lido das variáveis do CI (`GITHUB_HEAD_REF` e
`GITHUB_BASE_REF`, ou `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME` e
`CI_MERGE_REQUEST_TARGET_BRANCH_NAME`).

## sdd-adotar

```
sdd-adotar inventario [--tsv]
sdd-adotar contar
sdd-adotar aplicar <mapa> [--simular]
```

Traz para o padrão os artefatos de processo que outro processo ou outro agente
deixou fora do lugar. O `/sdd:iniciar` o usa por baixo; ver
[projetos existentes](projetos-existentes.md#projeto-com-artefatos-de-outro-processo).

**Inventário.** Lista os arquivos que parecem spec, plano, tarefas, ADR,
backlog, sprint, arquitetura ou regras do projeto (pelo nome e pela pasta) e
que não estão no lugar do padrão, agrupados por tipo. Funciona antes do
`/sdd:iniciar`: é ele que detecta um projeto que não nasceu com o plugin. O
`contar` imprime só o total (0: o projeto está no padrão). Ignora
dependências e saídas de build, e o que casar com `excecoes_de_layout`.

| Lugar do padrão | O que mora lá |
|---|---|
| `specs/NNN-slug/` (com `estado`) | feature: `spec.md`, `plano.md`, `tarefas.md`, `contexto.md`, `contratos/`, e os demais artefatos da feature |
| `docs/adr/NNNN-slug.md` | ADR, numerado com 4 dígitos |
| `.sdd/` | constituição, backlog, sprints, templates |
| `sistema/`, `releases/`, `incidentes/` | spec viva, entregas, incidentes |
| `docs/arquitetura/` | documentos e diagramas de arquitetura (C4, por exemplo), como referência |
| `docs/legado/` | o que veio de outro processo e não entra no fluxo: preservado, nunca apagado |

Uma pasta com nome de feature, mas sem o arquivo `estado`, conta como fora do
padrão: foi criada à mão, e não pelo `sdd-estado nova`.

**Aplicar.** Lê um mapa com uma linha por arquivo, `origem -> destino`
(linhas vazias e as que começam com `#` são ignoradas). O destino é um caminho
do padrão ou um atalho que o utilitário numera:

| Destino | Vira |
|---|---|
| `feature:<slug>/<arquivo>` | `specs/NNN-slug/<arquivo>`; o mesmo slug, a mesma feature. `<arquivo>`: `spec.md`, `plano.md`, `tarefas.md`, `contexto.md` ou `contratos/<nome>` |
| `adr:<slug>` | `docs/adr/NNNN-slug.md` |
| `legado:<caminho>` | `docs/legado/<caminho>` |
| `arquitetura:<caminho>` | `docs/arquitetura/<caminho>` |
| outro caminho | só se for do padrão (ex.: um arquivo novo numa feature que já existe) |

O mapa inteiro é conferido antes de mover qualquer arquivo: origem
inexistente ou repetida, destino existente, repetido ou fora do padrão, e
feature nova sem o atalho recusam tudo (saída 1). Com `--simular`, mostra os
destinos resolvidos e para. Na aplicação, usa `git mv` para arquivos
versionados (o histórico do arquivo segue), registra cada movimento no histórico do projeto e em `.sdd/adocao.md` e, quando
o destino é uma feature, no histórico dela com o hash do original (que também
vai para o `transicao.md`),
remove só as pastas que ficaram vazias e lista os arquivos que ainda citam os
caminhos antigos. Nunca sobrescreve nem apaga.

Cada feature nova nasce na **situação de transição**: `adocao=transicao`, fase
`especificacao`, nenhuma aprovação, e um `transicao.md` feito do modelo, com o
"como era" de cada arquivo (caminho original e hash) já preenchido. O agente
converte os arquivos para o padrão e preenche o "como vai ficar"; o usuário
aprova a transição (ver [sdd-estado](#sdd-estado)), e a feature segue da fase de
destino. Tarefas feitas fora do plugin ficam `[O]`; as abertas, `[ ]`.

## sdd-gitflow

```
sdd-gitflow conferir
sdd-gitflow iniciar
sdd-gitflow renomear <antiga> <nova>
sdd-gitflow feature <NNN-slug>
sdd-gitflow release <X.Y.Z>
sdd-gitflow hotfix <X.Y.Z>
sdd-gitflow integrar <NNN-slug> [--apagar]
sdd-gitflow finalizar <X.Y.Z> [--apos-pr]
sdd-gitflow esperada
sdd-gitflow valido <branch>
sdd-gitflow pode-integrar <origem> <destino>
sdd-gitflow nome feature <NNN-slug> | release <X.Y.Z> | hotfix <X.Y.Z>
```

O Git Flow com nomes fixos em todo projeto: `main`, `develop`,
`feature/NNN-slug`, `release/X.Y.Z`, `hotfix/X.Y.Z` e as tags `vX.Y.Z`. O guia
completo, com cada momento do ciclo, está em [Git Flow](git-flow.md).

| Comando | Faz | Recusa quando |
|---|---|---|
| `conferir` | lista branches fora do padrão (com o nome sugerido), a falta de `main` ou `develop`, e se a branch atual é a da feature ativa. Num repositório sem commit, mostra a branch inicial ("master (sem nenhum commit ainda)") | saída 3 com problemas |
| `iniciar` | garante `main`, cria `develop` a partir dela e muda para `develop`, de qualquer branch (sem código pendente) | não há commit; a produção tem outro nome (`master`); alteração pendente em código ao trocar |
| `renomear` | `git branch -m` local para um nome do padrão; imprime os passos do remoto | o nome novo está fora do padrão, já existe, ou é `feature/` de uma feature que não existe |
| `feature` | cria a branch da feature (de `develop`; de `main` num hotfix) ou muda para ela. Se a pasta da feature não existe na branch atual (ela ainda não foi integrada), procura a branch local que a tem (`feature/`, `hotfix/` ou `release/`) e muda para ela; se ela só existe em `origin/feature/NNN-slug`, cria a local rastreando a remota. Numa feature reprovada na homologação, a branch é a `release/X.Y.Z`; terminada a release, volta a ser `feature/NNN-slug` | a feature não existe em nenhuma branch local; alteração pendente em código |
| `release`, `hotfix` | cria `release/X.Y.Z` (de `develop`) ou `hotfix/X.Y.Z` (de `main`) | versão inválida; alteração pendente em código |
| `integrar` | merge `--no-ff` de `feature/NNN-slug` em `develop` | a feature não está pronta; é um hotfix; foi corrigida numa `release/` (volta pela release, com `sdd-release incluir`); a branch não existe localmente; alteração não commitada (fora do `.sdd/`); conflito (o merge fica em andamento) |
| `finalizar` | merge da `release/` (ou `hotfix/`) em `main`, tag `vX.Y.Z`, merge de `main` em `develop`; com `--apos-pr`, só a tag e o `develop`, depois do merge feito na plataforma | a versão é um pré-lançamento; a release não tem o go (`implantacao` ou `producao`); a branch não existe localmente; com `--apos-pr`, a branch ainda não está em `main`; alteração não commitada; conflito |
| `pode-integrar` | saída 0 se o fluxo é permitido (`feature/*` para `develop`; `release/*` e `hotfix/*` para `main` ou `develop`; `main` para `develop`) | saída 3 nos demais |

**Ao trocar de branch** (`iniciar`, `feature`, `release`, `hotfix`), as
alterações pendentes nos arquivos do SDD (`.sdd/`, `specs/`, `sistema/`,
`releases/`, `incidentes/`, `docs/`, `CLAUDE.md`, `AGENTS.md`,
`.gitattributes`, `CHANGELOG.md`) vão junto para a branch nova; alteração
pendente em código é recusada (faça o commit, ou o stash). Se o git recusar a
troca, a mensagem dele aparece com o que fazer.

Nunca faz push, nunca apaga branch remota, nunca reescreve histórico e não
escreve nos históricos do SDD. Com `gitflow: desligado` no config, os hooks e o
`sdd-verificar` não conferem branches.

**Configuração** (`.sdd/config.yml`): `gitflow` (`ativo` ou `desligado`) e
`integracao` (`local`: o `sdd-gitflow` faz os merges; `pr`: os merges são
pull requests na plataforma). O `conferir` também avisa quando nenhuma tag
segue `vX.Y.Z` (a base do cálculo de versão).

## Formatos

| O quê | Formato |
|---|---|
| Linha de tarefa | `- [ ] T-003 [P] descrição (atende: RF-002, CA-003; depende de: T-001)`; `[ ]` aberta, `[x]` feita no plugin, `[O]` feita fora do plugin (adoção) |
| Marca de teste | `// sdd:001:CA-003`, no nome ou no comentário logo acima |
| Item de backlog | `- [ ] B-014 título (prioridade: alta; nivel: 1; origem: texto; criado: AAAA-MM-DD)` |
| Origem na spec do sistema | `(origem: 004/RF-002)` |
| Passo de homologação | `\| H-001 \| NNN \| CA-NNN \| como testar \| esperado \| pendente \|` |
| Evento do histórico | `- AAAA-MM-DDTHH:MM:SSZ \| evento \| detalhe \| por: Nome` |
| Branch | `main`, `develop`, `feature/NNN-slug`, `release/X.Y.Z`, `hotfix/X.Y.Z`; tag `vX.Y.Z` |
| Linha do mapa de adoção | `origem -> destino`, com destino `feature:<slug>/<arquivo>`, `adr:<slug>`, `legado:<caminho>`, `arquitetura:<caminho>` ou um caminho do padrão |
| Commit | Conventional Commits: `tipo(NNN): T-XXX descrição`, com tipo `feat`, `fix`, `perf`, `docs`, `chore`, `refactor`, `test`, `build`, `ci`, `style` ou `revert`; `!` ou o rodapé `BREAKING CHANGE:` para mudança incompatível. Nas fases red a auditoria, a tarefa (`T-XXX`) ou o número `(NNN)` é obrigatório |
| Versão | SemVer `X.Y.Z`, com pré-lançamento `X.Y.Z-rc.N`; tag `vX.Y.Z` |
