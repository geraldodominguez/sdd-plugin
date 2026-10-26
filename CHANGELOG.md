# Changelog

Versionamento [SemVer](https://semver.org/lang/pt-BR/). Mudanças nos formatos
rastreáveis (linha de tarefa, marca de teste, IDs, fases, chaves de
configuração) sempre sobem a versão maior.

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
