# Utilitários

Treze scripts em bash, na pasta `bin/` do plugin. Nas sessões do Claude Code com
o plugin ativo, eles ficam no PATH. Fora delas (no terminal, no CI), chame pelo
caminho completo ou ponha `bin/` no PATH. Os comandos `/sdd:*` usam esses
utilitários por baixo; você raramente precisa chamá-los direto, mas eles servem
para scripts, para o CI e para conferir algo rápido. Todos aceitam `--ajuda`.

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
| `specs/NNN-slug/historico.md` | eventos da feature: criação, fases, aprovações, reaberturas, consolidação | `sdd-estado`, `sdd-sistema`, `sdd-release` |
| `releases/<versão>/estado` | `fase` da release, `tipo` (normal ou hotfix) | `sdd-release` |
| `releases/<versão>/historico.md` | testes, aceite, go, verificação, reversão | `sdd-release` |
| `.sdd/historico.md` | eventos do projeto: backlog, sprints, releases, incidentes, capacidades | todos |
| `.sdd/backlog.md`, `.sdd/sprints/<id>.md` | itens e sprints | `sdd-backlog`, `sdd-sprint`, e você |
| `sistema/<capacidade>.md` | comportamento vigente | o agente, com a sua confirmação; `sdd-sistema` registra |
| `incidentes/INC-NNN.md` | um incidente | `sdd-incidente`, e você |
| `.sdd/adocao.md` | de onde veio cada artefato adotado | `sdd-adotar` |

Os arquivos `estado` e `historico.md` (de features e de releases) e os do
`.sdd/` (inclusive o `adocao.md`) são protegidos pelo hook: o agente não consegue editá-los à mão. Linha
do histórico:

```
- 2026-10-23T18:40:30Z | aprovacao | spec.md | hash=2533c54be22d | por: Geraldo Dominguez
```

O autor é o `git config user.name` (ou a variável `SDD_AUTOR`).

---

## sdd-iniciar

```
sdd-iniciar [--forcar] [--nivel 1|2] [--protecao desligada|leve|estrita]
```

Cria `.sdd/` (config, constituição, estado, backlog, sprints, templates),
`specs/`, `sistema/` e `docs/adr/` no diretório atual (ou em
`$CLAUDE_PROJECT_DIR`), injeta o bloco de regras no `CLAUDE.md` e no
`AGENTS.md`, e acrescenta ao `.gitattributes` o merge por união dos históricos
(para os merges do Git Flow). Não sobrescreve nada sem `--forcar`.

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
```

**Fases:** `especificacao clarificacao plano tarefas red green seguranca
auditoria pronta homologacao producao`, e `cancelada`. O `definir fase=` só
aceita as fases de construção e revisão; `pronta` vem da aprovação,
`homologacao` e `producao` vêm da release, `cancelada` do `cancelar`.

**Aprovar** registra a aprovação do artefato da fase atual e avança:

| Fase | Artefato | Decisão | Próxima fase |
|---|---|---|---|
| `especificacao`, `clarificacao` | `spec.md` | | `plano` (nível 2) ou `tarefas` (nível 1) |
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

**Hash dos testes por bloco:** um bloco começa na linha com a marca
`sdd:NNN:` e vai até a marca de outra feature (ou o fim do arquivo). Testes que
outra feature acrescenta no mesmo arquivo não mudam o hash desta.

**Cancelar** vale para qualquer fase antes da homologação. **Reabrir** vale
para features `pronta`, `homologacao` ou `cancelada` (nunca `producao`), volta
para `especificacao` (padrão) ou `green`, e invalida as aprovações dos
artefatos da fase de reabertura em diante.

**Sensível** lista os arquivos alterados (desde `ref`, mais os não commitados)
que casam com `areas_sensiveis` e, se houver, marca `seguranca=obrigatoria`.
Saída 0 quando encontrou, 1 quando não.

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
da capacidade citando a feature (`origem: NNN/...`). Registra no histórico da
feature, acrescenta a linha no histórico da capacidade e atualiza "Última
feature". O texto da capacidade é editado antes, pelo agente.

## sdd-release

```
sdd-release proxima [major|minor|patch]
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

