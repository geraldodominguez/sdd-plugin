# Utilitários

Sete scripts em bash, na pasta `bin/` do plugin. Nas sessões do Claude Code com
o plugin ativo, eles ficam no PATH. Fora delas, chame pelo caminho completo ou
ponha `bin/` no seu PATH. Os comandos `/sdd:*` usam esses utilitários por baixo;
você raramente precisa chamá-los direto, mas eles servem para scripts, CI e
para conferir algo rápido no terminal.

| Utilitário | Para quê |
|---|---|
| `sdd-iniciar` | prepara o projeto |
| `sdd-estado` | features, fases, aprovações e histórico |
| `sdd-backlog` | itens sem spec |
| `sdd-sprint` | sprints |
| `sdd-status` | o quadro e o detalhe de uma feature |
| `sdd-pendencias` | o que espera decisão humana |
| `sdd-rastrear` | lacunas de rastreabilidade |

## Onde o estado mora

| Arquivo | Conteúdo | Escrito por |
|---|---|---|
| `.sdd/estado` | ponteiros pessoais: `feature=` (ativa) e `sprint=` (atual) | `sdd-estado`, `sdd-sprint` |
| `specs/NNN-slug/estado` | `fase`, `nivel`, `origem`, `atualizado` da feature | `sdd-estado` |
| `specs/NNN-slug/historico.md` | eventos da feature: criação, fases, aprovações | `sdd-estado` |
| `.sdd/historico.md` | eventos do projeto: backlog e sprints | `sdd-backlog`, `sdd-sprint` |
| `.sdd/backlog.md` | itens `B-NNN` | `sdd-backlog`, ou você, à mão |
| `.sdd/sprints/<id>.md` | uma sprint | `sdd-sprint`, e você, na revisão |

Os arquivos `estado` e `historico.md` são protegidos pelo hook: o agente não
consegue editá-los à mão. Linha do histórico:

```
- 2026-10-23T18:40:30Z | aprovacao | spec.md | hash=2533c54be22d | por: Geraldo Dominguez
```

## sdd-iniciar

```
sdd-iniciar [--forcar] [--nivel 1|2] [--protecao desligada|leve|estrita]
```

Cria a estrutura no diretório atual (ou em `$CLAUDE_PROJECT_DIR`). Não
sobrescreve nada sem `--forcar` e atualiza no lugar o bloco do `CLAUDE.md` e do
`AGENTS.md`.

## sdd-estado

```
sdd-estado ver [chave]                      ponteiros e estado da feature ativa
sdd-estado definir chave=valor [...]        fase, nivel (da feature ativa), feature, sprint
sdd-estado nova "título" [--nivel N] [--origem B-NNN]
sdd-estado usar NNN-slug                    troca a feature ativa
sdd-estado encerrar                         fase=concluida
sdd-estado aprovar [artefato] [--decisao aprovar|delta|corrigir] [--sem-avancar] [--nota "texto"]
sdd-estado aprovado <artefato> [NNN-slug]   confere a aprovação
sdd-estado listar                           todas as features (id, fase, nível, origem, atualização)
sdd-estado historico [NNN-slug|--projeto] [--desde AAAA-MM-DD]
sdd-estado caminho [arquivo]                specs/NNN-slug[/arquivo]
sdd-estado template nome.md                 caminho do template, local ou do plugin
```

Fases: `especificacao clarificacao plano tarefas red green auditoria concluida`.

**Aprovar** registra a aprovação do artefato da fase atual e avança:

| Fase | Artefato | Próxima fase |
|---|---|---|
| `especificacao`, `clarificacao` | `spec.md` | `plano` (nível 2) ou `tarefas` (nível 1) |
| `plano` | `plano.md` (o hash inclui `contratos/`) | `tarefas` |
| `tarefas` | `tarefas.md` | `red` |
| `red` | `testes` (arquivos de teste com a marca `sdd:NNN:`) | `green` |
| `green`, nível 1 | a entrega | `concluida` |
| `auditoria` | `auditoria.md`, com `--decisao` | `concluida` (aprovar, delta) ou `green` (corrigir) |

