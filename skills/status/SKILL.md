---
name: status
description: Mostra onde o projeto está no SDD (feature ativa, fase, artefatos, tarefas e lacunas de rastreabilidade) e qual comando rodar em seguida.
disable-model-invocation: true
allowed-tools: Bash(sdd-status), Bash(sdd-estado *), Bash(sdd-rastrear *)
---

# /sdd:status

1. Rode `sdd-status` e mostre a saída num bloco de código.
2. Recomende **um** próximo passo:

| Fase atual | Próximo comando |
|---|---|
| sem `.sdd/` | `/sdd:iniciar` |
| sem feature, ou `concluida` | `/sdd:especificar <mudança>` |
| `especificacao` com marcadores | `/sdd:clarificar` |
| `especificacao` ou `clarificacao` sem marcadores | `/sdd:planejar` (nível 2) ou `/sdd:tarefas` (nível 1) |
| `plano` aprovado | `/sdd:tarefas` |
| `tarefas` | `/sdd:implementar` |
| `red` ou `green` com tarefas abertas | `/sdd:implementar` |
| `green` concluída | `/sdd:auditar` |
| `auditoria` | decidir sobre o relatório: aprovar, aprovar a delta ou corrigir |

Não altere nada.
