# /sdd:auditar

## O que faz

Passa a feature por um auditor independente, o subagent `auditor-de-drift`,
que compara o diff com a spec, os contratos, a constituição e os testes. Ele
recebe só os artefatos e o diff, nenhuma justificativa da implementação, e não
corrige nada: aponta os desvios e, quando um deles parece correto, propõe uma
**delta spec**. A decisão é sua.

## Quando usar

Você digita `/sdd:auditar`; o agente não a usa por conta própria. Use quando a
fase green terminar. É obrigatória no nível 2 e opcional no nível 1. Informe a
base da comparação se não for `main`: `/sdd:auditar develop`.

## Pré-requisitos

A fase green concluída e, se a revisão de segurança é obrigatória (sempre no
nível 2), a [`/sdd:seguranca`](seguranca.md) aprovada.

## Drift e delta spec

**Drift** é o código divergir da spec. O auditor procura quatro formas dele:

| Forma | Exemplo |
|---|---|
| Requisito não atendido | nenhuma evidência no código para o RF-003 |
| Comportamento não especificado | o código registra o IP, e nenhum requisito pede isso |
| Contrato alterado | um campo da API mudou de tipo |
| Teste enfraquecido | o teste do CA-005 passa sem verificar o "Então" |

Além do código, ele audita o **processo**: confere se a spec, o plano, as
tarefas e os testes ainda batem com o hash aprovado. Um teste alterado depois da
aprovação da fase red é achado crítico.

A sua decisão é registrada com `/sdd:aprovar`:

| Decisão | O que acontece |
|---|---|
| Aprovar | a feature fica pronta e é consolidada na spec do sistema |
| Aprovar a delta spec | a spec absorve a mudança de `delta-spec.md`, é reaprovada, e a feature fica pronta |
| Corrigir o código | a feature volta ao green, só para os desvios apontados, e é auditada de novo |

## Perguntas frequentes

**Por que o auditor não corrige o que encontra?**

Porque se corrigisse ele viraria mais um implementador, e se reescrevesse a
spec legitimaria o drift. Ver o [ADR 0004](../.agents/adr/0004-auditor-so-propoe.md).

**Discordo de um achado.**

Diga isso na decisão. O relatório é a opinião de um revisor independente, não
uma ordem. A sessão principal não deve "corrigir" o relatório.

## Está funcionando se

- Todo achado tem `arquivo:linha` ou um ID.
- O relatório encontra pelo menos o que você mesmo notaria numa revisão de código.
- Divergências aceitas terminam na spec, não só no código.

## Onde se encaixa

Último passo da revisão da feature, depois da [segurança](seguranca.md) (ou do
[implementar](implementar.md), no nível 1). A
decisão passa pelo [aprovar](aprovar.md): uma delta spec aprovada atualiza a
spec; uma correção leva de volta à fase green. O mapa está na [ajuda](ajuda.md).
