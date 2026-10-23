# /sdd:especificar

## O que faz

Abre uma feature e escreve a spec: o quê e por quê, com requisitos em EARS,
critérios de aceitação em Dado, Quando, Então, e o que fica fora do escopo. Ela
não decide regra de negócio por você. Tudo que não sabe vira um marcador
`[PRECISA ESCLARECER]`, em vez de uma suposição escondida no meio do texto.

## Quando usar

Você digita `/sdd:especificar <a mudança>`; o agente não a usa por conta
própria. Use sempre que for mudar comportamento observável. Ela começa
classificando o **nível de rigor** e, se a mudança for nível 0 (typo,
refatoração coberta por testes), diz que não precisa de spec.

## Pré-requisitos

O [`/sdd:iniciar`](iniciar.md) rodado no repositório.

## A spec é a fonte de verdade

Tudo que vem depois deriva dela: o plano, as tarefas, os testes, a auditoria.
Por isso ela fica sem tecnologia (isso é do plano) e com critérios que viram
teste sem precisar perguntar nada a ninguém.

Em projetos existentes, no nível 2, o subagent `mapeador-de-contexto` varre o
código e grava um `contexto.md` com o que a mudança toca. A spec usa esse mapa,
mas não copia detalhes de implementação para dentro dela.

## Perguntas frequentes

**A spec saiu com muitos marcadores. Fiz algo errado?**

Não. Marcador é o método funcionando: são as perguntas que, sem ele, o agente
teria respondido sozinho. O próximo passo é o [clarificar](clarificar.md).

**Posso escrever a spec em inglês?**

Pode. Os IDs e as marcas são o que importa para as ferramentas. Os templates
estão em português; edite os seus em `.sdd/templates/`.

## Está funcionando se

- Você encontra na spec as perguntas que teria feito, marcadas, e não respondidas.
- Nenhum requisito cita framework, tabela ou arquivo.
- Cada critério de aceitação descreve algo que você conseguiria observar de fora.
- "Fora do escopo" tem pelo menos um item.

## Onde se encaixa

Primeiro passo do fluxo principal. Depois dela vêm o [clarificar](clarificar.md)
(se houver marcadores) e o [planejar](planejar.md) (nível 2) ou as
[tarefas](tarefas.md) (nível 1). O mapa está na [ajuda](ajuda.md).
