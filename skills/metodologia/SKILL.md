---
name: metodologia
description: "Disciplina do Specification-Driven Development (SDD): fases, níveis de rigor, rastreabilidade e como escrever specs, critérios de aceitação, planos e tarefas. Use ao trabalhar num projeto com pasta .sdd/, ao escrever ou revisar spec.md, plano.md, tarefas.md, ADRs ou a constituição, quando o usuário pedir uma mudança de comportamento num projeto SDD, ou mencionar spec, requisito, critério de aceitação, EARS, drift ou delta spec."
---

# SDD: Specification-Driven Development

Num projeto com `.sdd/`, **a spec é a fonte de verdade**. O código deriva
dela. Mudança de comportamento começa na spec, nunca no código.

## Mapa do projeto

| Caminho | O que é |
|---|---|
| `.sdd/constituicao.md` | Regras inegociáveis. Todo plano é checado contra ela. |
| `.sdd/config.yml` | Nível padrão, proteção, globs de teste e de contrato, comandos. |
| `.sdd/estado` | Ponteiros pessoais: feature ativa e sprint atual. Leia com `sdd-estado ver`. |
| `.sdd/backlog.md` | Itens sem spec (`B-NNN`), por prioridade. |
| `.sdd/sprints/<id>.md` | Uma sprint por arquivo: objetivo, datas, compromisso, revisão. |
| `.sdd/templates/` | Templates do projeto. Caminho de cada um: `sdd-estado template <nome>`. |
| `specs/NNN-slug/` | Uma pasta por feature: `estado`, `historico.md`, `contexto.md`, `spec.md`, `plano.md`, `contratos/`, `tarefas.md`, `auditoria.md`, `delta-spec.md`. |
| `docs/adr/` | Decisões arquiteturais duráveis. |

## Utilitários no PATH

- `sdd-estado ver | definir k=v | nova "título" --nivel N [--origem B-NNN] | usar NNN-slug | encerrar | aprovar | aprovado <artefato> | listar | historico | caminho [arq] | template <nome>`
- `sdd-rastrear [NNN-slug]`: lacunas de rastreabilidade (saída 3 indica lacunas)
- `sdd-status [NNN-slug]`: quadro do projeto, ou detalhe de uma feature
- `sdd-backlog listar | adicionar | ver | prioridade | promover | descartar | contar`
- `sdd-sprint nova | incluir | remover | iniciar | encerrar | ver | listar | itens`
- `sdd-pendencias [--contar]`: o que espera decisão humana
- `sdd-iniciar`: prepara o projeto (usado por `/sdd:iniciar`)

## Fases

| Fase | Pergunta | Artefato | Quem |
|---|---|---|---|
| `especificacao` | O quê e por quê? | `spec.md` (e `contexto.md`) | sessão principal, com o `mapeador-de-contexto` |
| `clarificacao` | O que está ambíguo? | `spec.md` atualizada | sessão principal e usuário |
| `plano` | Como? | `plano.md`, `contratos/`, ADRs | `arquiteto-de-contratos` |
| `tarefas` | Em que passos? | `tarefas.md` | sessão principal |
| `red` | Como provar que funciona? | testes falhando | `escritor-de-testes` |
| `green` | Fazer passar | código de produção | sessão principal |
| `auditoria` | Bate com a spec? | `auditoria.md` | `auditor-de-drift` |
| `concluida` | | | |

Toda fase termina num **gate**: apresente o artefato e diga ao usuário para
rodar `/sdd:aprovar`. É o `/sdd:aprovar` que registra a aprovação no
`historico.md`, com o hash do artefato, e avança a fase. **Nunca registre uma
aprovação nem avance a fase por conta própria.**

Antes de começar uma fase, confira a aprovação da anterior com
`sdd-estado aprovado <artefato>`: saída 0 é aprovado e inalterado; 4, alterado
depois da aprovação; 5, nunca aprovado. Com 4 ou 5, pare e peça `/sdd:aprovar`.

