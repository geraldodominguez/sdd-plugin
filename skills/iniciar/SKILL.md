---
name: iniciar
description: Prepara o repositório para o SDD. Cria .sdd/ (configuração, backlog, sprints), specs/ e docs/adr/, rascunha a constituição a partir do código e injeta as regras no CLAUDE.md e no AGENTS.md. Num projeto que não nasceu com o plugin, lê os artefatos de outros processos e agentes (specs, planos, tarefas, ADRs, backlog) e, com a sua aprovação, os traz para o padrão. Rode uma vez por repositório, e de novo com --adotar quando aparecerem artefatos fora do padrão.
argument-hint: "[--nivel 1|2] [--protecao desligada|leve|estrita] [--adotar]"
disable-model-invocation: true
allowed-tools: Bash(sdd-iniciar *), Bash(sdd-iniciar), Bash(sdd-status), Bash(sdd-adotar *), Bash(sdd-backlog adicionar *), Bash(sdd-pendencias), Bash(rm .sdd/adocao-mapa.txt), Read, Glob, Grep, Edit, Write
---

# /sdd:iniciar

Argumentos: `$ARGUMENTS`

## Processo

1. **Veja o estado.** Rode `sdd-adotar inventario`. Ele funciona antes do
   `.sdd/` existir e lista os artefatos de processo (specs, planos, tarefas,
   ADRs, backlog, sprints, arquitetura, regras) que estão fora do lugar do
   padrão.
   - **Sem `.sdd/` e com inventário vazio:** projeto novo ou sem processo. Siga
     do passo 2.
   - **Sem `.sdd/` e com inventário:** o projeto não nasceu com o plugin. Diga
     ao usuário quantos artefatos encontrou e de onde (`docs/specs/`, `.kiro/`,
     `TODO.md`...), avise que eles serão lidos e trazidos ao padrão depois da
     preparação, com a aprovação dele, e siga do passo 2.
   - **Com `.sdd/`:** rode `sdd-status` e mostre. Se há inventário, ou se veio
     `--adotar`, pule para a **Adoção** (abaixo): não reaplique nada. Senão,
     pergunte se o usuário quer reaplicar; `sdd-iniciar --forcar` sobrescreve
     templates e config, mas **não** apaga specs. Sem confirmação, pare aqui.

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
     comandos, ambientes e como se implanta hoje (CI, Dockerfile, scripts de
     deploy). O que não conseguir confirmar fica `{{a definir}}`. Não invente
     regra. Regra que o projeto já descumpre hoje vai para "Exceções aprovadas".
   - **Projeto novo:** mantenha os campos `{{...}}` e liste ao usuário as cinco
     decisões mais importantes (stack, arquitetura, política de testes,
     segurança, ambientes e entrega).

5. **Ajuste `.sdd/config.yml`.** Proponha `areas_sensiveis` (pastas de
   autenticação, pagamentos, dados pessoais, migrations) e confirme. Preencha
   `comando_teste`, `comando_lint` e, se der para descobrir, `comando_seguranca`
   e os de implantação, e adapte `globs_de_teste` à convenção real do projeto.

6. **Adoção.** Se o inventário do passo 1 não estava vazio, faça a **Adoção**
   (abaixo) agora, antes do gate.

7. **Gate.** Mostre o que foi criado, o rascunho da constituição, o resultado
   da adoção (se houve) e o que ficou em aberto. Peça ao usuário que revise e
   aprove a constituição: ela vale para todas as features.

8. **Encerre** dizendo os próximos passos possíveis:

   | O usuário tem | Próximo |
   |---|---|
   | features adotadas na fase especificacao | `/sdd:clarificar` em cada uma, depois `/sdd:aprovar` |
   | uma mudança para fazer agora | `/sdd:especificar <mudança>` |
   | uma lista de coisas para fazer | `/sdd:backlog adicionar` para cada uma, depois `/sdd:sprint planejar` |
   | um sistema que já está em produção | `/sdd:sistema mapear` na área que mais muda, e `/sdd:pipeline` |

## Adoção

Traz para o padrão o que outro processo ou outro agente deixou fora do lugar.
É o único momento em que o agente move artefatos, e sempre pelo `sdd-adotar`,
com um mapa aprovado pelo usuário.

1. **Leia tudo.** Leia **por inteiro** cada arquivo do inventário. Quando ele
   vier de uma pasta de outra ferramenta (`.specify/`, `.kiro/`, `openspec/`,
   `.taskmaster/`), leia a pasta inteira, inclusive o que não é markdown, para
   entender como as peças se ligam. O inventário reconhece pelo nome e pela
   pasta: passe os olhos também em `docs/` e na raiz atrás de documentos de
   processo com nomes incomuns (requisitos numa ata, um plano em `notas.md`) e
   inclua-os no mapa. Com muitos arquivos, leia em lotes por pasta, anotando
   cada um. Não pule nenhum.

