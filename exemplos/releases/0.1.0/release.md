# Release 0.1.0

| Campo | Valor |
|---|---|
| Versão | 0.1.0 |
| Tipo | normal |
| Objetivo | Clientes recuperam o acesso sozinhos |
| Criada em | 2026-10-28 |
| Situação | producao |

> Uma release agrupa features prontas e as leva por testes de sistema,
> homologação, implantação e produção. Use `/sdd:release` para conduzir. A
> situação muda só pelos utilitários; o histórico fica em `historico.md`.

## Features

- 001-redefinicao-de-senha
- 002-ultimo-acesso

## Arquivos desta release

| Arquivo | Para quê | Quando |
|---|---|---|
| `testes.md` | resultado dos testes de sistema (regressão, ponta a ponta, carga) | antes da homologação |
| `homologacao.md` | roteiro de aceite em linguagem de negócio, com o resultado de cada passo | na homologação |
| `implantacao.md` | passos, rollback e verificação pós-implantação | antes do go/no-go |
| `notas.md` | notas de versão para quem usa o sistema | antes da conclusão |
