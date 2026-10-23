# A spec versionada é a fonte de verdade; o plugin implementa o modelo "spec-anchored"

Há três posturas comuns de SDD: **spec-first** (a spec guia o início e depois é
abandonada), **spec-anchored** (a spec é mantida viva junto ao código, e toda
mudança de comportamento passa por ela) e **spec-as-source** (só a spec é
editada por pessoas e o código é sempre regenerado).

## Decisão

O plugin implementa o **spec-anchored**. A spec fica no repositório, ao lado do
código, e é atualizada por delta specs quando a auditoria encontra divergência
aceita.

## Por quê

- O spec-first perde valor em semanas: a spec abandonada vira documentação desatualizada.
- O spec-as-source ainda não é prático para a maioria dos projetos: exige geração de código determinística e confiável, e times que aceitem nunca editar código à mão.
- O spec-anchored é o ponto de equilíbrio. Dá rastreabilidade e intenção escrita sem exigir uma mudança radical de como o time trabalha.

## Consequências

- Mudar comportamento sem passar pela spec é a falha que o plugin mais procura evitar (regra 1 do bloco de agentes).
- A auditoria precisa existir: é ela que mantém a spec ancorada ao código.
