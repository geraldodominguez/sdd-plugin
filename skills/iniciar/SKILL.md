---
name: iniciar
description: Prepara o repositório para o SDD. Cria a pasta sdd/ (configuração, backlog, sprints, specs, sistema, adr), a pasta .claude/ com as subpastas que o Claude Code usa e, se faltar, o repositório git com tudo configurado, rascunha a constituição a partir do código e injeta as regras no CLAUDE.md e no AGENTS.md. Num projeto que não nasceu com o plugin, lê os artefatos de outros processos e agentes (specs, planos, tarefas, ADRs, backlog), os renomeia e converte para o padrão com a sua aprovação, e deixa cada feature em andamento numa transição que mostra como era e como fica, para o plugin continuar de onde o outro processo parou. Rode uma vez por repositório, e de novo com --adotar quando aparecerem artefatos fora do padrão.
argument-hint: "[--nivel 1|2] [--protecao desligada|leve|estrita] [--adotar] [--sem-git] [--sem-claude]"
disable-model-invocation: true
allowed-tools: Bash(git status), Bash(git status *), Bash(sdd-estado ver), Bash(sdd-estado definir feature=*), Bash(git symbolic-ref HEAD refs/heads/main), Bash(sdd-gitflow *), Bash(sdd-iniciar *), Bash(sdd-iniciar), Bash(sdd-status), Bash(sdd-status *), Bash(sdd-adotar *), Bash(git config user.name), Bash(git config user.email), Bash(git config user.name *), Bash(git config user.email *), Bash(git remote add *), Bash(gh auth status), Bash(gh repo view *), Bash(sdd-backlog adicionar *), Bash(sdd-pendencias), Bash(sdd-rastrear *), Bash(sdd-estado usar *), Bash(sdd-estado template *), Bash(sdd-estado definir nivel=*), Bash(sdd-estado definir capacidade=*), Bash(git ls-files *), Bash(git log *), Bash(rm sdd/adocao-mapa.txt), Read, Glob, Grep, Edit, Write, Bash(git tag *), Bash(git merge develop), Bash(git branch *)
---

# /sdd:iniciar

Argumentos: `$ARGUMENTS`

## Processo

1. **Veja o estado.** Rode `sdd-adotar inventario`. Ele funciona antes do
   `sdd/` existir e lista os artefatos de processo (specs, planos, tarefas,
   ADRs, backlog, sprints, arquitetura, regras) que estão fora do lugar do
   padrão.
   - **Sem `sdd/` e com inventário vazio:** projeto novo ou sem processo. Siga
     do passo 2. Se ele avisa que há uma `docs/` na raiz, ela também é adotada:
     faça só o passo 8 da **Adoção** (abaixo), depois da preparação.
   - **Sem `sdd/` e com inventário:** o projeto não nasceu com o plugin. Diga
     ao usuário quantos artefatos encontrou e de onde (`docs/specs/`, `.kiro/`,
     `TODO.md`...), avise que eles serão lidos e trazidos ao padrão depois da
     preparação, com a aprovação dele, e siga do passo 2.
   - **Com `sdd/`:** o projeto já usa o SDD. Não siga os passos 2 a 10 (eles
     são da preparação e reescreveriam a constituição e o config): vá para a
     **Atualização** (abaixo), que termina na Adoção se houver inventário ou
     `--adotar`.

