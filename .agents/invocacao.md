# Invocada pelo usuário ou pelo modelo

Toda skill deste repositório está de um lado de um único eixo, o de **quem pode
invocá-la**:

- **Invocada pelo usuário:** só roda quando a pessoa digita o nome. Leva
  `disable-model-invocation: true` no frontmatter (Claude Code) e
  `policy.allow_implicit_invocation: false` no `agents/openai.yaml` (Codex). A
  `description` é **para pessoas**: um resumo de uma linha, lido por quem
  percorre a lista de comandos. Sem lista de gatilhos ("Use quando o usuário...").
- **Invocada pelo modelo:** pode ser chamada pelo modelo ou pela pessoa. É o
  padrão: omita `disable-model-invocation` e o bloco `policy`. A `description`
  é **para o modelo** e mantém gatilhos ricos ("Use ao..., quando o usuário
  mencionar...") para a invocação automática funcionar. O teste para mantê-la
  assim: *o modelo poderia, com proveito, recorrer a ela sozinho?*

Neste plugin, **toda fase do fluxo é invocada pelo usuário**: o comando é o
gate. Só a `metodologia` é invocada pelo modelo.

Mantenha os dois arquivos em sincronia: uma skill é invocada pelo usuário nos
dois harnesses ou em nenhum.

## Dependências entre skills

Uma skill depende de outra por meio de uma instrução explícita para **chamar a
ferramenta Skill** com o nome (`Chame a ferramenta Skill com sdd:metodologia`),
não por links profundos (`../outra/ARQUIVO.md`) nem por um `/nome` solto no
texto. Material de referência compartilhado mora dentro da skill que é dona
dele.

Isso só vale para skills **invocadas pelo modelo**. Uma skill invocada pelo
usuário nunca é chamada por outra. Quando ela é pré-condição de um passo, a
instrução é para a pessoa: "diga ao usuário para rodar `/sdd:iniciar`".

Subagents são chamados pela ferramenta Agent, pelo nome
(`Chame a ferramenta Agent com o subagent auditor-de-drift`).
