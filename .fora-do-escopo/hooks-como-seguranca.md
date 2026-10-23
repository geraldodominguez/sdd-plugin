# Hooks como garantia de segurança

Pedidos para que os hooks bloqueiem qualquer forma de contorno (edição pelo
shell, troca de fase pelo próprio agente, escrita por subagent) estão fora do
escopo.

## Por que está fora do escopo

Os hooks são trilhos contra deslizes, não um sandbox. Tentar fechar todas as
brechas exigiria interpretar comandos de shell arbitrários, o que é frágil e
gera falsos bloqueios que atrapalham o trabalho legítimo. Por isso os hooks são
fail-open: na dúvida, permitem.

A garantia real vem de três lugares: os gates humanos, a auditoria
independente e o `sdd-rastrear` rodando na CI. Ver
[ADR 0003](../.agents/adr/0003-hooks-fail-open.md).