2. **Pergunte antes de preparar.** Rode `sdd-adotar estrutura --so-verificar`:
   ele mostra, sem criar nada, o que o projeto já tem (`sdd/`, `.claude/`, o
   repositório git) e o que falta. Com a saída em mãos, faça as perguntas que
   se aplicam, todas de uma vez, e só siga com as respostas:
   - **Repositório git ausente** (`- repositório git (falta)`): "Este
     diretório não é um repositório git. Crio um, com a branch `main`,
     `.gitignore` e um commit inicial vazio?" Se a resposta for não, use
     `--sem-git` e diga que o Git Flow fica desligado (`gitflow: desligado`).
     Se for sim, **confirme a conta antes de criar** (os dois itens abaixo) e
     só então rode o `sdd-iniciar`.
   - **A conta do git** (sempre que o repositório vai ser criado, e quando a
     identidade falta): mostre a identidade que o commit vai usar
     (`git config user.name` e `git config user.email`, que podem vir da
     configuração global) e pergunte se é a conta certa para este projeto. Uma
     pessoa com conta pessoal e de trabalho erra aqui sem perceber. Se for
     outra, ou se faltar, peça os valores e grave **no repositório**, depois do
     `git init` (`git config user.name` e `git config user.email`, sem
     `--global`). Não invente nem copie de outro lugar.
   - **A conta da plataforma** (GitHub, GitLab): com o `gh` instalado, rode
     `gh auth status` e mostre em que conta ele está logado; pergunte se é
     nela (ou em qual organização) que o repositório remoto fica. Sem o `gh`,
     pergunte a conta e a URL.
   - **O repositório remoto já existe?** Pergunte o nome do repositório e
     confira se ele já existe na conta ou na organização escolhida
     (`gh repo view <dono>/<nome>`; sem o `gh`, pergunte). Se existe, pergunte
     se é para **ligar** este projeto a ele (`git remote add origin <url>`) ou
     **criar outro** com um nome diferente. Ao ligar num repositório que já tem
     histórico, avise que o `main` local e o remoto vão divergir e não faça
     push nem pull sem combinar com o usuário. Para criar, `gh repo create
     <dono>/<nome>` só depois de ele confirmar o nome, a visibilidade
     (pública ou privada) e o dono.
   - **O repositório é de uma pasta acima** (`! repositório git: o projeto
     está dentro do repositório ...`): confirme se é esse mesmo.
   - **Identidade do git ausente** (`? identidade do git`): é o caso da conta
     do git acima, sem nenhum valor para mostrar.
   - **Remoto ausente** (`? remoto`), num repositório que já existia: as mesmas
     perguntas da conta da plataforma e do repositório remoto. Sem resposta,
     deixe sem remoto e avise que publicar fica para depois.
   - **`.claude/` com arquivo seu** (`! .claude/settings.json ...`): mostre o
     que falta e pergunte se acrescenta as permissões de leitura dos
     utilitários `sdd-*`; o arquivo é do usuário e só muda com a aprovação dele.
   - **Pasta `sdd/` que não é do SDD**, ou `.sdd/` do layout antigo: o
     `sdd-iniciar` se recusa a seguir; explique e pergunte como o usuário quer
     resolver (mover a pasta existente, ou mudar o que é dele).
   - **Convenções do projeto** que você não consegue deduzir (nível, proteção,
     `integracao`, comandos de teste): pergunte no passo 3 e no passo 6, não
     chute.

3. **Escolha os parâmetros.** Se os argumentos não trazem nível e proteção,
   proponha um padrão e confirme numa única pergunta:

   | Projeto | Nível padrão | Proteção |
   |---|---|---|
   | A maioria | 1 | `leve` |
   | Crítico (domínio rico, dinheiro, dados pessoais) | 2 | `estrita` |

4. **Rode** `sdd-iniciar` com os parâmetros escolhidos. Em seguida, a base do
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
     ela (de qualquer branch, se não houver código pendente). Todo commit daqui
     em diante (a preparação do SDD, a adoção) é feito em `develop`.
   - **Repositório sem nenhum commit:** o `sdd-iniciar` já cria o commit
     inicial vazio em `main` (`chore: início`) quando a identidade do git está
     configurada. Se ele avisou `? identidade do git`, configure-a (pergunta
     do passo 2) e faça o commit: `git commit --allow-empty -m "chore: início"`.
     O `sdd-gitflow iniciar` recusa um repositório sem commit.

5. **Rascunhe a constituição** em `sdd/constituicao.md`.
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

6. **Ajuste `sdd/config.yml`.** Proponha `areas_sensiveis` (pastas de
   autenticação, pagamentos, dados pessoais, migrations) e confirme. Preencha
   `comando_teste`, `comando_lint` e, se der para descobrir, `comando_seguranca`
   e os de implantação, e adapte `globs_de_teste` à convenção real do projeto.

7. **Adoção.** Se o inventário do passo 1 não estava vazio, faça a **Adoção**
   (abaixo) agora, antes do gate.

8. **Git Flow: as branches de trabalho.** Com o Git Flow ativo, rode
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

9. **Gate.** Mostre o que foi criado, o rascunho da constituição, o resultado
   da adoção (se houve) e o que ficou em aberto. Peça ao usuário que revise e
   aprove a constituição: ela vale para todas as features. Com a aprovação,
   sugira o commit da preparação em `develop` (ou na branch atual, com o Git
   Flow desligado): `chore: sdd iniciado`. Se houve adoção, os commits dela já
   foram feitos no caminho.

