# Papéis separados são subagents, não skills

Uma proposta comum é dividir o SDD em várias skills (indexador, arquiteto,
executor de TDD, auditor) orquestradas por uma skill principal.

## Decisão

Cada papel que precisa de **independência** é um **subagent**. Skills guardam o
conhecimento e disparam as fases. Ficam quatro subagents:
`mapeador-de-contexto`, `arquiteto-de-contratos`, `escritor-de-testes` e
`auditor-de-drift`.

## Por quê

Uma skill é carregada na sessão de quem a invoca. Várias skills na mesma sessão
compartilham a mesma janela de contexto: um "auditor" carregado como skill é o
mesmo agente que acabou de escrever o código, com as mesmas premissas. A
separação seria só de nome.

Um subagent roda com janela própria, recebe só o que lhe é passado e devolve um
resumo. É isso que torna real a separação entre quem testa, quem implementa e
quem audita.

## Consequências

- As skills de fase instruem explicitamente o que **não** passar ao subagent (o código ao `escritor-de-testes`, as justificativas ao `auditor-de-drift`).
- O `escritor-de-testes` e o `auditor-de-drift` têm ferramentas de escrita e de shell; o que os limita são as instruções e, na proteção estrita, os hooks. Ver ADR 0003.
