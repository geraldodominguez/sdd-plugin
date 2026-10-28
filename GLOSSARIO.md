# SDD: glossário

Um plugin de Specification-Driven Development para agentes de código. As
especificações versionadas são a fonte de verdade, e o código é derivado delas.

## Linguagem

**Fonte de verdade**:
A spec versionada da feature. Numa divergência, ela prevalece até ser alterada formalmente.
_Evite_: documentação (sugere algo secundário, escrito depois)

**Constituição**:
As regras inegociáveis de um projeto (stack, arquitetura, testes, segurança, convenções), em `.sdd/constituicao.md`. Todo **plano** é checado contra ela.
_Evite_: guia de estilo, padrões

**Layout**:
Os lugares fixos de cada artefato de processo: `specs/NNN-slug/`, `docs/adr/NNNN-slug.md`, `.sdd/`, `sistema/`, `releases/`, `incidentes/`, `docs/arquitetura/` e `docs/legado/`. Um contrato: o hook bloqueia criar artefato fora dele.
_Evite_: estrutura de pastas (sugere algo que cada um decide)

**Adoção**:
Trazer para o **layout** os artefatos que outro processo ou outro agente deixou fora do lugar, com um mapa aprovado pelo usuário (`/sdd:iniciar --adotar`, `sdd-adotar`). Move sem reescrever nem apagar.
_Evite_: migração (sugere converter o conteúdo)

**Feature**:
Uma unidade de mudança, com pasta própria `specs/NNN-slug/` e um **nível de rigor**.
_Evite_: história, épico, ticket

**Spec**:
O quê e por quê de uma **feature**: requisitos, **critérios de aceitação** e escopo. Nunca tecnologia.
_Evite_: especificação técnica (isso é o **plano**)

**Requisito** (`RF`, `RNF`):
Um comportamento que o sistema deve ter, funcional ou não funcional, escrito em EARS e com ID.

**Critério de aceitação** (`CA`):
Uma condição verificável em Dado, Quando, Então, que vira teste. É a ponte entre a **spec** e o teste.
_Evite_: caso de teste (o teste é o que nasce do critério)

**Marcador de esclarecimento**:
`[PRECISA ESCLARECER: pergunta]` dentro da **spec**. Existe para proibir a suposição silenciosa.

**Plano**:
O como de uma **feature**: componentes, **contratos**, dependências e decisões, checados contra a **constituição**.

**Contrato**:
Uma fronteira do sistema (entidade, objeto de valor, interface, schema, rota, DDL). Fica **congelado** durante a implementação.
_Evite_: interface (é só um dos tipos de contrato)

**Tarefa** (`T`):
Um passo pequeno e verificável, ligado a requisitos e critérios, em `tarefas.md`.

**Fase**:
Uma das etapas do ciclo da **feature**: `especificacao`, `clarificacao`, `plano`, `tarefas`, `red`, `green`, `seguranca`, `auditoria`, `pronta`, `homologacao`, `producao`, ou `cancelada`. As quatro últimas só mudam por **aprovação**, **release** ou cancelamento, nunca à mão.

**Red** e **green**:
As duas fases do TDD. Na red, os testes são escritos e falham. Na green, o código é escrito até eles passarem, com os testes **congelados**.

**Gate**:
O ponto de aprovação humana no fim de cada **fase**. Os comandos são os gates: só a pessoa avança o fluxo.
_Evite_: checkpoint, revisão

**Nível de rigor**:
0, 1 ou 2. Quanto do fluxo uma mudança exige, de acordo com o risco dela.

**Proteção**:
Quanto os hooks impõem o fluxo: `desligada`, `leve` ou `estrita`.
_Evite_: enforcement

**Rastreabilidade**:
A cadeia requisito, critério, tarefa, commit e teste, verificável por máquina com o `sdd-rastrear`.

**Marca de teste**:
`sdd:NNN:CA-XXX` no nome ou num comentário de um teste. Liga o teste ao **critério de aceitação**.
_Evite_: tag (no git, tag é outra coisa)

**Drift**:
A divergência entre o código e a **spec**. O maior risco do método.
_Evite_: desvio de escopo (drift pode acontecer dentro do escopo)

**Delta spec**:
A proposta formal de mudança na **spec** para absorver um **drift** considerado correto. Só entra com aprovação humana.

**ADR**:
Architecture Decision Record. O registro curto de uma decisão durável, em `docs/adr/`.

