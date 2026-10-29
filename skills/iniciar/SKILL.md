---
name: iniciar
description: Prepara o repositório para o SDD. Cria .sdd/ (configuração, backlog, sprints), specs/ e docs/adr/, rascunha a constituição a partir do código e injeta as regras no CLAUDE.md e no AGENTS.md. Num projeto que não nasceu com o plugin, lê os artefatos de outros processos e agentes (specs, planos, tarefas, ADRs, backlog), os renomeia e converte para o padrão com a sua aprovação, e deixa cada feature em andamento numa transição que mostra como era e como fica, para o plugin continuar de onde o outro processo parou. Rode uma vez por repositório, e de novo com --adotar quando aparecerem artefatos fora do padrão.
argument-hint: "[--nivel 1|2] [--protecao desligada|leve|estrita] [--adotar]"
disable-model-invocation: true
allowed-tools: Bash(git status), Bash(sdd-gitflow *), Bash(sdd-iniciar *), Bash(sdd-iniciar), Bash(sdd-status), Bash(sdd-status *), Bash(sdd-adotar *), Bash(sdd-backlog adicionar *), Bash(sdd-pendencias), Bash(sdd-rastrear *), Bash(sdd-estado usar *), Bash(sdd-estado template *), Bash(sdd-estado definir nivel=*), Bash(sdd-estado definir capacidade=*), Bash(git ls-files *), Bash(git log *), Bash(rm .sdd/adocao-mapa.txt), Read, Glob, Grep, Edit, Write, Bash(git tag *), Bash(git merge develop), Bash(git branch *)
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
   - **Com `.sdd/`:** o projeto já usa o SDD. Não siga os passos 2 a 9 (eles
     são da preparação e reescreveriam a constituição e o config): vá para a
     **Atualização** (abaixo), que termina na Adoção se houver inventário ou
     `--adotar`.

2. **Escolha os parâmetros.** Se os argumentos não trazem nível e proteção,
   proponha um padrão e confirme numa única pergunta:

   | Projeto | Nível padrão | Proteção |
   |---|---|---|
   | A maioria | 1 | `leve` |
   | Crítico (domínio rico, dinheiro, dados pessoais) | 2 | `estrita` |

3. **Rode** `sdd-iniciar` com os parâmetros escolhidos. Em seguida, a base do
   **Git Flow** (ver `GIT-FLOW.md` da skill metodologia), antes de qualquer
   commit, porque o hook não deixa commitar em `main`:
   - Pergunte como as branches se juntam e grave `integracao` no config:
     `local` (o plugin faz o merge e a tag; bom para quem trabalha sozinho) ou
     `pr` (pull request na plataforma; bom para time). Se o usuário não quer
     Git Flow neste projeto, grave `gitflow: desligado` e pule o resto.
   - Rode `sdd-gitflow conferir`. Se a produção não se chama `main`
     (`master`, `production`) ou a integração não se chama `develop`
     (`development`, `dev`), proponha a troca e, com aprovação, rode
     `sdd-gitflow renomear <antiga> main` (ou `develop`). Mostre os comandos do
     remoto que ele imprime; não os rode sem pedir.
   - **Versões.** Se o projeto já tem versões publicadas, a última precisa de
     uma tag `vX.Y.Z` em `main`: é dela que o `sdd-release` calcula a próxima
     (ver `VERSIONAMENTO.md` da skill metodologia). Tags em outro formato
     (`1.4.2`, `release-1.4.2`) aparecem no `sdd-gitflow conferir`; proponha a
     tag `v1.4.2` no mesmo commit (`git tag -a v1.4.2 <commit> -m "versão 1.4.2"`)
     e crie só com aprovação. Os commits anteriores à adoção podem não seguir
     o Conventional Commits: eles ficam antes da tag e não contam.
   - Rode `sdd-gitflow iniciar`: ele garante `main`, cria `develop` e muda para
     ela. Todo commit daqui em diante (a preparação do SDD, a adoção) é feito
     em `develop`. Repositório sem nenhum commit: peça o primeiro commit em
     `main` antes.

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

