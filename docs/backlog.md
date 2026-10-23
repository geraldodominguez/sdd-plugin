# /sdd:backlog

## O que faz

Gerencia o **backlog**: as ideias, os pedidos de cliente, os bugs relatados e as
pendências encontradas fora do escopo, tudo que ainda **não tem spec**. Lista
por prioridade, adiciona, prioriza com você, descarta com motivo e encaminha um
item para virar feature. Ele não escreve spec: um item só vira feature pelo
`/sdd:especificar B-NNN`.

## Quando usar

Você digita `/sdd:backlog`; o agente não o usa por conta própria.

| Você quer | Digite |
|---|---|
| ver o que está na fila | `/sdd:backlog` |
| guardar uma ideia para depois | `/sdd:backlog adicionar <ideia>` |
| decidir o que vem primeiro | `/sdd:backlog priorizar` |
| tirar algo da fila | `/sdd:backlog descartar B-NNN` |
| começar a trabalhar num item | `/sdd:especificar B-NNN` |

Para algo que você vai fazer agora, vá direto ao [especificar](especificar.md).

## Pré-requisitos

O [`/sdd:iniciar`](iniciar.md) rodado: o backlog mora em `.sdd/backlog.md`.

## O item de backlog

```
- [ ] B-014 Exportar relatório de vendas em CSV (prioridade: alta; nivel: 1; origem: cliente ACME; criado: 2026-10-23)
```

| Marca | Situação |
|---|---|
| `[ ]` | aberto |
| `[x]` | promovido a feature (ganha `feature: NNN-slug`) |
| `[-]` | descartado (ganha `descartado: motivo`) |

O **nível** é uma estimativa (`1`, `2` ou `?`). Item com `?` aparece nas
[pendências](pendencias.md) como "a triar". Detalhes livres podem ir em linhas
recuadas abaixo do item. Dentro da mesma prioridade, vale a ordem do arquivo.

Quando a feature nasce de um item, a ligação fica registrada nos dois lados: o
item ganha `feature: NNN-slug`, e a spec ganha `Origem: B-NNN`. A
rastreabilidade vai do pedido original até o teste.

O agente também alimenta o backlog: quando encontra algo fora do escopo durante
a implementação, ele registra como item, com origem "pendência da NNN", em vez
de implementar.

## Perguntas frequentes

**Posso editar o backlog.md à mão?**

Pode, mantendo o formato da linha, que os utilitários leem. Reordenar linhas e
acrescentar detalhes recuados é seguro.

## Está funcionando se

- Ideias deixam de virar feature na hora e passam a esperar a vez.
- O topo do backlog no [status](status.md) é o que você faria a seguir.
- Nada se perde: itens descartados ficam com motivo, e não somem.

## Onde se encaixa

Antes do fluxo principal: alimenta o [especificar](especificar.md) e o
planejamento da [sprint](sprint.md). O mapa está na [ajuda](ajuda.md).
