<!-- sdd:inicio -->
## Metodologia: Specification-Driven Development (SDD)

Este projeto usa SDD. As especificações em `specs/` são a fonte de verdade.

**Regras sempre ativas:**

1. Mudança de comportamento observável passa primeiro pela spec. Nunca altere comportamento direto no código.
2. Implemente apenas tarefas listadas em `tarefas.md` da feature ativa (`sdd-estado ver`). Surgiu algo fora do escopo? Registre no backlog (`sdd-backlog adicionar`) e não implemente.
3. Respeite `.sdd/constituicao.md` em toda decisão técnica.
4. Na implementação, nunca altere um teste para fazê-lo passar. Teste errado significa voltar à spec, com aprovação humana.
5. Os contratos (`specs/NNN/contratos/`) ficam congelados durante a implementação.
6. Commits citam a tarefa: `tipo(NNN): T-XXX descrição`.
7. Na dúvida sobre um requisito, pergunte. Não suponha.
8. Aprovações são do usuário, pelo `/sdd:aprovar` e pelo `/sdd:release`. Nunca registre uma aprovação nem avance a fase por conta própria. Antes de cada fase, confira a anterior com `sdd-estado aprovado <artefato>`.

9. Mudança em área sensível (`areas_sensiveis` no `.sdd/config.yml`) exige revisão de segurança, mesmo no nível 1.
10. Artefatos de processo moram só nos lugares do padrão: feature nova só pelo `/sdd:especificar` (que cria `specs/NNN-slug/`), ADR em `docs/adr/NNNN-slug.md`, ideia com `sdd-backlog adicionar`, arquitetura em `docs/arquitetura/`. Nunca invente pastas ou nomes próprios (`docs/specs/`, `tasks/`, `TODO.md`, `PLAN.md`, `.kiro/`, `.specify/`): o hook bloqueia. Achou artefatos fora do padrão? Avise o usuário (`/sdd:iniciar --adotar`) e não os mova por conta própria.

**Níveis de rigor:** 0, direto (typo, ajuste visual, refatoração sem mudar comportamento); 1, leve (correção de bug ou feature pequena); 2, completo (feature nova, domínio, schema, contrato público).

**Fluxo da feature:** especificacao, clarificacao, plano, tarefas, red, green, seguranca, auditoria, pronta. **Da release:** pronta, homologacao, producao. Cada feature guarda a própria fase em `specs/NNN/estado` e o histórico em `specs/NNN/historico.md`. Ideias para depois vão para `.sdd/backlog.md`; a sprint atual fica em `.sdd/sprints/`. O que o sistema faz hoje está em `sistema/` (spec viva, por capacidade): leia antes de mudar uma área. Incidentes em produção seguem `/sdd:incidente`. Situação geral: `sdd-status`.
<!-- sdd:fim -->