7. **Git Flow: as branches de trabalho.** Com o Git Flow ativo, rode
   `sdd-gitflow conferir` de novo. Para cada branch fora do padrão que sobrou,
   proponha o nome novo numa tabela e peça aprovação (é o usuário quem decide):

   | Branch antiga | Nome do padrão |
   |---|---|
   | branch de uma feature adotada ou em andamento (`feat/login`, `feature-login`) | `feature/NNN-slug` da feature (a feature já existe, depois da adoção) |
   | release antiga ainda aberta (`release-1.2`) | `release/1.2.0` |
   | branch sem feature correspondente | pergunte: criar a feature, juntar a outra, ou deixar como está até ser apagada |

   Aplique com `sdd-gitflow renomear <antiga> <nova>`, uma por vez. Ele só
   renomeia localmente; mostre os comandos do remoto que ele imprime e não os
   rode sem pedir. Avise que, na plataforma (GitHub, GitLab), `main` e
   `develop` devem ser protegidas: só por pull request, com o CI obrigatório
   (o `/sdd:pipeline` ajuda).

8. **Gate.** Mostre o que foi criado, o rascunho da constituição, o resultado
   da adoção (se houve) e o que ficou em aberto. Peça ao usuário que revise e
   aprove a constituição: ela vale para todas as features.

9. **Encerre** dizendo os próximos passos possíveis:

   | O usuário tem | Próximo |
   |---|---|
   | features adotadas em transição | `/sdd:aprovar` em cada uma (aprova a transição e leva à fase de destino), depois o comando dessa fase |
   | uma mudança para fazer agora | `/sdd:especificar <mudança>` |
   | uma lista de coisas para fazer | `/sdd:backlog adicionar` para cada uma, depois `/sdd:sprint planejar` |
   | um sistema que já está em produção | `/sdd:sistema mapear` na área que mais muda, e `/sdd:pipeline` |

## Atualização

Para um projeto que já tem `.sdd/`: traz o projeto para a versão instalada do
plugin sem tocar no que é do time. A constituição, o config já preenchido, as
specs e os históricos ficam como estão.

1. **Mostre e confirme.** Rode `sdd-status` e mostre. Diga o que a atualização
   faz (os passos abaixo) e pergunte se pode seguir. Sem confirmação, pare.

2. **Rode `sdd-iniciar`, sem `--forcar` e sem `--nivel` ou `--protecao`.** Ele
   cria só o que falta (um template novo, por exemplo), atualiza o bloco de
   regras no `CLAUDE.md` e no `AGENTS.md`, acrescenta o `.gitattributes` e
   mantém o resto. Mostre a saída. Nunca use `--forcar` aqui: ele sobrescreve
   config, constituição e templates, e só vale se o usuário pedir, com essas
   palavras, para recomeçar a configuração.

3. **Templates diferentes (`~` na saída).** O projeto pode tê-los
   customizado, ou eles podem só estar desatualizados. Para cada um, leia a
   cópia do projeto e a do plugin (`sdd-estado template --plugin <nome>` dá o
   caminho; para os da release, `release/<nome>`) e mostre a diferença em
   poucas linhas. Pergunte, um por um: trocar pelo do plugin, ou manter. Com
   "trocar", escreva o conteúdo do plugin na cópia do projeto.

4. **Chaves novas do config (`?` na saída).** Enquanto faltam, vale o padrão
   mostrado; o hook já age por ele. Para cada uma, explique em uma linha e
   pergunte o valor:
   - `gitflow`: `ativo` (o plugin cria e confere as branches; o hook bloqueia
     commit em `main` e em branch fora do padrão) ou `desligado` (como antes);
   - `integracao`: `local` (o plugin faz os merges) ou `pr` (pull request na
     plataforma);
   - `commits`: `convencional` (Conventional Commits; a versão sai deles) ou
     `livre` (como antes);
   - as demais: o padrão mostrado, a não ser que o usuário queira outro.
   Acrescente cada chave ao `.sdd/config.yml` com o comentário que ela tem no
   config do plugin (`sdd-estado template --plugin config.yml` dá o caminho).
   Não mude as chaves que já existem.

5. **Git Flow.** Com `gitflow: ativo`, faça a parte do Git Flow do passo 3 do
   Processo, menos a pergunta da `integracao` (já respondida): `sdd-gitflow
   conferir`, renomear `main` e `develop` com aprovação, a tag `vX.Y.Z` da
   versão em produção com aprovação, e `sdd-gitflow iniciar`. As alterações
   da atualização vão junto para `develop`. Depois, o passo 7 do Processo
   (as branches de trabalho fora do padrão).