10. **Encerre** dizendo os próximos passos possíveis:

   | O usuário tem | Próximo |
   |---|---|
   | features adotadas em transição | `/sdd:aprovar` em cada uma (aprova a transição e leva à fase de destino), depois o comando dessa fase |
   | uma mudança para fazer agora | `/sdd:especificar <mudança>` |
   | uma lista de coisas para fazer | `/sdd:backlog adicionar` para cada uma, depois `/sdd:sprint planejar` |
   | um sistema que já está em produção | `/sdd:sistema mapear` na área que mais muda, e `/sdd:pipeline` |

## Atualização

Para um projeto que já tem `sdd/`: traz o projeto para a versão instalada do
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

   Rode também `sdd-adotar estrutura`: ele confere `sdd/`, `.claude/` e o
   repositório git, e cria o que falta de `.claude/` e do git. Para cada linha
   `!` (fora do padrão, como um `.claude/settings.json` sem as permissões dos
   `sdd-*`) ou `?` (sem remoto, sem identidade do git), mostre e pergunte como
   seguir, como no passo 2 do Processo. Nunca altere um arquivo seu sem a
   aprovação dele.

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
   Acrescente cada chave ao `sdd/config.yml` com o comentário que ela tem no
   config do plugin (`sdd-estado template --plugin config.yml` dá o caminho).
   Não mude as chaves que já existem.

5. **Feature ativa.** Se `sdd-estado ver` mostra uma feature ativa, anote o
   id e desative-a (`sdd-estado definir feature=`): a atualização é do
   projeto, e o hook mandaria o commit dela para a branch da feature. No fim,
   ela volta (passo 8).

6. **Git Flow.** Com `gitflow: ativo`, faça a parte do Git Flow do passo 4 do
   Processo, menos a pergunta da `integracao` (já respondida): `sdd-gitflow
   conferir`, renomear `main` e `develop` com aprovação, a tag `vX.Y.Z` da
   versão em produção com aprovação, e `sdd-gitflow iniciar`, que muda para
   `develop` de qualquer branch (inclusive a de uma feature) e leva junto as
   alterações da atualização. Se ele recusar por código pendente, mostre ao
   usuário: o código precisa de um commit na branch dele (ou de um `git
   stash`) antes. Depois, o passo 8 do Processo
   (as branches de trabalho fora do padrão).

7. **Commit.** Mostre `git status` e sugira o commit em `develop` (ou na
   branch atual, com o Git Flow desligado):
   `chore: atualiza o SDD para a versão do plugin`.

8. **Adoção.** Se o `sdd-adotar inventario` do passo 1 do Processo não
   estava vazio, ou se veio `--adotar`, faça a **Adoção** (abaixo), já em
   `develop` e com o commit da atualização feito. Rode o inventário de novo
   em `develop`: se ele não acha mais os artefatos, eles estão commitados só
   na branch de onde você veio (a de uma feature). Diga isso ao usuário: a
   adoção deles acontece depois que essa branch entrar em `develop` (pela
   integração da feature), ou agora, se ele preferir trazer a branch com um
   merge em `develop`.

9. **Encerre** com o que mudou (bloco, `.gitattributes`, templates trocados,
   chaves acrescentadas, branches), o que ficou como estava e, se houver,
   features adotadas esperando o `/sdd:aprovar`. Se havia uma feature ativa no
   passo 5, o trabalho dela continua na branch dela: proponha
   `sdd-gitflow feature <NNN-slug>` e só então `sdd-estado usar <NNN-slug>`
   (em `develop`, a pasta de uma feature ainda não integrada não existe, e o
   `usar` recusa).

## Adoção

Traz para o padrão o que outro processo ou outro agente deixou fora do lugar.
É o único momento em que o agente move artefatos, e sempre pelo `sdd-adotar`,
com um mapa aprovado pelo usuário.

0. **Confira a estrutura.** Rode `sdd-adotar estrutura`. Ele verifica se o
   projeto já tem `sdd/`, `.claude/` (com `settings.json`, `agents/`,
   `skills/`, `commands/` e `rules/`) e o repositório git, cria o que falta
   de `.claude/` e do git, e aponta o que existe fora do padrão (`!`) ou
   depende de uma resposta (`?`). Resolva cada linha com o usuário antes de
   mover qualquer arquivo; os itens de `sdd/` que faltam são completados pelo
   `sdd-iniciar`.

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
   | material de entrada do projeto (documentação de API externa, levantamento ou ata de cliente, norma, glossário) | `docs:<caminho>` |
   | segundo arquivo de spec da mesma feature, duplicata, rascunho abandonado | `legado:...` (nunca apague) |
   | documento que não é de processo (manual, guia), mas tem nome de artefato | fica onde está; proponha o glob em `excecoes_de_layout` |

   Uma feature tem um único `spec.md`: escolha o arquivo principal e mande os
   demais para `legado:`, citando-os no gate.

