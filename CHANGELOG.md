# Changelog

Versionamento [SemVer](https://semver.org/lang/pt-BR/). Mudanças nos formatos
rastreáveis (linha de tarefa, marca de teste, IDs, fases, chaves de
configuração) sempre sobem a versão maior.

## Não lançado

## 1.0.2 - 2026-10-30

Correções do uso real no macOS e no Windows. Nenhum formato rastreável mudou.

### Correções

- **`sdd-gitflow` quebrava no macOS** com erro de sintaxe: um `case` dentro de uma substituição de comando `$( )`, que o bash 3.2 (o `/bin/bash` do macOS) não entende. Além de falhar, ele imprimia um trecho do próprio código como se fosse a lista de alterações pendentes. O filtro foi para uma função.
- **Aprovações invalidadas no Windows:** com o `core.autocrlf` do git, trocar de branch troca LF por CRLF nos arquivos, e o hash do artefato mudava sem ninguém ter mexido nele (a spec aparecia como alterada depois da aprovação, e a release não ia para homologação). Os finais de linha não entram mais no hash; aprovações feitas no Linux e no macOS continuam valendo.
- O `sdd-estado usar` só aponta a feature ativa e não troca de branch. Agora ele avisa quando a branch da feature ainda não existe, ou quando você está em outra, com o comando para ir até ela.

### Qualidade

- Novo `tests/bash32.py`, rodado pelo `rodar-testes.sh`: acha construções que o bash 3.2 não entende (como o `case` dentro de `$( )`) e recursos do bash 4.
- O CI roda os testes no macOS também com o `/bin/bash` 3.2 (o bash do runner é o do Homebrew), e anota no resumo de cada job os testes que falham.
- Os testes ignoram as variáveis do CI (`GITHUB_HEAD_REF`, `GITHUB_BASE_REF` e as do GitLab), que o `sdd-verificar` dos projetos de teste lia como se fossem deles. O CI estava vermelho no Linux, no macOS e no Windows desde a 1.0.0 por isso e pelos dois erros acima.

## 1.0.1 - 2026-10-29

Correções achadas numa auditoria que percorreu cada cenário das skills
executando os comandos de verdade. Nenhum formato rastreável mudou.

### Correções

- **Atualização de um projeto que já usa o SDD:** o `/sdd:iniciar` ganhou um caminho próprio. Antes, ele seguia os passos de projeto novo e podia reescrever a constituição e o config, ou ia direto à adoção sem atualizar o bloco de regras. Agora roda o `sdd-iniciar` sem `--forcar`, apresenta um a um os templates que diferem dos do plugin e as chaves novas do config, prepara o Git Flow e só então faz a adoção, se houver. Funciona também com uma feature ativa ou estando na branch de uma feature.
- O `sdd-iniciar` lista os templates diferentes dos do plugin e as chaves que faltam no config, mostra o nível e a proteção do config (não os padrões) e não sugere mais `--forcar`. Novo `sdd-estado template --plugin <nome>`.
- O hook de edição dava resultados diferentes conforme o diretório em que rodava: os globs (`tests/**`) eram expandidos contra os arquivos existentes. Um teste novo podia ser permitido ou bloqueado na fase green.
- Marcar uma tarefa como feita (`[x]`) fazia o `tarefas.md` aparecer como alterado depois da aprovação, e o `/sdd:implementar` parava. As caixas `[ ]` e `[x]` agora entram iguais no hash; aprovações antigas continuam valendo.
- `sdd-estado sensivel` sem argumento compara desde o início da feature. Sem o Git Flow, a base anterior (`main`) não existia ou não via os commits da feature, e a revisão de segurança deixava de ser exigida.
- Artefato de fase anterior alterado depois de aprovado (a spec mexida durante o green): o `sdd-status` marca com `✗`, o `sdd-pendencias` aponta e o `/sdd:implementar` para. Antes, só a entrega acusava.
- `sdd-gitflow iniciar` muda para `develop` vindo de qualquer branch (antes, só de `main`), e o `conferir` mostra a branch inicial num repositório sem commit.
- `sdd-gitflow feature` acha a feature que só existe na branch dela (ainda não integrada), em vez de dizer que ela não existe.
- **Feature reprovada na homologação:** o `sdd-release reprovar` grava a `release/X.Y.Z` como a branch dela, então a correção é feita na release (antes, o `/sdd:implementar` criava uma branch nova a partir de `develop`). O `integrar` recusa essa feature, e o `/sdd:aprovar` e o `/sdd:release` descrevem a volta com `sdd-release incluir`.
- **Release candidate:** o `/sdd:release` ganhou o caminho do `X.Y.Z-rc.N`, que só é homologado. O pré-lançamento nunca vira a versão de referência, as releases são ordenadas pelo SemVer (o `rc` antes da final), e o próximo número de `rc` conta as releases já criadas, não só as tags.
- O `finalizar` recusava logo depois do go, porque o `autorizar` deixa registros a commitar: a skill e as docs agora fazem o commit `chore(release): X.Y.Z autorizada` antes.
- `/sdd:release cancelar` documentado (skill e página), inclusive o que fazer com as correções commitadas na `release/`.
- Hotfix: o commit do registro do incidente em `develop` funciona estando no meio de outra feature, e o agente lê o incidente de `develop` (`git show`), porque a `hotfix/X.Y.Z` sai de `main` e não o tem.
- O aviso de branch errada sugeria `sdd-gitflow feature hotfix/X.Y.Z`, que não existe; agora sugere o id da feature.
- O `sdd-status` diz "integrada em develop; branch apagada" depois do `integrar --apagar`, em vez de só o nome da branch.
- Com `integracao: pr`, a skill pede para publicar a branch antes do pull request, cobre o `hotfix/` e o caso de `develop` só aceitar pull request. A proteção recomendada para `develop` passa a depender da `integracao`.
- Na aprovação do plano, os ADRs da feature passam de `proposta` para `aceita`.
- Na adoção, o commit vem depois dos ajustes (backlog, links, mapa), cada feature convertida tem o seu commit antes da próxima, e a feature é ativada só depois de estar na branch dela.
- Na proteção estrita, o `/sdd:pipeline` desativa a feature ativa para gravar o arquivo do pipeline.
- Duas features criadas em paralelo a partir de `develop` recebiam o mesmo número: o `sdd-estado nova` só via as pastas da branch atual. Agora conta também as branches `feature/NNN-*` (locais e remotas) e as pastas em `hotfix/` e `release/`.
- Pré-lançamento não vai para produção: `sdd-release autorizar` e `sdd-gitflow finalizar` recusam `X.Y.Z-rc.N`, e o `aceitar` de um candidate diz o próximo passo certo.
- Um hotfix aberto entre o `finalizar` e o `concluir` reservava a mesma versão já marcada com a tag: a release com o go (`implantacao`) passa a ser a base da próxima versão.
- Uma feature reprovada numa release que já terminou voltava à branch da release: agora ganha uma `feature/NNN-slug` nova a partir de `develop`.
- A versão de referência é a maior entre a última release em produção (ou com o go) e a última tag final: depois de uma versão revertida, a próxima não anda mais para trás. E uma versão já usada (release cancelada, tag, branch reservada) não é reproposta.
- O `sdd-release listar` ordena os pré-lançamentos pelo SemVer (`rc.2` antes de `rc.10`).
- `sdd-gitflow feature` cria a branch local de uma feature que só existe no remoto.
- O commit do registro do incidente exclui só a pasta do hotfix (`':!specs/NNN-slug/'`), não a pasta `specs/` inteira, que deixava de fora o histórico da feature de origem e travava a troca de branch.
- Documentação conferida contra a saída real: o quadro do `sdd-status`, a mensagem de bloqueio do Conventional Commits, o `git log` da simulação e o hash da transição no exemplo da adoção.

## 1.0.0 - 2026-10-29

Versão maior: muda formatos rastreáveis e o comportamento padrão. Ver
"Incompatível", abaixo. Para atualizar um projeto que já usa o plugin, rode
`/sdd:iniciar` de novo (sem `--forcar`): ele atualiza o bloco de regras e o
`.gitattributes` e não mexe no config nem na constituição.

### Incompatível

- Git Flow e Conventional Commits ficam ligados por padrão (`gitflow: ativo`, `commits: convencional`). O hook passa a bloquear commit em `main`, branch com nome fora do padrão e mensagem fora do formato. Para manter o comportamento anterior, use `gitflow: desligado` e `commits: livre` no `.sdd/config.yml`.
- A linha de tarefa aceita a marca `[O]` (feita fora do plugin), além de `[ ]` e `[x]`.
- Chaves novas em `specs/NNN/estado`: `adocao` (`transicao` ou `regularizada`) e `branch`.
- Regras 6, 10 e 11 do bloco do `CLAUDE.md` e do `AGENTS.md`: a 6 passa a exigir o Conventional Commits (`tipo(NNN): T-XXX descrição`); a 10 (artefatos só nos lugares do padrão) e a 11 (Git Flow com nomes fixos) são novas. Rode `/sdd:iniciar` de novo para atualizar o bloco.
- `sdd-estado reabrir` não reabre mais uma feature em `homologacao`: quem a devolve é o `sdd-release reprovar`, que mantém a release coerente.

### Novidades

- Layout como contrato: cada artefato de processo (spec, plano, tarefas, ADR, backlog, sprint, arquitetura, regras) tem um único lugar, e o hook `guarda-edicoes` bloqueia criar um fora dele, nas proteções leve e estrita. Uma pasta de feature sem `estado` (criada à mão) também conta como fora do padrão. Ver [ADR 0014](.agents/adr/0014-layout-como-contrato-e-adocao.md).
- Adoção de projetos que não nasceram com o plugin: o `/sdd:iniciar` detecta artefatos de outros processos e agentes, lê tudo, propõe um mapa e, com a aprovação do usuário, os traz para o padrão. `/sdd:iniciar --adotar` repete a adoção num projeto já preparado.
- Utilitário `sdd-adotar` (`inventario`, `contar`, `aplicar` com `--simular`): numera features e ADRs, renomeia com `git mv`, registra cada movimento em `.sdd/adocao.md` e no histórico do projeto, guarda o hash de cada original no histórico da feature e no `transicao.md`, e aponta os links para os caminhos antigos.
- Situação de transição das features adotadas: chave `adocao` (`transicao` ou `regularizada`) em `specs/NNN/estado` e modelo `transicao.md`, que mostra como a feature era e como fica. O agente converte spec, plano e tarefas para os modelos; o `/sdd:aprovar` aprova a transição de uma vez (`sdd-estado aprovar`, com `decisao: transicao` para cada artefato) e leva a feature à fase de destino (`especificacao`, `plano`, `tarefas` ou `red`), para continuar de onde parou. Durante a transição, aprovar outro artefato e `definir fase=` são recusados.
- Marca `[O]` na linha de tarefa: feita fora do plugin, antes da adoção, sem gate. Conta como feita no `sdd-status`, que a mostra à parte, e é lida pelo `sdd-rastrear`. Os testes dos critérios dela vêm na fase red e devem passar de início.
- Novos lugares do padrão: `docs/arquitetura/` (referência) e `docs/legado/` (o que veio de outro processo e não entra no fluxo).
- Chave nova `excecoes_de_layout` no `.sdd/config.yml`, para documentos com nome de artefato que não são do SDD.
- `sdd-verificar` avisa sobre artefatos fora do padrão, e `sdd-pendencias` os lista na seção "Fora do padrão".
- Regra 10 no bloco do `CLAUDE.md` e do `AGENTS.md`: artefatos só nos lugares do padrão.

- Guias passo a passo: [começar um projeto novo](docs/referencia/projeto-novo.md) e [adotar o SDD num projeto em andamento](docs/referencia/projeto-em-andamento.md), com as saídas reais dos comandos e o que olhar em cada gate, e o exemplo [`exemplos/adocao/`](exemplos/adocao/), com o antes e o depois de uma adoção.

- **Git Flow com nomes fixos** em todo projeto: `main`, `develop`, `feature/NNN-slug`, `release/X.Y.Z`, `hotfix/X.Y.Z` e as tags `vX.Y.Z`, ligado ao ciclo: o `/sdd:iniciar` cria `develop`, o `/sdd:especificar` cria a branch da feature, o `/sdd:aprovar` integra a feature pronta, o `/sdd:release` cria a `release/` e, depois do go, a leva a `main` com a tag, e o `/sdd:incidente` cria o `hotfix/` a partir de `main`. Ver [docs/referencia/git-flow.md](docs/referencia/git-flow.md) e o [ADR 0015](.agents/adr/0015-git-flow-com-nomes-fixos.md).
- Utilitário `sdd-gitflow` (`conferir`, `iniciar`, `renomear`, `feature`, `release`, `hotfix`, `integrar`, `finalizar`, `esperada`, `valido`, `pode-integrar`, `nome`). Nunca faz push nem reescreve histórico.
- Chaves novas: `gitflow` (`ativo` ou `desligado`) e `integracao` (`local` ou `pr`) no `.sdd/config.yml`; `branch` em `specs/NNN/estado`.
- O hook `guarda-commits` bloqueia branch com nome fora do padrão, commit em `main`, commit numa branch fora do padrão e commit da feature ativa fora da branch dela.
- O `sdd-verificar` falha com pull request fora do Git Flow (variáveis do GitHub Actions e do GitLab CI) e avisa sobre branch fora do padrão; o `sdd-pendencias` ganha a seção "Git Flow" (develop ausente, branches fora do padrão, feature pronta não integrada, release com o go fora de `main`); o `sdd-status` mostra a branch.
- Os modelos de pipeline seguem o Git Flow: homologação no push de `release/**` e `hotfix/**`, produção na tag.
- O `/sdd:iniciar` põe os históricos do SDD com `merge=union` no `.gitattributes`, para os merges do Git Flow não darem conflito neles.
- A simulação do ciclo roda o Git Flow inteiro, com branches, merges e tags reais.

- **Versão pelos commits:** SemVer calculado pelos Conventional Commits. `sdd-release proxima` (agora `auto` por padrão) sugere a próxima versão (`!` ou `BREAKING CHANGE:` major, minor antes da 1.0.0; `feat` minor; o resto patch), `--pre rc` dá o próximo pré-lançamento, `sdd-release analisar` mostra a conta e o motivo, e `sdd-release changelog X.Y.Z [--escrever]` gera a seção no `CHANGELOG.md` (Keep a Changelog). Ver [docs/referencia/versionamento.md](docs/referencia/versionamento.md) e o [ADR 0016](.agents/adr/0016-versao-pelos-commits.md).
- O hook `guarda-commits` confere o formato Conventional Commits das mensagens inline (também em heredoc), com a chave nova `commits` (`convencional` ou `livre`).
- O `sdd-gitflow conferir` avisa quando nenhuma tag segue `vX.Y.Z`; o `/sdd:iniciar` propõe a tag da versão em produção num projeto adotado.

### Mudanças

- `sdd-release proxima` sem argumento calcula pelos commits (antes, era sempre minor).
- O aviso de links para o caminho antigo ignora o bloco de regras do SDD, os registros da adoção e as citações parciais (`TODO.md` não casa com `docs/legado/TODO.md`).
- O `.sdd/adocao.md` entra na lista de arquivos que só os utilitários escrevem.
- `sdd_slug`, `sdd_proximo_numero_feature` e `sdd_proximo_numero_adr` passam para a `lib/sdd-comum.sh`.
- O `sdd-release concluir` diz se a tag `vX.Y.Z` já existe ou se falta o `sdd-gitflow finalizar`.
- Os modelos de pipeline fixam a versão do plugin em `SDD_VERSAO`; o do GitLab ganha `workflow: rules`, para não rodar duas vezes num merge request.

### Correções

- Todo utilitário responde a `--ajuda` (e `-h`), mesmo fora de um projeto, com o cabeçalho completo; antes, algumas ajudas saíam cortadas ou com linhas de código.
- O hook `guarda-commits` lê a mensagem de `git commit -F arquivo` para conferir o formato e a tarefa citada.
- `sdd_config` devolvia o comentário da linha quando a chave estava vazia.
- O `/sdd:iniciar` num projeto já preparado oferecia só o `--forcar`, que sobrescreve config e constituição; agora atualiza pelo caminho seguro, sem `--forcar`.
- Documentação conferida contra o código: eventos de histórico completos, seção Git Flow do `sdd-pendencias`, `consolidar --sem-mudanca`, aprovação da spec num hotfix, reprovação a partir de `aceita`, `revert` fora do changelog, commits de hotfix sem `T-NNN`, `/sdd:sistema mapear`, `/sdd:pipeline conferir` e homologação no push de `release/` e `hotfix/`.
- Ao trocar de branch, o `sdd-gitflow` leva as alterações pendentes nos arquivos do SDD e recusa, com a explicação, quando há alteração pendente em código; antes, a troca podia falhar com a mensagem crua do git.

## 0.1.0

Primeira versão pública. Cobre o ciclo de vida inteiro: análise,
desenvolvimento, testes, segurança, homologação, produção, entrega, DevOps e
manutenção. O mapa está em [docs/referencia/ciclo-de-vida.md](docs/referencia/ciclo-de-vida.md).

### Novidades

- Comandos do fluxo da feature, invocados pelo usuário: `/sdd:iniciar`, `/sdd:especificar`, `/sdd:clarificar`, `/sdd:planejar`, `/sdd:tarefas`, `/sdd:aprovar`, `/sdd:implementar`, `/sdd:seguranca`, `/sdd:auditar` e `/sdd:sistema`.
- Comandos de entrega e operação, invocados pelo usuário: `/sdd:release`, `/sdd:incidente` e `/sdd:pipeline`.
- Fases da feature: `especificacao`, `clarificacao`, `plano`, `tarefas`, `red`, `green`, `seguranca`, `auditoria`, `pronta`, `homologacao`, `producao`, e `cancelada`. As quatro últimas só mudam por aprovação, release ou cancelamento.
- Revisão de segurança independente (fase `seguranca`, `seguranca.md`), obrigatória no nível 2 e em features que tocam `areas_sensiveis`, com as decisões aprovar, aceitar o risco ou corrigir.
- Spec viva do sistema em `sistema/<capacidade>.md`, com consolidação registrada de cada feature pronta (`sdd-sistema`).
- Releases em `releases/<versão>/`: testes de sistema, roteiro de homologação, aceite, go/no-go com plano de implantação e rollback, notas de versão, reversão (`sdd-release`).
- Incidentes em `incidentes/INC-NNN.md`, com severidade, mitigação, hotfix (feature que nasce no red, com spec retroativa obrigatória) e post-mortem (`sdd-incidente`).
- Cancelamento e reabertura de features, com a reabertura invalidando as aprovações da fase em diante.
- Hash dos testes por bloco de marca (`sdd:NNN:`), para que testes de outra feature no mesmo arquivo não invalidem a aprovação.
- `sdd-verificar` para o CI e modelos de pipeline para GitHub Actions e GitLab CI, com o deploy de produção condicionado ao go (`sdd-release pode-implantar`).
- Comandos de acompanhamento, invocados pelo usuário: `/sdd:ajuda`, `/sdd:status` (quadro com sprint, colunas, backlog e pendências), `/sdd:pendencias`, `/sdd:retomar`, `/sdd:backlog` e `/sdd:sprint`.
- Aprovação formal de cada gate, registrada no histórico da feature com autor, data e hash do artefato. Artefato alterado depois de aprovado é detectado pelos comandos, pelas pendências e pelo auditor.
- Estado por feature (`specs/NNN/estado`) e histórico de eventos (`specs/NNN/historico.md`, `.sdd/historico.md`), protegidos contra edição manual pelo hook.
- Backlog em `.sdd/backlog.md` (itens `B-NNN`, promovidos a feature com a origem registrada na spec) e sprints em `.sdd/sprints/`.
- Skill `metodologia`, invocada pelo modelo, com os templates (constituição, spec completa, leve e de hotfix, contexto, plano, tarefas, ADR, segurança, auditoria, delta spec, capacidade do sistema, release, incidente, pipeline) e as referências (ciclo de vida, EARS, critérios de aceitação, decomposição de tarefas, níveis de rigor, qualidade da spec).
- Subagents `mapeador-de-contexto`, `arquiteto-de-contratos`, `escritor-de-testes`, `revisor-de-seguranca`, `auditor-de-drift` e `testador-de-sistema`.
- Hooks `guarda-edicoes`, com proteção por fase nos modos desligada, leve e estrita, e `guarda-commits`, que exige a tarefa na mensagem de commit.
- Utilitários `sdd-iniciar`, `sdd-estado`, `sdd-sistema`, `sdd-release`, `sdd-incidente`, `sdd-backlog`, `sdd-sprint`, `sdd-status`, `sdd-pendencias`, `sdd-rastrear` e `sdd-verificar`.
- Níveis de rigor 0, 1 e 2.
- Bloco de regras injetado no `CLAUDE.md` e no `AGENTS.md` dos projetos.
- Exemplo completo de uma feature de nível 2, do backlog à produção, com revisão de segurança, auditoria, delta spec, a capacidade do sistema, a release 0.1.0, um incidente com post-mortem e uma sprint encerrada.
- Guias: do desenvolvedor (do zero ao primeiro deploy), ciclo de vida, acompanhamento (rotina diária, semanal, de sprint, de release e de incidente) e passo a passo.
- Testes dos utilitários e hooks, e uma simulação do ciclo inteiro (`tests/simular-ciclo.sh`), com CI em Linux, macOS e Windows.
