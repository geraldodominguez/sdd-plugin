# Níveis de rigor

Um processo único para tudo falha dos dois jeitos: fica burocrático e é
abandonado, ou fica frouxo e não protege nada. Aqui o rigor acompanha o
**risco da mudança**.

> **Regra de ouro:** mudou comportamento observável, nível 1 no mínimo.

## Como escolher

| Pergunta | Se sim |
|---|---|
| Altera schema de banco, contrato público (API, evento) ou modelo de domínio? | **2** |
| É feature nova com mais de um caso de uso? | **2** |
| Toca segurança, dinheiro, dados pessoais ou integração externa crítica? | **2** |
| Muda comportamento observável, mas de forma localizada (um a três arquivos)? | **1** |
| É correção de bug com causa conhecida? | **1** |
| Não muda comportamento (typo, formatação, renomeação interna, refatoração coberta por testes)? | **0** |

Na dúvida, o maior. O `/sdd:especificar` faz a classificação e pede a sua confirmação.

## O que cada nível exige

| Etapa | Nível 0 | Nível 1 | Nível 2 |
|---|---|---|---|
| Feature em `specs/` | não | sim | sim |
| `contexto.md` | não | opcional | sim, em projeto existente |
| Spec | não | `spec-leve` | `spec` completa |
| `/sdd:clarificar` | não | se houver dúvida | sim |
| `/sdd:planejar` e contratos | não | não | sim |
| `/sdd:tarefas` | não | sim, de duas a cinco | sim |
| Red com `escritor-de-testes` | não | sim | sim |
| `/sdd:seguranca` | não | se tocar área sensível | sempre |
| `/sdd:auditar` | não | opcional | sim |
| Commit com `T-XXX` | não | sim | sim |
| Consolidar em `sistema/` | não | sim | sim |
| Entrar numa release (`/sdd:release`) | não, vai no próximo deploy | sim | sim |

O **hotfix** é um caso à parte: nível 1, nasce de um incidente, começa no red
(teste de regressão) e escreve a spec depois, antes da entrega. Ver
[/sdd:incidente](../incidente.md).

## Área sensível

`areas_sensiveis`, no `.sdd/config.yml`, lista os globs que tornam a revisão de
segurança obrigatória (ex.: `src/auth/**`, `src/pagamentos/**`,
`migrations/**`). No fim do green, o `/sdd:implementar` roda
`sdd-estado sensivel`: se a feature tocou um desses caminhos, mesmo sendo nível
1, ela passa por `/sdd:seguranca` antes de ficar pronta. No nível 2 a revisão é
sempre obrigatória.

## Exemplos

| Mudança | Nível | Por quê |
|---|---|---|
| Corrigir um erro de digitação numa mensagem | 0 | nenhum comportamento muda |
| Renomear uma variável interna, com testes verdes | 0 | refatoração coberta |
| O botão de exportar mostra o formato errado | 1 | bug localizado com causa conhecida |
| Filtro por data numa listagem existente | 1 | comportamento novo e localizado |
| Campo obrigatório novo no cadastro de cliente | 2 | schema, contrato e validação |
| Redefinição de senha | 2 | segurança, contrato e tabela nova |
| Integração com um gateway de pagamento | 2 | dinheiro e integração externa |

## Mudando de nível

| Situação | O que fazer |
|---|---|
| Era maior do que parecia | `sdd-estado definir nivel=2` (isso também torna a revisão de segurança obrigatória), troque a spec pelo template completo (`sdd-estado template spec.md`) e siga com `/sdd:clarificar` e `/sdd:planejar` |
| Era menor do que parecia | `sdd-estado definir nivel=1` e siga para `/sdd:tarefas` |

O nível padrão de novas features fica em `.sdd/config.yml` (`nivel_padrao`). É
só a sugestão inicial.