6. **Adoção.** Se o `sdd-adotar inventario` do passo 1 do Processo não
   estava vazio, ou se veio `--adotar`, faça a **Adoção** (abaixo).

7. **Commit.** Mostre `git status` e sugira o commit em `develop` (ou na
   branch atual, com o Git Flow desligado):
   `chore: atualiza o SDD para a versão do plugin`.

8. **Encerre** com o que mudou (bloco, `.gitattributes`, templates trocados,
   chaves acrescentadas, branches), o que ficou como estava e, se houver,
   features adotadas esperando o `/sdd:aprovar`.

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
   (nascem em transição); o que fica onde está e as exceções propostas; e as
   suas dúvidas de classificação, com uma recomendação. Pergunte se pode
   aplicar. Sem aprovação explícita, pare aqui. Se ninguém está acompanhando a
   sessão, não aplique: deixe o mapa e a simulação prontos e encerre dizendo
   isso.

5. **Aplique.** Antes, rode `git ls-files` nas origens que vão para features:
   o "como era" de cada arquivo fica no git. Arquivo fora do git perde o
   original na conversão, então copie-o antes para `docs/legado/<caminho original>`.
   Rode `sdd-adotar aplicar .sdd/adocao-mapa.txt`. Ele renomeia cada arquivo
   para o padrão (com `git mv`), cria as features na situação de
   **transição** (`adocao=transicao`) e, em cada uma, o `transicao.md` a partir
   do modelo, com o "como era" dos arquivos já preenchido. Sugira um commit
   agora, em `develop` (`chore: adoção do SDD, arquivos no padrão`), para que a conversão fique num commit
   separado e o diff mostre exatamente o que mudou. Depois:
   - itens em aberto de backlog, roadmap e TODO: `sdd-backlog adicionar "título" --origem "adoção: <arquivo>"`, um por item, sem os já feitos;
   - regras de outro processo: incorpore à constituição (passo 4 do processo) o que for regra do projeto e ainda valer;
   - links: atualize os arquivos que o `aplicar` listou como citando o caminho antigo;
   - exceções aprovadas: preencha `excecoes_de_layout` no `.sdd/config.yml`;
   - apague o mapa (`rm .sdd/adocao-mapa.txt`): o registro fica em `.sdd/adocao.md` e no histórico.

6. **Converta cada feature para o padrão** (passo seguinte), uma de cada vez.

7. **Confira.** `sdd-adotar contar` deve dar 0. Mostre `sdd-pendencias`: cada
   feature adotada aparece esperando a aprovação da transição.

## Conversão de uma feature adotada

Os arquivos já estão com o nome do padrão (`spec.md`, `plano.md`,
`tarefas.md`), mas com o conteúdo do outro processo. Converta cada um para o
modelo do SDD e registre no `transicao.md` como era e como ficou, para o
usuário aprovar a transição e o plugin continuar de onde o outro processo
parou.

1. **Vá para a branch da feature, antes de mudar qualquer arquivo dela.**
   `sdd-estado usar NNN-slug`. Com o Git Flow, a conversão é commitada na
   branch da feature:
   - sem branch antiga: `sdd-gitflow feature NNN-slug`, que cria
     `feature/NNN-slug` a partir de `develop`;
   - se o código feito fora do plugin está numa branch antiga que ainda não
     entrou em `develop` (`feat/login`, por exemplo): com aprovação,
     `sdd-gitflow renomear feat/login feature/NNN-slug`,
     `sdd-gitflow feature NNN-slug` e, perguntando antes, `git merge develop`,
     para a branch receber os arquivos adotados.

   Só então **acerte o nível e a capacidade.** A feature nasce com o
   `nivel_padrao`; se ela mexe em domínio, schema, contrato público ou
   segurança, proponha o nível 2 e, com a confirmação do usuário, rode
   `sdd-estado definir nivel=2`. Defina a capacidade da spec do sistema com
   `sdd-estado definir capacidade=<nome>`.

2. **Descubra onde a feature parou.** Para cada tarefa do original, procure no
   código a evidência de que foi feita (`Grep` pelos nomes, caminho:linha). A
   caixa marcada no original não basta: sem evidência, a tarefa conta como
   aberta. Escolha a **fase de destino**:

   | A feature tem | Destino |
   |---|---|
   | só uma ideia, ou requisitos com dúvidas que mudam o escopo | `especificacao` |
   | spec clara, nível 2, sem plano técnico | `plano` |
   | spec clara (e plano, no nível 2), sem tarefas | `tarefas` |
   | spec, tarefas (e plano, no nível 2), algumas feitas ou nenhuma | `red` |

   No nível 2, o plano convertido precisa cumprir o modelo (contratos,
   ameaças, implantação). Se o original não tem isso, o destino é `plano`.

