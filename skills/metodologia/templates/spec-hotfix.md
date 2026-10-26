# Spec {{FEATURE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Nível | 1 (hotfix) |
| Situação | rascunho, **retroativa** |
| Criada em | {{DATA}} |
| Origem | {{ORIGEM}} |
| Capacidade | {{CAPACIDADE}} |

> **Hotfix.** A correção começa antes da spec, para não atrasar a resposta a um
> incidente em produção. Mas a spec é obrigatória: a feature só fica pronta
> depois que esta spec for preenchida e aprovada (`/sdd:aprovar`). Escreva-a
> logo depois da correção, enquanto o contexto está fresco.

## Comportamento incorreto

{{o que o sistema fazia, com o impacto observado no incidente}}

## Comportamento correto

- **RF-001**: {{O SISTEMA DEVE ...}}

## Critérios de aceitação

- **CA-001** (valida RF-001, teste de regressão do incidente)
  - **Dado** {{as condições que provocaram o incidente}}
  - **Quando** {{a ação}}
  - **Então** {{o resultado correto}}

## Causa

{{causa técnica imediata; a análise completa vai no post-mortem do incidente}}

## Fora do escopo

- {{melhorias que o incidente sugeriu e vão para o backlog}}
