# /sdd:status

## O que faz

Mostra a situação do projeto num **quadro**: a sprint atual com o progresso e os
dias restantes, as features em cada coluna (especificação, planejamento,
implementação, auditoria), quantas estão concluídas, o topo do backlog e quanto
está esperando por você. Termina recomendando um único próximo comando. Não
altera nada.

## Quando usar

Você digita `/sdd:status`; o agente não o usa por conta própria. Use sempre que
quiser saber "como está tudo". Com uma feature como argumento
(`/sdd:status 004-convite`), mostra o detalhe dela. O mesmo painel sai no
terminal com `sdd-status`.

| Você quer saber | Use |
|---|---|
| como está o projeto | `status` |
| o que depende de mim | [pendencias](pendencias.md) |
| o que aconteceu numa feature | [retomar](retomar.md) |

## O quadro

```
Sprint 2026-S44 (ativa) · 2026-10-26 a 2026-11-06 · faltam 4 dias
Objetivo: clientes recuperam o acesso sozinhos
Progresso: 1/3 itens concluídos · 11/19 tarefas

QUADRO   ▶ feature ativa   ★ na sprint atual
Especificação
  ★ 003-perfil-com-foto                n1 · especificacao · 2 dúvida(s) · aguarda aprovação
Planejamento
  ★ 004-convite-de-membros             n2 · plano · aguarda aprovação
Implementação
  ▶ 001-redefinicao-de-senha           n2 · green · 6/8 tarefas
Auditoria
    (vazia)
Concluída: 2 feature(s)

BACKLOG: 5 item(ns) aberto(s)
  B-014  alta   n2  Exportar relatório de vendas em CSV
  ...

ESPERANDO VOCÊ: 4 item(ns) (/sdd:pendencias)
```

Cada feature guarda a própria fase, então o quadro mostra todas ao mesmo tempo,
não só a ativa.

## Está funcionando se

- Você sabe, em cinco segundos, onde está o gargalo.
- A recomendação final é um comando só.
- Features paradas esperando você aparecem marcadas como "aguarda aprovação".

## Onde se encaixa

Uso avulso, a qualquer momento, e o primeiro passo da rotina diária (ver o
[guia de acompanhamento](referencia/acompanhamento.md)). O mapa dos comandos
está na [ajuda](ajuda.md).
