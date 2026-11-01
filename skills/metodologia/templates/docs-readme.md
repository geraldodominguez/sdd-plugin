# Documentos do projeto

Esta pasta guarda o **material de entrada** do projeto: o que as pessoas e os
agentes precisam ler para entender o problema, mas que não é um artefato do
processo do SDD (spec, plano, tarefas).

| Exemplos do que vem aqui | Exemplos do que não vem aqui |
|---|---|
| documentação de API externa que o sistema consome | a spec de uma mudança (`sdd/specs/`) |
| levantamentos, atas e pedidos de clientes | o que o sistema faz hoje (`sdd/sistema/`) |
| regulamentos, contratos e normas que o projeto cumpre | uma decisão de arquitetura (`sdd/adr/`) |
| glossário do domínio, diagramas de negócio | a spec ou o plano de uma mudança, mesmo que tenha nome de requisito (vão para `sdd/specs/`) |

O `/sdd:especificar` e o `mapeador-de-contexto` consultam esta pasta antes de
perguntar ao usuário. Quando uma spec se apoia em um documento daqui, ela cita
o caminho (`sdd/docs/apis/pagamentos.md`).

## Regras

- Só texto versionável (markdown, texto, diagramas em texto). PDF e planilha
  grandes ficam fora do git: guarde um resumo aqui e o link do original.
- Nada confidencial que não possa ir ao repositório: contrato com dado
  pessoal, senha, chave de API.
- Organize como o projeto precisar (por exemplo `apis/`, `clientes/`). O SDD
  não exige subpastas, e o hook não confere o que está aqui.