| Comando | De | Para | Exige |
|---|---|---|---|
| `nova` | | `preparacao` | versão SemVer nova |
| `incluir`, `remover` | `preparacao` | | features `pronta` |
| `homologar` | `preparacao` | `homologacao` | features prontas e com aprovações em dia; `testes.md` completo com `Resultado: aprovado`; roteiro (`| H-NNN |`) em `homologacao.md` |
| `aceitar` | `homologacao` | `aceita` | nenhum passo `pendente` ou `reprovado`; `--por` |
| `reprovar` | `homologacao`, `aceita` | `preparacao` | a feature volta ao green |
| `autorizar` (go) | `aceita` | `implantacao` | `implantacao.md` (com Rollback) e `notas.md` completos |
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

## sdd-pendencias

```
sdd-pendencias [--contar]
```

Incidentes, releases paradas, aprovações pendentes ou invalidadas, revisões de
segurança devidas, dúvidas, delta specs e ADRs propostos, consolidações
pendentes, prontas fora de release, backlog a triar e itens da sprint sem spec.

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

Num hotfix sem `tarefas.md`, só a ligação critério e teste é conferida. Saída:
`0` sem lacunas, `3` com lacunas, `1` erro de uso.

## sdd-verificar

```
sdd-verificar [--estrito] [--silencioso]
```

Feito para o CI. Falha (saída 3) com: lacuna de rastreabilidade numa feature da
fase green em diante; feature pronta ou em homologação com spec, testes, plano
ou revisão de segurança sem aprovação ou alterados depois dela; release em
andamento com feature fora da fase esperada. Avisos (falham só com
`--estrito`): artefato de processo fora do lugar do padrão, consolidação
pendente, incidente S1 ou S2 não encerrado, hotfix sem spec aprovada, branch
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
versionados (o histórico do arquivo segue), registra cada movimento (com o
hash do original) no histórico do projeto e da feature e em `.sdd/adocao.md`,
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
| `conferir` | lista branches fora do padrão (com o nome sugerido), a falta de `main` ou `develop`, e se a branch atual é a da feature ativa | saída 3 com problemas |
| `iniciar` | garante `main`, cria `develop` a partir dela e muda para `develop` | não há commit; a produção tem outro nome (`master`) |
| `renomear` | `git branch -m` local para um nome do padrão; imprime os passos do remoto | o nome novo está fora do padrão, já existe, ou é `feature/` de uma feature que não existe |
| `feature` | cria a branch da feature (de `develop`; de `main` num hotfix) ou muda para ela | a feature não existe; há alterações não commitadas fora da pasta dela e do `.sdd/` |
| `release`, `hotfix` | cria `release/X.Y.Z` (de `develop`) ou `hotfix/X.Y.Z` (de `main`) | versão inválida; alterações não commitadas |
| `integrar` | merge `--no-ff` de `feature/NNN-slug` em `develop` | a feature não está pronta; é um hotfix; conflito (o merge fica em andamento) |
| `finalizar` | merge da `release/` (ou `hotfix/`) em `main`, tag `vX.Y.Z`, merge de `main` em `develop`; com `--apos-pr`, só a tag e o `develop`, depois do merge feito na plataforma | a release não tem o go (`implantacao` ou `producao`); conflito |
| `pode-integrar` | saída 0 se o fluxo é permitido (`feature/*` para `develop`; `release/*` e `hotfix/*` para `main` ou `develop`; `main` para `develop`) | saída 3 nos demais |

Nunca faz push, nunca apaga branch remota, nunca reescreve histórico e não
escreve nos históricos do SDD. Com `gitflow: desligado` no config, os hooks e o
`sdd-verificar` não conferem branches.

**Configuração** (`.sdd/config.yml`): `gitflow` (`ativo` ou `desligado`) e
`integracao` (`local`: o `sdd-gitflow` faz os merges; `pr`: os merges são
pull requests na plataforma).

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
| Commit (red, green, segurança, auditoria) | `tipo(NNN): T-XXX descrição`, ou `tipo(NNN): descrição` para artefatos |
