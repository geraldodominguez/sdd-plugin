# Versionamento

O plugin numera as versões com os padrões de mercado e calcula a próxima
versão a partir dos commits, em vez de deixar a escolha para a memória de quem
faz a release. Este guia explica os padrões, como o plugin os usa e o que você
decide.

## Sumário

1. [Os três padrões](#1-os-três-padrões)
2. [SemVer: o número da versão](#2-semver-o-número-da-versão)
3. [Conventional Commits: a mensagem decide a versão](#3-conventional-commits-a-mensagem-decide-a-versão)
4. [Como o plugin calcula a próxima versão](#4-como-o-plugin-calcula-a-próxima-versão)
5. [Pré-lançamentos](#5-pré-lançamentos)
6. [O CHANGELOG.md](#6-o-changelogmd)
7. [Na release, passo a passo](#7-na-release-passo-a-passo)
8. [Projeto que já existe](#8-projeto-que-já-existe)
9. [E o CalVer?](#9-e-o-calver)
10. [Perguntas frequentes](#10-perguntas-frequentes)

---

## 1. Os três padrões

| Padrão | Para quê | No plugin |
|---|---|---|
| [SemVer 2.0.0](https://semver.org/lang/pt-BR/) | o número da versão: `MAJOR.MINOR.PATCH` | a tag `vX.Y.Z` em `main`, a pasta `releases/X.Y.Z/`, a branch `release/X.Y.Z` |
| [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/) | a mensagem de commit diz o tipo da mudança | o hook confere a mensagem; o `sdd-release` lê os tipos |
| [Keep a Changelog 1.1.0](https://keepachangelog.com/pt-BR/1.1.0/) | o formato do `CHANGELOG.md` | o `sdd-release changelog` gera a seção de cada versão |

São os mesmos padrões de ferramentas como o semantic-release e o
release-please. A diferença é que no plugin a versão calculada é uma
**sugestão**, decidida por uma pessoa no `/sdd:release`.

## 2. SemVer: o número da versão

| Parte | Sobe quando | De 1.4.2 vai para |
|---|---|---|
| MAJOR | algo **quebra** para quem depende do sistema: um campo removido da API, um evento com outro formato, um schema consumido por outro sistema | 2.0.0 |
| MINOR | algo **novo e compatível**: um endpoint, uma funcionalidade | 1.5.0 |
| PATCH | uma **correção** que não muda o comportamento esperado | 1.4.3 |

Mais quatro regras:

- **Zerar à direita:** quando uma parte sobe, as da direita voltam a zero.
- **`0.y.z`:** é a fase inicial, em que a API ainda pode mudar. Uma mudança incompatível sobe o minor (`0.4.0` vai para `0.5.0`). A `1.0.0` se declara de propósito, quando a API está estável.
- **Uma versão publicada não muda:** saiu errada, sai outra.
- **A tag tem `v`, a versão não:** a tag é `v1.4.2`, a versão é `1.4.2`.

## 3. Conventional Commits: a mensagem decide a versão

```
tipo(escopo)!: descrição

corpo opcional

BREAKING CHANGE: o que quebrou (opcional)
```

No SDD, o escopo é o número da feature:

```
feat(004): T-002 permitir exportar em CSV
fix(004): T-005 corrigir a data no fuso de Brasília
test(004): T-001 critérios da exportação
feat(007)!: T-003 remover o campo total da API de pedidos
```

| Tipo | Use quando | Efeito na versão |
|---|---|---|
| `feat` | entrega comportamento novo para quem usa o sistema | minor |
| `fix` | corrige comportamento errado | patch |
| `perf` | melhora desempenho, sem mudar o comportamento | patch |
| `refactor` | reorganiza o código, sem mudar o comportamento | nenhum |
| `test` | só testes (a fase red) | nenhum |
| `docs` | specs, documentação, ADRs | nenhum |
| `build`, `ci` | dependências, build, pipeline | nenhum |
| `chore`, `style`, `revert` | manutenção, formatação, reverter um commit | nenhum |
| qualquer tipo com `!`, ou o rodapé `BREAKING CHANGE:` | quebra um contrato público | **major** |

O hook bloqueia commit com mensagem fora do formato (nas proteções `leve` e
`estrita`), e ensina os tipos na mensagem de bloqueio:

```
SDD bloqueou o commit: a mensagem "ajustes" não segue o Conventional Commits.
Formato: tipo(escopo): descrição. Tipos: feat (funcionalidade, sobe o minor), fix (correção, sobe o patch), perf, docs, chore, refactor, test, build, ci, style, revert.
Mudança incompatível: tipo(escopo)!: descrição, ou o rodapé BREAKING CHANGE: (sobe o major).
O escopo é o número da feature. Exemplo: feat(004): T-002 valida token expirado.
```

Mensagens `Merge ...` e `Revert ...` (as que o git gera) e commits feitos pelo
editor, sem mensagem no comando, não são conferidos; a mensagem de arquivo
(`-F`) é lida e conferida. Num projeto que não quer o padrão, `commits: livre`
no `.sdd/config.yml` desliga a conferência; a versão automática continua, mas
só enxerga os commits que, por acaso, seguirem o padrão.

## 4. Como o plugin calcula a próxima versão

1. **A versão de referência** é a última release em produção (`releases/X.Y.Z/` na situação `producao`). Sem nenhuma, a última tag `vX.Y.Z` alcançável; tags de pré-lançamento (`v1.3.0-rc.1`) não contam.
2. **Os commits** são os desde a tag dessa versão, sem os merges. Se essa
   versão não tem tag, contam os desde a última tag `vX.Y.Z` final; sem tag
   nenhuma, o histórico inteiro.
3. **O maior impacto** entre eles decide: major, minor ou patch.

| Os commits têm | Versão | Exemplo a partir da 1.4.2 |
|---|---|---|
| algum `!` ou `BREAKING CHANGE:` | major (antes da 1.0.0, minor) | 2.0.0 |
| algum `feat` | minor | 1.5.0 |
| só `fix` ou `perf` | patch | 1.4.3 |
| só manutenção | patch | 1.4.3 |
| (não há versão anterior) | 0.1.0 | |

O `sdd-release analisar` mostra a conta inteira:

```
Versão atual: 1.2.0 (commits desde v1.2.0)
Commits (sem os merges): 5
  incompatíveis (major): 0
  feat (minor):          1
  fix e perf (patch):    2
  sem impacto na versão: 1
  fora do Conventional Commits (não contam): 1
    - atualiza coisas
Sugestão: 1.3.0 (minor: há feat e nenhuma mudança incompatível)
Commits que mudam a versão:
  [patch] fix: corrige timeout do login
  [patch] fix(001): T-002 data errada
  [minor] feat(001): T-001 exportar CSV
```

| Comando | Imprime |
|---|---|
| `sdd-release proxima` | a versão calculada pelos commits |
| `sdd-release proxima major` (ou `minor`, `patch`) | a versão de um tipo escolhido por você |
| `sdd-release proxima --pre rc` | o próximo pré-lançamento |
| `sdd-release analisar` | a conta acima |

## 5. Pré-lançamentos

Para homologar uma versão grande antes de fechá-la, use um release candidate:

| Comando | Resultado |
|---|---|
| `sdd-release proxima --pre rc` | `1.3.0-rc.1` |
| (depois da tag `v1.3.0-rc.1`) `sdd-release proxima --pre rc` | `1.3.0-rc.2` |
| `sdd-release proxima` | `1.3.0` (a tag de pré-lançamento não vira a base) |

Também valem `alpha` e `beta`. A ordem do SemVer é
`1.3.0-alpha.1 < 1.3.0-beta.1 < 1.3.0-rc.1 < 1.3.0`. A release, a branch
(`release/1.3.0-rc.1`) e a tag (`v1.3.0-rc.1`) aceitam o sufixo.

## 6. O CHANGELOG.md

O `sdd-release changelog X.Y.Z` monta a seção da versão a partir dos mesmos
commits:

```markdown
## [2.0.0] - 2026-10-29

### Adicionado

- Exportar pedidos (001)

### Modificado

- **Incompatível:** remove o campo total (api)

### Corrigido

- corrige timeout do login
```

| Os commits | Viram |
|---|---|
| de uma feature (escopo `NNN`) | **uma** linha com o título da feature, na categoria do maior impacto entre os commits dela |
| `feat` sem feature | uma linha em Adicionado |
| `fix` sem feature | uma linha em Corrigido |
| `perf` sem feature | uma linha em Modificado |
| incompatíveis | uma linha em Modificado, marcada **Incompatível**, com a nota do `BREAKING CHANGE:` |
| `docs`, `chore`, `refactor`, `test`, `build`, `ci`, `style` | nada: não mudam o que o usuário vê |

Com `--escrever`, a seção entra no `CHANGELOG.md` (criado no formato Keep a
Changelog se não existir), logo abaixo de `## [Não lançado]`, acima das
versões anteriores. Ele recusa gravar uma versão que já está lá.

O `CHANGELOG.md` é técnico, para quem desenvolve ou integra. As **notas da
versão** (`releases/X.Y.Z/notas.md`) continuam sendo o texto em linguagem de
negócio, para quem usa o sistema.

## 7. Na release, passo a passo

| Momento | O que acontece |
|---|---|
| `/sdd:release preparar` | o agente roda `sdd-release analisar` e propõe a versão, com o motivo; você confirma ou escolhe outra |
| a versão está decidida | `sdd-gitflow release X.Y.Z` cria `release/X.Y.Z`; `sdd-release nova X.Y.Z` cria `releases/X.Y.Z/` |
| `/sdd:release implantar`, antes do go | `sdd-release changelog X.Y.Z --escrever`, revisado com você, e o commit `docs(release): changelog X.Y.Z` na branch da release |
| depois do go | `sdd-gitflow finalizar X.Y.Z`: a tag `vX.Y.Z` em `main`, que o pipeline implanta |

Um hotfix é sempre patch: `hotfix/X.Y.Z` já nasce com a próxima patch.

## 8. Projeto que já existe

| Situação | O que fazer |
|---|---|
| já tem tags `vX.Y.Z` | nada: a última é a referência |
| tem tags em outro formato (`1.4.2`, `release-1.4.2`) | o `sdd-gitflow conferir` avisa; crie `v1.4.2` no mesmo commit (`git tag -a v1.4.2 <commit> -m "versão 1.4.2"`) |
| tem versões publicadas, mas nenhuma tag | crie a tag da versão em produção no commit que está em produção |
| nunca publicou | a primeira versão é 0.1.0 |
| os commits antigos não seguem o padrão | não importa: eles ficam antes da tag e não contam |

## 9. E o CalVer?

O CalVer (versão por data, como `2026.10` ou `24.04`) é o padrão de quem tem
cadência fixa e não é consumido como biblioteca: sistemas operacionais,
aplicativos finais. Ele diz **quando** a versão saiu, não **quanto** mudou. O
plugin usa o SemVer porque a pergunta que a release responde é "isto quebra
quem depende de nós?", e só o MAJOR do SemVer responde a ela.

## 10. Perguntas frequentes

**A versão calculada é obrigatória?**

Não. É uma sugestão com o motivo. Você decide no `/sdd:release`, e pode passar
o tipo explícito (`sdd-release proxima major`).

**Esqueci o `!` num commit que quebrou a API. E agora?**

A sugestão vai sair minor, e é por isso que o `/sdd:release` confere a sugestão
contra as features da release. Escolha a major. Para os próximos, o hábito:
contrato público mudou, `!` e `BREAKING CHANGE:`.

**Uma refatoração grande sobe a versão?**

Não, se o comportamento não mudou. Tamanho não é critério; efeito para quem
usa o sistema é.

**Por que a release só com `docs` e `chore` sobe o patch?**

Porque toda release precisa de um número novo, e manutenção é o menor degrau.
O `analisar` diz "nenhum feat nem fix: só manutenção".

**Posso desligar a conferência das mensagens?**

Pode, com `commits: livre`. A versão automática continua funcionando, mas só
enxerga os commits que, por acaso, seguirem o padrão.
