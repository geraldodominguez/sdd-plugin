# Auditoria {{FEATURE}}: {{TITULO}}

| Campo | Valor |
|---|---|
| Auditada em | {{DATA}} |
| Base da comparação | {{commit ou branch base}} até {{HEAD}} |
| Veredito | aprovada, aprovada com ressalvas ou reprovada |

> Escrita pelo subagent `auditor-de-drift`, com contexto limpo. O auditor
> **não corrige nada**: aponta divergências e propõe a delta spec. A decisão
> (corrigir o código ou aprovar a mudança na spec) é humana.

## 1. Cobertura de requisitos

| ID | Implementado? | Evidência (arquivo:linha) | Teste |
|---|---|---|---|

## 2. Critérios de aceitação

| CA | Teste com marca | Resultado | Observação |
|---|---|---|---|

## 3. Desvios encontrados (drift)

| # | Tipo | Descrição | Onde | Gravidade |
|---|---|---|---|---|

Tipos: comportamento não especificado, requisito não atendido, contrato
alterado, violação da constituição, efeito colateral, teste enfraquecido.

## 4. Conformidade com a constituição

| Regra | Situação | Evidência |
|---|---|---|

## 5. Rastreabilidade (`sdd-rastrear`)

```
{{saída do sdd-rastrear}}
```

## 6. Delta spec proposta

> Só quando um desvio parece intencional e correto. A proposta fica num arquivo
> à parte, `delta-spec.md`, na pasta da feature, pelo template de mesmo nome.
> Exige aprovação humana (`/sdd:aprovar`).

{{"nenhuma" ou um resumo de uma linha e o link para delta-spec.md}}

## 7. Processo

| Verificação | Resultado |
|---|---|
| Spec aprovada e inalterada desde a aprovação | {{sdd-estado aprovado spec.md}} |
| Plano aprovado e inalterado (nível 2) | {{sdd-estado aprovado plano.md}} |
| Tarefas aprovadas | {{sdd-estado aprovado tarefas.md}} |
| Testes inalterados desde a aprovação da fase red | {{sdd-estado aprovado testes}} |

## 8. Recomendação

{{o que fazer: corrigir T-XXX, aprovar a delta ou abrir uma nova feature}}
