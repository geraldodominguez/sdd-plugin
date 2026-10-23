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
Uma das etapas do ciclo: `especificacao`, `clarificacao`, `plano`, `tarefas`, `red`, `green`, `auditoria`, `concluida`.

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

## Relações

- Uma **feature** tem uma **spec**, um **nível de rigor** e, no nível 2, um **plano**
- Uma **spec** tem muitos **requisitos**, e cada **requisito** tem ao menos um **critério de aceitação**
- Uma **tarefa** atende um ou mais **requisitos** ou **critérios**
- Um **critério de aceitação** tem ao menos um teste com a **marca de teste**
- Toda **fase** termina num **gate**
- Um **drift** termina corrigido no código ou absorvido por uma **delta spec**

## Ambiguidades resolvidas

- "Tag" era usado para a marca nos testes e para as tags de versão do git. Resolvido: nos testes, **marca de teste**.
- "Enforcement" era usado para o modo dos hooks. Resolvido: **proteção**, com os valores `desligada`, `leve` e `estrita`.
- "Spec" às vezes queria dizer a spec e o plano juntos. Resolvido: a **spec** é só o quê e por quê; o como é o **plano**.
