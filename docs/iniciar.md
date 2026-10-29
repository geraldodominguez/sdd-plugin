# /sdd:iniciar

## O que faz

Prepara um repositório para o SDD: cria `.sdd/` (configuração, backlog,
sprints, templates), `specs/`, `sistema/` e `docs/adr/`, injeta as regras do método no `CLAUDE.md` e
no `AGENTS.md` e rascunha a **constituição**. Num projeto existente, ela
preenche a constituição só com o que observa no código (stack, versões,
camadas, comandos) e deixa como "a definir" o que não consegue confirmar. Não
inventa regra.

Num projeto que não nasceu com o plugin, ela também faz a **adoção**: lê os
artefatos que outros processos e agentes deixaram (specs, planos, tarefas,
ADRs, backlog, em qualquer pasta) e propõe um mapa que os leva para o lugar do
padrão. Ela não move nada sem a sua aprovação do mapa.

## Quando usar

Você digita `/sdd:iniciar`; o agente não a usa por conta própria. Use uma vez
por repositório, antes de qualquer outro comando. Pode rodar de novo para
atualizar o bloco de regras depois de atualizar o plugin: ela não duplica nem
apaga o que você escreveu no `CLAUDE.md`. Com o projeto já preparado, use
`/sdd:iniciar --adotar` quando o `/sdd:pendencias` mostrar artefatos "Fora do
padrão".

## O Git Flow

Antes de qualquer commit, ela prepara a base do Git Flow: pergunta se as
branches se juntam pelo plugin (`integracao: local`) ou por pull request
(`integracao: pr`), propõe renomear `master` para `main` e `development` para
`develop` quando for o caso, e cria `develop`, onde o trabalho passa a
acontecer. Os nomes das branches são fixos em todo projeto. Ver
[Git Flow](referencia/git-flow.md).

## A adoção

| Etapa | O que acontece |
|---|---|
| Inventário | `sdd-adotar inventario` acha os artefatos fora do lugar, pelo nome e pela pasta |
| Leitura | o agente lê cada um por inteiro e olha o código para saber o que já foi implementado |
| Mapa | cada arquivo recebe um destino: feature nova, ADR, `docs/arquitetura/` ou `docs/legado/` |
| **Gate** | você aprova o mapa; sem aprovação, nada se move |
| Aplicação | `sdd-adotar aplicar` renomeia para o padrão com `git mv`, numera, registra em `.sdd/adocao.md` e põe cada feature em **transição** |
| Arrumação | backlog, constituição, links e exceções |
| Conversão | o agente reescreve spec, plano e tarefas no modelo, marca `[O]` as tarefas feitas fora do plugin e `[ ]` as abertas, e preenche no `transicao.md` como era e como vai ficar |
| **Gate da transição** | você aprova cada feature com `/sdd:aprovar`, e ela continua de onde parou |

O detalhe está em [projetos existentes](referencia/projetos-existentes.md#projeto-com-artefatos-de-outro-processo).

## A constituição

O artefato mais importante que ela produz. São as regras inegociáveis que todo
plano precisa respeitar. Revise com calma: ela vale para todas as features.

| Escolha | Para quem |
|---|---|
| nível padrão 1, proteção `leve` | a maioria dos projetos |
| nível padrão 2, proteção `estrita` | projetos críticos: domínio rico, dinheiro, dados pessoais |

Ver [proteção por hooks](referencia/protecao-por-hooks.md) e
[níveis de rigor](referencia/niveis-de-rigor.md).

## A constituição e o config

| Seção da constituição | Usada por |
|---|---|
| Stack, arquitetura, qualidade e testes, convenções | plano, auditoria |
| Segurança | revisão de segurança |
| Ambientes e entrega | release, pipeline |
| Operação e manutenção | plano (observabilidade), incidentes |

| Chave do `.sdd/config.yml` | Para quê |
|---|---|
| `areas_sensiveis` | globs que tornam a revisão de segurança obrigatória no nível 1 |
| `comando_teste`, `comando_lint` | testes e lint (escritor de testes, auditor, pipeline) |
| `comando_seguranca` | varreduras de dependências, segredos e código |
| `comando_teste_sistema` | ponta a ponta e carga (testador de sistema) |
| `comando_deploy_homologacao`, `comando_deploy_producao`, `comando_verificacao_producao` | release e pipeline |

## Perguntas frequentes

**Ela altera o meu CLAUDE.md?**

Só acrescenta, ou atualiza no lugar, o bloco entre `<!-- sdd:inicio -->` e
`<!-- sdd:fim -->`. O resto do arquivo fica como está.

**Ela vai mexer nas minhas specs antigas?**

Renomeia para o padrão, só com o mapa que você aprovou, e depois converte o
conteúdo para os modelos do SDD. O `git mv` preserva o histórico de cada
arquivo, o hash do original fica no `transicao.md` e nada é apagado: o que não
entra no fluxo vai para `docs/legado/`.

**A feature continua de onde parou?**

Sim, depois que você aprova a transição. Ela nasce em transição, sem nenhuma
aprovação, porque ninguém aprovou aquele trabalho dentro do SDD. O
`transicao.md` mostra como era e como ficou, e diz em que fase ela continua
(por exemplo, `red`, com 6 tarefas `[O]` feitas fora do plugin e 4 `[ ]`
abertas). Ao aprovar, a spec, o plano e as tarefas convertidos ficam aprovados,
e o plugin segue pelas tarefas abertas. Os testes das tarefas `[O]` vêm na
fase red e devem passar de início.

**Um documento meu tem nome de artefato, mas não é do SDD.**

Ele fica onde está. Ponha o glob em `excecoes_de_layout` no `.sdd/config.yml`,
e nem o hook nem o inventário voltam a apontá-lo.

**O meu projeto já descumpre regras que eu quero na constituição. E agora?**

Coloque a regra e registre a situação atual em "Exceções aprovadas", com o plano
de saída. Uma constituição que finge que o projeto cumpre tudo ensina o agente a
ignorá-la.

## Está funcionando se

- A constituição cita versões e comandos que existem de verdade no projeto.
- Nada nela soa como boa prática genérica ("código limpo", "boas práticas").
- `/sdd:status` mostra o quadro (vazio, ou com as features adotadas), sem dizer que o projeto não usa SDD.
- `sdd-adotar contar` dá 0.

## O que versionar

| Caminho | Versionar? | Por quê |
|---|---|---|
| `.sdd/config.yml`, `constituicao.md`, `templates/`, `backlog.md`, `sprints/` | sim | são do time |
| `sistema/`, `releases/`, `incidentes/` | sim | a spec viva, as entregas e os incidentes são do time |
| `specs/` (inclusive `estado` e `historico.md` de cada feature) | sim | o quadro e as aprovações são do time |
| `.sdd/adocao.md`, `docs/legado/`, `docs/arquitetura/` | sim | de onde veio cada artefato adotado, e o que veio de outro processo |
| `.sdd/estado` | não (já vem no `.sdd/.gitignore`) | é o ponteiro pessoal: a feature ativa e a sprint atual de cada pessoa |

## Onde se encaixa

Configuração de uma vez, antes de tudo. Depois dela vêm o
[especificar](especificar.md), para uma mudança imediata, ou o
[backlog](backlog.md) e a [sprint](sprint.md), para organizar uma lista de
trabalho. O passo a passo está nos guias [projeto novo](referencia/projeto-novo.md)
e [projeto em andamento](referencia/projeto-em-andamento.md). O mapa completo
está na [ajuda](ajuda.md).
