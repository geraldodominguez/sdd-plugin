---
name: iniciar
description: Prepara o repositório para o SDD. Cria .sdd/ (configuração, backlog, sprints), specs/ e docs/adr/, rascunha a constituição a partir do código e injeta as regras no CLAUDE.md e no AGENTS.md. Rode uma vez por repositório.
argument-hint: "[--nivel 1|2] [--protecao desligada|leve|estrita]"
disable-model-invocation: true
allowed-tools: Bash(sdd-iniciar *), Bash(sdd-iniciar), Bash(sdd-status), Read, Glob, Grep, Edit, Write
---

# /sdd:iniciar

Argumentos: `$ARGUMENTS`

## Processo

1. **Veja o estado.** Se `.sdd/` já existe, rode `sdd-status`, mostre o
   resultado e pergunte se o usuário quer reaplicar. `sdd-iniciar --forcar`
   sobrescreve templates e config, mas **não** apaga specs. Sem confirmação,
   pare aqui.

2. **Escolha os parâmetros.** Se os argumentos não trazem nível e proteção,
   proponha um padrão e confirme numa única pergunta:

   | Projeto | Nível padrão | Proteção |
   |---|---|---|
   | A maioria | 1 | `leve` |
   | Crítico (domínio rico, dinheiro, dados pessoais) | 2 | `estrita` |

3. **Rode** `sdd-iniciar` com os parâmetros escolhidos.

4. **Rascunhe a constituição** em `.sdd/constituicao.md`.
   - **Projeto existente:** leia os manifestos (package.json, pyproject.toml,
     *.csproj, go.mod, Dockerfile, docker-compose, CI), a estrutura de pastas,
     a configuração de lint e de testes e um ou dois módulos representativos.
     Preencha **só o que observou**: stack e versões, camadas, convenções,
     comandos. O que não conseguir confirmar fica `{{a definir}}`. Não invente
     regra. Regra que o projeto já descumpre hoje vai para "Exceções aprovadas".
   - **Projeto novo:** mantenha os campos `{{...}}` e liste ao usuário as cinco
     decisões mais importantes (stack, arquitetura, política de testes,
     segurança, convenções).

5. **Ajuste `.sdd/config.yml`.** Preencha `comando_teste` e `comando_lint` se
   os descobriu, e adapte `globs_de_teste` à convenção real do projeto.

6. **Gate.** Mostre o que foi criado, o rascunho da constituição e o que ficou
   em aberto. Peça ao usuário que revise e aprove a constituição: ela vale para
   todas as features.

7. **Encerre** dizendo os próximos passos possíveis:

   | O usuário tem | Próximo |
   |---|---|
   | uma mudança para fazer agora | `/sdd:especificar <mudança>` |
   | uma lista de coisas para fazer | `/sdd:backlog adicionar` para cada uma, depois `/sdd:sprint planejar` |

## Não faça

- Não crie features nem specs.
- Não altere código do projeto.
- Não reescreva um `CLAUDE.md` existente: o `sdd-iniciar` só acrescenta ou
  atualiza o bloco entre `<!-- sdd:inicio -->` e `<!-- sdd:fim -->`.

## Pronto quando

- `.sdd/` (com `backlog.md` e `sprints/`), `specs/` e `docs/adr/` existem.
- A constituição tem só fatos observados ou campos marcados como a definir.
- `comando_teste` está preenchido ou o usuário sabe que precisa preencher.
- O usuário revisou a constituição.
