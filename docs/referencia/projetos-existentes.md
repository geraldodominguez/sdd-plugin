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
| Aplicar | o `sdd-adotar` | renomeia para o padrão com `git mv`, numera features e ADRs, cria cada feature em **transição** com o `transicao.md` e registra tudo em `.sdd/adocao.md` |
| Arrumar | o agente | põe os itens em aberto no backlog, leva as regras para a constituição e atualiza os links |
| Converter | o agente | reescreve spec, plano e tarefas de cada feature no modelo do SDD e preenche, no `transicao.md`, como era e como vai ficar |
| Transição | **você** | aprova cada transição com `/sdd:aprovar`; a feature continua de onde parou |

| O artefato é | Vai para |
|---|---|
| spec, plano ou tarefas de algo ainda não implementado, ou pela metade | uma feature nova em `specs/NNN-slug/`, em transição |
| spec de algo já implementado | `docs/legado/` (não especifique o passado) |
| decisão de arquitetura | `docs/adr/NNNN-slug.md` |
| backlog, roadmap, TODO | itens no `.sdd/backlog.md`; o arquivo vai para `docs/legado/` |
| regras e convenções | conteúdo na constituição; o arquivo vai para `docs/legado/` |
| arquitetura, diagramas | `docs/arquitetura/` |

Nada é apagado: o que não entra no fluxo vai para `docs/legado/`, e o
original de cada arquivo convertido fica no git (o hash dele está no
`transicao.md`).

### Continuar de onde parou

Uma feature que outro agente deixou pela metade não recomeça do zero. Na
conversão, o agente confere no código o que já foi feito e escolhe a **fase de
destino**:

| A feature tem | Continua em |
|---|---|
| só uma ideia, ou requisitos com dúvidas | `especificacao` |
| spec clara, nível 2, sem plano | `plano` |
| spec clara (e plano, no nível 2), sem tarefas | `tarefas` |
| spec e tarefas, algumas feitas ou nenhuma | `red` |

As tarefas convertidas recebem uma marca que diz de onde vieram:

```
- [O] T-001 login por e-mail (atende: RF-001, CA-001; depende de: nada)
- [ ] T-002 redefinir a senha (atende: RF-002, CA-002; depende de: T-001)
- [x] T-003 bloquear após 5 tentativas (atende: RF-003, CA-003; depende de: T-001)
```

| Marca | Significado |
|---|---|
| `[O]` | feita **fora** do plugin, antes da adoção, sem gate; não se refaz |
| `[ ]` | aberta: o plugin continua daqui |
| `[x]` | feita **no** plugin, com os testes verdes |

Enquanto a feature está em **transição** (`adocao=transicao` no `estado`),
nada avança: o quadro mostra "em transição", o `/sdd:pendencias` cobra, e
aprovar outro artefato ou mudar a fase à mão é recusado. O `transicao.md`
mostra, linha a linha, **como era** (o arquivo, o requisito e a tarefa
originais) e **como vai ficar** (o RF, o CA e o T-NNN novos). Você aprova a
transição com `/sdd:aprovar`, e com ela a spec, o plano e as tarefas
convertidos, com o hash de cada um. A feature vai para a fase de destino.

No destino `red`, as tarefas `[O]` também ganham testes: os testes que já
existiam recebem a marca `sdd:NNN:CA-XXX`, e os que faltam são escritos. Esses
testes devem **passar** de início, e é assim que o trabalho de fora é
verificado. Se algum falhar, você decide: a tarefa volta a `[ ]` e o plugin a
refaz, ou a spec estava errada. A partir daí, o fluxo é o normal, e a marca
`[O]` fica no `tarefas.md` como registro do que veio de fora.

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
