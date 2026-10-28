# Projetos existentes

O uso mais comum do SDD não é começar do zero, e sim mudar um sistema que já
existe.

## Não especifique o passado

Escrever specs retroativas para o sistema inteiro é caro, desatualiza rápido e
atrasa tudo. **Só o que muda ganha spec.** Em poucos meses, as partes mais
mexidas do sistema, que são justamente as que mais importam, estarão
especificadas.

O mesmo vale para a spec do sistema (`sistema/`): a capacidade nasce quando a
primeira feature mexe nela, e cresce a cada consolidação. Se quiser um ponto de
partida, `/sdd:sistema mapear <capacidade>` descreve o comportamento atual a
partir do código e dos testes, marcando cada item com a origem no código (`origem: código, caminho:linha`), para
você revisar. Mapeie só a capacidade que vai mudar, não o sistema inteiro.

## Adoção em seis passos

| Passo | O quê | Por quê |
|---|---|---|
| 1 | `/sdd:iniciar`, com a constituição rascunhada a partir do código e os artefatos de outros processos trazidos ao padrão | a constituição descreve o projeto real, não um ideal, e a verdade fica num lugar só |
| 2 | comece com `protecao: leve` | a estrita exige disciplina de fases desde o primeiro dia; suba quando o fluxo estiver natural |
| 3 | use o `mapeador-de-contexto` em toda feature de nível 2 | é ele que impede a spec de ignorar o que já existe |
| 4 | ajuste os `globs_de_teste` à convenção do projeto | sem isso, os hooks e o `sdd-rastrear` não reconhecem os seus testes |
| 5 | preencha `areas_sensiveis` e os comandos de entrega no `config.yml` | a revisão de segurança e a release dependem deles |
| 6 | `/sdd:pipeline` para acrescentar o `sdd-verificar` e o go/no-go ao CI que já existe | o pipeline passa a respeitar os gates sem ser reescrito |

Se o projeto já tem um processo de deploy, a release do SDD não o substitui: ela
registra as decisões (aceite, go) e o pipeline consulta `sdd-release
pode-implantar` antes do passo de produção que já existe.

Regra que o projeto já descumpre vai para "Exceções aprovadas" na constituição,
com o plano de saída. Não finja que cumpre.

## Projeto com artefatos de outro processo

Projetos que já usaram agentes costumam ter specs, planos e tarefas
espalhados, cada agente com a sua estrutura: `docs/specs/login.md`,
`tasks/`, um `TODO.md` e um `PLAN.md` na raiz, um `.kiro/specs/` ou um
`.specify/` de outra ferramenta, ADRs em `docs/decisions/` sem numeração. O
`/sdd:iniciar` percebe isso sozinho: antes de preparar o repositório, ele roda
o `sdd-adotar inventario` e, se encontra artefatos fora do lugar, avisa que o
projeto não nasceu com o plugin.

Depois de preparar o repositório, ele faz a **adoção**:

| Etapa | Quem | O quê |
|---|---|---|
| Ler | o agente | lê por inteiro cada artefato encontrado, e a pasta inteira quando ela é de outra ferramenta |
| Classificar | o agente | agrupa o que é da mesma mudança e decide o destino de cada arquivo, olhando o código para saber o que já foi implementado |
| Mapa | o agente | escreve o mapa (`origem -> destino`) e o confere com `sdd-adotar aplicar --simular` |
| Gate | **você** | aprova o mapa, com cada destino e o motivo, as features que vão nascer e as dúvidas |
| Aplicar | o `sdd-adotar` | move com `git mv`, numera features e ADRs, cria o estado e registra tudo em `.sdd/adocao.md` |
| Arrumar | o agente | põe os itens em aberto no backlog, leva as regras para a constituição e atualiza os links |

| O artefato é | Vai para |
|---|---|
| spec, plano ou tarefas de algo ainda não implementado | uma feature nova em `specs/NNN-slug/`, na fase `especificacao`, sem aprovação |
| spec de algo já implementado | `docs/legado/` (não especifique o passado) |
| decisão de arquitetura | `docs/adr/NNNN-slug.md` |
| backlog, roadmap, TODO | itens no `.sdd/backlog.md`; o arquivo vai para `docs/legado/` |
| regras e convenções | conteúdo na constituição; o arquivo vai para `docs/legado/` |
| arquitetura, diagramas | `docs/arquitetura/` |

Nada é apagado nem reescrito: o conteúdo chega como estava, e a revisão vem no
fluxo normal (`/sdd:clarificar` e `/sdd:aprovar` em cada feature adotada).

Depois disso, o padrão se mantém: o hook bloqueia criar um artefato fora do
lugar ([proteção por hooks](protecao-por-hooks.md#arquivos-novos-só-no-lugar-do-padrão)),
o `sdd-verificar` avisa na CI e o `/sdd:pendencias` lista o que escapou em
"Fora do padrão". Para trazer de volta, `/sdd:iniciar --adotar`.

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
