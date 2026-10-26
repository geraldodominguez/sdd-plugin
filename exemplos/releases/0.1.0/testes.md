# Testes de sistema da release 0.1.0

| Campo | Valor |
|---|---|
| Executados em | 2026-10-29 |
| Ambiente | homologação, commit 9b2c4f1 |
| Resultado | aprovado |

> Escritos e executados pelo subagent `testador-de-sistema`. Cobrem o que o TDD
> de cada feature não cobre: o sistema inteiro funcionando junto.

## 1. Regressão

| Suíte | Comando | Testes | Falhas |
|---|---|---|---|
| Completa | `npm test` | 412 | 0 |

## 2. Ponta a ponta

| Fluxo | Features envolvidas | Arquivo | Resultado |
|---|---|---|---|
| Esqueci a senha, recebo o e-mail, defino a nova, entro com ela | 001 | `e2e/redefinicao-de-senha.spec.ts` | passou |
| Entro, vejo no perfil a data do último acesso | 002 | `e2e/ultimo-acesso.spec.ts` | passou |
| Redefino a senha e o último acesso não muda até eu entrar de novo | 001, 002 | `e2e/redefinicao-e-ultimo-acesso.spec.ts` | passou |

## 3. Requisitos não funcionais com número

| RNF | Meta | Medido | Como mediu | Resultado |
|---|---|---|---|---|
| 001/RNF-001 | 5 por hora por e-mail, 20 por hora por IP | o 6º pedido e o 21º pedido recebem 429 | `e2e/limites.spec.ts` | passou |
| 001/RNF-004 | IP sem o e-mail, retenção de 90 dias | registro sem e-mail; job de expurgo agendado | consulta na tabela e no agendador | passou |

## 4. Falhas encontradas

| # | Teste | Feature provável | Gravidade | Situação |
|---|---|---|---|---|

Nenhuma.

## 5. Conclusão

Pronta para homologação. Fora do escopo destes testes: concorrência entre duas
confirmações simultâneas do mesmo link (nenhum RNF pedia; ver INC-001).
