# /sdd:listar

## O que faz

Abre, por extenso, o que o quadro do [status](status.md) só resume: as tarefas
`T-NNN` de todas as features, as specs, os planos, os critérios de aceitação
(cada um com a tarefa que o atende e o teste que o prova) e as ADRs. Com
`falta`, diz o que ainda separa uma feature de ficar **pronta**. Só lê: não
altera nada e não decide nada, apenas junta o que está espalhado pelas pastas
das features.

## Quando usar

Você digita `/sdd:listar`; o agente não o usa por conta própria. Use quando o
`/sdd:status` mostrar "3/5 tarefas" e você quiser saber **quais**, ou quando for
decidir uma aprovação e quiser ver os critérios sem abrir cada arquivo. Para a
visão do projeto inteiro, use [status](status.md); para o que depende de você,
use [pendencias](pendencias.md).

| Você quer saber | Comando |
|---|---|
| quais tarefas faltam, em todas as features | `/sdd:listar tarefas --abertas` |
| se cada critério tem tarefa e teste | `/sdd:listar criterios` |
| só os critérios que ainda não têm tarefa ou teste | `/sdd:listar criterios --abertas` |
| as features, o nível, a fase e se a spec está aprovada | `/sdd:listar specs` |
| os planos e se estão aprovados | `/sdd:listar planos` |
| as decisões de arquitetura ainda propostas | `/sdd:listar adrs --abertas` |
| o que falta para uma feature ficar pronta | `/sdd:listar falta 005-exportar-csv` |

## Os filtros

Valem para `tarefas`, `specs`, `planos` e `criterios`:

| Filtro | Efeito |
|---|---|
| `--feature NNN` | só essa feature (basta o número) |
| `--fase green` | só as features nessa fase |
| `--sprint` | só as features da sprint atual |
| `--esperando-eu` | só as features que aguardam a sua aprovação |
| `--abertas` | tarefas não feitas; features ainda em construção; critérios sem tarefa ou sem teste; ADRs propostas |

## Um exemplo

```
$ sdd-listar criterios --feature 001
001-redefinicao-de-senha (green)
  CA-001  (valida RF-001) · tarefa: T-001 · teste: tests/reset.test.ts
  CA-002  (valida RF-002) · tarefa: T-002 · teste: ✗ nenhum
```

O `✗` é uma lacuna de rastreabilidade: o `sdd-rastrear` a aponta e a
[auditoria](auditar.md) a cobraria depois. Aqui você a vê antes.

## Perguntas frequentes

**Isto muda alguma coisa nos arquivos?** Não. Nem o `estado` nem o histórico
são tocados.

**Por que uma tarefa aparece com `[O]`?** Foi feita fora do plugin, antes da
adoção, sem gate. Ela conta como feita.

**A lista de tarefas mostra só a feature ativa?** Não: mostra todas, agrupadas
por feature. Use `--feature` para uma só.

**Por que o critério aparece sem teste se eu escrevi o teste?** O teste precisa
da marca `sdd:NNN:CA-XXX`, num arquivo que case com `globs_de_teste` do
`sdd/config.yml`.

## Está funcionando se

- Você sabe, sem abrir arquivo, qual tarefa é a próxima e em qual feature.
- Um critério sem tarefa ou sem teste aparece com `✗`.
- Um filtro que não casa com nada diz "nada com esses filtros", em vez de calar.

## Onde se encaixa

Uso avulso, entre o [status](status.md) (o quadro) e o
[retomar](retomar.md) (o que aconteceu numa feature). O mesmo conteúdo sai no
terminal com `sdd-listar` e `sdd-status NNN-slug --falta`. O mapa dos comandos
está na [ajuda](ajuda.md).
