# Guia de acompanhamento: a rotina do humano

O SDD coloca o agente para trabalhar dentro de limites, e você no lugar de quem
**decide**: o que entra, o que está certo e o que fica para depois. Este guia
mostra como acompanhar o trabalho sem precisar ler cada arquivo nem lembrar de
cada comando.

## O mapa em uma tabela

| Pergunta | Comando | Frequência |
|---|---|---|
| Como está o projeto? | `/sdd:status` | todo dia, ao começar |
| O que depende de mim? | `/sdd:pendencias` | todo dia, ao começar |
| O que aconteceu nesta feature? | `/sdd:retomar` | ao voltar a uma feature |
| Isto está certo para seguir? | `/sdd:aprovar` | no fim de cada fase |
| Onde guardo esta ideia? | `/sdd:backlog adicionar` | sempre que surgir |
| O que vem primeiro? | `/sdd:backlog priorizar` | toda semana, ou antes de planejar |
| O que entra neste período? | `/sdd:sprint planejar` | no começo de cada sprint |
| Estamos no ritmo? | `/sdd:sprint` | no meio da sprint |
| O que entregamos? | `/sdd:sprint encerrar` | no fim de cada sprint |
| Isto é seguro? | `/sdd:seguranca` | antes da auditoria (nível 2) ou quando a feature tocou área sensível |
| O que vai para produção, e quando? | `/sdd:release` | a cada entrega |
| O comportamento do sistema hoje | `/sdd:sistema` | ao especificar algo novo e ao consolidar uma feature pronta |
| Quebrou em produção | `/sdd:incidente` | assim que alguém percebe |

## Rotina diária (5 minutos)

1. **`/sdd:status`**: veja o quadro. Repare na coluna onde as features estão
   paradas e no número de "ESPERANDO VOCÊ".
2. **`/sdd:pendencias`**: resolva o que está bloqueando a sprint, nesta ordem:
   incidentes abertos, releases paradas esperando aceite ou go, artefatos
   alterados depois de aprovados, aprovações e dúvidas de itens da sprint,
   revisões de segurança devidas, delta specs, consolidações pendentes.
3. **`/sdd:retomar`** na feature em que vai trabalhar, se ficou um tempo longe dela.
4. Siga o comando que o status recomendou.

> O agente nunca avança uma fase sozinho. Se uma feature está parada, quase
> sempre está esperando você: é isso que o "aguarda aprovação" quer dizer.

## O que olhar em cada aprovação

O `/sdd:aprovar` mostra um resumo, mas a decisão é sua. Gaste a atenção onde ela
rende:

| Você aprova | Pergunte-se | Sinal de alerta |
|---|---|---|
| A spec | "É isso que eu quero? O que ficou de fora está certo?" | regra de negócio que você não ditou, fora do escopo vazio, marcador em aberto |
| O plano | "Isso respeita a constituição? Há dependência nova que eu não quero?" | contrato com lógica, decisão sem ADR, componente sem requisito |
| As tarefas | "Cada uma é pequena e tem requisito?" | tarefa com nome de arquivo, lacuna no `sdd-rastrear` |
| Os testes | "Os testes dizem o que a spec diz?" | teste passando antes da implementação, critério sem teste |
| A revisão de segurança | "Corrijo, ou aceito o risco por escrito?" | achado alto sem correção, segredo no código, dado pessoal em log |
| A auditoria | "Aceito o desvio, ou o código volta?" | achado crítico, teste alterado depois da red |
| A consolidação | "A spec do sistema diz agora o que o sistema faz?" | requisito da feature sem linha em `sistema/`, linha antiga contraditória que ficou |
| A homologação (aceite) | "O cliente viu e aprovou cada passo do roteiro?" | passo pendente, aceite dado por quem não é dono do produto |
| O go de produção | "Há plano de rollback testado e janela combinada?" | rollback em branco, migração irreversível sem plano |
| O post-mortem | "A ação evita que volte a acontecer?" | ação sem dono, causa raiz que é "erro humano" |

> Revise a spec, não o diff. Duas páginas de spec bem lidas valem mais que duas
> mil linhas de código passadas por cima.

## Rotina semanal: o backlog

1. **`/sdd:backlog`**: olhe a fila inteira.
2. **`/sdd:backlog priorizar`**: dê prioridade e nível aos itens novos (as
   pendências que o agente registrou chegam aqui com nível `?`) e descarte, com
   motivo, o que não faz mais sentido.

Regra útil: **ideia nova vai para o backlog, não para a sprint**. A sprint em
andamento só recebe algo novo se você decidir tirar outra coisa.

