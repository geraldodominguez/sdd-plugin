# Passo a passo: do pedido à entrega

Este guia acompanha uma feature real, **redefinição de senha por e-mail**, num
projeto existente, no nível 2 (fluxo completo), desde o pedido do cliente até a
produção, e depois na manutenção, quando um incidente aparece. Os artefatos que
ela produz estão em [exemplos/](../../exemplos/).

> No nível 1 o caminho é o mesmo, sem o `/sdd:planejar`, sem a auditoria
> obrigatória e com a revisão de segurança só quando a feature toca área
> sensível. Ver [níveis de rigor](niveis-de-rigor.md). Para a rotina de
> acompanhamento (o que olhar todo dia), ver o
> [guia de acompanhamento](acompanhamento.md). Para o mapa do processo inteiro,
> ver o [ciclo de vida](ciclo-de-vida.md).

## 0. Preparar o repositório, uma vez

```
/sdd:iniciar
```

O agente pergunta o nível padrão e a proteção, cria a estrutura (com backlog e
sprints, e a pasta `sistema/`), lê o projeto e rascunha a constituição só com
o que observou. **A sua parte:** revisar a constituição, porque ela vale para
todas as features, e preencher no `.sdd/config.yml` as `areas_sensiveis`
(aqui, `src/auth/**`) e os comandos de entrega. Para o CI, rode
`/sdd:pipeline` uma vez. Depois,
faça commit de tudo (o `.sdd/estado`, pessoal, já fica fora do git).

## 1. Registrar o pedido no backlog

O cliente pediu redefinição de senha, mas você está no meio de outra coisa.

```
/sdd:backlog adicionar clientes precisam redefinir a senha sozinhos, hoje abrem chamado
```

O agente reescreve como comportamento, propõe prioridade e nível, e registra:

```
- [ ] B-001 Redefinição de senha por e-mail (prioridade: alta; nivel: 2; origem: cliente ACME; criado: 2026-10-20)
```

## 2. Planejar a sprint

```
/sdd:sprint planejar
```

