# Decomposição em tarefas

## O tamanho certo

Uma boa tarefa:

- cabe num **único ciclo do agente**: escrever, rodar os testes, ajustar;
- toca **poucos arquivos** (como referência, até três de produção);
- tem **critério de pronto próprio**: os testes dos CAs que ela atende ficam verdes;
- pode ser **revisada sozinha**, num diff pequeno.

| Exemplo | Avaliação |
|---|---|
| "implementar a redefinição de senha" | grande demais |
| "criar o arquivo token.ts" | pequena demais, e descreve arquivo, não comportamento |
| "gerar token de uso único com expiração de 30 min (atende: RF-001, CA-001)" | boa |

## Ordem

1. **Contratos e fundação:** tipos, interfaces, migrations, configuração.
2. **Comportamento do domínio:** regras puras, as mais fáceis de testar.
3. **Aplicação e integração:** casos de uso, adaptadores, APIs.
4. **Acabamento:** observabilidade, mensagens, documentação de uso.

## Dependências e paralelismo

- `depende de: T-001, T-002` define a ordem obrigatória.
- `[P]` marca tarefas sem dependência mútua no mesmo grupo, que podem rodar em paralelo.
- Ciclo de dependência é erro de decomposição: refaça.

## Rastreabilidade

Toda tarefa cita os IDs que atende. Todo RF, RNF e CA da spec aparece em pelo
menos uma tarefa. O `sdd-rastrear` verifica as duas direções.

## Formato da linha

```
- [ ] T-003 [P] valida expiração do token (atende: RF-002, CA-003, CA-004; depende de: T-001)
```

O `sdd-rastrear` e o `sdd-status` leem exatamente este formato: `- [ ]` ou
`- [x]`, seguido de `T-NNN`.
