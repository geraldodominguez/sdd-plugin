# Convenções de manutenção deste repositório

Este arquivo orienta quem mantém o plugin (pessoas e agentes). Ele **não** é o
bloco de regras que o `/sdd:iniciar` injeta nos projetos dos usuários: esse
bloco fica em `skills/metodologia/templates/bloco-agentes.md`.

## Idioma

Tudo neste repositório é escrito em **português do Brasil**: skills, agents,
documentação, mensagens dos scripts, comentários, changelog, ADRs e issues.
Termos técnicos consagrados sem tradução corrente ficam como estão (spec,
drift, hook, subagent, red, green, commit, merge).

## Skills

Toda skill fica em `skills/<nome>/SKILL.md`, com `skills/<nome>/agents/openai.yaml` ao lado.

Toda skill tem:

- entrada no array `skills` do `.claude-plugin/plugin.json`;
- entrada no `README.md`, com o nome ligado ao `SKILL.md`, no grupo certo (**Invocadas pelo usuário** ou **Invocadas pelo modelo**);
- página de documentação em `docs/<nome>.md`, escrita conforme [.agents/escrita-de-docs.md](.agents/escrita-de-docs.md).

Toda skill é **invocada pelo usuário** ou **invocada pelo modelo**. Ver
[.agents/invocacao.md](.agents/invocacao.md). As skills de fase do fluxo são
sempre invocadas pelo usuário, porque cada uma é um gate.

A skill [`ajuda`](skills/ajuda/SKILL.md) é o roteador sobre todos os comandos.
Sempre que você adicionar, renomear, remover ou mudar o papel de uma skill
invocada pelo usuário, releia e atualize a `ajuda`: um roteador que cita um
comando que não existe, ou ignora um que existe, mente.

## Subagents

Ficam em `agents/<nome>.md`. Todo subagent aparece no `README.md` (seção
Subagents), na tabela do modo de falha #5 e na página da skill que o chama.

## Formatos rastreáveis

A linha de tarefa, a marca de teste `sdd:NNN:CA-XXX`, os IDs (`RF`, `RNF`, `CA`,
`T`), as fases e as chaves de `.sdd/config.yml` e `.sdd/estado` são **contrato
público**. Mudar qualquer um exige atualizar, juntos: `bin/`, `lib/`,
`scripts/`, `tests/`, templates, skills, documentação e `CHANGELOG.md`. É uma
mudança incompatível (versão maior).

## Scripts

Bash compatível com o 3.2 (macOS), sem dependência obrigatória. `jq` e
`python3` são opcionais, com reserva por expressão regular. Hooks são
**fail-open**: na dúvida, permitem. Toda mudança em `bin/`, `lib/` ou
`scripts/` vem com teste em `tests/rodar-testes.sh`.

## Instalação

Os comandos de instalação são copiados literalmente de
[.agents/bloco-de-instalacao.md](.agents/bloco-de-instalacao.md). Mude lá
primeiro e depois propague.

Depois de mexer em qualquer manifesto, rode `claude plugin validate .`. O modo `--strict` acusa um único aviso esperado: este `CLAUDE.md` na raiz não é carregado como contexto do plugin. Ele existe para quem mantém o repositório, não para quem instala.

## Decisões

As decisões de desenho do plugin ficam em [.agents/adr/](.agents/adr/). Ideias
rejeitadas ficam em [.fora-do-escopo/](.fora-do-escopo/), uma por arquivo, e
são listadas no [ESCOPO.md](ESCOPO.md).

## Sem travessões

Nenhum travessão (o caractere U+2014) na prosa deste repositório: skills,
documentação, `README.md`, `CHANGELOG.md`, ADRs e comentários. Quando uma frase
pedir um, reescreva com vírgula, dois-pontos, ponto, parênteses ou uma
conjunção, o que a frase de fato pedir. Nunca troque o caractere às cegas. O
teste `tests/sem-travessoes.sh` confere isso na CI.