3. **Escreva o mapa** em `sdd/adocao-mapa.txt`, uma linha por arquivo, no
   formato `origem -> destino`, com um comentário (`#`) acima de cada grupo
   dizendo por quê. Rode `sdd-adotar aplicar sdd/adocao-mapa.txt --simular` e
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
   original na conversão, então copie-o antes para `sdd/legado/<caminho original>`.
   Rode `sdd-adotar aplicar sdd/adocao-mapa.txt`. Ele renomeia cada arquivo
   para o padrão (com `git mv`), cria as features na situação de
   **transição** (`adocao=transicao`) e, em cada uma, o `transicao.md` a partir
   do modelo, com o "como era" dos arquivos já preenchido. Depois:
   - itens em aberto de backlog, roadmap e TODO: `sdd-backlog adicionar "título" --origem "adoção: <arquivo>"`, um por item, sem os já feitos;
   - regras de outro processo: incorpore à constituição (passo 5 do processo) o que for regra do projeto e ainda valer;
   - links: atualize os arquivos que o `aplicar` listou como citando o caminho antigo;
   - exceções aprovadas: preencha `excecoes_de_layout` no `sdd/config.yml`;
   - apague o mapa (`rm sdd/adocao-mapa.txt`): o registro fica em `sdd/adocao.md` e no histórico.

   Então, com nenhuma feature ativa, sugira o commit de tudo isso em `develop`
   (ou na branch atual, com o Git Flow desligado): `chore: adoção do SDD,
   arquivos no padrão`. Ele precisa vir antes da conversão: o `sdd-gitflow`
   não troca de branch com essas alterações pendentes, e a conversão de cada
   feature fica nos commits seguintes, na branch dela, com o diff mostrando
   exatamente o que mudou.

6. **Converta cada feature para o padrão** (passo seguinte), uma de cada vez,
   terminando cada uma com o commit dela antes de começar a próxima.

7. **Confira.** `sdd-adotar contar` deve dar 0. Mostre `sdd-pendencias`: cada
   feature adotada aparece esperando a aprovação da transição.

8. **Migre a `docs/` da raiz, por último.** Só depois de specs, planos,
   tarefas e ADRs estarem no lugar e commitados (o `sdd-adotar docs` recusa
   rodar antes: ele exige `contar` em 0). Tudo do SDD mora em `sdd/`, então a
   `docs/` do projeto vai para `sdd/docs/`.
   - Rode `sdd-adotar docs --simular` e mostre ao usuário a lista, com as
     colisões (um `README.md` vira `README-original.md`).
   - **Antes de pedir a aprovação, procure quem usa a `docs/` pelo caminho**,
     porque mover quebra isso: `mkdocs.yml` (`docs_dir`), Docusaurus, Sphinx
     (`conf.py`), GitHub Pages (`/docs` nas configurações do repositório),
     workflows de CI, `package.json`, `Makefile` e links do `README.md`
     (`Grep` por `docs/` nesses arquivos). Mostre o que achou e o que
     precisaria mudar.
   - Pergunte se pode migrar. Se o projeto publica a `docs/` (GitHub Pages, site
     de documentação) e o usuário não quer mexer na publicação, deixe a `docs/`
     onde está e diga que o SDD segue funcionando (o hook não confere a
     `docs/`); o material de entrada do SDD vai em `sdd/docs/`.
   - Com o "sim", rode `sdd-adotar docs`, atualize os links que ele listou, os
     arquivos de configuração achados e o `excecoes_de_layout` do
     `sdd/config.yml`, se citar `docs/`. Sugira o commit, em `develop`:
     `chore: docs/ da raiz para sdd/docs/`.
   - Projeto sem `docs/` na raiz: não há o que migrar, e o passo termina aqui.

## Conversão de uma feature adotada

Os arquivos já estão com o nome do padrão (`spec.md`, `plano.md`,
`tarefas.md`), mas com o conteúdo do outro processo. Converta cada um para o
modelo do SDD e registre no `transicao.md` como era e como ficou, para o
usuário aprovar a transição e o plugin continuar de onde o outro processo
parou.