2. **Classifique e agrupe.** Arquivos que descrevem a mesma mudança formam uma
   feature e recebem o mesmo slug. Para decidir se algo já foi implementado,
   olhe o código (`Grep` pelos nomes do domínio) e as caixas marcadas nas
   tarefas, não só o texto. Cada arquivo recebe um destino:

   | O arquivo é | Destino no mapa |
   |---|---|
   | spec, PRD ou requisitos de algo ainda não implementado, ou em andamento | `feature:<slug>/spec.md` |
   | plano ou design técnico dessa mesma mudança | `feature:<slug>/plano.md` |
   | tarefas dessa mesma mudança | `feature:<slug>/tarefas.md` |
   | spec de algo já implementado | `legado:specs/<nome>.md` (não especifique o passado; a capacidade se mapeia com `/sdd:sistema mapear` quando for mudar) |
   | decisão de arquitetura | `adr:<slug>` |
   | backlog, roadmap, TODO solto | `legado:<nome>.md`; os itens em aberto viram `sdd-backlog adicionar` depois |
   | sprint de outro processo | `legado:sprints/<nome>.md` (a sprint do SDD se replaneja com `/sdd:sprint planejar`) |
   | regras, convenções, constituição de outro processo | `legado:<nome>.md`; o conteúdo alimenta a constituição |
   | arquitetura, diagramas, C4 | `arquitetura:<nome>` |
   | segundo arquivo de spec da mesma feature, duplicata, rascunho abandonado | `legado:...` (nunca apague) |
   | documento que não é de processo (manual, guia), mas tem nome de artefato | fica onde está; proponha o glob em `excecoes_de_layout` |

   Uma feature tem um único `spec.md`: escolha o arquivo principal e mande os
   demais para `legado:`, citando-os no gate.

3. **Escreva o mapa** em `.sdd/adocao-mapa.txt`, uma linha por arquivo, no
   formato `origem -> destino`, com um comentário (`#`) acima de cada grupo
   dizendo por quê. Rode `sdd-adotar aplicar .sdd/adocao-mapa.txt --simular` e
   corrija o mapa até a simulação passar.

4. **Gate da adoção.** Mostre ao usuário, agrupado por destino: cada origem, o
   destino resolvido pela simulação e o motivo em uma linha; as features novas
   (nascem na fase `especificacao`, sem aprovação); o que fica onde está e as
   exceções propostas; e as suas dúvidas de classificação, com uma
   recomendação. Pergunte se pode aplicar. Sem aprovação explícita, pare aqui.
   Se ninguém está acompanhando a sessão, não aplique: deixe o mapa e a
   simulação prontos e encerre dizendo isso.

5. **Aplique.** Rode `sdd-adotar aplicar .sdd/adocao-mapa.txt`. Depois:
   - itens em aberto de backlog, roadmap e TODO: `sdd-backlog adicionar "título" --origem "adoção: <arquivo>"`, um por item, sem os já feitos;
   - regras de outro processo: incorpore à constituição (passo 4 do processo) o que for regra do projeto e ainda valer;
   - links: atualize os arquivos que o `aplicar` listou como citando o caminho antigo;
   - exceções aprovadas: preencha `excecoes_de_layout` no `.sdd/config.yml`;
   - apague o mapa (`rm .sdd/adocao-mapa.txt`): o registro fica em `.sdd/adocao.md` e no histórico.

6. **Confira.** `sdd-adotar contar` deve dar 0. Mostre `sdd-pendencias`.

## Não faça

- Não crie features nem specs, a não ser as features que a adoção aprovada cria.
- Não altere código do projeto.
- Não reescreva um `CLAUDE.md` existente: o `sdd-iniciar` só acrescenta ou
  atualiza o bloco entre `<!-- sdd:inicio -->` e `<!-- sdd:fim -->`.
- Na adoção, não mova nem apague arquivos por conta própria (`mv`, `git mv`,
  `rm`, Write em outro lugar): só o `sdd-adotar aplicar`, com o mapa aprovado.
- Não reescreva o conteúdo dos arquivos adotados. Eles chegam como estavam; a
  revisão vem no fluxo normal (`/sdd:clarificar`, `/sdd:aprovar`).
- Não registre aprovação de nenhuma feature adotada.

## Pronto quando

- `.sdd/` (com `backlog.md` e `sprints/`), `specs/` e `docs/adr/` existem.
- A constituição tem só fatos observados ou campos marcados como a definir.
- `comando_teste` está preenchido ou o usuário sabe que precisa preencher.
- `sdd-adotar contar` dá 0, ou o usuário decidiu deixar a adoção para depois.
- O usuário revisou a constituição.
