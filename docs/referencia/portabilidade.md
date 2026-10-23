# Portabilidade

O plugin é feito para o Claude Code, mas **o método e os artefatos não dependem
dele**.

## O que é portável

| Item | Formato | Portável? |
|---|---|---|
| `specs/`, `docs/adr/` | markdown | sim, qualquer ferramenta |
| `.sdd/constituicao.md`, `.sdd/templates/` | markdown | sim |
| `.sdd/config.yml`, `.sdd/estado` | texto | sim |
| `AGENTS.md` (bloco SDD) | markdown | sim, lido por vários agentes |
| `bin/sdd-*` | bash | sim, qualquer terminal |
| `skills/` | formato padrão de skill (`SKILL.md`) | sim, em harnesses que leem skills |
| `skills/*/agents/openai.yaml` | metadados do Codex | sim, no Codex |
| `agents/` (subagents) | formato do Claude Code | adaptar: o conteúdo serve de prompt |
| `hooks/` | formato do Claude Code | adaptar: os scripts leem um JSON simples |

## O AGENTS.md

O `/sdd:iniciar` injeta o mesmo bloco de regras no `CLAUDE.md` e no `AGENTS.md`.
Agentes que leem o `AGENTS.md` seguem as mesmas sete regras, e um time pode usar
ferramentas diferentes no mesmo repositório sem quebrar o fluxo.

## Usando com outro agente

1. Garanta que ele leia o `AGENTS.md`.
2. Ponha `bin/` no PATH, ou copie os scripts para o projeto.
3. Copie `skills/` para o diretório de skills dele.
4. Use os arquivos de `agents/` como prompt de sessões **separadas**: uma sessão nova para o escritor de testes, outra para o auditor. O isolamento vem da sessão separada.
5. Rode o `sdd-rastrear` na CI, que independe de agente.

## Skills fora do Claude Code

Algumas superfícies aceitam só `name`, `description`, `license`, `compatibility`,
`metadata` e `allowed-tools` no frontmatter. Para usar uma skill lá, remova os
campos específicos do Claude Code (`disable-model-invocation`, `argument-hint`).
