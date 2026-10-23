# Níveis de rigor

O rigor do processo acompanha o risco da mudança. Regra de ouro: **mudou
comportamento observável, nível 1 no mínimo.**

## Como escolher

| Pergunta | Se sim |
|---|---|
| Altera schema de banco, contrato público (API, evento) ou modelo de domínio? | **2** |
| É feature nova com mais de um caso de uso? | **2** |
| Toca segurança, dinheiro, dados pessoais ou integração externa crítica? | **2** |
| Muda comportamento observável, mas de forma localizada (um a três arquivos)? | **1** |
| É correção de bug com causa conhecida? | **1** |
| Não muda comportamento (typo, formatação, renomeação interna, refatoração coberta por testes)? | **0** |

Na dúvida entre dois níveis, escolha o maior. Rebaixar depois é barato;
descobrir na auditoria que faltou spec não é.

## O que cada nível exige

| Etapa | Nível 0 | Nível 1 | Nível 2 |
|---|---|---|---|
| Feature em `specs/` | não | sim | sim |
| `contexto.md` | não | opcional | sim, em projeto existente |
| Spec | não | `spec-leve` | `spec` completa |
| Clarificação | não | se houver dúvida | sempre |
| Plano e contratos | não | não | sim |
| Tarefas | não | sim, curtas | sim |
| Red com `escritor-de-testes` | não | sim | sim |
| Auditoria com `auditor-de-drift` | não | opcional | sim |
| Gates | nenhum | spec e final | todas as fases |
| Commit com `T-XXX` | não | sim | sim |

## Fluxo de cada nível

| Nível | Fluxo |
|---|---|
| 0 | implementa e faz commit; não abre feature nem mexe em `.sdd/estado` |
| 1 | `/sdd:especificar`, `/sdd:clarificar` se houver marcadores, `/sdd:tarefas`, `/sdd:implementar`, `/sdd:auditar` opcional |
| 2 | `/sdd:especificar`, `/sdd:clarificar`, `/sdd:planejar`, `/sdd:tarefas`, `/sdd:implementar`, `/sdd:auditar` |

## Mudando de nível no meio do caminho

Se aparecer impacto em domínio, schema ou contrato: pare, rode
`sdd-estado definir nivel=2`, converta a spec para o template completo e siga
para `/sdd:planejar`.
