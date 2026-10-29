---
name: metodologia
description: "Disciplina do Specification-Driven Development (SDD) do pedido à manutenção: fases da feature e da release, gates, níveis de rigor, rastreabilidade, segurança, spec viva do sistema, incidentes, e como escrever specs, critérios de aceitação, planos e tarefas. Use ao trabalhar num projeto com pasta .sdd/, ao escrever ou revisar spec.md, plano.md, tarefas.md, seguranca.md, ADRs, a constituição ou a spec do sistema, quando o usuário pedir uma mudança de comportamento num projeto SDD, ou mencionar spec, requisito, critério de aceitação, EARS, drift, delta spec, release, homologação, deploy, hotfix ou incidente."
---

# SDD: Specification-Driven Development

Num projeto com `.sdd/`, **a spec é a fonte de verdade**. O código deriva dela.
Mudança de comportamento começa na spec, nunca no código. O ciclo completo
está em [CICLO-DE-VIDA.md](CICLO-DE-VIDA.md): leia quando precisar decidir o
próximo passo fora do comum.

## Mapa do projeto

| Caminho | O que é |
|---|---|
| `.sdd/constituicao.md` | Regras inegociáveis, inclusive segurança, ambientes e operação. Todo plano é checado contra ela. |
| `.sdd/config.yml` | Nível padrão, proteção, globs de teste, contrato e áreas sensíveis, comandos (teste, lint, segurança, deploy). |
| `.sdd/estado` | Ponteiros pessoais: feature ativa e sprint atual. |
| `.sdd/backlog.md`, `.sdd/sprints/` | O que vem depois, e o que entra neste período. |
| `specs/NNN-slug/` | Uma pasta por feature: `estado`, `historico.md`, `contexto.md`, `spec.md`, `plano.md`, `contratos/`, `tarefas.md`, `seguranca.md`, `auditoria.md`, `delta-spec.md`. |
| `sistema/<capacidade>.md` | A spec viva: o que o sistema faz **hoje**, por capacidade. Leia antes de mudar uma área. |
| `releases/<versão>/` | `release.md`, `testes.md`, `homologacao.md`, `implantacao.md`, `notas.md`, `historico.md`. |
| `incidentes/INC-NNN.md` | Um incidente, da abertura ao post-mortem. |
| `docs/adr/NNNN-slug.md` | Decisões arquiteturais duráveis, numeradas com 4 dígitos. |
| `docs/arquitetura/` | Documentos e diagramas de arquitetura, como referência. |
| `docs/legado/` | O que veio de outro processo e não entra no fluxo. Não é fonte de verdade. |

Esses são os únicos lugares de artefatos de processo. Não crie pastas ou nomes
próprios (`docs/specs/`, `tasks/`, `TODO.md`, `PLAN.md`): o hook bloqueia, e o
que escapar aparece no `sdd-pendencias` como "Fora do padrão".

## Utilitários no PATH

- `sdd-estado ver | definir | nova | usar | aprovar | aprovado | cancelar | reabrir | sensivel | listar | historico | caminho | template`
- `sdd-sistema listar | nova | ver | consolidar | consolidada | pendentes`
- `sdd-release proxima | analisar | changelog | nova | incluir | remover | homologar | aceitar | reprovar | autorizar | pode-implantar | concluir | reverter | cancelar | ver | listar | atual`
- `sdd-incidente abrir | situacao | nota | hotfix | encerrar | listar | ver`
- `sdd-adotar inventario | contar | aplicar` (usado pelo `/sdd:iniciar`; o mapa só se aplica com a aprovação do usuário)
- `sdd-gitflow conferir | iniciar | renomear | feature | release | hotfix | integrar | finalizar | esperada | pode-integrar`
- `sdd-backlog`, `sdd-sprint`, `sdd-status`, `sdd-pendencias`, `sdd-rastrear`, `sdd-verificar`, `sdd-iniciar`

## Fases da feature

| Fase | Pergunta | Artefato | Quem | Gate (o que se aprova) |
|---|---|---|---|---|
| `especificacao`, `clarificacao` | O quê e por quê? | `spec.md` | sessão principal, `mapeador-de-contexto` | `spec.md` |
| `plano` (nível 2) | Como? | `plano.md`, `contratos/`, ADRs | `arquiteto-de-contratos` | `plano.md` |
| `tarefas` | Em que passos? | `tarefas.md` | sessão principal | `tarefas.md` |
| `red` | Como provar? | testes falhando | `escritor-de-testes` | testes |
| `green` | Fazer passar | código | sessão principal | entrega (nível 1 sem segurança) |
| `seguranca` | É seguro? | `seguranca.md` | `revisor-de-seguranca` | decisão: aprovar, aceitar-risco, corrigir |
| `auditoria` | Bate com a spec? | `auditoria.md` | `auditor-de-drift` | decisão: aprovar, delta, corrigir |
| `pronta` | | consolidação em `sistema/` | sessão principal | |
| `homologacao`, `producao` | | `releases/<versão>/` | `/sdd:release`, `testador-de-sistema` | aceite do negócio, go/no-go |
| `cancelada` | | | | |

Revisão de segurança: **sempre** no nível 2; no nível 1 quando a mudança toca
`areas_sensiveis` (o `sdd-estado sensivel` marca) ou a spec a exige. Auditoria:
sempre no nível 2, opcional no nível 1.

