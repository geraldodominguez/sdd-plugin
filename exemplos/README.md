# Exemplos

Os arquivos que o SDD produz num projeto de verdade, para servir de referência
de **nível de detalhe**: specs curtas e precisas, planos que apontam para
requisitos, tarefas rastreáveis, uma revisão de segurança e uma auditoria com
achados reais, a spec do sistema, uma release completa, um incidente com
post-mortem, e o acompanhamento (histórico, backlog e sprint).

A história é a do [passo a passo](../docs/referencia/passo-a-passo.md): uma API
em Node e TypeScript com PostgreSQL, de um cliente fictício, a ACME.

## A feature

[`001-redefinicao-de-senha/`](001-redefinicao-de-senha/) é uma feature de
**nível 2** depois de passar por todas as fases e chegar a produção, do jeito
que fica em `specs/`.

| Arquivo | Fase | Escrito por |
|---|---|---|
| `contexto.md` | especificação | `mapeador-de-contexto` |
| `spec.md` | especificação e clarificação | sessão principal e usuário |
| `plano.md` | plano | `arquiteto-de-contratos` |
| `contratos/` | plano | `arquiteto-de-contratos` |
| `adr-0007-hash-do-token.md` | plano | `arquiteto-de-contratos`, aceito pelo usuário |
| `tarefas.md` | tarefas | sessão principal |
| `seguranca.md` | segurança | `revisor-de-seguranca`, com a decisão do usuário |
| `auditoria.md` | auditoria | `auditor-de-drift` |
| `delta-spec.md` | auditoria | `auditor-de-drift`, aceita pelo usuário |
| `estado` | todas | `sdd-estado` |
| `historico.md` | todas | `sdd-estado`, `sdd-sistema` e `sdd-release`, a cada aprovação e troca de fase |

Num projeto de verdade, o ADR ficaria em `docs/adr/0007-hash-do-token.md`. Aqui
ele está junto dos outros arquivos para facilitar a leitura.

Leia o `historico.md` de cima para baixo: ele conta a vida da feature, com cada
aprovação e o hash do que foi aprovado. Repare em três momentos: a área
sensível tornando a revisão de segurança obrigatória; a primeira revisão
mandando corrigir (S-001) e a segunda aceitando um risco (S-002); e a
reaprovação da spec depois da delta spec da auditoria, antes de a feature ficar
pronta. Depois vêm a consolidação, a release e o incidente.

## Depois de pronta

| Arquivo | No projeto fica em | O que mostra |
|---|---|---|
| [`sistema/autenticacao.md`](sistema/autenticacao.md) | `sistema/autenticacao.md` | a spec viva da capacidade, já com o requisito do hotfix, cada item com a origem |
| [`releases/0.1.0/`](releases/0.1.0/) | `releases/0.1.0/` | uma release do começo ao fim: `release.md`, `testes.md` (testador de sistema), `homologacao.md` (roteiro com o aceite da cliente), `implantacao.md` (passos e rollback), `notas.md`, `estado` e `historico.md` |
| [`incidentes/INC-001.md`](incidentes/INC-001.md) | `incidentes/INC-001.md` | um incidente S2: mitigação, hotfix, linha do tempo e post-mortem com as ações no backlog |

Leia o `historico.md` da release para ver os gates em ordem: testes, aceite (de
quem homologou), go (de quem responde pela produção) e verificação.

## A adoção de um projeto em andamento

[`adocao/`](adocao/) mostra uma loja que outro agente começou fora do plugin:
a exportação de pedidos com o CSV feito e o PDF não, uma decisão de banco e um
`TODO.md`. É o exemplo do guia
[adotar o SDD num projeto em andamento](../docs/referencia/projeto-em-andamento.md).

| Arquivo | O que mostra |
|---|---|
| [`antes/`](adocao/antes/) | os arquivos como o outro processo os deixou: `docs/specs/`, `tasks/`, `docs/decisions/`, `TODO.md` |
| [`adocao-mapa.txt`](adocao/adocao-mapa.txt) | o mapa que o agente propôs e o usuário aprovou, com o motivo de cada grupo |
| [`depois/specs/001-exportar-pedidos/transicao.md`](adocao/depois/specs/001-exportar-pedidos/transicao.md) | **como era** e **como vai ficar**: arquivos, requisitos e tarefas, linha a linha, e a fase de destino |
| [`depois/specs/001-exportar-pedidos/spec.md`](adocao/depois/specs/001-exportar-pedidos/spec.md) | a spec convertida para o modelo, com RF e CA |
| [`depois/specs/001-exportar-pedidos/tarefas.md`](adocao/depois/specs/001-exportar-pedidos/tarefas.md) | duas tarefas `[O]` (feitas fora do plugin) e duas `[ ]` (o plugin continua daqui) |
| [`depois/specs/001-exportar-pedidos/historico.md`](adocao/depois/specs/001-exportar-pedidos/historico.md) | a adoção com o hash de cada original e a aprovação da transição, que leva a feature à fase red |
| [`depois/docs/adr/0001-usar-postgres.md`](adocao/depois/docs/adr/0001-usar-postgres.md), [`depois/docs/legado/TODO.md`](adocao/depois/docs/legado/TODO.md) | o ADR numerado e o TODO preservado no legado (o item em aberto foi para o backlog) |
| [`depois/.sdd/adocao.md`](adocao/depois/.sdd/adocao.md) | o registro de onde veio cada arquivo |

Compare `antes/docs/specs/exportar-pedidos.md` com `depois/specs/001-exportar-pedidos/spec.md`,
e `antes/tasks/exportar-pedidos.md` com `depois/specs/001-exportar-pedidos/tarefas.md`:
é exatamente o que o `transicao.md` descreve.

## O acompanhamento

| Arquivo | No projeto fica em | O que mostra |
|---|---|---|
| [`backlog.md`](backlog.md) | `.sdd/backlog.md` | itens abertos, promovidos (`[x]`), descartados (`[-]`), uma pendência registrada pelo agente durante a implementação, um risco aceito na revisão de segurança e as ações do post-mortem |
| [`sprint-2026-S44.md`](sprint-2026-S44.md) | `.sdd/sprints/2026-S44.md` | uma sprint encerrada, com o resultado gerado e as conclusões |

