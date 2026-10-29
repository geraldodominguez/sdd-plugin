# Versionamento no SDD

Todo projeto com o SDD usa os mesmos três padrões de mercado:

| Padrão | Para quê |
|---|---|
| [SemVer 2.0.0](https://semver.org/lang/pt-BR/) | o número da versão: `MAJOR.MINOR.PATCH`, a tag `vX.Y.Z` em `main` |
| [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/) | a mensagem de commit diz o tipo da mudança, e o tipo decide a versão |
| [Keep a Changelog 1.1.0](https://keepachangelog.com/pt-BR/1.1.0/) | o `CHANGELOG.md`, uma seção por versão |

## A mensagem de commit

```
tipo(escopo)!: descrição

corpo opcional

BREAKING CHANGE: o que quebrou (opcional)
```

O escopo é o número da feature (`feat(004): T-002 valida token expirado`).

| Tipo | Quando | Versão |
|---|---|---|
| `feat` | comportamento novo para quem usa o sistema | minor |
| `fix` | correção de comportamento errado | patch |
| `perf` | desempenho, sem mudar o comportamento | patch |
| `docs`, `chore`, `refactor`, `test`, `build`, `ci`, `style`, `revert` | o resto | nenhuma |
| qualquer tipo com `!`, ou o rodapé `BREAKING CHANGE:` | quebra um contrato público | major |

Antes da 1.0.0, a mudança incompatível sobe o minor: a API ainda não é estável.
A 1.0.0 se declara de propósito (`sdd-release proxima major`).

## Os comandos

| Comando | Faz |
|---|---|
| `sdd-release analisar` | os commits desde a última versão, o impacto de cada um e a sugestão, com o motivo |
| `sdd-release proxima` | a próxima versão, calculada pelos commits (ou `major`, `minor`, `patch` explícitos) |
| `sdd-release proxima --pre rc` | o próximo pré-lançamento: `X.Y.Z-rc.1`, `-rc.2`... Um pré-lançamento só é homologado, nunca vai para produção (ver o `/sdd:release`, Release candidate) |
| `sdd-release changelog X.Y.Z [--escrever]` | a seção da versão no `CHANGELOG.md` |

A versão de referência é a última release em produção; sem nenhuma, a última
tag `vX.Y.Z` final (pré-lançamentos, em release ou em tag, não contam). Commits fora do padrão
não contam para a versão: o `analisar` os lista.

## Regras

1. Escolha o tipo pelo efeito para quem usa o sistema, não pelo tamanho da mudança.
2. Quebrou um contrato público (API, evento, schema que outro sistema consome)? `!` e `BREAKING CHANGE:`, sempre. Esquecer é o erro mais caro: a versão sai minor e quem depende do sistema quebra sem aviso.
3. A versão sugerida é uma sugestão: o usuário decide no `/sdd:release`.
4. O `CHANGELOG.md` é gerado e **revisado**: a linha vem da descrição do commit ou do título da feature.
