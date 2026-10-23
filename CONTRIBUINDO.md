# Contribuindo

Antes de abrir uma issue ou um pull request, leia o [ESCOPO.md](ESCOPO.md): ele
diz o que entra e o que já foi decidido. As convenções de manutenção estão no
[CLAUDE.md](CLAUDE.md).

## Estrutura do repositório

```
.claude-plugin/
  plugin.json          manifesto (nome "sdd", então os comandos são /sdd:*)
  marketplace.json     este repositório também é o marketplace "sdd-plugin"
  icon.png
skills/<nome>/
  SKILL.md             uma skill por pasta
  agents/openai.yaml   metadados para o Codex
skills/metodologia/    a skill invocada pelo modelo, com as referências e os templates
agents/                os quatro subagents
hooks/hooks.json       registra os hooks PreToolUse
scripts/               guarda-edicoes.sh, guarda-commits.sh
bin/                   sdd-iniciar, sdd-estado, sdd-rastrear, sdd-status (vão para o PATH)
lib/sdd-comum.sh       funções compartilhadas por bin/ e scripts/
tests/                 testes dos utilitários e hooks, e a checagem de travessões
docs/                  uma página por skill, e docs/referencia/ com os guias
exemplos/              os artefatos de uma feature completa
.agents/               convenções do repositório e ADRs do próprio plugin
.fora-do-escopo/       ideias rejeitadas, uma por arquivo
```

## Desenvolvendo

```bash
git clone https://github.com/geraldodominguez/sdd-plugin.git
cd sdd-plugin

tests/rodar-testes.sh                    # utilitários e hooks
tests/sem-travessoes.sh                  # prosa sem travessões
shellcheck -x -S warning bin/* scripts/*.sh lib/*.sh tests/*.sh
claude plugin validate .                 # estrutura do plugin (ver CLAUDE.md sobre o --strict)

# usar a versão local num projeto
cd ../meu-projeto
claude --plugin-dir ../sdd-plugin
```

Na sessão, `/reload-plugins` recarrega depois de editar.

## Mudando uma skill

1. Edite o `SKILL.md` e, se mudar o modo de invocação, o `agents/openai.yaml` junto. Ver [.agents/invocacao.md](.agents/invocacao.md).
2. Atualize a página em `docs/<nome>.md`, conforme [.agents/escrita-de-docs.md](.agents/escrita-de-docs.md).
3. Se mudou o papel da skill no fluxo, atualize a [`ajuda`](skills/ajuda/SKILL.md) e o `README.md`.
4. Registre no `CHANGELOG.md`.

## Mudando um script

Toda mudança em `bin/`, `lib/` ou `scripts/` vem com teste em
`tests/rodar-testes.sh`. O arquivo já roda os testes de hook com os três
leitores de JSON (jq, python e expressão regular).

## Publicando uma versão

1. Atualize `version` em `.claude-plugin/plugin.json` e o `CHANGELOG.md`.
2. Rode os testes e o `claude plugin validate .`.
3. Faça o commit e rode `claude plugin tag . --push`, que cria a tag `sdd--vX.Y.Z`.
