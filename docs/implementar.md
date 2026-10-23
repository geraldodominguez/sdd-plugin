# /sdd:implementar

## O que faz

Executa as tarefas da feature em TDD, em duas fases. Na **red**, o subagent
`escritor-de-testes` escreve os testes só a partir dos critérios de aceitação e
dos contratos, sem ver código de produção nem a intenção de quem vai
implementar. Na **green**, a sessão principal implementa até os testes passarem,
e os testes ficam **congelados**: um hook bloqueia a edição deles.

## Quando usar

Você digita `/sdd:implementar`; o agente não a usa por conta própria. Use
depois das [tarefas](tarefas.md) aprovadas. Para rodar só uma tarefa ou um grupo:
`/sdd:implementar T-004`.

## Pré-requisitos

`tarefas.md` aprovado com `/sdd:aprovar` e um comando de testes conhecido
(`comando_teste` no `.sdd/config.yml`; se estiver vazio, ela descobre e confirma
com você).

## Duas rodadas, com um gate no meio

| Rodada | O que acontece | Termina com |
|---|---|---|
| 1ª `/sdd:implementar` | fase red: o `escritor-de-testes` escreve os testes, que falham | você roda `/sdd:aprovar`, que registra o hash dos testes e leva ao green |
| 2ª `/sdd:implementar` | fase green: a sessão principal implementa, com os testes congelados | `/sdd:auditar`, ou `/sdd:aprovar` para entregar uma feature de nível 1 |

Se a sessão for interrompida, rode `/sdd:implementar` de novo: ele continua da
primeira tarefa aberta.

## Por que separar quem testa de quem implementa

Quando o mesmo agente escreve teste e código, o teste tende a confirmar a
implementação que ele já imaginou. Separados, o teste representa a spec, e o
código precisa se ajustar a ela.

Cada teste leva a **marca** `sdd:NNN:CA-XXX`, que liga o teste ao critério e é
o que o `sdd-rastrear` procura.

| Se, na fase green... | O agente |
|---|---|
| um teste parece errado | para e pergunta: corrigir a spec ou devolver ao escritor-de-testes |
| aparece algo fora do escopo | registra no [backlog](backlog.md), com origem "pendência da NNN", e não implementa |
| um contrato precisa mudar | para e propõe voltar ao plano |

## Perguntas frequentes

**O agente parou dizendo que não pode editar um teste. Por quê?**

É o hook de proteção funcionando. Na fase green, os testes estão congelados. Se
o teste está de fato errado, a correção começa no critério de aceitação da spec,
com a sua aprovação. Ver [proteção por hooks](referencia/protecao-por-hooks.md).

**O agente consegue contornar o bloqueio escrevendo o teste pelo shell?**

Tecnicamente consegue: o hook não interpreta comandos de shell. As instruções
proíbem, e a auditoria procura testes mexidos depois da fase red. Ver o
[ADR 0003](../.agents/adr/0003-hooks-fail-open.md).

## Está funcionando se

- Os testes aparecem antes do código, e falham por falta de comportamento, não por erro de sintaxe.
- Os nomes dos testes descrevem comportamento ("recusa link expirado").
- Nenhum arquivo de teste muda depois que a fase green começa (`sdd-estado aprovado testes` continua saindo com 0).
- Cada commit cita a tarefa (`feat(001): T-004 ...`).

## Onde se encaixa

Quinto passo do fluxo principal, entre [tarefas](tarefas.md) e
[auditar](auditar.md), com o [aprovar](aprovar.md) entre as fases red e green.
O mapa está na [ajuda](ajuda.md).
