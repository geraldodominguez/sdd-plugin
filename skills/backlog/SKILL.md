---
name: backlog
description: Gerencia o backlog, os itens que ainda não têm spec. Lista por prioridade, adiciona ideias e pedidos, prioriza com você, descarta com motivo e promove um item a feature.
argument-hint: "[listar | adicionar <ideia> | priorizar | descartar B-NNN | promover B-NNN]"
disable-model-invocation: true
allowed-tools: Bash(sdd-backlog *), Bash(sdd-backlog), Bash(sdd-estado *), Bash(sdd-status), Read, Edit
---

# /sdd:backlog

Pedido: `$ARGUMENTS` (vazio significa listar)

O backlog fica em `.sdd/backlog.md`. Um item (`B-NNN`) é uma ideia, um pedido
de cliente, um bug relatado ou uma pendência encontrada fora do escopo de uma
feature. Ele **não tem spec**. Quando ganha spec, vira feature.

## Ações

| Pedido | O que fazer |
|---|---|
| vazio ou `listar` | `sdd-backlog listar` (ou `--todos`) e mostre num bloco de código, com uma linha de leitura: quantos abertos, quantos de prioridade alta, quantos sem nível |
| `adicionar <ideia>` | ver "Adicionar" abaixo |
| `priorizar` | ver "Priorizar" abaixo |
| `descartar B-NNN` | pergunte o motivo e rode `sdd-backlog descartar B-NNN "motivo"` |
| `promover B-NNN` | diga ao usuário para rodar `/sdd:especificar B-NNN`, que cria a feature a partir do item |

### Adicionar

1. Reescreva a ideia como um **título curto de comportamento** ("Exportar
   relatório de vendas em CSV"), não de solução ("usar a lib X").
2. Proponha a **prioridade** e o **nível estimado** (1, 2, ou `?` se não der
   para saber), com uma linha de justificativa, e a **origem** (cliente, bug,
   ideia interna, pendência da feature NNN).
3. Com a confirmação, rode `sdd-backlog adicionar "título" --prioridade P --nivel N --origem "texto"`.
4. Se o usuário deu detalhes que não cabem no título, acrescente-os em linhas
   recuadas logo abaixo do item no `.sdd/backlog.md`.

### Priorizar

1. Rode `sdd-backlog listar` e leia os detalhes dos itens.
2. Comece pelos itens **sem nível** e **sem prioridade clara**. Para cada um,
   proponha prioridade e nível, com o porquê em uma linha, e pergunte.
   Ofereça também descartar o que não faz mais sentido.
3. Aplique com `sdd-backlog prioridade B-NNN alta|media|baixa`. Para mudar o
   nível, edite o campo `nivel:` da linha no `.sdd/backlog.md`.
4. Para reordenar dentro da mesma prioridade, mova as linhas no arquivo: dentro
   de uma prioridade, vale a ordem do arquivo.

Use a ferramenta de perguntas de múltipla escolha quando houver. No máximo
cinco itens por rodada.

## Não faça

- Não escreva spec aqui: isso é o `/sdd:especificar`.
- Não apague itens. Descarte com motivo, para o histórico ficar completo.

## Pronto quando

- O backlog reflete o que foi pedido, e cada item aberto tem prioridade e, de preferência, nível.