O agente pergunta o período e o objetivo ("clientes recuperam o acesso
sozinhos"), propõe o compromisso a partir do backlog e explica o que ficou de
fora. Com a sua aprovação, cria `.sdd/sprints/2026-S44.md` e a inicia.

## 3. Especificar a partir do item

```
/sdd:especificar B-001
```

O agente lê o item, confirma o nível 2, pergunta a **capacidade** do sistema
que a feature muda (aqui, `autenticacao`), cria `specs/001-redefinicao-de-senha/`
(o item vira `[x]` no backlog e a spec registra `Origem: B-001`), lê
`sistema/autenticacao.md` para saber o que o sistema já faz, pede ao
`mapeador-de-contexto` o mapa do código de autenticação e escreve a spec,
marcando o que não sabe:

```markdown
- [PRECISA ESCLARECER: quanto tempo o link deve valer?]
- [PRECISA ESCLARECER: o que responder quando o e-mail não está cadastrado?]
```

## 4. Clarificar

```
/sdd:clarificar
```

> **1. Validade do link** (RF-002): por quanto tempo o link vale?
> - 15 minutos
> - **30 minutos (recomendado: equilíbrio entre segurança e e-mail lento)**
> - 24 horas
>
> **2. E-mail não cadastrado** (RF-001): o que o sistema responde?
> - **A mesma mensagem genérica (recomendado: evita enumeração de usuários)**
> - "E-mail não encontrado"

Você responde. A spec é atualizada e cada resposta vai para o histórico de
clarificação.

## 5. Aprovar a spec

```
/sdd:aprovar
```

O agente resume (objetivo, 5 RFs, 3 RNFs, 9 CAs, fora do escopo, nenhuma
dúvida em aberto) e pergunta: "Aprova a spec da 001?". Com o seu "sim", o
histórico ganha:

```
- 2026-10-20T14:02:11Z | aprovacao | spec.md | hash=2533c54be22d | por: Geraldo Dominguez
- 2026-10-20T14:02:11Z | fase | clarificacao para plano (spec.md aprovado) | por: Geraldo Dominguez
```

A partir daqui, se a spec mudar, o `/sdd:status` volta a mostrar "aguarda
aprovação", e o `/sdd:planejar` se recusa a continuar até você aprovar de novo.

## 6. Planejar e aprovar o plano

```
/sdd:planejar
```

O `arquiteto-de-contratos` decide os componentes, desenha os contratos (entidade,
interfaces, OpenAPI, DDL), preenche a checagem contra a constituição, as
**ameaças** (enumeração de usuários, força bruta no token), o **plano de
implantação e rollback** (a migration é aditiva, o rollback é desligar a rota) e
a **observabilidade** (métrica de pedidos de redefinição, alerta de pico), e
propõe um ADR: "guardar só o hash SHA-256 do token". Você revisa e roda
`/sdd:aprovar`.

## 7. Tarefas e aprovação

```
/sdd:tarefas
```

```markdown
## Grupo 1: contratos e fundação
- [ ] T-001 migration da tabela password_reset_tokens (atende: RNF-002, RF-005; depende de: nada)
- [ ] T-002 [P] entidade ResetToken com expiração, uso único e substituição (atende: RF-002, RF-004, RF-005, CA-003, CA-005, CA-006; depende de: nada)
- [ ] T-003 [P] TokenGenerator com hash SHA-256 (atende: RNF-002, CA-008; depende de: nada)

## Grupo 2: comportamento
- [ ] T-004 solicitar redefinição sem enumeração de usuários (atende: RF-001, CA-001, CA-002; depende de: T-001, T-002, T-003)
```

O `sdd-rastrear` confirma que todo requisito tem tarefa. Você roda `/sdd:aprovar`.

## 8. Implementar: red, aprovar, green

```
/sdd:implementar
```

**Red.** O `escritor-de-testes` recebe só a spec, as tarefas e os contratos, e
escreve um teste por critério:

```ts
// sdd:001:CA-003
it('recusa link de redefinição com mais de 30 minutos', async () => { ... })
```

Os testes falham por falta de comportamento. O agente para. Você roda
`/sdd:aprovar`: o hash dos testes fica registrado e a feature vai para o green.

```
/sdd:implementar
```

**Green.** O agente implementa tarefa por tarefa, com os testes congelados. Se
tentar editar um teste, o hook bloqueia:

```
SDD (proteção leve) bloqueou a edição de 'tests/password-reset.test.ts' na fase 'green' da feature 001-redefinicao-de-senha.
Na fase green os testes estão congelados: implemente o código para fazê-los passar.
```

No meio do caminho, ele percebe que o rate limit global está mal configurado.
Em vez de corrigir, registra no backlog:

```
- [ ] B-006 Rate limit global com chave errada (prioridade: media; nivel: ?; origem: pendência da 001; criado: 2026-10-22)
```

Cada tarefa vira um commit: `feat(001): T-004 solicitar redefinição sem enumeração`.

No fim, o agente roda `sdd-estado sensivel`: a feature tocou `src/auth/`, e a
revisão de segurança fica obrigatória (no nível 2 ela já seria).

## 9. Revisão de segurança

```
/sdd:seguranca
```

O `revisor-de-seguranca`, sem ver a conversa, lê a spec, as ameaças do plano e
o diff, roda o `comando_seguranca` (SAST, dependências, segredos) e escreve
`seguranca.md`:

> **S-001 (alta):** o token é comparado com `==`, sujeito a ataque de tempo.
> Correção: comparação em tempo constante.
>
> **S-002 (baixa):** a mensagem de link expirado mostra o horário do servidor.

Você decide com `/sdd:aprovar`: **corrigir** (volta ao green com os achados),
**aceitar o risco** (de S-002, com a justificativa registrada) ou **aprovar**.
Aqui: corrigir S-001, aceitar S-002. Corrigido, a revisão roda de novo e você
aprova. A feature vai para a auditoria.

## 10. Auditar e decidir

```
/sdd:auditar main
```

O `auditor-de-drift` recebe só a pasta da feature e a ref base. Ele confere o
código contra a spec, os testes contra os critérios e o **processo** (spec,
plano, tarefas e testes ainda batem com o hash aprovado). Exemplo de achado:

> **Desvio #1 (média):** comportamento não especificado.
> `src/auth/password-reset.service.ts:25` registra o IP da solicitação, e nenhum
> requisito pede isso, com implicação de LGPD. **Delta spec proposta** em
> `delta-spec.md`: RNF-004, registro de IP para auditoria de segurança, com
> retenção de 90 dias.

Você decide com `/sdd:aprovar`: aprovar, aprovar a delta spec (a spec absorve o
RNF-004 e é reaprovada) ou mandar corrigir. Ao aprovar, o utilitário confere
que spec, plano, testes e revisão de segurança continuam aprovados e
inalterados, e a feature fica **pronta**.

## 11. Consolidar na spec do sistema

Pronta não é em produção, mas o comportamento já está decidido. O
`/sdd:aprovar` emenda:

```
/sdd:sistema consolidar
```

O agente reescreve `sistema/autenticacao.md` para descrever como a autenticação
funciona **agora**, com cada item ligado à origem:

```markdown
- QUANDO o usuário pedir a redefinição, O SISTEMA DEVE enviar um link de uso
  único, válido por 30 minutos. (origem: 001/RF-001, 001/RF-002)
```

Você confere e confirma; o histórico da feature ganha a linha `consolidacao`. A
próxima feature que mexer em autenticação parte deste arquivo, não do código.

## 12. Release: do pronto à produção

```
/sdd:release preparar
```

O agente lista as features prontas, propõe a versão (`0.1.0`, porque há
capacidade nova), cria `releases/0.1.0/` e chama o `testador-de-sistema`, que
roda a regressão, os fluxos ponta a ponta afetados e a medição dos RNFs, e
preenche `testes.md`. Depois escreve o roteiro de homologação em linguagem de
quem usa:

```markdown
| H-001 | 001 | CA-001 | Em "Esqueci a senha", informe um e-mail cadastrado. | Chega um e-mail com o link em até 1 minuto. | pendente |
```

```
/sdd:release homologar
```

Com a versão no ambiente de homologação, a feature passa à fase
`homologacao`. Bia, a dona do produto, percorre o roteiro, e cada passo vira
`aprovado` ou `reprovado`.

```
/sdd:release aceitar
```

Todos os passos aprovados: o aceite fica registrado em nome dela. Se um passo
tivesse reprovado, a feature voltaria ao green e a release, à preparação.

```
/sdd:release implantar
```

O agente mostra o plano de implantação, o **rollback**, a janela e as notas, e
pergunta: go ou no-go? Com o go, o pipeline, ao receber a tag `v0.1.0`, roda
`sdd-release pode-implantar` e implanta. Depois da verificação em produção:

```
/sdd:release concluir
```

A feature vai para `producao`, as notas ficam publicadas e a tag é criada.

## 13. Manutenção: um incidente

Duas semanas depois, o suporte avisa que um link de redefinição foi usado duas
vezes.

```
/sdd:incidente abrir
```

O agente registra `incidentes/INC-001.md` com severidade S2, ligado à feature
001 e à release 0.1.0, e pergunta pela **mitigação**: a redefinição é
desligada por flag, e o incidente fica `mitigado`.

```
/sdd:incidente hotfix
```

Nasce a feature `002-invalidar-link-apos-o-uso`, do tipo hotfix, já na fase
red: o `escritor-de-testes` escreve o teste que reproduz o problema; você
aprova; o agente corrige; a **spec retroativa** é escrita e aprovada (sem ela,
a entrega é recusada); como tocou `src/auth/`, passa pela revisão de segurança;
é consolidada em `sistema/autenticacao.md`; e sai na release `0.1.1`, com
homologação expressa, aceite e go.

Em produção, o incidente fica `resolvido`. Você escreve o **post-mortem** com o
agente (linha do tempo, causa raiz, ações, cada ação com dono e item no
backlog) e encerra:

```
/sdd:incidente encerrar INC-001
```

## 14. Acompanhar e fechar a sprint

Ao longo da sprint:

```
/sdd:status
```

mostra o quadro, e `/sdd:pendencias` mostra o que espera você. No fim:

```
/sdd:sprint encerrar
```

grava "Entregue: 2 de 3 itens", pergunta o destino do que ficou e preenche a
revisão com você.
