# Changelog

Versionamento [SemVer](https://semver.org/lang/pt-BR/). Mudanças nos formatos
rastreáveis (linha de tarefa, marca de teste, IDs, fases, chaves de
configuração) sempre sobem a versão maior.

## Não lançado

### Novidades

- Layout como contrato: cada artefato de processo (spec, plano, tarefas, ADR, backlog, sprint, arquitetura, regras) tem um único lugar, e o hook `guarda-edicoes` bloqueia criar um fora dele, nas proteções leve e estrita. Uma pasta de feature sem `estado` (criada à mão) também conta como fora do padrão. Ver [ADR 0014](.agents/adr/0014-layout-como-contrato-e-adocao.md).
- Adoção de projetos que não nasceram com o plugin: o `/sdd:iniciar` detecta artefatos de outros processos e agentes, lê tudo, propõe um mapa e, com a aprovação do usuário, os traz para o padrão. `/sdd:iniciar --adotar` repete a adoção num projeto já preparado.
- Utilitário `sdd-adotar` (`inventario`, `contar`, `aplicar` com `--simular`): numera features e ADRs, renomeia com `git mv`, registra em `.sdd/adocao.md` (com o hash de cada original) e aponta os links para os caminhos antigos.
- Situação de transição das features adotadas: chave `adocao` (`transicao` ou `regularizada`) em `specs/NNN/estado` e modelo `transicao.md`, que mostra como a feature era e como fica. O agente converte spec, plano e tarefas para os modelos; o `/sdd:aprovar` aprova a transição de uma vez (`sdd-estado aprovar`, com `decisao: transicao` para cada artefato) e leva a feature à fase de destino (`especificacao`, `plano`, `tarefas` ou `red`), para continuar de onde parou. Durante a transição, aprovar outro artefato e `definir fase=` são recusados.
- Marca `[O]` na linha de tarefa: feita fora do plugin, antes da adoção, sem gate. Conta como feita no `sdd-status`, que a mostra à parte, e é lida pelo `sdd-rastrear`. Os testes dos critérios dela vêm na fase red e devem passar de início.
- Novos lugares do padrão: `docs/arquitetura/` (referência) e `docs/legado/` (o que veio de outro processo e não entra no fluxo).
- Chave nova `excecoes_de_layout` no `.sdd/config.yml`, para documentos com nome de artefato que não são do SDD.
- `sdd-verificar` avisa sobre artefatos fora do padrão, e `sdd-pendencias` os lista na seção "Fora do padrão".
- Regra 10 no bloco do `CLAUDE.md` e do `AGENTS.md`: artefatos só nos lugares do padrão.

### Mudanças

- O `.sdd/adocao.md` entra na lista de arquivos que só os utilitários escrevem.
- `sdd_slug`, `sdd_proximo_numero_feature` e `sdd_proximo_numero_adr` passam para a `lib/sdd-comum.sh`.

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