**Teste enfraquecido**:
Um teste que passa sem verificar de fato o **critério de aceitação** que diz verificar.

**Aprovação**:
O registro de que uma pessoa aceitou o artefato de uma **fase**, feito pelo `/sdd:aprovar`, com data, autor e **hash** do artefato. É o que transforma um **gate** em fato verificável.
_Evite_: ok, aceite verbal

**Hash do artefato**:
Uma impressão curta do conteúdo aprovado. Se o artefato muda, o hash deixa de bater, e a **aprovação** é invalidada.

**Histórico**:
O registro de eventos de uma **feature** (`specs/NNN/historico.md`) ou do projeto (`.sdd/historico.md`): criação, **fases**, **aprovações**, backlog e sprints. Escrito só pelos utilitários.
_Evite_: log (genérico demais)

**Item de backlog** (`B`):
Uma ideia, pedido, bug relatado ou pendência que ainda não tem **spec**, em `.sdd/backlog.md`. Vira **feature** quando é promovido.
_Evite_: história, tarefa (uma **tarefa** pertence a uma feature)

**Backlog**:
A fila priorizada de **itens de backlog**.

**Sprint**:
Um período com um objetivo e um compromisso (features e itens de backlog), em `.sdd/sprints/<id>.md`.
_Evite_: ciclo, iteração

**Quadro**:
A visão de todas as **features** por coluna (especificação, planejamento, implementação, revisão, pronta, homologação), com a **release** em andamento e os **incidentes** abertos, mostrada pelo `/sdd:status`.

**Pendência**:
Algo que espera uma decisão humana: **incidente** aberto, **release** esperando **aceite** ou **go**, **aprovação**, **revisão de segurança** devida, dúvida na spec, **delta spec** ou ADR proposto, **consolidação** pendente, item a triar, item da sprint sem spec. Listado pelo `/sdd:pendencias`.

**Feature ativa**:
A feature em que a pessoa está trabalhando agora, apontada em `.sdd/estado`. Cada pessoa tem a sua.

**Pronta**:
A **fase** de uma **feature** com tudo aprovado e inalterado (spec, testes, plano no nível 2, **revisão de segurança** quando obrigatória). Está pronta para entrar numa **release**, ainda não está em produção.
_Evite_: concluída, entregue (a entrega é a **release**)

**Cancelada**:
A **fase** de uma **feature** que não vai mais ser feita. Fica no histórico, com o motivo, e sai do **quadro**. Pode ser **reaberta**.

**Reabertura**:
Volta de uma feature **pronta**, em **homologação** ou **cancelada** para `especificacao` ou `green`, com motivo. Invalida as **aprovações** dos artefatos da fase de reabertura em diante.

**Área sensível**:
Um caminho do código (glob em `areas_sensiveis`, no `.sdd/config.yml`) cuja alteração torna a **revisão de segurança** obrigatória, mesmo no nível 1.

**Revisão de segurança**:
A análise independente da mudança como um atacante a veria: ameaças, varreduras (dependências, segredos, análise estática) e LGPD. Feita pelo subagent `revisor-de-seguranca`, gravada em `seguranca.md`, decidida pela pessoa.
_Evite_: pentest (é outra atividade, maior e externa)

**Aceite de risco**:
A decisão registrada de seguir com um achado de segurança sem corrigi-lo, com justificativa e responsável. Fica em `seguranca.md` e no **histórico**.

**Capacidade**:
Uma área de comportamento do sistema, do ponto de vista de quem usa (autenticação, pagamentos, relatórios). Cada **feature** declara a capacidade que muda.
_Evite_: módulo, serviço (são divisões do código, não do comportamento)

**Spec do sistema**:
O comportamento **vigente** de cada **capacidade**, em `sistema/<capacidade>.md`, com cada item ligado à feature e ao requisito de origem. Diferente da spec da feature, que descreve uma mudança.
_Evite_: documentação do sistema, spec mestre

**Consolidação**:
Atualizar a **spec do sistema** com o que uma feature **pronta** mudou, registrada no histórico da feature pelo `sdd-sistema consolidar`.

**Release**:
Um conjunto de **features** prontas levado junto à produção, com versão SemVer, em `releases/<versão>/`. Tem o seu próprio ciclo: `preparacao`, `homologacao`, `aceita`, `implantacao`, `producao` (ou `cancelada`, `revertida`).
_Evite_: deploy (o deploy é um passo da release)

