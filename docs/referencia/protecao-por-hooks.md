# Proteção por hooks

O plugin tem dois hooks `PreToolUse`. Eles rodam **antes** de cada uso de
ferramenta e podem bloquear a ação (saída 2). A mensagem vai para o agente, que
deve parar e explicar a situação a você.

Nos dois hooks, valem as mesmas regras de base:

- **Só agem em projetos com `.sdd/`.** O plugin pode ficar instalado de forma global sem afetar quem não usa SDD.
- **Sem feature ativa, ou com ela pronta, em homologação, em produção ou cancelada, a fase não bloqueia nada.**
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

**Nunca editáveis à mão**, em qualquer fase (proteção leve ou estrita): o
`estado` e o `historico.md` de cada feature e de cada release, e o
`.sdd/estado` e o `.sdd/historico.md`. Eles são escritos só pelos utilitários. É isso que impede
o agente de forjar uma aprovação ou de pular uma fase editando um arquivo.

**Sempre editáveis**, em qualquer modo e fase: o resto de `.sdd/`, `specs/`,
`sistema/`, `releases/` e `incidentes/`, e também `docs/`, `CLAUDE.md`,
`AGENTS.md`, `.claude/` e qualquer arquivo fora do projeto.

| Fase | `leve` | `estrita` |
|---|---|---|
| `especificacao`, `clarificacao`, `tarefas` | livre | só artefatos |
| `plano` | livre | artefatos e `globs_de_contrato` |
| `red` | livre | artefatos, testes e `globs_de_contrato` |
| `green` | **testes bloqueados** | **testes e `globs_de_contrato` bloqueados** |
| `seguranca`, `auditoria` | **testes bloqueados** | **só artefatos** |
| `pronta`, `homologacao`, `producao`, `cancelada` | livre | livre |

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
- há feature ativa nas fases `red`, `green`, `seguranca` ou `auditoria`.

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
| O agente trocando a fase ou aprovando pelo shell (`sdd-estado definir`, `sdd-estado aprovar`, `sdd-release aceitar`) | as instruções (só o `/sdd:aprovar`, digitado por você, aprova), o autor registrado em cada aprovação e a auditoria, que confere as aprovações |
| Subagent com ferramenta de escrita | as instruções dele e, na proteção estrita, o hook da fase |

Para garantia determinística, rode o `sdd-verificar` na CI (a saída 3 falha o
pipeline): ele roda o `sdd-rastrear` em cada feature e confere as aprovações e
as releases. Ver [utilitários](utilitarios.md#sdd-verificar), o
[/sdd:pipeline](../pipeline.md) e o
[ADR 0003](../../.agents/adr/0003-hooks-fail-open.md).

## Desligar por um momento

`protecao: desligada` no config, ou `sdd-estado definir feature=` para ficar sem
feature ativa (os hooks só restringem quando há uma). Para voltar,
`sdd-estado usar NNN-slug`.
