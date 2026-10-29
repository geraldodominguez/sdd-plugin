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

`tarefas.md` aprovado com `/sdd:aprovar`, a spec (e, no nível 2, o plano)
aprovada e sem alteração depois disso, e um comando de testes conhecido
(`comando_teste` no `.sdd/config.yml`; se estiver vazio, ela descobre e confirma
com você). Marcar tarefas como feitas não conta como alteração.

## Duas rodadas, com um gate no meio

| Rodada | O que acontece | Termina com |
|---|---|---|
| 1ª `/sdd:implementar` | fase red: o `escritor-de-testes` escreve os testes, que falham | você roda `/sdd:aprovar`, que registra o hash dos testes e leva ao green |
| 2ª `/sdd:implementar` | fase green: a sessão principal implementa, com os testes congelados | o próximo passo da tabela abaixo |

Se a sessão for interrompida, rode `/sdd:implementar` de novo: ele continua da
primeira tarefa aberta.

## Depois da fase green

No fim, o agente roda `sdd-estado sensivel`: se a feature tocou uma das
`areas_sensiveis` do `.sdd/config.yml` (em qualquer commit dela, desde que ela
começou, ou em arquivo ainda não commitado), a revisão de segurança passa a ser
obrigatória para esta feature.

| Feature | Próximo |
|---|---|
| nível 2 | [`/sdd:seguranca`](seguranca.md), depois [`/sdd:auditar`](auditar.md) |
| nível 1 com segurança obrigatória | [`/sdd:seguranca`](seguranca.md) |
| nível 1 sem segurança obrigatória | `/sdd:aprovar` (entrega), ou `/sdd:auditar` antes |
| hotfix | spec retroativa, `/sdd:aprovar` da spec, depois da entrega |

## A branch e os commits

O trabalho acontece na branch da feature, `feature/NNN-slug` (ou `hotfix/X.Y.Z`
num hotfix): se você estiver em outra, ela muda para a certa antes de começar
(`sdd-gitflow feature`). Os commits seguem o Conventional Commits e citam a
tarefa, `tipo(NNN): T-XXX descrição`, e o tipo decide a próxima versão: `feat`
para comportamento novo, `fix` para correção, `test` para os testes da fase
red, `!` para o que quebra um contrato público. Ver [Git Flow](referencia/git-flow.md)
e [versionamento](referencia/versionamento.md).

## Casos especiais

### Hotfix

Um hotfix (aberto pelo [`/sdd:incidente`](incidente.md)) já nasce na fase red,
sem tarefas nem spec. O `escritor-de-testes` recebe o incidente e escreve o
**teste de regressão** que reproduz o problema. Depois da correção, a spec é
escrita e aprovada: sem ela, a feature não fica pronta.

### Feature adotada

Numa feature que veio de outro processo, as tarefas `[O]` foram feitas fora do
plugin. Elas não se implementam de novo, mas os critérios delas ganham testes
na fase red (os que já existiam recebem a marca), e esses testes devem passar
de início. Se um falhar, você decide se a tarefa volta a `[ ]`, para o plugin
refazer. Na fase green, só as tarefas `[ ]` são implementadas.

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

Etapa de construção, entre [tarefas](tarefas.md) e a revisão
([segurança](seguranca.md) e [auditar](auditar.md)), com o
[aprovar](aprovar.md) entre as fases red e green.
O mapa está na [ajuda](ajuda.md).
