<!-- sdd:inicio -->
## Metodologia: Specification-Driven Development (SDD)

Este projeto usa SDD. As especificações em `specs/` são a fonte de verdade.

**Regras sempre ativas:**

1. Mudança de comportamento observável passa primeiro pela spec. Nunca altere comportamento direto no código.
2. Implemente apenas tarefas listadas em `tarefas.md` da feature ativa (`sdd-estado ver`). Surgiu algo novo? Pare e proponha a mudança na spec.
3. Respeite `.sdd/constituicao.md` em toda decisão técnica.
4. Na implementação, nunca altere um teste para fazê-lo passar. Teste errado significa voltar à spec, com aprovação humana.
5. Os contratos (`specs/NNN/contratos/`) ficam congelados durante a implementação.
6. Commits citam a tarefa: `tipo(NNN): T-XXX descrição`.
7. Na dúvida sobre um requisito, pergunte. Não suponha.

**Níveis de rigor:** 0, direto (typo, ajuste visual, refatoração sem mudar comportamento); 1, leve (correção de bug ou feature pequena); 2, completo (feature nova, domínio, schema, contrato público).

**Fluxo:** especificacao, clarificacao, plano, tarefas, red, green, auditoria, concluida. O estado atual fica em `.sdd/estado`.
<!-- sdd:fim -->