**Testes de sistema**:
Regressão completa, ponta a ponta dos fluxos afetados e medição dos RNFs, feitos para a **release** inteira pelo subagent `testador-de-sistema`, em `testes.md`.

**Homologação**:
A verificação, por quem representa o negócio, de que a **release** faz o que foi pedido, seguindo um roteiro de passos `H-NNN` escrito em linguagem de usuário, num ambiente separado da produção.
_Evite_: QA, UAT (use homologação)

**Aceite**:
O registro, com nome e papel, de que quem homologou aprovou todos os passos do roteiro. Sem ele a **release** não avança para o **go**.

**Go/no-go**:
A decisão registrada de implantar a **release** em produção, tomada depois de conferir o plano de implantação, o rollback, a janela e as notas. O pipeline consulta o go com `sdd-release pode-implantar`.
_Evite_: deploy aprovado (vago sobre quem aprovou o quê)

**Rollback**:
O procedimento, escrito antes do go em `implantacao.md`, para voltar à versão anterior se a implantação der errado.

**Incidente** (`INC`):
Uma falha em produção, registrada em `incidentes/INC-NNN.md` com **severidade**, situação (`aberto`, `mitigado`, `resolvido`, `encerrado`) e linha do tempo.

**Severidade**:
O impacto de um **incidente**: S1 (fora do ar ou perda de dados), S2 (função importante quebrada, sem contorno), S3 (quebrada com contorno), S4 (incômodo).

**Mitigação**:
O que reduz o impacto de um **incidente** antes da correção: rollback, flag desligada, contorno.

**Hotfix**:
Uma **feature** de correção urgente que nasce de um **incidente**: nível 1, começa no red com um teste que reproduz o problema e escreve a **spec retroativa** antes da entrega.

**Spec retroativa**:
A spec de um **hotfix**, escrita depois da correção e aprovada antes de ela ficar **pronta**. O processo é invertido por urgência, não dispensado.

**Post-mortem**:
A análise de um **incidente** resolvido, sem culpados: linha do tempo, causa raiz, o que funcionou, e ações com dono que viram **itens de backlog**. Exigido para encerrar o incidente.

## Relações

- Uma **feature** tem uma **spec**, um **nível de rigor** e, no nível 2, um **plano**
- Uma **spec** tem muitos **requisitos**, e cada **requisito** tem ao menos um **critério de aceitação**
- Uma **tarefa** atende um ou mais **requisitos** ou **critérios**
- Um **critério de aceitação** tem ao menos um teste com a **marca de teste**
- Toda **fase** termina num **gate**, e todo gate termina numa **aprovação** registrada no **histórico**
- Um **item de backlog** vira no máximo uma **feature**, e a spec dela guarda a origem
- Uma **sprint** compromete **features** e **itens de backlog**
- Um **drift** termina corrigido no código ou absorvido por uma **delta spec**
- Uma **feature** muda uma **capacidade**, e quando fica **pronta** é **consolidada** na **spec do sistema**
- Uma **release** agrupa **features** prontas e passa por **testes de sistema**, **homologação**, **aceite** e **go** antes da produção
- Um **incidente** pode gerar um **hotfix**, que sai numa **release** de correção, e termina com um **post-mortem**

## Ambiguidades resolvidas

- "Tag" era usado para a marca nos testes e para as tags de versão do git. Resolvido: nos testes, **marca de teste**.
- "Enforcement" era usado para o modo dos hooks. Resolvido: **proteção**, com os valores `desligada`, `leve` e `estrita`.
- "Spec" às vezes queria dizer a spec e o plano juntos. Resolvido: a **spec** é só o quê e por quê; o como é o **plano**.
- "Pendência" era usado para o que o agente achava fora do escopo. Resolvido: isso vira **item de backlog** (origem "pendência da NNN"); **pendência** é o que espera decisão humana.
- "Concluída" queria dizer tanto "o código está pronto" quanto "está em produção". Resolvido: **pronta** é o fim do ciclo da feature; **producao** só vem da **release**.
- "Spec" era usado para a mudança e para o sistema. Resolvido: a **spec** é da feature (uma mudança); a **spec do sistema** é o comportamento vigente.
- "Estado" queria dizer tanto a feature ativa quanto a fase. Resolvido: a **feature ativa** é pessoal (`.sdd/estado`); a fase é da feature (`specs/NNN/estado`).
