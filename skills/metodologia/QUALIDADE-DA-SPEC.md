# Checklist de qualidade da spec

Use antes de encerrar `/sdd:especificar` e de novo antes de `/sdd:planejar`.

## Completude

- [ ] Objetivo e problema descritos em linguagem de negócio
- [ ] Todo requisito tem ID (`RF-NNN` ou `RNF-NNN`)
- [ ] Todo requisito tem pelo menos um CA que o valida
- [ ] Caminho feliz, erro e borda cobertos para cada RF
- [ ] Os RNFs têm números (latência, volume, disponibilidade)
- [ ] "Fora do escopo" preenchido explicitamente

## Clareza

- [ ] Nenhum termo vago (rápido, fácil, adequado, robusto, intuitivo)
- [ ] Cada requisito descreve um único comportamento
- [ ] Nenhuma tecnologia ou estrutura de código, que pertencem ao plano
- [ ] Toda suposição está marcada `[PRECISA ESCLARECER]` ou foi confirmada

## Consistência

- [ ] Nenhum requisito contradiz outro
- [ ] Nenhum requisito viola a constituição
- [ ] IDs únicos e sequenciais
- [ ] Terminologia consistente: o mesmo conceito tem o mesmo nome na spec inteira

## Testabilidade

- [ ] Cada CA vira um teste automatizado sem precisar perguntar nada a ninguém
- [ ] O "Então" descreve resultado observável, não detalhe interno

## Sinal de pronto

A spec está pronta para o plano quando não há `[PRECISA ESCLARECER]` em aberto
e o checklist passa inteiro.