| Fase | Aprova-se | Leva a |
|---|---|---|
| `especificacao`, `clarificacao` | `spec.md` | `plano` (nível 2) ou `tarefas` (nível 1) |
| `plano` | `plano.md` e `contratos/` | `tarefas` |
| `tarefas` | `tarefas.md` | `red` |
| `red` | os testes marcados `sdd:NNN:` | `green` |
| `green` | a entrega (só nível 1) | `concluida` |
| `auditoria` | a decisão: aprovar, delta ou corrigir | `concluida` ou `green` |

## Níveis de rigor

- **0, direto:** não muda comportamento (typo, formatação, refatoração coberta por testes). Sem feature.
- **1, leve:** correção de bug ou mudança localizada. `spec-leve`, tarefas, red e green.
- **2, completo:** feature nova, domínio, schema, contrato público ou segurança. O fluxo inteiro.

Regra de ouro: **mudou comportamento observável, nível 1 no mínimo.** Na dúvida,
o maior. Detalhes em [NIVEIS-DE-RIGOR.md](NIVEIS-DE-RIGOR.md).

## Como escrever cada artefato

**Spec:** só O QUÊ e POR QUÊ. IDs `RF-NNN`, `RNF-NNN`, `CA-NNN`, `US-NNN`.
Requisitos em EARS ([EARS.md](EARS.md)). Critérios em Dado, Quando, Então
([CRITERIOS-DE-ACEITACAO.md](CRITERIOS-DE-ACEITACAO.md)). Toda dúvida vira
`[PRECISA ESCLARECER: pergunta]`. **Nunca preencha lacuna com suposição.**
Antes de entregar, passe pelo [QUALIDADE-DA-SPEC.md](QUALIDADE-DA-SPEC.md).

**Plano:** só COMO. Toda decisão aponta para um requisito. Checagem explícita
contra a constituição. Decisão durável vira ADR.

**Contratos:** as fronteiras do sistema (entidades, objetos de valor,
interfaces, schemas, OpenAPI, DDL). Ficam congelados durante a implementação.

**Tarefas:** pequenas, verificáveis, com IDs de rastreio e dependências
([DECOMPOSICAO-DE-TAREFAS.md](DECOMPOSICAO-DE-TAREFAS.md)). Formato da linha:
`- [ ] T-NNN [P] descrição (atende: RF-NNN, CA-NNN; depende de: T-NNN)`

**Testes:** todo CA tem teste com a marca `sdd:<NNN>:<CA-ID>`, por exemplo
`// sdd:004:CA-003`.

**Commits:** `tipo(NNN): T-XXX descrição`.

## Invariantes

1. Não implemente nada que não esteja numa tarefa da feature ativa.
2. Na fase `green`, não altere testes para fazê-los passar. Se um teste parece
   errado, pare e diga isso ao usuário. A correção começa pela spec, com aprovação.
3. Não altere contratos em `red` ou `green` sem voltar ao plano, com aprovação.
4. Não avance de fase sem aprovação humana explícita.
5. Encontrou algo fora do escopo? Registre no backlog
   (`sdd-backlog adicionar "título" --nivel ? --origem "pendência da NNN"`), não implemente.
6. Divergência entre código e spec se resolve **primeiro na spec**, com uma delta spec.

## Backlog e sprint

O **backlog** guarda o que ainda não tem spec: ideias, pedidos, bugs relatados,
pendências fora do escopo. Um item vira feature com `/sdd:especificar B-NNN`.
A **sprint** é um período com objetivo e compromisso (features e itens de
backlog). Pedidos que são para depois vão para o backlog, não viram feature na
hora.

## Pedidos fora dos comandos

Se o usuário pedir uma mudança de comportamento sem usar um comando,
classifique o nível. Para o nível 1 ou 2, proponha começar com
`/sdd:especificar` em vez de ir direto ao código. Os comandos são do usuário:
diga a ele qual rodar, não tente rodá-los.
