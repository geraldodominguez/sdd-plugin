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
| `.sdd/estado` | Feature ativa, fase e nível. Leia com `sdd-estado ver`. |
| `.sdd/templates/` | Templates do projeto. Caminho de cada um: `sdd-estado template <nome>`. |
| `specs/NNN-slug/` | Uma pasta por feature: `contexto.md`, `spec.md`, `plano.md`, `contratos/`, `tarefas.md`, `auditoria.md`. |
| `docs/adr/` | Decisões arquiteturais duráveis. |

## Utilitários no PATH

- `sdd-estado ver | definir k=v | nova "título" --nivel N | usar NNN-slug | encerrar | caminho [arq] | template <nome>`
- `sdd-rastrear [NNN-slug]`: lacunas de rastreabilidade (saída 3 indica lacunas)
- `sdd-status`: painel da feature ativa
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

Toda fase termina num **gate**: apresente o artefato, peça aprovação explícita
e só então avance com `sdd-estado definir fase=<próxima>`. Nunca avance duas
fases sem aprovação.

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
5. Encontrou algo fora do escopo? Registre como pendência, não implemente.
6. Divergência entre código e spec se resolve **primeiro na spec**, com uma delta spec.

## Pedidos fora dos comandos

Se o usuário pedir uma mudança de comportamento sem usar um comando,
classifique o nível. Para o nível 1 ou 2, proponha começar com
`/sdd:especificar` em vez de ir direto ao código. Os comandos são do usuário:
diga a ele qual rodar, não tente rodá-los.
