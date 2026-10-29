# O layout é contrato, e projetos alheios são adotados por um mapa aprovado

## Decisão

- Cada artefato de processo tem um único lugar: `specs/NNN-slug/` (com `estado`), `docs/adr/NNNN-slug.md`, `.sdd/`, `sistema/`, `releases/`, `incidentes/`, `docs/arquitetura/` e `docs/legado/`. Um classificador único em `lib/sdd-comum.sh` (`sdd_fora_do_layout`) decide o que é artefato e se está no lugar, e é usado pelo hook, pelo `sdd-adotar` e pelo `sdd-verificar`.
- O hook `guarda-edicoes` bloqueia **criar** com o `Write` um artefato fora do lugar, nas proteções leve e estrita. Editar ou reescrever um arquivo que já existe continua livre.
- O `/sdd:iniciar` detecta um projeto que não nasceu com o plugin (`sdd-adotar inventario`, que funciona sem `.sdd/`) e faz a adoção: o agente lê tudo, escreve um mapa `origem -> destino`, o usuário aprova, e o `sdd-adotar aplicar` move. Numeração de features e ADRs é do utilitário, não do agente.
- A adoção renomeia para o padrão e nunca apaga. O que não entra no fluxo vai para `docs/legado/`.
- Cada feature adotada nasce na situação de **transição** (`adocao=transicao`), sem aprovação, com um `transicao.md` feito do modelo: o "como era" (caminho e hash de cada original) vem do utilitário, e o "como vai ficar" (requisitos e tarefas, linha a linha) vem da conversão que o agente faz para os modelos do SDD. Uma única aprovação do usuário registra a transição e os artefatos que a fase de destino pressupõe, cada um com hash, e a feature continua de onde parou.
- Tarefa feita fora do plugin fica `[O]`, distinta da `[x]` (feita no plugin). Ela não se refaz, mas os critérios dela ganham testes na fase red, que devem passar de início.
- `excecoes_de_layout` no config libera documentos que têm nome de artefato, mas não são do SDD.

## Por quê

- Sem um lugar fixo, cada agente inventa uma estrutura (`docs/specs/`, `tasks/`, `PLAN.md`, `.kiro/`), e a verdade se espalha por lugares que ninguém revisa. Instrução no `CLAUDE.md` reduz o problema, mas não o elimina; o hook, sim, no caso mais comum.
- Bloquear só arquivos novos mantém o hook fail-open de verdade (ver [ADR 0003](0003-hooks-fail-open.md)): ele nunca trava o trabalho sobre o que já existe, que é assunto da adoção.
- Classificar o que um documento antigo é exige ler e julgar; mover, numerar e registrar exige determinismo. Por isso o agente propõe o mapa e o utilitário o executa, conferindo o mapa inteiro antes do primeiro movimento.
- Uma spec de outro processo nunca foi aprovada dentro do SDD. Entrar já aprovada seria forjar um gate; refazer todos os gates de uma feature pela metade seria repetir trabalho que já existe. A transição é um gate só, humano e registrado, que mostra o antes e o depois.
- A marca `[O]` mantém visível o que entrou sem gate. Os testes da fase red verificam esse trabalho em vez de confiar nele.

## Consequências

- `docs/arquitetura/` guarda documentos e diagramas de arquitetura (C4, por exemplo) como referência. O plugin não os mantém nem os atualiza a cada feature: um mapa global mantido pelo processo segue fora do escopo ([mapa-global-do-sistema](../../.fora-do-escopo/mapa-global-do-sistema.md)).
- `adocao` é uma chave nova em `specs/NNN/estado`, e `[O]` é um estado novo da linha de tarefa: os dois entram no contrato público.
- Quem cria artefato pelo shell escapa do hook. O `sdd-verificar` avisa na CI e o `sdd-pendencias` lista em "Fora do padrão".
- O classificador olha nome e pasta, não conteúdo: um documento de processo com nome incomum só entra na adoção se o agente o achar na leitura, e um manual chamado `tasks.md` precisa de uma exceção.
