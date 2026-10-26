# /sdd:iniciar

## O que faz

Prepara um repositório para o SDD: cria `.sdd/` (configuração, backlog,
sprints, templates), `specs/`, `sistema/` e `docs/adr/`, injeta as regras do método no `CLAUDE.md` e
no `AGENTS.md` e rascunha a **constituição**. Num projeto existente, ela
preenche a constituição só com o que observa no código (stack, versões,
camadas, comandos) e deixa como "a definir" o que não consegue confirmar. Não
inventa regra.

## Quando usar

Você digita `/sdd:iniciar`; o agente não a usa por conta própria. Use uma vez
por repositório, antes de qualquer outro comando. Pode rodar de novo para
atualizar o bloco de regras depois de atualizar o plugin: ela não duplica nem
apaga o que você escreveu no `CLAUDE.md`.

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

**O meu projeto já descumpre regras que eu quero na constituição. E agora?**

Coloque a regra e registre a situação atual em "Exceções aprovadas", com o plano
de saída. Uma constituição que finge que o projeto cumpre tudo ensina o agente a
ignorá-la.

## Está funcionando se

- A constituição cita versões e comandos que existem de verdade no projeto.
- Nada nela soa como boa prática genérica ("código limpo", "boas práticas").
- `/sdd:status` mostra o quadro (vazio), sem dizer que o projeto não usa SDD.

## O que versionar

| Caminho | Versionar? | Por quê |
|---|---|---|
| `.sdd/config.yml`, `constituicao.md`, `templates/`, `backlog.md`, `sprints/` | sim | são do time |
| `sistema/`, `releases/`, `incidentes/` | sim | a spec viva, as entregas e os incidentes são do time |
| `specs/` (inclusive `estado` e `historico.md` de cada feature) | sim | o quadro e as aprovações são do time |
| `.sdd/estado` | não (já vem no `.sdd/.gitignore`) | é o ponteiro pessoal: a feature ativa e a sprint atual de cada pessoa |

## Onde se encaixa

Configuração de uma vez, antes de tudo. Depois dela vêm o
[especificar](especificar.md), para uma mudança imediata, ou o
[backlog](backlog.md) e a [sprint](sprint.md), para organizar uma lista de
trabalho. O mapa completo está na [ajuda](ajuda.md).
