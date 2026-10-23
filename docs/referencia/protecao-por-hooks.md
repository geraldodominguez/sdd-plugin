# Proteção por hooks

O plugin tem dois hooks `PreToolUse`. Eles rodam **antes** de cada uso de
ferramenta e podem bloquear a ação (saída 2). A mensagem vai para o agente, que
deve parar e explicar a situação a você.

Nos dois hooks, valem as mesmas regras de base:

- **Só agem em projetos com `.sdd/`.** O plugin pode ficar instalado de forma global sem afetar quem não usa SDD.
- **Sem feature ativa, ou com a fase `concluida`, não bloqueiam nada.**
- **Fail-open:** qualquer erro inesperado permite a ação.

## Modos

Em `.sdd/config.yml`:

```yaml
protecao: leve   # desligada | leve | estrita
```

| Modo | Para quem |
|---|---|
| `desligada` | só orientação (skills e `CLAUDE.md`); útil para experimentar |
| `leve` | **o padrão**: protege o que mais importa sem atrapalhar |
| `estrita` | projetos críticos: impõe a ordem das fases sobre o código |

## guarda-edicoes: edição de arquivos

Intercepta `Edit`, `Write`, `MultiEdit` e `NotebookEdit`.

**Sempre editáveis**, em qualquer modo e fase: `.sdd/`, `specs/`, `docs/`,
`CLAUDE.md`, `AGENTS.md`, `.claude/` e qualquer arquivo fora do projeto.

| Fase | `leve` | `estrita` |
|---|---|---|
| `especificacao`, `clarificacao`, `tarefas` | livre | só artefatos |
| `plano` | livre | artefatos e `globs_de_contrato` |
| `red` | livre | artefatos, testes e `globs_de_contrato` |
| `green` | **testes bloqueados** | **testes e `globs_de_contrato` bloqueados** |
| `auditoria` | livre | só artefatos |

### O que conta como teste

Os `globs_de_teste`, separados por vírgula:

```yaml
globs_de_teste: tests/**,test/**,__tests__/**,spec/**,**/*.test.*,**/*.spec.*,**/*_test.*,**/test_*.py,**/*Test.java,**/*Tests.cs
```

Ajuste para a convenção do seu projeto. Um `**/` no começo também casa arquivos
na raiz.

### O que conta como contrato em código

Os `globs_de_contrato`, vazios por padrão. Preencha se quiser que o
`arquiteto-de-contratos` materialize tipos e interfaces em código na fase plano:

```yaml
globs_de_contrato: src/domain/contracts/**,db/migrations/**
```

## guarda-commits: mensagens de commit

Intercepta `Bash`, e só age quando:

- o comando tem `git commit` com mensagem inline (`-m`, `-am`, `--message`, `-F`);
- a proteção não é `desligada`;
- há feature ativa nas fases `red`, `green` ou `auditoria`.

A mensagem precisa citar `T-NNN` ou `(NNN)`:

| Mensagem | Resultado |
|---|---|
| `feat(001): T-004 solicitar redefinição` | permitida |
| `docs(001): atualiza a spec depois da auditoria` | permitida |
| `ajustes` | bloqueada |

Commits sem mensagem inline (editor, `--amend --no-edit`) não são inspecionados.

## O que os hooks não pegam

Os hooks são trilhos contra deslizes, não um sandbox:

| Brecha | O que cobre |
|---|---|
| Edição pelo shell (`echo > tests/x.test.ts`) | as instruções das skills e dos subagents, e a auditoria, que procura testes mexidos depois da red |
| O agente trocando a fase com `sdd-estado definir` | os gates: as skills mandam trocar de fase só com a sua aprovação |
| Subagent com ferramenta de escrita | as instruções dele e, na proteção estrita, o hook da fase |

Para garantia determinística, rode o `sdd-rastrear` na CI (a saída 3 falha o
pipeline). Ver [utilitários](utilitarios.md#na-ci) e o
[ADR 0003](../../.agents/adr/0003-hooks-fail-open.md).

## Desligar por um momento

`protecao: desligada` no config, ou `sdd-estado encerrar` para sair da feature ativa.
