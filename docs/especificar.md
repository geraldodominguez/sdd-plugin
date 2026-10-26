# /sdd:especificar

## O que faz

Abre uma feature e escreve a spec: o quê e por quê, com requisitos em EARS,
critérios de aceitação em Dado, Quando, Então, e o que fica fora do escopo. Ela
não decide regra de negócio por você. Tudo que não sabe vira um marcador
`[PRECISA ESCLARECER]`, em vez de uma suposição escondida no meio do texto.

## Quando usar

Você digita `/sdd:especificar`; o agente não a usa por conta própria. Use
sempre que for mudar comportamento observável. Ela começa classificando o
**nível de rigor** e, se a mudança for nível 0 (typo, refatoração coberta por
testes), diz que não precisa de spec.

| Ponto de partida | Digite |
|---|---|
| um pedido novo, para agora | `/sdd:especificar <a mudança>` |
| um item do backlog | `/sdd:especificar B-NNN` (o item é promovido e a spec registra a origem) |
| uma ideia para depois | não especifique: `/sdd:backlog adicionar <ideia>` |

## Pré-requisitos

O [`/sdd:iniciar`](iniciar.md) rodado no repositório.

## Capacidade e segurança

Antes de escrever, ela decide duas coisas com você:

| Decisão | Para quê |
|---|---|
| **Capacidade** (cadastro, autenticação, faturamento...) | ler o comportamento vigente em `sistema/<capacidade>.md` e, quando a feature ficar pronta, consolidar nela |
| **Revisão de segurança** obrigatória ou dispensada | sempre obrigatória no nível 2; no nível 1, quando a mudança toca autenticação, dados pessoais, pagamentos ou as áreas sensíveis do projeto |

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
- Ela termina pedindo `/sdd:aprovar`, sem aprovar sozinha.

## Onde se encaixa

Primeiro passo do fluxo principal, alimentado pelo [backlog](backlog.md).
Depois dela vêm o [clarificar](clarificar.md), se houver marcadores, e o
[aprovar](aprovar.md). Com a spec aprovada, seguem o [planejar](planejar.md)
(nível 2) ou as [tarefas](tarefas.md) (nível 1). O mapa está na [ajuda](ajuda.md).
