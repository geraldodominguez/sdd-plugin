# Auditor que corrige o código ou a spec

Pedidos para que o `auditor-de-drift` aplique as próprias correções, no código
ou na spec, estão fora do escopo.

## Por que está fora do escopo

Se o auditor corrige o código, ele vira mais um implementador, e alguém
precisaria auditar a auditoria. Se o auditor reescreve a spec para bater com o
código, ele legitima o drift em vez de detectá-lo, e a spec deixa de ser fonte
de verdade.

O auditor aponta e propõe (a delta spec). Quem decide é a pessoa, e quem aplica
é a sessão principal, depois da decisão. Ver
[ADR 0004](../.agents/adr/0004-auditor-so-propoe.md).