3. **Converta, na ordem do destino**, usando os modelos (`sdd-estado template
   <nome>` dá o caminho):
   - **`spec.md`**: reescreva no modelo da spec (leve no nível 1, completa no
     nível 2). Cada requisito do original vira um `RF`/`RNF` em EARS, e cada
     condição verificável vira um `CA` em Dado, Quando, Então. O que for
     ambíguo vira `[PRECISA ESCLARECER]` (aí o destino é `especificacao`).
     Não invente requisito que o original não tem.
   - **`plano.md`**: reescreva no modelo do plano, mantendo as decisões do
     original e ligando cada uma a um requisito.
   - **`tarefas.md`**: reescreva no modelo das tarefas. Cada tarefa do
     original vira uma linha `T-NNN` com `atende:` e `depende de:`. As feitas
     fora do plugin (com evidência) ficam **`- [O] T-NNN`**; as abertas, ou
     sem evidência, ficam **`- [ ] T-NNN`**, e é por elas que o plugin
     continua. Nunca marque `[x]`: essa marca é do trabalho feito no plugin.
     Tarefa do original que não cabe em nenhum requisito vai para "O que
     ficou de fora" e, se ainda valer, para o backlog.
   - **testes existentes**: procure os testes que já cobrem os CAs das
     tarefas `[O]` e liste-os em "Testes que já existiam". Não os edite agora:
     a marca é acrescentada na fase red.

4. **Preencha o `transicao.md`**, sem deixar nenhum `{{...}}`: a fase de
   destino e o porquê, a situação encontrada (com caminho:linha), e as tabelas
   de **como era** e **como vai ficar** dos requisitos e das tarefas, linha a
   linha, com o texto original ao lado do ID novo. Rode `sdd-rastrear` na
   feature e corrija as tarefas sem referência ou com ID inexistente.

5. **Gate da transição.** Mostre ao usuário, para cada feature: a fase de
   destino com a evidência, o "como era" e o "como vai ficar" lado a lado,
   quantas tarefas ficam `[O]` e quantas `[ ]`, e o que ficou de fora. Ele
   aprova com `/sdd:aprovar` (feature ativa: `sdd-estado usar NNN-slug`), que
   registra a transição e os artefatos convertidos, com hash, e leva a feature
   à fase de destino. Você não aprova nada.

## Não faça

- Não crie features nem specs, a não ser as features que a adoção aprovada cria.
- Não altere código do projeto.
- Numa atualização, não reescreva a constituição, não mude chaves do config
  que já existem e não rode `sdd-iniciar --forcar` sem o usuário pedir.
- Não reescreva um `CLAUDE.md` existente: o `sdd-iniciar` só acrescenta ou
  atualiza o bloco entre `<!-- sdd:inicio -->` e `<!-- sdd:fim -->`.
- Na adoção, não mova nem apague arquivos por conta própria (`mv`, `git mv`,
  `rm`, Write em outro lugar): só o `sdd-adotar aplicar`, com o mapa aprovado.
- Na conversão, não invente requisito, critério ou tarefa que o original não
  tem, e não apague nada do original sem dizer para onde foi ("O que ficou de
  fora").
- Não marque `[O]` sem evidência no código, nem `[x]` em tarefa de fora.
- Não aprove a transição nem mude a fase da feature adotada: só o usuário,
  pelo `/sdd:aprovar`.

## Pronto quando

- `.sdd/` (com `backlog.md` e `sprints/`), `specs/` e `docs/adr/` existem.
- A constituição tem só fatos observados ou campos marcados como a definir.
- `comando_teste` está preenchido ou o usuário sabe que precisa preencher.
- `sdd-adotar contar` dá 0, ou o usuário decidiu deixar a adoção para depois.
- Cada feature adotada tem o `transicao.md` sem lacunas, à espera do `/sdd:aprovar`.
- O usuário revisou a constituição.
- Com o Git Flow ativo, `sdd-gitflow conferir` não aponta problemas (ou o usuário decidiu o que fazer com cada branch fora do padrão), e o trabalho está em `develop`.
