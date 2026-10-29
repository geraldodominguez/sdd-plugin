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
`.sdd/estado`, o `.sdd/historico.md` e o `.sdd/adocao.md`. Eles são escritos só pelos utilitários. É isso que impede
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

### Arquivos novos só no lugar do padrão

Sem um lugar fixo, cada agente inventa o seu: um cria `docs/specs/`, outro
`tasks/`, outro um `PLAN.md` na raiz, e a verdade se espalha. Por isso, em
qualquer fase (proteção leve ou estrita), **criar** com o `Write` um arquivo
que é artefato de processo fora do lugar do padrão é bloqueado, com a
mensagem dizendo onde ele mora:

| Tentativa | Resultado |
|---|---|
| `docs/specs/login.md`, `tasks/fazer.md`, `TODO.md`, `PLAN.md` | bloqueada: feature nova só pelo `/sdd:especificar` |
| `specs/009-feita-a-mao/spec.md`, numa pasta sem `estado` | bloqueada: a pasta não foi criada pelo `sdd-estado nova` |
| `docs/adr/usar-redis.md` | bloqueada: ADR é `docs/adr/NNNN-slug.md` |
| `docs/adr/0002-usar-redis.md`, `specs/001-login/contexto.md` | permitida |
| `docs/guia.md`, `src/qualquer.ts` | permitida: não é artefato de processo |

Um arquivo é artefato de processo pelo nome ou pela pasta (spec, PRD,
requisitos, plano, design, tarefas, TODO, ADR, decisões, backlog, roadmap,
sprint, arquitetura, convenções), em markdown ou diagrama. Editar ou reescrever
um arquivo que **já existe** continua livre: os artefatos antigos são trazidos
ao padrão pelo `/sdd:iniciar --adotar`, não pelo hook. Um documento que tem nome
de artefato, mas não é do SDD (um manual com `tasks.md`, por exemplo), entra
nos `excecoes_de_layout` do config:

```yaml
excecoes_de_layout: docs/manual/**,site/content/**
```

Os lugares do padrão estão no [sdd-adotar](utilitarios.md#sdd-adotar).

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

## guarda-commits: commits e branches

Intercepta `Bash`. Faz duas coisas: confere a mensagem dos commits e, com o
Git Flow ativo, as branches.

### A mensagem do commit

Só age quando:

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

### As branches do Git Flow

Com `gitflow: ativo` no config (o padrão), nas proteções `leve` e `estrita`:

| Tentativa | Resultado |
|---|---|
| criar ou renomear uma branch com nome fora do padrão (`git checkout -b feat-x`, `git switch -c bugfix/x`, `git branch -m dev2`) | bloqueada |
| criar `feature/NNN-slug` de uma feature que não existe em `specs/` | bloqueada |
| `git commit` em `main` | bloqueado: `main` só recebe merge, pelo `sdd-gitflow finalizar` |
| `git commit` numa branch fora do padrão | bloqueado |
| `git commit` com uma feature ativa em andamento, fora da branch dela (em `develop`, ou na branch de outra feature) | bloqueado |
| `git commit` na branch da feature ativa, ou em `release/` e `hotfix/` | permitido |
| `git commit` em `develop` do registro de um incidente, antes de a branch do hotfix existir | permitido |
| `git commit` com um merge em andamento (resolução de conflito) | permitido |

Os nomes do padrão: `main`, `develop`, `feature/NNN-slug`, `release/X.Y.Z`,
`hotfix/X.Y.Z`. O guia completo está em [Git Flow](git-flow.md).

## O que os hooks não pegam

Os hooks são trilhos contra deslizes, não um sandbox:

| Brecha | O que cobre |
|---|---|
| Edição pelo shell (`echo > tests/x.test.ts`) | as instruções das skills e dos subagents, e a auditoria, que procura testes mexidos depois da red |
| Branch criada de um jeito que o hook não lê (`git worktree add`, um script) | o `sdd-gitflow conferir`, o `/sdd:pendencias` (seção "Git Flow") e o `sdd-verificar` no CI |
| Artefato criado fora do padrão pelo shell (`mkdir docs/specs`) | o `sdd-verificar` na CI, que avisa, e o `/sdd:pendencias`, que lista em "Fora do padrão" |
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
