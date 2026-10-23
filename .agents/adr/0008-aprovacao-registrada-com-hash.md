# Aprovações registradas com hash do artefato

Na primeira versão, a aprovação de cada gate acontecia só na conversa. Nada
provava depois que a spec tinha sido aprovada, por quem, quando, nem se ela
mudou depois disso.

## Decisão

- O `/sdd:aprovar`, invocado só pelo usuário, registra a aprovação no `historico.md` da feature: data, autor (o nome do git) e um hash curto do artefato.
- O hash do plano inclui todos os arquivos de `contratos/`. O hash dos testes inclui todo arquivo de teste com a marca `sdd:NNN:`.
- `sdd-estado aprovado <artefato>` responde por código de saída: 0 aprovado e inalterado, 4 alterado depois, 5 nunca aprovado.
- Os comandos de fase conferem a aprovação da fase anterior antes de começar, e o auditor confere todas.
- O hook de edição bloqueia a edição manual do `historico.md` e do `estado` de cada feature.

## Por quê

O gate só vale se deixar rastro. Com o hash, uma mudança silenciosa (uma regra
de negócio alterada depois de aprovada, um teste "consertado" na fase green)
deixa de ser invisível. É o mesmo princípio da spec como fonte de verdade,
aplicado ao processo.

## Consequências

- Qualquer mudança num artefato aprovado exige nova aprovação, mesmo uma vírgula. É barato e torna a regra simples.
- O agente ainda conseguiria chamar `sdd-estado aprovar` pelo shell. A defesa é em camadas: as instruções, o autor registrado e a auditoria. Ver ADR 0003.