**Aprovado** responde pelo código de saída:

| Saída | Significado |
|---|---|
| 0 | aprovado e inalterado desde a aprovação |
| 4 | alterado depois da aprovação |
| 5 | nunca aprovado |
| 1 | o artefato não existe |

## sdd-backlog

```
sdd-backlog listar [--todos]
sdd-backlog adicionar "título" [--prioridade alta|media|baixa] [--nivel 1|2|?] [--origem "texto"]
sdd-backlog ver B-NNN
sdd-backlog prioridade B-NNN alta|media|baixa
sdd-backlog promover B-NNN NNN-slug      (usado por sdd-estado nova --origem)
sdd-backlog descartar B-NNN "motivo"
sdd-backlog contar
```

Formato da linha:

```
- [ ] B-NNN título (prioridade: alta; nivel: 2; origem: texto; criado: AAAA-MM-DD)
```

`listar` ordena por prioridade e, dentro dela, pela ordem do arquivo.

## sdd-sprint

```
sdd-sprint nova [id] --objetivo "texto" [--inicio AAAA-MM-DD] [--fim AAAA-MM-DD | --dias N]
sdd-sprint incluir <id> <NNN-slug|B-NNN> [...]
sdd-sprint remover <id> <item>
sdd-sprint iniciar <id>
sdd-sprint encerrar [id]
sdd-sprint ver [id]
sdd-sprint listar
sdd-sprint itens [id]
```

O id padrão é a semana ISO do início (`2026-S44`), e a duração padrão é de 14
dias. Um item `B-NNN` promovido é acompanhado pela feature que ele virou.

## sdd-status

```
sdd-status               o quadro
sdd-status <NNN-slug>    o detalhe de uma feature
sdd-status --ativa       o detalhe da feature ativa
```

## sdd-pendencias

```
sdd-pendencias [--contar]
```

Aprovações pendentes ou invalidadas, dúvidas nas specs, delta specs e ADRs
propostos, backlog a triar (nível `?`) e itens da sprint atual sem spec.

## sdd-rastrear

```
sdd-rastrear [NNN-slug] [--silencioso]
```

| Verifica | Lacuna apontada |
|---|---|
| todo RF e RNF tem tarefa | "RF-002 está na spec, mas nenhuma tarefa o atende" |
| todo CA tem tarefa | idem, para CA |
| todo CA tem teste com a marca `sdd:NNN:CA-XXX` | "CA-003 não tem teste com a marca 004:CA-003" |
| toda tarefa referencia algo | "T-005 não referencia nenhum requisito ou critério" |
| as tarefas só citam IDs que existem | "tarefas.md cita RF-009, que não existe na spec" |

Saída: `0` sem lacunas, `3` com lacunas, `1` erro de uso.

### Na CI

No pipeline do **seu projeto**, por exemplo no GitHub Actions:

```yaml
- name: Rastreabilidade e aprovações SDD
  run: |
    git clone --depth 1 https://github.com/geraldodominguez/sdd-plugin /tmp/sdd
    for f in specs/[0-9][0-9][0-9]-*/; do
      id="$(basename "$f")"
      /tmp/sdd/bin/sdd-rastrear "$id" || exit 1
      if grep -q '^fase=concluida' "$f/estado"; then
        /tmp/sdd/bin/sdd-estado aprovado spec.md "$id" || exit 1
      fi
    done
```

## Formatos

| O quê | Formato |
|---|---|
| Linha de tarefa | `- [ ] T-003 [P] descrição (atende: RF-002, CA-003; depende de: T-001)` |
| Marca de teste | `// sdd:001:CA-003`, no nome ou no comentário logo acima |
| Item de backlog | `- [ ] B-014 título (prioridade: alta; nivel: 1; origem: texto; criado: AAAA-MM-DD)` |
| Evento do histórico | `- AAAA-MM-DDTHH:MM:SSZ \| evento \| detalhe \| por: Nome` |
| Commit (red, green, auditoria) | `tipo(NNN): T-XXX descrição`, ou `tipo(NNN): descrição` para artefatos |
