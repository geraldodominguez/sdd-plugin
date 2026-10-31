# Estrutura de pastas: o que o SDD cria e para que serve cada uma

O SDD guarda tudo numa pasta só, **`sdd/`**, para a raiz do seu projeto não se
encher de pastas do método. Fora dela, ele só toca em cinco coisas, que outras
ferramentas esperam na raiz: `CLAUDE.md`, `AGENTS.md`, `.claude/`,
`.gitattributes` e `.gitignore`. Este guia explica cada pasta: quem escreve
nela, se vai para o git e quando ela aparece.

## Sumário

1. [A árvore completa](#1-a-árvore-completa)
2. [Dentro de sdd/](#2-dentro-de-sdd)
3. [Dentro de uma feature](#3-dentro-de-uma-feature)
4. [Fora de sdd/](#4-fora-de-sdd)
5. [O que vai para o git](#5-o-que-vai-para-o-git)
6. [Quem escreve onde](#6-quem-escreve-onde)
7. [Onde pôr cada tipo de documento](#7-onde-pôr-cada-tipo-de-documento)
8. [Mudar o caminho de uma pasta](#8-mudar-o-caminho-de-uma-pasta)
9. [Perguntas frequentes](#9-perguntas-frequentes)

---

## 1. A árvore completa

```
seu-projeto/
├── sdd/                          tudo do SDD
│   ├── config.yml                configuração do projeto
│   ├── constituicao.md           as regras inegociáveis
│   ├── backlog.md                o que vem depois
│   ├── estado                    ponteiro pessoal (fora do git)
│   ├── historico.md              eventos do projeto (criado pelos utilitários)
│   ├── adocao.md                 de onde veio cada artefato adotado (só na adoção)
│   ├── sprints/                  uma sprint por arquivo
│   ├── templates/                cópia dos modelos, para você customizar
│   ├── specs/                    uma pasta por feature (o que cada mudança alterou)
│   ├── sistema/                  a spec viva (o que o sistema faz hoje)
│   ├── adr/                      decisões de arquitetura
│   ├── docs/                     documentos do projeto: APIs externas, levantamentos
│   ├── releases/                 uma pasta por release (nasce na primeira release)
│   ├── incidentes/               um arquivo por incidente (nasce no primeiro incidente)
│   ├── arquitetura/              documentos e diagramas de arquitetura (só na adoção)
│   └── legado/                   o que veio de outro processo (só na adoção)
├── .claude/                      o que o Claude Code lê do projeto
│   ├── settings.json
│   ├── agents/  skills/  commands/  rules/
├── CLAUDE.md                     com o bloco de regras do SDD
├── AGENTS.md                     com o mesmo bloco, para outros agentes
├── .gitattributes                merge por união dos históricos
└── .gitignore
```

O `/sdd:iniciar` cria o que está na lista sem a marca "nasce" ou "só na
adoção". O resto aparece quando é preciso.

## 2. Dentro de sdd/

| Caminho | Para que serve | Quem escreve | Quando aparece |
|---|---|---|---|
| `config.yml` | nível de rigor, proteção dos hooks, Git Flow, pastas, globs de teste, áreas sensíveis e comandos do projeto (teste, lint, segurança, implantação) | você, com ajuda do agente | `/sdd:iniciar` |
| `constituicao.md` | as regras que todo plano precisa respeitar: stack, arquitetura, qualidade, segurança, ambientes, operação. Vale para todas as features | o agente rascunha, você aprova | `/sdd:iniciar` |
| `backlog.md` | itens ainda sem spec, com id `B-NNN` | `/sdd:backlog` | `/sdd:iniciar` |
| `estado` | a feature ativa e a sprint atual **de cada pessoa**; não vai para o git | `sdd-estado` | `/sdd:iniciar` |
| `historico.md` | eventos do projeto (backlog, sprint, release, incidente, adoção), só com linhas novas | os utilitários | quando o primeiro evento acontece |
| `sprints/` | uma sprint por arquivo (`S-NNN`), com a meta e os itens | `/sdd:sprint` | `/sdd:iniciar` |
| `templates/` | cópia dos modelos de spec, plano, tarefas, release, incidente e outros; edite para adaptar ao seu time | você | `/sdd:iniciar` |
| `specs/` | uma pasta por feature, `NNN-slug/`. É o **histórico** de cada mudança: o que mudou e por quê | as fases do fluxo | `/sdd:iniciar` |
| `sistema/` | a **spec viva**: o que o sistema faz hoje, por capacidade, em `sistema/<capacidade>.md`. Cada requisito aponta a feature de origem | `/sdd:sistema` | `/sdd:iniciar` |
| `adr/` | decisões de arquitetura duráveis, `NNNN-slug.md` (4 dígitos) | o agente propõe, você aceita | `/sdd:iniciar` |
| `docs/` | **material de entrada** do projeto: documentação de API externa, levantamentos e atas de clientes, normas, glossários. Não é artefato de processo | você e o agente | `/sdd:iniciar` |
| `releases/` | uma pasta por versão, `X.Y.Z/`: `release.md`, `testes.md`, `homologacao.md`, `implantacao.md`, `notas.md`, `estado`, `historico.md` | `/sdd:release` | primeira release |
| `incidentes/` | um arquivo por incidente, `INC-NNN.md`, da abertura ao post-mortem | `/sdd:incidente` | primeiro incidente |
| `arquitetura/` | documentos e diagramas de arquitetura (C4, por exemplo), como referência. O plugin não os mantém | você | na adoção, se havia |
| `legado/` | o que veio de outro processo e não entra no fluxo. Nunca é apagado, e não é fonte de verdade | `sdd-adotar` | na adoção |
| `adocao.md` | o registro de onde veio cada arquivo adotado | `sdd-adotar` | na adoção |

### A diferença entre specs/ e sistema/

| Pasta | Responde | Muda quando |
|---|---|---|
| `specs/NNN-slug/` | "o que **essa mudança** alterou, e por quê" | durante a feature; depois, só ganha o histórico |
| `sistema/<capacidade>.md` | "o que o sistema faz **agora**" | quando uma feature fica pronta e é consolidada (`/sdd:sistema consolidar`) |

Para entender uma decisão, siga a `origem:` do requisito em `sistema/` até a
feature em `specs/`. Para entender o sistema hoje, leia `sistema/`.

### A diferença entre sdd/docs/ e sdd/adr/

| Pasta | O que guarda | Exemplo |
|---|---|---|
| `docs/` | o que **vem de fora** e informa o projeto | a documentação da API do gateway de pagamento; a ata de reunião com o cliente |
| `adr/` | o que **o projeto decidiu** | "usar Postgres em vez de MongoDB" |

## 3. Dentro de uma feature

`sdd/specs/NNN-slug/` nasce com o `/sdd:especificar` e ganha um arquivo por
fase. O `estado` e o `historico.md` são escritos só pelos utilitários.

| Arquivo | Fase | Para que serve |
|---|---|---|
| `estado` | todas | a fase, o nível, a origem, a branch e se a segurança é obrigatória |
| `historico.md` | todas | os eventos da feature, com o hash de cada aprovação |
| `contexto.md` | especificação | o mapa do código que a mudança toca (nível 2, projeto existente) |
| `spec.md` | especificação | os requisitos (`RF`, `RNF`) e os critérios de aceitação (`CA`) |
| `plano.md` | plano | as decisões técnicas, ligadas aos requisitos (nível 2) |
| `contratos/` | plano | entidades, interfaces, schemas, OpenAPI, DDL (nível 2) |
| `tarefas.md` | tarefas | as tarefas `T-NNN`, cada uma com o requisito que atende |
| `seguranca.md` | segurança | a modelagem de ameaças e as varreduras |
| `auditoria.md` | auditoria | o que a implementação cumpre e o que desviou da spec |
| `delta-spec.md` | auditoria | a proposta de ajuste da spec, quando a implementação a superou |
| `transicao.md` | adoção | como era e como vai ficar, nas features adotadas de outro processo |

## 4. Fora de sdd/

| Caminho | Para que serve | Quem escreve | Vai para o git? |
|---|---|---|---|
| `.claude/settings.json` | permissões do projeto para o Claude Code; o `/sdd:iniciar` põe as de leitura dos utilitários `sdd-*` | o plugin cria; é seu depois | sim |
| `.claude/agents/`, `skills/`, `commands/`, `rules/` | as pastas que o Claude Code lê do projeto; ficam vazias (com `.gitkeep`) até você ter algo seu | você | sim |
| `.claude/settings.local.json` | suas permissões pessoais; já vem no `.gitignore` | você | não |
| `CLAUDE.md`, `AGENTS.md` | o bloco de regras do SDD entre `<!-- sdd:inicio -->` e `<!-- sdd:fim -->`; o resto do arquivo é seu | o plugin só toca no bloco | sim |
| `.gitattributes` | o merge por união dos históricos, que o Git Flow precisa | o plugin acrescenta | sim |
| `.gitignore` | lixo do sistema, `.env` e `.claude/settings.local.json` | o plugin acrescenta o que falta | sim |

## 5. O que vai para o git

Quase tudo. Só o ponteiro pessoal fica de fora.

| Caminho | Versionar? | Por quê |
|---|---|---|
| `sdd/config.yml`, `constituicao.md`, `templates/`, `backlog.md`, `sprints/` | sim | são do time |
| `sdd/specs/`, inclusive `estado` e `historico.md` de cada feature | sim | o quadro e as aprovações são do time |
| `sdd/sistema/`, `releases/`, `incidentes/`, `adr/`, `docs/` | sim | a spec viva, as entregas, os incidentes, as decisões e o material do projeto |
| `sdd/adocao.md`, `legado/`, `arquitetura/` | sim | o que veio de outro processo |
| `sdd/estado` | **não** (o `sdd/.gitignore` ignora só `/estado`) | é o ponteiro de cada pessoa |
| `.claude/settings.json` e as pastas do `.claude/` | sim | o time compartilha as permissões |
| `.claude/settings.local.json` | não | é pessoal |

O que não deve ir para `sdd/docs/`: PDF e planilha grandes (guarde um resumo e
o link do original), contrato com dado pessoal, senhas e chaves de API.

## 6. Quem escreve onde

| Quem | Escreve | Não escreve |
|---|---|---|
| **Você** | `config.yml`, `constituicao.md` (revisa), `templates/`, `docs/`, o que é seu no `.claude/` | `estado` e `historico.md` de feature e release (só pelos utilitários) |
| **Os comandos `/sdd:*`** | `specs/`, `sistema/`, `adr/`, `backlog.md`, `sprints/`, `releases/`, `incidentes/` | `sdd/docs/` sem a sua aprovação |
| **Os utilitários `sdd-*`** | `estado`, `historico.md`, `adocao.md`, a numeração das features e dos ADRs | o conteúdo das specs |
| **Os hooks** | nada; só conferem | |

Com a proteção `leve` ou `estrita`, o hook bloqueia **criar** um artefato de
processo (spec, plano, tarefas, ADR, backlog, sprint) fora destes lugares.
`sdd/docs/` é isenta: o que está nela é material de entrada, e o hook não a
confere. Ver [proteção por hooks](protecao-por-hooks.md#arquivos-novos-só-no-lugar-do-padrão).

## 7. Onde pôr cada tipo de documento

| Você tem | Vai para |
|---|---|
| o pedido de uma mudança | `/sdd:especificar`, que cria `sdd/specs/NNN-slug/` |
| a documentação de uma API que o sistema consome | `sdd/docs/` (por exemplo `sdd/docs/apis/pagamentos.md`) |
| um levantamento, uma ata ou um pedido de cliente | `sdd/docs/` |
| uma norma, um regulamento, um glossário do domínio | `sdd/docs/` |
| uma decisão de arquitetura tomada | `sdd/adr/` |
| um diagrama C4 ou documento de arquitetura | `sdd/arquitetura/` |
| o manual ou o site do produto | `sdd/docs/` também (ou, se o projeto publica a `docs/` pelo caminho, como GitHub Pages ou mkdocs, deixe-a na raiz e recuse a migração) |
| um TODO, um roadmap ou uma lista de ideias | `/sdd:backlog adicionar`, item por item |
| a spec de outro processo (Spec Kit, Kiro, OpenSpec) | `/sdd:iniciar --adotar` |
| um contrato com dado pessoal, uma chave, uma senha | fora do repositório |

## 8. Mudar o caminho de uma pasta

Quatro pastas têm o caminho configurável no `sdd/config.yml`, relativo à raiz do
projeto:

| Chave | Padrão |
|---|---|
| `pasta_specs` | `sdd/specs` |
| `pasta_sistema` | `sdd/sistema` |
| `pasta_releases` | `sdd/releases` |
| `pasta_incidentes` | `sdd/incidentes` |

As demais (`sdd/adr`, `sdd/docs`, `sdd/legado`, `sdd/arquitetura`,
`sdd/templates`, `sdd/sprints`) são fixas. Se você mudar uma das quatro, mova a
pasta junto, ou os utilitários não a encontram.

## 9. Perguntas frequentes

**Por que `sdd/` e não `.sdd/`?**

Para ser visível e fácil de achar no editor e no GitHub. O plugin reconhece o
projeto pelo `sdd/config.yml`, então uma pasta `sdd/` que não é do SDD não o
confunde: o `/sdd:iniciar` se recusa a seguir e pergunta como resolver.

**O `/sdd:iniciar` cria uma `docs/` na raiz?**

Nunca. Tudo o que o SDD cria está dentro de `sdd/`, inclusive a `sdd/docs/`.

**E se o meu projeto já tem uma `docs/` na raiz?**

Na adoção, ela é a **última** coisa a migrar. Primeiro vão para o lugar as
specs, os planos, as tarefas e os ADRs que estão soltos (inclusive os que
estão dentro de `docs/`, como `docs/specs/` ou `docs/decisions/`). Só então o
`sdd-adotar docs` leva o que sobrou da `docs/` para `sdd/docs/`, com `git mv`,
mantendo os caminhos relativos (`docs/guias/x.md` vira `sdd/docs/guias/x.md`) e
sem apagar nada. Um arquivo que colide com um que já existe, como o
`README.md`, ganha o sufixo `-original`.

Antes de migrar, o agente procura o que usa a `docs/` pelo caminho (mkdocs,
Docusaurus, Sphinx, GitHub Pages, CI, links do README) e mostra o que quebraria.
Você aprova, ou recusa e a `docs/` fica onde está: o hook não confere a `docs/`
da raiz, então o SDD segue funcionando.

**Posso criar subpastas em `sdd/docs/`?**

Pode, do jeito que o projeto precisar (`apis/`, `clientes/`, `referencias/`). O
SDD não exige estrutura e o hook não confere o conteúdo.

**O agente lê o `sdd/docs/`?**

Sim. O `/sdd:especificar` e o `mapeador-de-contexto` consultam a pasta antes de
perguntar a você sobre uma API externa ou um cliente, e a spec cita o caminho do
documento em que se apoia.

**Posso mudar o nome `sdd`?**

Não. Ele é fixo: é o marcador do projeto e está em todos os utilitários, hooks
e documentos.

**Tenho um projeto com `docs/specs/`, `tasks/` e um `TODO.md`. O que acontece?**

Isso é artefato de outro processo. O `/sdd:iniciar --adotar` propõe um mapa
para levar cada arquivo ao lugar certo (feature, ADR, `sdd/docs/`,
`sdd/legado/`) e só move com a sua aprovação. Ver
[adotar o SDD num projeto em andamento](projeto-em-andamento.md).
