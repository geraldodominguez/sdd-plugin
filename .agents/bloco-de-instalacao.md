# Bloco canônico de instalação

Uma história de instalação, uma redação. `README.md`, `CHANGELOG.md` e qualquer
página em `docs/` usam **este** texto e nenhum outro. Mude aqui primeiro e
depois propague.

## Claude Code

<bloco nome="claude-code">

```bash
claude plugin marketplace add geraldodominguez/sdd-plugin
claude plugin install sdd@sdd-plugin
```

</bloco>

## Atualização no Claude Code

<bloco nome="atualizacao">

```bash
claude plugin marketplace update sdd-plugin
claude plugin update sdd
```

</bloco>

## Outros agentes

<bloco nome="outros">

As skills seguem o formato padrão (`SKILL.md`). Copie a pasta `skills/` para o
diretório de skills do seu agente, ponha `bin/` no PATH e garanta que ele leia o
`AGENTS.md` do projeto. Os hooks são específicos do Claude Code.

</bloco>

## Regras

- Páginas em `docs/` não repetem comandos de instalação: apontam para o `README.md`.
- Nunca prometa atualização automática para uma rota que não a tenha.
- Num fork, troque `geraldodominguez` pelo seu usuário aqui e propague.
