# Escopo

Este repositório é um plugin pequeno e opinativo de Specification-Driven
Development. Ideias são bem-vindas, e cada uma é julgada pelo critério abaixo.
Issues servem para acompanhar mudanças no plugin. Perguntas e conversas vão para
as Discussions do GitHub.

## O critério

Uma issue de ideia ou de problema fica aberta só se cumprir **as duas** partes:

1. **Falha observada.** Descreve algo que deu errado numa sessão real: o que você rodou, o que o comando fez, o que você esperava. Uma melhoria hipotética ("seria melhor se...") não cumpre esta parte.
2. **Cabe na filosofia.** Não repete nada de [`.fora-do-escopo/`](.fora-do-escopo/) nem uma rejeição anterior, e não é uma opção de configuração, um ramo para um harness específico ou um ajuste ao fluxo de uma pessoa. Isso pertence ao seu próprio `CLAUDE.md` ou `AGENTS.md`, ou a um fork.

O tamanho não importa: uma correção de uma palavra e uma reescrita enfrentam o
mesmo critério. Reações e comentários "+1" não contam.

## O que já está decidido

Cada arquivo em [`.fora-do-escopo/`](.fora-do-escopo/) registra um conceito
rejeitado e o porquê. Leia antes de abrir uma issue:

- [`fase-sem-gate.md`](.fora-do-escopo/fase-sem-gate.md)
- [`auditor-que-corrige.md`](.fora-do-escopo/auditor-que-corrige.md)
- [`mapa-global-do-sistema.md`](.fora-do-escopo/mapa-global-do-sistema.md)
- [`hooks-como-seguranca.md`](.fora-do-escopo/hooks-como-seguranca.md)
- [`novos-comandos.md`](.fora-do-escopo/novos-comandos.md)

## Issues pouco claras

Uma issue que não dá para julgar pelo critério recebe uma rodada de perguntas e
o rótulo `precisa-de-informacao`. Sem resposta em 14 dias, é fechada. Rejeições
são fechadas como "não planejado".
