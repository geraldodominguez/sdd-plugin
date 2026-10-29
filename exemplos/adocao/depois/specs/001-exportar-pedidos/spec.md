# Spec 001-exportar-pedidos: Exportar pedidos

| Campo | Valor |
|---|---|
| Nível | 1 (leve) |
| Situação | rascunho |
| Criada em | 2026-10-29 |
| Origem | adoção: docs/specs/exportar-pedidos.md |
| Capacidade | pedidos |

## Objetivo

O lojista exporta os pedidos do mês para conferir as vendas fora do sistema.

## Requisitos

- **RF-001**: QUANDO o lojista pedir a exportação em CSV, O SISTEMA DEVE gerar um arquivo com data, cliente e valor de cada pedido do mês.
- **RF-002**: QUANDO o lojista pedir a exportação em PDF, O SISTEMA DEVE gerar um arquivo com o logo da loja e os mesmos campos do CSV.
- **RF-003**: SE quem pede a exportação não é o dono da loja, ENTÃO O SISTEMA DEVE recusar.

## Critérios de aceitação

- **CA-001** (valida RF-001)
  - **Dado** três pedidos em outubro
  - **Quando** o dono pede o CSV de outubro
  - **Então** recebe um arquivo com três linhas: data, cliente e valor
- **CA-002** (valida RF-002)
  - **Dado** três pedidos em outubro
  - **Quando** o dono pede o PDF de outubro
  - **Então** recebe um PDF com o logo e as três linhas
- **CA-003** (valida RF-003)
  - **Dado** um atendente logado
  - **Quando** ele pede a exportação
  - **Então** a exportação é recusada

## Fora do escopo

- Exportar outros períodos além do mês.