## Gates

Toda fase termina num **gate**: apresente o artefato e diga ao usuário para
rodar `/sdd:aprovar` (ou o `/sdd:release`, nos gates da release). É ele que
registra a aprovação no `historico.md` com o hash do artefato e avança.
**Nunca registre uma aprovação nem avance a fase por conta própria.**
`sdd-estado definir fase=` recusa as fases `pronta`, `homologacao`, `producao`
e `cancelada`.

Antes de começar uma fase, confira a anterior com
`sdd-estado aprovado <artefato>`: 0 é aprovado e inalterado; 4, alterado depois
da aprovação; 5, não aprovado (ou invalidado por reabertura). Com 4 ou 5, pare
e peça `/sdd:aprovar`.

## Níveis de rigor

- **0, direto:** não muda comportamento. Sem feature.
- **1, leve:** correção de bug ou mudança localizada.
- **2, completo:** feature nova, domínio, schema, contrato público, segurança, dinheiro.

Mudou comportamento observável, nível 1 no mínimo. Na dúvida, o maior. Ver
[NIVEIS-DE-RIGOR.md](NIVEIS-DE-RIGOR.md).

## Como escrever cada artefato

**Spec:** só O QUÊ e POR QUÊ. IDs `RF-NNN`, `RNF-NNN`, `CA-NNN`, `US-NNN`.
Requisitos em EARS ([EARS.md](EARS.md)). Critérios em Dado, Quando, Então
([CRITERIOS-DE-ACEITACAO.md](CRITERIOS-DE-ACEITACAO.md)). Toda dúvida vira
`[PRECISA ESCLARECER: pergunta]`. Declare a **capacidade** e o **impacto na spec
do sistema**. Passe pelo [QUALIDADE-DA-SPEC.md](QUALIDADE-DA-SPEC.md).

**Plano:** só COMO. Cada decisão aponta para um requisito. Checagem contra a
constituição, **ameaças e mitigações**, **implantação e rollback**,
**observabilidade**. Decisão durável vira ADR.

**Contratos:** fronteiras (entidades, interfaces, schemas, OpenAPI, DDL),
congelados durante a implementação.

**Tarefas:** pequenas, rastreáveis ([DECOMPOSICAO-DE-TAREFAS.md](DECOMPOSICAO-DE-TAREFAS.md)):
`- [ ] T-NNN [P] descrição (atende: RF-NNN, CA-NNN; depende de: T-NNN)`.
`[x]` é feita no plugin; `[O]` é feita fora do plugin, antes da adoção, sem
gate: não se refaz, mas os testes dos critérios dela vêm na fase red e devem
passar de início.

**Feature adotada:** veio de outro processo e nasce em transição
(`adocao=transicao`), com um `transicao.md` que mostra como ela era e como
fica. Nada avança antes de o usuário aprovar a transição (`/sdd:aprovar`).

**Testes:** todo CA tem teste com a marca `sdd:<NNN>:<CA-ID>`. O hash dos testes
cobre só os blocos marcados com o número da feature.

**Commits:** Conventional Commits, `tipo(NNN): T-XXX descrição`
([VERSIONAMENTO.md](VERSIONAMENTO.md)). O tipo decide a versão: `feat` sobe o
minor, `fix` e `perf` o patch, `!` ou `BREAKING CHANGE:` o major; `docs`,
`chore`, `refactor`, `test`, `build`, `ci`, `style` e `revert` não mudam a
versão. O hook bloqueia mensagem fora do formato.

**Git Flow** ([GIT-FLOW.md](GIT-FLOW.md)): nomes fixos em todo projeto.
`main` (produção, só por merge, tag `vX.Y.Z`), `develop` (integração),
`feature/NNN-slug` (uma por feature, de `develop`), `release/X.Y.Z` (de
`develop`) e `hotfix/X.Y.Z` (de `main`). Branch se cria pelo `sdd-gitflow`,
nunca à mão; o commit de uma feature ativa vai na branch dela.

## Invariantes

1. Não implemente nada fora das tarefas da feature ativa.
2. Depois da fase red, não altere testes para fazê-los passar. Teste errado: pare e diga ao usuário.
3. Não altere contratos durante a implementação sem voltar ao plano, com aprovação.
4. Não avance de fase nem registre aprovação sem o comando do usuário.
5. Algo fora do escopo vai para o backlog (`sdd-backlog adicionar ... --origem "pendência da NNN"`).
6. Divergência entre código e spec se resolve **primeiro na spec** (delta spec).
7. Não implante nada sem o go registrado da release, nem mitigue um incidente sem confirmação.
8. Feature em produção não se reabre: mudança nova é feature nova; defeito é incidente.

## Pedidos fora dos comandos

| Pedido | Caminho |
|---|---|
| mudança de comportamento para agora | classifique o nível e proponha `/sdd:especificar` |
| ideia para depois | `/sdd:backlog adicionar` |
| "está quebrado em produção" | `/sdd:incidente abrir` |
| "sobe isso para produção" | `/sdd:release` (nunca deploy direto) |
| "o que o sistema faz em X?" | leia `sistema/` |

Os comandos são do usuário: diga qual rodar, não tente rodá-los.
