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
SDD: loja · proteção leve
Git Flow: em feature/005-exportar-csv

Sprint 2026-S44 (ativa) · 2026-10-26 a 2026-11-06 · faltam 4 dias
Objetivo: clientes recuperam o acesso sozinhos
Progresso: 0/3 itens concluídos · 6/6 tarefas

QUADRO   ▶ feature ativa   ★ na sprint atual
Especificação
  ★ 003-perfil-com-foto                n1 · especificacao · 2 dúvida(s) · aguarda aprovação
Planejamento
  ★ 004-convite-de-membros             n2 · plano · aguarda aprovação
Implementação
  ▶ 005-exportar-csv                   n1 · green · 3/5 tarefas
    007-importar-planilha              n1 · red · 2/6 tarefas (2 fora do plugin)
Revisão
  ★ 006-limite-de-tentativas           n2 · seguranca · aguarda aprovação
Pronta
    002-ultimo-acesso                  n1 · pronta · não consolidada
Homologação
    001-redefinicao-de-senha           n2 · homologacao · release 1.2.0
Produção: 14 feature(s) · Cancelada: 1

RELEASE
  Release 1.2.0 (homologacao, normal) · objetivo: autoatendimento de senha
    001-redefinicao-de-senha           homologacao
    documentos:
      ✓ testes.md
      ✓ homologacao.md
      · implantacao.md (a preencher)
      · notas.md (a preencher)
    próximo: executar o roteiro e 'sdd-release aceitar 1.2.0 --por "Nome"'

INCIDENTES ABERTOS: 1
  INC-003  S3  mitigado   Exportação lenta para relatórios grandes

BACKLOG: 7 item(ns) aberto(s)
  B-014  alta   n2  Login com conta Google
  B-015  alta   n1  Exportar pedidos em PDF
  B-016  media  n1  Tema escuro
  B-017  media  n?  Notificação por e-mail
  B-018  baixa  n1  Busca por cliente
  ... (/sdd:backlog para ver todos)

ESPERANDO VOCÊ: 6 item(ns) (/sdd:pendencias)
```

Cada feature guarda a própria fase, então o quadro mostra todas ao mesmo tempo,
não só a ativa. Uma feature adotada de outro processo aparece com "em
transição" até você aprovar a transição, e as tarefas feitas fora do plugin
(`[O]`) aparecem à parte. No topo, a branch em que você está; se a feature
ativa é feita em outra, um aviso diz qual.

No detalhe de uma feature (`/sdd:status 005-exportar-csv`), aparecem também a
branch dela e, depois de pronta, se já foi integrada em `develop`.

## Está funcionando se

- Você sabe, em cinco segundos, onde está o gargalo.
- A recomendação final é um comando só.
- Features paradas esperando você aparecem marcadas como "aguarda aprovação".

## Onde se encaixa

Uso avulso, a qualquer momento, e o primeiro passo da rotina diária (ver o
[guia de acompanhamento](referencia/acompanhamento.md)). O mapa dos comandos
está na [ajuda](ajuda.md).
