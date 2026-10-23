# Tudo em português, inclusive os nomes de comandos, fases e configuração

## Decisão

Comandos (`/sdd:especificar`), subagents (`auditor-de-drift`), utilitários
(`sdd-rastrear`), fases (`especificacao`, `plano`), chaves de configuração
(`protecao`, `globs_de_teste`) e toda a prosa do repositório são em português do
Brasil. Termos sem tradução corrente na área ficam como estão: spec, drift,
hook, subagent, red, green, commit.

## Por quê

O público do plugin trabalha em português. Misturar nomes em inglês com prosa
em português obriga a traduzir mentalmente a cada comando, e a documentação
passa a falar duas línguas.

## Consequências

- Os nomes de fase não levam acento (`especificacao`, `concluida`) para funcionar em qualquer shell e sistema de arquivos.
- Mudar qualquer nome é mudança de contrato público (versão maior). Ver `CLAUDE.md`.
