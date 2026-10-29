# Começar um projeto novo com o SDD

Este guia leva um repositório vazio até a primeira feature pronta, passo a
passo. Cada passo diz o que você digita, o que o agente faz, o que você decide
e como saber que deu certo.

Se o projeto já tem código, specs ou tarefas de outro processo, o guia certo é
o [adotar o SDD num projeto em andamento](projeto-em-andamento.md).

## Sumário

1. [O que você vai ter no fim](#1-o-que-você-vai-ter-no-fim)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Instalar o plugin](#3-instalar-o-plugin)
4. [Criar o repositório](#4-criar-o-repositório)
5. [Preparar o repositório: /sdd:iniciar](#5-preparar-o-repositório-sddiniciar)
6. [Escrever a constituição](#6-escrever-a-constituição)
7. [Ajustar a configuração](#7-ajustar-a-configuração)
8. [Ligar o CI: /sdd:pipeline](#8-ligar-o-ci-sddpipeline)
9. [Organizar o trabalho: backlog e sprint](#9-organizar-o-trabalho-backlog-e-sprint)
10. [A primeira feature, do pedido ao pronto](#10-a-primeira-feature-do-pedido-ao-pronto)
11. [Entregar: a primeira release](#11-entregar-a-primeira-release)
12. [A rotina depois disso](#12-a-rotina-depois-disso)
13. [Conferência final](#13-conferência-final)

---

## 1. O que você vai ter no fim

| Item | Onde fica | Para quê |
|---|---|---|
| As regras do projeto | `.sdd/constituicao.md` | todo plano é checado contra elas |
| A configuração | `.sdd/config.yml` | nível, proteção, testes, áreas sensíveis, comandos de entrega |
| O backlog e a sprint | `.sdd/backlog.md`, `.sdd/sprints/` | o que vem depois e o que é para agora |
| A primeira feature | `specs/001-<slug>/` | spec, tarefas, histórico com as suas aprovações |
| A spec viva do sistema | `sistema/<capacidade>.md` | o que o sistema faz hoje |
| As regras para os agentes | bloco no `CLAUDE.md` e no `AGENTS.md` | todo agente do projeto segue o mesmo processo e o mesmo layout |
| O CI | `.github/workflows/` ou `.gitlab-ci.yml` | confere o processo em todo push e só implanta com o go |
| O Git Flow | `main`, `develop`, `feature/NNN-slug`, `release/X.Y.Z`, `hotfix/X.Y.Z`, tags `vX.Y.Z` | os mesmos nomes de branch em todo projeto; os comandos criam e juntam as branches |

O layout é fixo e igual em todo projeto que usa o plugin. Nenhum agente cria
pastas ou nomes próprios: o hook bloqueia (ver
[proteção por hooks](protecao-por-hooks.md#arquivos-novos-só-no-lugar-do-padrão)).

## 2. Pré-requisitos

| Requisito | Por quê |
|---|---|
| Claude Code | os comandos `/sdd:*` e os hooks rodam nele |
| `git` | o estado, as aprovações e os hashes são versionados |
| `bash` | os utilitários são scripts em bash (no Windows, o [Git for Windows](https://git-scm.com/download/win), que traz o Git Bash) |
| `git config user.name` preenchido | é o nome que aparece em cada aprovação |
| `jq` ou `python3` | opcionais; sem eles, os hooks usam uma reserva |

Confira o seu nome no git antes de tudo:

```bash
git config --global user.name    # deve mostrar o seu nome
git config --global user.name "Seu Nome"   # se estiver vazio
```

## 3. Instalar o plugin

Uma vez por máquina:

```bash
claude plugin marketplace add geraldodominguez/sdd-plugin
claude plugin install sdd@sdd-plugin
```

Para atualizar depois:

```bash
claude plugin marketplace update sdd-plugin
claude plugin update sdd
```

**Deu certo se** `/sdd:status`, dentro de qualquer pasta, responde "Este projeto
ainda não usa SDD. Rode /sdd:iniciar para começar."

## 4. Criar o repositório

```bash
mkdir loja && cd loja
git init -b main
git commit --allow-empty -m "chore: início"
```

A branch de produção se chama **`main`** em todo projeto do SDD (ver
[Git Flow](git-flow.md)). Com um git antigo, sem a opção `-b`, rode `git init`
e depois `git symbolic-ref HEAD refs/heads/main`.

Se você já sabe a stack, crie o esqueleto antes (`npm init`, `dotnet new`,
`poetry new`, o que for) e faça o commit. O `/sdd:iniciar` lê os manifestos
para rascunhar a constituição: quanto mais existir, menos fica "a definir".

Abra o Claude Code na pasta do projeto.

## 5. Preparar o repositório: /sdd:iniciar

```
/sdd:iniciar
```

**O que o agente pergunta**, numa única pergunta, se você não passou nos
argumentos:

| Projeto | Nível padrão | Proteção | Argumentos |
|---|---|---|---|
| a maioria | 1 | `leve` | `/sdd:iniciar --nivel 1 --protecao leve` |
| crítico: domínio rico, dinheiro, dados pessoais | 2 | `estrita` | `/sdd:iniciar --nivel 2 --protecao estrita` |

O **nível padrão** é o sugerido para cada feature nova (você confirma feature a
feature). A **proteção** diz o quanto os hooks impõem o fluxo:

| Proteção | O que os hooks fazem |
|---|---|
| `desligada` | nada; só as instruções orientam |
| `leve` | congelam os testes depois da fase red, exigem `T-NNN` nos commits, protegem histórico e estado, e mantêm o layout |
| `estrita` | tudo da `leve`, mais: nada de código antes do plano, só testes na fase red, nada de edição na auditoria |

Na dúvida, comece com `leve`. Dá para subir depois, no `.sdd/config.yml`.

**O que ele cria:**

```
.sdd/
  config.yml          configuração do projeto
  constituicao.md     regras inegociáveis (rascunho)
  backlog.md          itens ainda sem spec
  sprints/            uma sprint por arquivo
  templates/          cópia dos modelos, para você customizar
  estado              sua feature ativa (fora do git)
  .gitignore
specs/                uma pasta por feature
sistema/README.md     a spec viva do sistema começa aqui
docs/adr/             decisões de arquitetura
CLAUDE.md, AGENTS.md  com o bloco de regras do SDD (o resto do arquivo fica intacto)
```

**O Git Flow.** Logo depois, o agente pergunta como as branches se juntam e
prepara a `develop`:

| `integracao` | Para quem | O que acontece numa feature pronta |
|---|---|---|
| `local` | quem trabalha sozinho, ou time sem revisão de código | o plugin faz o merge em `develop` (perguntando antes) |
| `pr` | time com revisão de código no GitHub ou no GitLab | o agente abre o pull request para `develop` |

Então ele roda `sdd-gitflow iniciar`, que cria `develop` a partir de `main` e
muda para ela:

```
Criada develop a partir de main.
Agora em develop: o trabalho do dia a dia parte daqui.
Lembre de publicar: git push -u origin main develop
```

Daqui em diante, ninguém faz commit em `main`: o hook bloqueia. Ela só recebe
as releases, depois do go.

Ele também acrescenta ao `.gitattributes` o merge por união dos históricos do
SDD, para que os merges do Git Flow não deem conflito neles.

Num projeto novo, o inventário de artefatos de outro processo vem vazio, e não
há adoção. Se ele encontrar alguma coisa, siga o
[guia de projeto em andamento](projeto-em-andamento.md).

## 6. Escrever a constituição

A constituição (`.sdd/constituicao.md`) é o conjunto de regras que valem para
**todas** as features. O planejador checa cada plano contra ela, e o auditor
cobra cada desvio. Num projeto novo, o agente deixa os campos como
`{{a definir}}` e lista as cinco decisões que importam:

| Decisão | Exemplo de resposta |
|---|---|
| Stack | Node 22, TypeScript 5, PostgreSQL 16 |
| Arquitetura | API em camadas: rotas, serviços, repositórios; regra de negócio só nos serviços |
| Testes | todo CA tem teste; Vitest; banco real em contêiner nos testes de integração |
| Segurança | senha com Argon2; nenhum segredo no código; LGPD: dados pessoais nunca no log |
| Ambientes e entrega | homologação e produção; deploy por tag `vX.Y.Z`; rollback pela versão anterior |

**O que você faz:** responde às cinco, revisa o texto que o agente escreve e
apaga o que não for regra de verdade. Regra genérica ("código limpo") não
ajuda ninguém: prefira regras que alguém consegue conferir num diff.

**Deu certo se** a constituição não tem mais `{{...}}` (o `/sdd:status` avisa
enquanto tiver) e cada regra é verificável.

## 7. Ajustar a configuração

Abra `.sdd/config.yml`. O agente sugere os valores; você confirma:

| Chave | O que pôr | Exemplo |
|---|---|---|
| `nivel_padrao` | 1 ou 2 | `1` |
| `protecao` | `desligada`, `leve` ou `estrita` | `leve` |
| `globs_de_teste` | onde ficam os testes no seu projeto | `tests/**,**/*.test.ts` |
| `areas_sensiveis` | código cuja mudança exige revisão de segurança, mesmo no nível 1 | `src/auth/**,src/pagamentos/**,db/migrations/**` |
| `comando_teste` | a suíte de testes | `npm test` |
| `comando_lint` | lint e checagem de tipos | `npm run lint && npx tsc --noEmit` |
| `comando_seguranca` | varreduras de dependências e segredos | `npm audit --audit-level=high && gitleaks detect` |
| `comando_deploy_homologacao`, `comando_deploy_producao` | como se implanta | `./deploy.sh homolog` |
| `comando_verificacao_producao` | o teste depois do deploy | `curl -fsS https://loja.exemplo/saude` |
| `excecoes_de_layout` | documentos com nome de artefato que não são do SDD (raro num projeto novo) | `docs/manual/**` |
| `gitflow` | `ativo` (padrão) ou `desligado` | `ativo` |
| `integracao` | `local` ou `pr` | `local` |
| `commits` | `convencional` (padrão) ou `livre` | `convencional` |

Os comandos de entrega podem ficar vazios até a primeira release. O
`comando_teste`, não: sem ele, o escritor de testes e o auditor perguntam a
cada vez.

Faça o commit, em `develop`, e publique as duas branches:

```bash
git add -A
git commit -m "chore: sdd iniciado"
git push -u origin main develop
```

O `.sdd/estado` (a sua feature ativa) já fica fora do git. O resto é do time.

## 8. Ligar o CI: /sdd:pipeline

```
/sdd:pipeline
```

O agente gera (ou completa) o pipeline do GitHub Actions ou do GitLab CI com:
lint, testes, `sdd-verificar` (rastreabilidade, aprovações em dia e layout),
varreduras de segurança, deploy em homologação e deploy em produção **só se** a
release tiver o go registrado. Revise e faça o commit.

**Deu certo se** o primeiro push passa no CI. O `sdd-verificar` num projeto sem
features responde "Nenhuma falha".

Na plataforma, proteja `main` e `develop`: só por pull request, com o estágio
`verificar` obrigatório, sem push direto e sem force-push. O pipeline também
recusa pull request fora do Git Flow (uma feature direto para `main`, por
exemplo).

## 9. Organizar o trabalho: backlog e sprint

Opcional, mas útil desde o começo. Anote as ideias no backlog, uma por vez:

```
/sdd:backlog adicionar exportar os pedidos do mês em CSV
/sdd:backlog adicionar cupom de desconto no checkout
/sdd:backlog priorizar
```

Escolha o que entra no período:

```
/sdd:sprint planejar
```

| O agente faz | Você decide |
|---|---|
| lista o backlog por prioridade e sugere um conjunto | quais itens entram e o objetivo da sprint |
| cria `.sdd/sprints/<id>.md` | a duração |

Se você trabalha sozinho e sem sprints, pule este passo e vá direto para o
`/sdd:especificar`.

## 10. A primeira feature, do pedido ao pronto

O fluxo abaixo é o de uma feature de **nível 1**. As diferenças do nível 2
estão na tabela logo depois. O [passo a passo](passo-a-passo.md) mostra uma
feature de nível 2 inteira, com os arquivos de verdade.

### 10.1 Especificar

```
/sdd:especificar B-001
```

(ou `/sdd:especificar exportar os pedidos do mês em CSV`, sem passar pelo backlog)

| O agente faz | Você decide |
|---|---|
| classifica o nível e pergunta | confirma o nível |
| escolhe a capacidade (`sistema/`) | confirma o nome |
| cria `specs/001-exportar-pedidos/` pelo `sdd-estado nova` | nada |
| cria a branch `feature/001-exportar-pedidos` a partir de `develop` e muda para ela (`sdd-gitflow feature`) | nada |
| escreve a spec: requisitos (RF) em EARS e critérios de aceitação (CA) em Dado, Quando, Então | lê: é isso que você quer? |
| marca o que não sabe com `[PRECISA ESCLARECER]` | nada ainda |

A pasta da feature **sempre** nasce pelo `sdd-estado nova`, numerada, e a
branch tem o mesmo nome: `feature/` mais o id da pasta. Um agente que tentar
criar `docs/specs/exportar.md`, `specs/exportar/` ou uma branch `feat/exportar`
à mão é bloqueado pelo hook. Toda a feature, da spec ao código, é commitada na
branch dela.

### 10.2 Esclarecer e aprovar a spec

```
/sdd:clarificar      # só se houver dúvidas na spec
/sdd:aprovar
```

O `/sdd:clarificar` faz até cinco perguntas por rodada, cada uma com opções e
uma recomendação. O `/sdd:aprovar` mostra o resumo e pede o seu "sim". A
aprovação fica no `specs/001-exportar-pedidos/historico.md` com o hash da spec:
se ela mudar depois, os comandos percebem.

### 10.3 Tarefas

```
/sdd:tarefas
/sdd:aprovar
```

Cada tarefa fica numa linha que os utilitários leem:

```
- [ ] T-001 gerar o CSV dos pedidos do mês (atende: RF-001, CA-001; depende de: nada)
```

`[ ]` é aberta, `[x]` é feita no plugin. (Existe uma terceira marca, `[O]`, que
só aparece em projetos adotados: ver o [outro guia](projeto-em-andamento.md).)

### 10.4 Implementar em duas rodadas

```
/sdd:implementar     # fase red: o escritor-de-testes escreve os testes a partir dos CAs
/sdd:aprovar         # você aprova os testes; eles ficam congelados
/sdd:implementar     # fase green: o código, tarefa por tarefa
```

Na primeira rodada, os testes devem **falhar** pelo motivo certo (o
comportamento ainda não existe). Na segunda, o agente implementa até eles
passarem, sem poder editá-los.

Os commits seguem o **Conventional Commits** e citam a tarefa:
`feat(001): T-001 gera o CSV`, `test(001): T-002 critérios da exportação`,
`fix(001): T-003 corrige o fuso`. O tipo não é enfeite: é dele que sai a
próxima versão (`feat` sobe o minor, `fix` o patch, `!` o major). O hook
bloqueia mensagem fora do formato. Ver [versionamento](versionamento.md).

### 10.5 Entregar a feature

No nível 1, sem área sensível:

```
/sdd:aprovar         # a entrega: a feature fica pronta
```

O `/sdd:aprovar` confere que spec e testes estão aprovados e inalterados e
conduz a **consolidação**: o agente atualiza `sistema/pedidos.md` com o
comportamento novo e mostra o diff para você confirmar.

Depois, ele pergunta se pode levar a feature para `develop`. Com
`integracao: local`, roda `sdd-gitflow integrar 001-exportar-pedidos`:

```
Integrada: feature/001-exportar-pedidos em develop.
Publique quando quiser: git push origin develop
```

Com `integracao: pr`, ele abre o pull request `feature/001-exportar-pedidos`
para `develop`, e o merge acontece na plataforma.

### 10.6 O que muda no nível 2, ou numa área sensível

| Situação | O que entra a mais |
|---|---|
| nível 2 | `/sdd:planejar` e `/sdd:aprovar` depois da spec (plano, contratos, ameaças, rollback) |
| nível 2 | `/sdd:seguranca` e `/sdd:aprovar` depois do green |
| nível 2 | `/sdd:auditar` e `/sdd:aprovar` no fim |
| nível 1 que tocou `areas_sensiveis` | `/sdd:seguranca` e `/sdd:aprovar` antes da entrega |

Perdeu o fio em qualquer ponto? `/sdd:status` mostra onde a feature está e qual
é o próximo comando.

## 11. Entregar: a primeira release

```
/sdd:release preparar      # escolhe as features prontas e a versão; cria release/X.Y.Z; testes de sistema
/sdd:release homologar     # implanta em homologação e entrega o roteiro em linguagem de negócio
/sdd:release aceitar       # quem homologou aprova
/sdd:release implantar     # plano de implantação e rollback; você diz go ou no-go
/sdd:release concluir      # depois da verificação em produção
```

O Git Flow da release:

| Momento | No git |
|---|---|
| `preparar` | a versão sai dos commits (`sdd-release analisar`: a primeira é 0.1.0); `release/0.1.0` nasce de `develop`; o push dela implanta em homologação |
| correção pedida na homologação | commit em `release/0.1.0` |
| antes do go | `sdd-release changelog 0.1.0 --escrever`: a seção da versão no `CHANGELOG.md`, revisada por você |
| "go" no `implantar` | `sdd-gitflow finalizar 0.1.0`: merge em `main`, tag `v0.1.0`, merge de volta em `develop` |
| você publica | `git push origin main develop v0.1.0`: a tag dispara o deploy de produção, que confere o go |

Detalhes no [release](../release.md) e no [Git Flow](git-flow.md).

## 12. A rotina depois disso

| Quando | Comando |
|---|---|
| começo do dia | `/sdd:status` e `/sdd:pendencias` |
| ideia nova | `/sdd:backlog adicionar` (não entra na sprint em andamento) |
| mudar comportamento | `/sdd:especificar` |
| fim de cada fase | `/sdd:aprovar` |
| voltar a uma feature | `/sdd:retomar` |
| quebrou em produção | `/sdd:incidente abrir` (o hotfix nasce em `hotfix/X.Y.Z`, a partir de `main`) |
| ver as branches | `sdd-gitflow conferir` |
| fim da sprint | `/sdd:sprint encerrar` |
| não sei qual comando | `/sdd:ajuda` |

Typo, ajuste visual ou refatoração coberta por testes são **nível 0**: o agente
faz direto, sem feature. A regra é simples: mudou comportamento observável, é
nível 1 no mínimo.

A rotina completa, com o que olhar em cada aprovação, está no
[guia de acompanhamento](acompanhamento.md).

## 13. Conferência final

Depois da primeira feature pronta:

- [ ] `/sdd:status` mostra a feature na coluna "Pronta" (ou em produção, depois da release).
- [ ] `specs/001-<slug>/historico.md` tem uma linha de aprovação para cada gate, com o seu nome e um hash.
- [ ] `sistema/<capacidade>.md` descreve o comportamento novo, com `(origem: 001/RF-001)`.
- [ ] `sdd-verificar` passa no CI.
- [ ] `/sdd:pendencias` diz "Nada esperando por você", ou só o que você já sabe.
- [ ] Nenhum arquivo de processo fora do layout: a seção "Fora do padrão" não aparece nas pendências.
- [ ] `sdd-gitflow conferir` diz "Tudo no padrão", e o `git log --graph` mostra a feature entrando em `develop` e a release em `main` com a tag.

### Problemas comuns no começo

| Sintoma | Causa | O que fazer |
|---|---|---|
| `sdd-*: command not found` | o plugin não está ativo na sessão | `/reload-plugins`; no Windows, confirme o Git Bash |
| o hook bloqueou um arquivo que não é teste | `globs_de_teste` amplo demais | ajuste no `.sdd/config.yml` |
| o hook bloqueou criar `docs/specs/x.md` ou `TODO.md` | o layout é contrato | peça a feature pelo `/sdd:especificar`; ideias vão para o backlog |
| o hook bloqueou um `tasks.md` de um manual seu | o arquivo tem nome de artefato | ponha o caminho em `excecoes_de_layout` |
| "spec.md não está aprovado ou mudou depois da aprovação" | a spec foi editada depois do "sim" | `git diff`; aprove de novo ou desfaça |
| `sdd-rastrear` diz que um CA não tem teste | a marca está sem o número da feature | use `sdd:001:CA-001`, não `sdd:CA-001` |
| o hook bloqueou um commit em `develop` | há uma feature ativa, e o commit dela é na branch dela | `sdd-gitflow feature NNN-slug`; ou `sdd-estado definir feature=` se o commit não é dela |
| `sdd-gitflow iniciar` diz que a produção se chama `master` | o `git init` criou `master` | `sdd-gitflow renomear master main` |

Mais em [guia do desenvolvedor](guia-do-desenvolvedor.md#10-problemas-comuns).
