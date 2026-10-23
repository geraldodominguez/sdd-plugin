# Projetos existentes

O uso mais comum do SDD não é começar do zero, e sim mudar um sistema que já
existe.

## Não especifique o passado

Escrever specs retroativas para o sistema inteiro é caro, desatualiza rápido e
atrasa tudo. **Só o que muda ganha spec.** Em poucos meses, as partes mais
mexidas do sistema, que são justamente as que mais importam, estarão
especificadas.

## Adoção em quatro passos

| Passo | O quê | Por quê |
|---|---|---|
| 1 | `/sdd:iniciar`, com a constituição rascunhada a partir do código | a constituição descreve o projeto real, não um ideal |
| 2 | comece com `protecao: leve` | a estrita exige disciplina de fases desde o primeiro dia; suba quando o fluxo estiver natural |
| 3 | use o `mapeador-de-contexto` em toda feature de nível 2 | é ele que impede a spec de ignorar o que já existe |
| 4 | ajuste os `globs_de_teste` à convenção do projeto | sem isso, os hooks e o `sdd-rastrear` não reconhecem os seus testes |

Regra que o projeto já descumpre vai para "Exceções aprovadas" na constituição,
com o plano de saída. Não finja que cumpre.

## Área sem testes

Quando o `contexto.md` aponta que a área afetada não tem testes:

1. considere uma primeira tarefa de **testes de caracterização**, que registram o comportamento atual antes da mudança;
2. registre na spec que ela está fora do escopo funcional, mas é necessária para a segurança da mudança.

Se o projeto não tem testes de forma alguma, a constituição diz o que se espera
**daqui para a frente** ("toda feature nova tem testes para os seus critérios"),
e a infraestrutura mínima vira uma tarefa explícita da primeira feature.

## Features antigas que quebram

Abra uma feature nova, de nível 1 ou 2, para a correção. A spec dela documenta o
comportamento esperado daquela parte. Não é preciso reconstruir a história.

## Quando não usar

| Situação | Por quê |
|---|---|
| Protótipo descartável, spike de pesquisa | o código existe para responder uma pergunta, não para durar |
| Projeto que não é software (conteúdo, procedimentos, mídia) | o plugin é feito para código; o template de spec pode servir como briefing |
