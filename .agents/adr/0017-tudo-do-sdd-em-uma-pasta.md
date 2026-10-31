# Tudo do SDD mora em sdd/, e o iniciar prepara .claude/ e o git

## Decisão

- Todo artefato do SDD fica dentro de uma pasta só, `sdd/`: `config.yml`, `constituicao.md`, `backlog.md`, `estado`, `sprints/`, `templates/`, `specs/`, `sistema/`, `releases/`, `incidentes/`, `adr/`, `arquitetura/` e `legado/`. Na raiz do projeto sobram `CLAUDE.md`, `AGENTS.md`, `.gitattributes`, `.gitignore` e `.claude/`. Esta decisão substitui a lista de lugares da [ADR 0014](0014-layout-como-contrato-e-adocao.md), que continua valendo no resto (layout como contrato, mapa aprovado, transição).
- O projeto usa o SDD quando tem `sdd/config.yml`. O `sdd/estado` (ponteiro pessoal, fora do git) também vale, para o projeto ser reconhecido numa branch que ainda não recebeu o `sdd/`. A [ADR 0003](0003-hooks-fail-open.md) vale com esse marcador no lugar de `.sdd/`.
- O `sdd/.gitignore` ignora só `/estado`, ancorado: o `estado` de cada feature é versionado.
- O `/sdd:iniciar` e o `sdd-iniciar` criam também a pasta `.claude/` (`settings.json` com as permissões de leitura dos `sdd-*`, e `agents/`, `skills/`, `commands/` e `rules/`) e, se o diretório não é um repositório, o repositório git: branch `main`, `.gitignore`, commit inicial vazio (com `user.name` e `user.email` configurados) e o aviso de que falta o remoto. `--sem-git` e `--sem-claude` pulam cada parte.
- O `sdd-adotar estrutura` confere `sdd/`, `.claude/` e o git e completa o que falta. Um `.claude/settings.json` que já existe nunca é reescrito: o utilitário aponta o que falta e a skill pergunta.
- A skill `iniciar` pergunta ao usuário o que não dá para deduzir (criar o repositório, identidade do git, remoto, `.claude/settings.json` existente, pasta `sdd/` alheia, nível, proteção, integração, comandos) antes de criar qualquer coisa.
- Sem migração: o `sdd-iniciar` recusa um projeto com a pasta `.sdd/` do layout antigo e diz como mover. Nenhum projeto usava o plugin quando a mudança foi feita.

## Por quê

- Três pastas do plugin (`specs/`, `sistema/`, `.sdd/`) e a `docs/adr/` na raiz de um projeto alheio são intrusivas, e `specs/` e `docs/adr/` colidem com os lugares onde outros processos guardam artefatos, o que embaralhava o inventário da adoção. Uma pasta só deixa claro o que é do método e tem um nome que ninguém usa por acaso.
- `sdd/` sem ponto é visível, versionada e fácil de achar. O marcador é o `config.yml`, não a pasta, porque um projeto pode ter uma `sdd/` que não é do SDD.
- O `.claude/` e o repositório git são o que o Claude Code e o Git Flow pressupõem; criá-los no mesmo passo evita o "falta o repositório" no meio do fluxo.
- O hook não pode ser instalado em `.claude/settings.json`: os hooks do plugin já rodam pelo `hooks.json`, e repetir duplicaria a execução.

## Consequências

- É uma mudança incompatível (versão maior, 2.0.0): os caminhos são contrato público.
- `pasta_specs`, `pasta_sistema`, `pasta_releases` e `pasta_incidentes` continuam configuráveis; os padrões agora começam em `sdd/`.
- O `.gitattributes` passa a apontar `sdd/historico.md` e `sdd/specs/*/historico.md`.
- Um artefato solto em `specs/`, `docs/adr/` ou `.sdd/` na raiz é "fora do padrão": a adoção o leva para `sdd/`.