1. **Vá para a branch da feature, antes de mudar qualquer arquivo dela.** Com
   o Git Flow, a conversão é commitada na branch da feature (o commit da
   adoção, no passo 5 da Adoção, precisa estar feito):
   - sem branch antiga: `sdd-gitflow feature NNN-slug`, que cria
     `feature/NNN-slug` a partir de `develop`;
   - se o código feito fora do plugin está numa branch antiga que ainda não
     entrou em `develop` (`feat/login`, por exemplo): com aprovação,
     `sdd-gitflow renomear feat/login feature/NNN-slug`,
     `sdd-gitflow feature NNN-slug` e, perguntando antes, `git merge develop`,
     para a branch receber os arquivos adotados.

   Já na branch, ative a feature: `sdd-estado usar NNN-slug`. Só então
   **acerte o nível e a capacidade.** A feature nasce com o
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
   feature e corrija as tarefas sem referência ou com ID inexistente. As
   lacunas de teste ("CA-XXX não tem teste com a marca") são esperadas até a
   fase red: não as corrija agora.

   Termine a feature com o commit da conversão, na branch dela:
   `docs(NNN): transição para o SDD`. Só depois passe à próxima feature: sem
   o commit, as alterações desta iriam junto para a branch da outra.

5. **Gate da transição.** Mostre ao usuário, para cada feature: a fase de
   destino com a evidência, o "como era" e o "como vai ficar" lado a lado,
   quantas tarefas ficam `[O]` e quantas `[ ]`, e o que ficou de fora. Ele
   aprova com `/sdd:aprovar` (feature ativa: `sdd-estado usar NNN-slug`), que
   registra a transição e os artefatos convertidos, com hash, e leva a feature
   à fase de destino. Você não aprova nada.

## Não faça

- Não crie features nem specs, a não ser as features que a adoção aprovada cria.
- Não altere código do projeto.
- Não crie o repositório sem confirmar a conta (a identidade do git e a conta
  da plataforma). Não invente a identidade, a URL do remoto nem o nome de um
  repositório novo: pergunte. Se o repositório remoto já existe, não escolha
  entre ligar e criar outro: pergunte. Criar um repositório na plataforma (`gh repo create`) é
  decisão do usuário e pede a confirmação dele no momento.
- Não altere um `.claude/settings.json` que já existe sem a aprovação do
  usuário: mostre o que falta e pergunte.
- Numa atualização, não reescreva a constituição, não mude chaves do config
  que já existem e não rode `sdd-iniciar --forcar` sem o usuário pedir.
- Não reescreva um `CLAUDE.md` existente: o `sdd-iniciar` só acrescenta ou
  atualiza o bloco entre `<!-- sdd:inicio -->` e `<!-- sdd:fim -->`.
- Na adoção, não mova nem apague arquivos por conta própria (`mv`, `git mv`,
  `rm`, Write em outro lugar): só o `sdd-adotar aplicar` e o `sdd-adotar docs`, com o mapa aprovado.
- Na conversão, não invente requisito, critério ou tarefa que o original não
  tem, e não apague nada do original sem dizer para onde foi ("O que ficou de
  fora").
- Não marque `[O]` sem evidência no código, nem `[x]` em tarefa de fora.
- Não aprove a transição nem mude a fase da feature adotada: só o usuário,
  pelo `/sdd:aprovar`.

## Pronto quando

- `sdd/` (com `backlog.md`, `sprints/`, `specs/`, `sistema/` e `adr/`) existe e é a única pasta do SDD na raiz.
- `.claude/` tem `settings.json` e as pastas `agents/`, `skills/`, `commands/` e `rules/`.
- O projeto é um repositório git, com `main`, `.gitignore` e commit inicial, e o usuário decidiu o remoto.
- A constituição tem só fatos observados ou campos marcados como a definir.
- `comando_teste` está preenchido ou o usuário sabe que precisa preencher.
- `sdd-adotar contar` dá 0, ou o usuário decidiu deixar a adoção para depois.
- Cada feature adotada tem o `transicao.md` sem lacunas, à espera do `/sdd:aprovar`.
- A `docs/` da raiz foi migrada para `sdd/docs/` (por último), ou o usuário decidiu deixá-la onde está.
- O usuário revisou a constituição.
- Com o Git Flow ativo, `sdd-gitflow conferir` não aponta problemas (ou o usuário decidiu o que fazer com cada branch fora do padrão), e o trabalho está em `develop`.
