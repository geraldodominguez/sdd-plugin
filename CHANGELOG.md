# Changelog

Versionamento [SemVer](https://semver.org/lang/pt-BR/). Mudanças nos formatos
rastreáveis (linha de tarefa, marca de teste, IDs, fases, chaves de
configuração) sempre sobem a versão maior.

## 0.1.0

Primeira versão pública.

### Novidades

- Comandos de fluxo, invocados pelo usuário: `/sdd:iniciar`, `/sdd:especificar`, `/sdd:clarificar`, `/sdd:planejar`, `/sdd:tarefas`, `/sdd:aprovar`, `/sdd:implementar` e `/sdd:auditar`.
- Comandos de acompanhamento, invocados pelo usuário: `/sdd:ajuda`, `/sdd:status` (quadro com sprint, colunas, backlog e pendências), `/sdd:pendencias`, `/sdd:retomar`, `/sdd:backlog` e `/sdd:sprint`.
- Aprovação formal de cada gate, registrada no histórico da feature com autor, data e hash do artefato. Artefato alterado depois de aprovado é detectado pelos comandos, pelas pendências e pelo auditor.
- Estado por feature (`specs/NNN/estado`) e histórico de eventos (`specs/NNN/historico.md`, `.sdd/historico.md`), protegidos contra edição manual pelo hook.
- Backlog em `.sdd/backlog.md` (itens `B-NNN`, promovidos a feature com a origem registrada na spec) e sprints em `.sdd/sprints/`.
- Skill `metodologia`, invocada pelo modelo, com os templates (constituição, spec completa e leve, contexto, plano, tarefas, ADR, auditoria, delta spec) e as referências (EARS, critérios de aceitação, decomposição de tarefas, níveis de rigor, qualidade da spec).
- Subagents `mapeador-de-contexto`, `arquiteto-de-contratos`, `escritor-de-testes` e `auditor-de-drift`.
- Hooks `guarda-edicoes`, com proteção por fase nos modos desligada, leve e estrita, e `guarda-commits`, que exige a tarefa na mensagem de commit.
- Utilitários `sdd-iniciar`, `sdd-estado`, `sdd-backlog`, `sdd-sprint`, `sdd-status`, `sdd-pendencias` e `sdd-rastrear`.
- Níveis de rigor 0, 1 e 2.
- Bloco de regras injetado no `CLAUDE.md` e no `AGENTS.md` dos projetos.
- Exemplo completo de uma feature de nível 2, com histórico, delta spec, backlog e uma sprint encerrada.
- Guia de acompanhamento com a rotina diária, semanal e de sprint.
- Testes dos utilitários e hooks, com CI em Linux, macOS e Windows.
