# Utilitários

Quatro scripts em bash, na pasta `bin/` do plugin. Nas sessões do Claude Code
com o plugin ativo, eles ficam no PATH. Fora delas, chame pelo caminho completo
ou ponha `bin/` no seu PATH.

## sdd-iniciar

```
sdd-iniciar [--forcar] [--nivel 1|2] [--protecao desligada|leve|estrita]
```

Cria a estrutura no diretório atual (ou em `$CLAUDE_PROJECT_DIR`). Não
sobrescreve nada sem `--forcar` e atualiza no lugar o bloco do `CLAUDE.md` e do
`AGENTS.md`. É o que o `/sdd:iniciar` roda por baixo.

## sdd-estado

```
sdd-estado ver [chave]                 o estado inteiro, ou uma chave
sdd-estado definir chave=valor [...]   fase, nivel ou feature, com validação
sdd-estado nova "título" [--nivel N]   cria specs/NNN-slug/ e ativa a feature
sdd-estado usar NNN-slug               troca a feature ativa
sdd-estado encerrar                    fase=concluida
sdd-estado caminho [arquivo]           specs/NNN-slug[/arquivo]
sdd-estado template nome.md            caminho do template, local ou do plugin
```

Fases: `especificacao clarificacao plano tarefas red green auditoria concluida`.

O estado fica em `.sdd/estado`:

```
feature=004-redefinicao-de-senha
fase=green
nivel=2
atualizado=2026-10-23T15:42:10Z
```

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
- name: Rastreabilidade SDD
  run: |
    git clone --depth 1 https://github.com/geraldodominguez/sdd-plugin /tmp/sdd
    for f in specs/[0-9][0-9][0-9]-*/; do
      /tmp/sdd/bin/sdd-rastrear "$(basename "$f")" || exit 1
    done
```

## sdd-status

```
sdd-status
```

O painel: proteção, features registradas, feature ativa, fase, artefatos,
progresso das tarefas e o resultado do `sdd-rastrear`.

## Formatos

| O quê | Formato |
|---|---|
| Linha de tarefa | `- [ ] T-003 [P] descrição (atende: RF-002, CA-003; depende de: T-001)` |
| Marca de teste | `// sdd:001:CA-003`, no nome ou no comentário logo acima |
| Commit (red, green, auditoria) | `tipo(NNN): T-XXX descrição`, ou `tipo(NNN): descrição` para artefatos |
