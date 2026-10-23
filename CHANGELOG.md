# Changelog

Versionamento [SemVer](https://semver.org/lang/pt-BR/). Mudanças nos formatos
rastreáveis (linha de tarefa, marca de teste, IDs, fases, chaves de
configuração) sempre sobem a versão maior.

## 0.1.0

Primeira versão pública.

### Novidades

- Comandos invocados pelo usuário: `/sdd:ajuda`, `/sdd:iniciar`, `/sdd:especificar`, `/sdd:clarificar`, `/sdd:planejar`, `/sdd:tarefas`, `/sdd:implementar`, `/sdd:auditar` e `/sdd:status`.
- Skill `metodologia`, invocada pelo modelo, com os templates (constituição, spec completa e leve, contexto, plano, tarefas, ADR, auditoria, delta spec) e as referências (EARS, critérios de aceitação, decomposição de tarefas, níveis de rigor, qualidade da spec).
- Subagents `mapeador-de-contexto`, `arquiteto-de-contratos`, `escritor-de-testes` e `auditor-de-drift`.
- Hooks `guarda-edicoes`, com proteção por fase nos modos desligada, leve e estrita, e `guarda-commits`, que exige a tarefa na mensagem de commit.
- Utilitários `sdd-iniciar`, `sdd-estado`, `sdd-rastrear` e `sdd-status`.
- Níveis de rigor 0, 1 e 2.
- Bloco de regras injetado no `CLAUDE.md` e no `AGENTS.md` dos projetos.
- Exemplo completo de uma feature de nível 2.
- Testes dos utilitários e hooks, com CI em Linux, macOS e Windows.
