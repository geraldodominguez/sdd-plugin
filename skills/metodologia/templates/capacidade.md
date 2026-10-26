# {{TITULO}}

| Campo | Valor |
|---|---|
| Capacidade | {{CAPACIDADE}} |
| Criada em | {{DATA}} |
| Atualizada em | {{DATA}} |
| Última feature | nenhuma |

> **Spec viva do sistema.** Este arquivo diz o que o sistema FAZ HOJE nesta
> capacidade. Ele não conta a história (isso está nas features, em `specs/`):
> mostra só o comportamento vigente. Quando uma feature que toca esta
> capacidade fica pronta, os requisitos dela entram aqui, substituindo os que
> ela mudou. Cada item cita a origem no formato `origem: NNN/ID`.

## Propósito

{{o que esta capacidade entrega e para quem, em duas ou três frases}}

## Comportamento vigente

### Requisitos funcionais

- QUANDO {{evento}}, O SISTEMA DEVE {{resposta}}. (origem: {{NNN/RF-NNN}})

### Requisitos não funcionais

- O SISTEMA DEVE {{...}}. (origem: {{NNN/RNF-NNN}})

### Regras de negócio

- {{regra}} (origem: {{NNN/RF-NNN}})

## Contratos públicos

| Contrato | Onde está | Origem |
|---|---|---|
| {{ex.: POST /auth/password-reset}} | {{specs/NNN/contratos/api.yaml}} | {{NNN}} |

## Fora desta capacidade

- {{o que parece fazer parte, mas pertence a outra capacidade}}

## Histórico de consolidação

> Uma linha por feature consolidada, gravada pelo `sdd-sistema consolidar`.

| Data | Feature | Título |
|---|---|---|