## O ciclo de uma sprint

| Momento | Comando | O que você decide |
|---|---|---|
| Começo | `/sdd:sprint planejar` | o objetivo (uma frase de resultado) e o compromisso |
| Começo | `/sdd:especificar B-NNN` para cada item sem spec | o quê e o porquê de cada item |
| Meio | `/sdd:sprint` | se está no ritmo; o que cortar, se não estiver |
| Fim | `/sdd:sprint encerrar` | o destino de cada item não concluído e as lições |

Para escolher o compromisso, prefira **menos itens concluídos a muitos itens
começados**. Uma feature de nível 2 passa por spec, plano, tarefas, testes e
auditoria.

## O ciclo de uma release

A feature `pronta` ainda não está em produção. Ela entra numa release, que tem
o seu próprio caminho e os seus próprios gates humanos:

| Momento | Comando | Quem decide |
|---|---|---|
| Preparar e testar o sistema | `/sdd:release preparar` (subagent `testador-de-sistema`) | o agente executa, você lê |
| Homologação | `/sdd:release homologar`, roteiro passo a passo | o dono do produto ou cliente aprova cada passo |
| Aceite | `/sdd:release aceitar` | o dono do produto |
| Go/no-go | `/sdd:release implantar` | quem responde pela produção |
| Implantar e verificar | o pipeline (que confere o go) e `/sdd:release concluir` | o time de operação |

Um ritmo comum: uma release por sprint, aberta no planejamento e concluída
antes do encerramento. Em produto com deploy contínuo, uma release por feature,
com homologação curta.

## Quando quebra em produção

1. **`/sdd:incidente abrir`** com a severidade (S1 para fora do ar, S4 para
   incômodo). Primeiro **mitigue** (rollback, flag desligada), registre e só
   depois corrija.
2. Correção urgente: **`/sdd:incidente hotfix`**. Começa por um teste que
   reproduz o problema; a spec vem depois, mas é aprovada antes de entregar.
3. A correção sai numa release de hotfix (`/sdd:release preparar`, que propõe uma versão patch de hotfix),
   com homologação expressa.
4. Resolvido, escreva o **post-mortem** e encerre. As ações viram itens no
   backlog.

S1 e S2 abertos aparecem no topo das pendências e geram aviso no CI até o
encerramento.

## Trabalhando em time

| O que é | Fica no git? | Por quê |
|---|---|---|
| Backlog, sprints, specs, estado e histórico de cada feature | sim | o quadro e as aprovações são do time |
| `sistema/`, `releases/`, `incidentes/` | sim | são o retrato do produto, das entregas e da operação |
| `.sdd/estado` (a feature ativa e a sprint atual de cada pessoa) | não | cada pessoa trabalha numa feature |

O autor de cada aprovação é o nome configurado no git (`git config user.name`).
Configure-o em cada máquina antes de aprovar.

Num conflito de merge em `historico.md`, mantenha as linhas dos dois lados: cada
linha é um evento com data.

## Sozinho ou com clientes

- **Sozinho:** sprint é opcional. O par `status` mais `pendencias` já dá o
  controle. Use o backlog para não perder ideias no meio de uma feature.
- **Com cliente:** registre cada pedido no backlog com a origem
  (`--origem "cliente ACME"`). A spec de cada feature guarda a origem, e a
  auditoria mostra o que foi entregue contra o que foi pedido.

## Quando algo sai do trilho

| Sintoma | O que fazer |
|---|---|
| O status mostra artefato "alterado depois da aprovação" | leia o que mudou (`git diff`) e aprove de novo, ou reverta |
| A feature cresceu no meio do caminho | `sdd-estado definir nivel=2`, depois `/sdd:clarificar` e `/sdd:planejar` |
| O agente quer mexer num teste na fase green | ele vai parar e perguntar; decida entre corrigir a spec (e reaprovar) ou devolver ao escritor de testes |
| A sprint não vai fechar | corte itens com `/sdd:sprint` e devolva-os ao backlog, em vez de estender o prazo |
| Não sei o que aconteceu enquanto estava fora | `/sdd:retomar` |
| A feature não vai mais ser feita | `sdd-estado cancelar --motivo "..."` (fica no histórico, sai do quadro) |
| A homologação reprovou uma feature | `/sdd:release aceitar` registra a reprovação: ela volta ao green e a release volta à preparação |
| Uma feature pronta precisa mudar antes de sair | `sdd-estado reabrir --motivo "..."`; as aprovações da fase de reabertura em diante caem |
| O deploy deu errado | `/sdd:release reverter`, execute o rollback do `implantacao.md` e abra um incidente |
