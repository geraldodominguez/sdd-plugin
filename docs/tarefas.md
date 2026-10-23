# /sdd:tarefas

## O que faz

Quebra a spec (e o plano, no nível 2) em tarefas pequenas e ordenadas. Cada
tarefa cita os requisitos e critérios que atende e as tarefas de que depende.
Ela confere a **rastreabilidade** com o `sdd-rastrear` antes de entregar: nenhum
requisito sem tarefa, nenhuma tarefa sem requisito.

## Quando usar

Você digita `/sdd:tarefas`; o agente não a usa por conta própria. Use depois do
plano aprovado (nível 2) ou da spec aprovada (nível 1). Sem a aprovação, ela
para e pede `/sdd:aprovar`.

## O formato da linha

```
- [ ] T-003 [P] valida expiração do token (atende: RF-002, CA-003; depende de: T-001)
```

O `[P]` marca tarefas que podem rodar em paralelo. O `sdd-rastrear` e o
`sdd-status` leem exatamente este formato, por isso ele é fixo.

## Perguntas frequentes

**O sdd-rastrear aponta que os critérios não têm teste. Está errado?**

Não. Nesta fase ainda não há testes. Essas lacunas somem no
[implementar](implementar.md). As lacunas que precisam sumir aqui são as de
tarefa.

## Está funcionando se

- Cada tarefa descreve um comportamento, não um arquivo.
- Você consegue imaginar o diff de cada tarefa revisado sozinho.
- O `sdd-rastrear` só aponta lacunas de teste.

## Onde se encaixa

Quarto passo do fluxo principal. Termina no [aprovar](aprovar.md); depois vem
o [implementar](implementar.md). O progresso das tarefas aparece no
[status](status.md) e na [sprint](sprint.md). O mapa está na [ajuda](ajuda.md).
