# Ciclo de vida completo

Do pedido à manutenção. Cada etapa tem um comando, um artefato e um gate.

```
ANÁLISE        backlog -> sprint -> especificar -> clarificar -> [aprovar spec]
DESENHO        planejar (nível 2) -> [aprovar plano] -> tarefas -> [aprovar tarefas]
CONSTRUÇÃO     implementar: red -> [aprovar testes] -> green
REVISÃO        seguranca -> [decisão] -> auditar -> [decisão]  ==> feature PRONTA
               consolidação na spec do sistema (sistema/)
ENTREGA        release: preparar (testes de sistema, roteiro, notas)
               -> homologar -> [aceite do negócio] -> plano de implantação
               -> [go/no-go] -> implantar -> verificar -> concluir  ==> PRODUÇÃO
DEVOPS         pipeline: verificar e seguranca em todo push; homologação na main;
               produção na tag vX.Y.Z, só com o go registrado
MANUTENÇÃO     incidente -> mitigar -> hotfix (red, green, spec retroativa)
               -> release de hotfix -> resolver -> post-mortem -> backlog
```

## Feature: estados e transições

| De | Para | Como | Condição |
|---|---|---|---|
| (nova) | `especificacao` | `sdd-estado nova` | |
| (nova, hotfix) | `red` | `sdd-incidente hotfix` | origem é um incidente |
| `especificacao`, `clarificacao` | `plano` ou `tarefas` | aprovar `spec.md` | |
| `plano` | `tarefas` | aprovar `plano.md` | |
| `tarefas` | `red` | aprovar `tarefas.md` | |
| `red` | `green` | aprovar os testes | testes marcados existem |
| `green` | `seguranca` | `/sdd:seguranca` | tarefas concluídas |
| `green` | `pronta` | aprovar a entrega | nível 1, sem segurança obrigatória, tudo aprovado |
| `green` | `auditoria` | `/sdd:auditar` | nível 1 que quer auditoria |
| `seguranca` | `auditoria` / `pronta` / `green` | decisão aprovar ou aceitar-risco (nível 2 / nível 1), ou corrigir | |
| `auditoria` | `pronta` / `green` | decisão aprovar ou delta, ou corrigir | tudo aprovado e inalterado |
| `pronta` | `homologacao` | `sdd-release homologar` | testes de sistema aprovados |
| `homologacao` | `producao` | `sdd-release concluir` | aceite e go registrados |
| `homologacao` | `green` | `sdd-release reprovar` | reprovada no aceite |
| `pronta`, `cancelada` | `especificacao` ou `green` (a cancelada, sempre `especificacao`) | `sdd-estado reabrir --motivo` | invalida aprovações da fase em diante |
| `homologacao` | `green` | `sdd-release reprovar` | as demais features da release voltam a `pronta` |
| qualquer, menos `homologacao` e `producao` | `cancelada` | `sdd-estado cancelar --motivo` | |
| `producao` | | | não se reabre: feature nova ou incidente |

## Release: estados

| De | Para | Comando | Condição |
|---|---|---|---|
| | `preparacao` | `sdd-release nova` | versão SemVer nova |
| `preparacao` | `homologacao` | `sdd-release homologar` | features prontas, `testes.md` aprovado, roteiro escrito |
| `homologacao` | `aceita` | `sdd-release aceitar --por` | roteiro sem pendentes nem reprovados |
| `homologacao`, `aceita` | `preparacao` | `sdd-release reprovar` | feature reprovada |
| `aceita` | `implantacao` | `sdd-release autorizar` (go) | `implantacao.md` e `notas.md` completos |
| `implantacao` | `producao` | `sdd-release concluir --verificacao` | verificação feita |
| `implantacao`, `producao` | `revertida` | `sdd-release reverter` | rollback executado |

## Incidente: estados

| De | Para | Comando |
|---|---|---|
| | `aberto` | `sdd-incidente abrir --severidade` |
| `aberto` | `mitigado` | `sdd-incidente situacao INC mitigado` |
| `aberto`, `mitigado` | `resolvido` | `sdd-incidente situacao INC resolvido` |
| `resolvido` | `encerrado` | `sdd-incidente encerrar` (post-mortem completo) |

## Quem faz o quê

| Etapa | Pessoa | Agente |
|---|---|---|
| Pedido, prioridade, sprint | dono do produto | organiza e propõe |
| Spec e clarificação | dono do produto aprova | escreve e pergunta |
| Plano, contratos, ADRs | tech lead aprova | `arquiteto-de-contratos` |
| Testes | dev aprova | `escritor-de-testes` |
| Código | dev revisa | sessão principal |
| Segurança | responsável por segurança decide | `revisor-de-seguranca` |
| Auditoria | tech lead decide | `auditor-de-drift` |
| Testes de sistema | dev confere | `testador-de-sistema` |
| Homologação | dono do produto ou cliente aceita | escreve o roteiro |
| Go/no-go e implantação | tech lead e operação | conduz o plano |
| Incidente | quem está de plantão | registra, propõe mitigação, conduz o post-mortem |

Num time de uma pessoa, a mesma pessoa ocupa todos os papéis: os gates
continuam valendo, porque separam momentos de decisão, não pessoas.
