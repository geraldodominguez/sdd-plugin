# /sdd:status

## O que faz

Mostra a situação do projeto num **quadro**: a sprint atual com o progresso e os
dias restantes, as features em cada coluna (especificação, planejamento,
implementação, revisão, pronta, homologação), quantas estão em produção, a
release em andamento, os incidentes abertos, o topo do backlog e quanto está
esperando por você. Termina recomendando um único próximo comando. Não
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
Progresso: 1/3 itens entregues · 11/19 tarefas

QUADRO   ▶ feature ativa   ★ na sprint atual
Especificação
  ★ 003-perfil-com-foto                n1 · especificacao · 2 dúvida(s) · aguarda aprovação
Planejamento
  ★ 004-convite-de-membros             n2 · plano · aguarda aprovação
Implementação
  ▶ 005-exportar-csv                   n1 · green · 3/5 tarefas
Revisão
  ★ 006-limite-de-tentativas           n2 · seguranca · aguarda aprovação
Pronta
    002-ultimo-acesso                  n1 · pronta · não consolidada
Homologação
    001-redefinicao-de-senha           n2 · homologacao · release 1.2.0
Produção: 14 feature(s) · Cancelada: 1

RELEASE
  Release 1.2.0 (homologacao, normal) · objetivo: autoatendimento de senha
  próximo: executar o roteiro e 'sdd-release aceitar 1.2.0 --por "Nome"'

INCIDENTES ABERTOS: 1
  INC-003  S3  mitigado   Exportação lenta para relatórios grandes

BACKLOG: 5 item(ns) aberto(s)
  B-014  alta   n2  Login com conta Google
  ...

ESPERANDO VOCÊ: 6 item(ns) (/sdd:pendencias)
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
