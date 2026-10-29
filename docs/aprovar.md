# /sdd:aprovar

## O que faz

É o **gate** formal. Mostra um resumo do que está em jogo na fase atual, pede a
sua confirmação e registra a aprovação no `historico.md` da feature, com data,
autor e o **hash** do artefato aprovado. Depois disso, avança a feature para a
fase seguinte. Ele nunca registra nada sem um "sim" seu, e é o único caminho
para avançar o fluxo.

## Quando usar

Você digita `/sdd:aprovar`; o agente não o usa por conta própria. Use sempre que
um comando de fase terminar dizendo "próximo: `/sdd:aprovar`", ou quando o
`/sdd:status` mostrar "aguarda aprovação".

| Fase | O que você aprova | Para onde a feature vai |
|---|---|---|
| qualquer, com a feature em transição (adotada de outro processo) | o `transicao.md`: como era e como vai ficar, e com ele a spec, o plano e as tarefas convertidos | a fase de destino do `transicao.md`: especificação, plano, tarefas ou red |
| especificação ou clarificação | a `spec.md` | plano (nível 2) ou tarefas (nível 1) |
| plano | o `plano.md` e os `contratos/` | tarefas |
| tarefas | o `tarefas.md` | red |
| red | os testes escritos pelo `escritor-de-testes` | green |
| green, nível 1 sem segurança obrigatória | a entrega | pronta |
| green, hotfix | a spec retroativa, depois a entrega | pronta |
| segurança | a decisão: aprovar, aceitar o risco ou corrigir | auditoria (nível 2), pronta (nível 1) ou green |
| auditoria | a decisão: aprovar, aprovar a delta spec ou corrigir | pronta ou green |

Daqui em diante, os gates são da release (aceite do negócio e go/no-go), no
[`/sdd:release`](release.md).

## Pré-requisitos

Uma feature ativa com o artefato da fase pronto.

## Aprovação com hash

O registro guarda um hash curto do artefato. Se alguém mudar a spec depois de
aprovada, o hash deixa de bater, e isso aparece em três lugares:

- `sdd-estado aprovado spec.md` sai com 4 (alterado depois da aprovação);
- os comandos das fases seguintes recusam continuar e pedem uma nova aprovação;
- o `auditor-de-drift` registra o desvio na seção de processo da auditoria.

O mesmo vale para os testes: aprovados na fase red, qualquer mudança neles
durante a implementação fica visível.

O histórico e o estado de cada feature só são escritos pelos utilitários: o hook
de proteção bloqueia a edição manual desses arquivos pelo agente.

## Pronta: tudo conferido de uma vez

Para uma feature ficar **pronta**, o utilitário confere que a spec, os testes, o
plano (nível 2) e a revisão de segurança (quando obrigatória) estão aprovados
**e inalterados** desde a aprovação. Se algo mudou, ele recusa e lista o que
reaprovar. Com a feature pronta, o `/sdd:aprovar` conduz a consolidação na
[spec do sistema](sistema.md).

## Perguntas frequentes

**Mudei uma vírgula na spec. Preciso aprovar de novo?**

Sim. O hash não distingue vírgula de regra de negócio, e é justamente isso que o
torna confiável. Rode `/sdd:aprovar` de novo: leva segundos.

**O agente pode aprovar por mim?**

Não deveria, e as instruções proíbem: o comando só existe quando você o digita,
e o histórico e o estado são protegidos contra edição. O agente ainda conseguiria
chamar o utilitário pelo shell, por isso o autor de cada aprovação fica
registrado (o nome configurado no git), e a revisão do histórico mostra quem
aprovou o quê.

## Está funcionando se

- Toda troca de fase no `historico.md` vem logo depois de uma linha de aprovação.
- Mudar a spec aprovada faz o `/sdd:status` mostrar "aguarda aprovação" de novo.
- Nenhum comando de fase segue adiante com um artefato anterior não aprovado.

## Onde se encaixa

É o elo entre todas as fases da feature: aparece depois de
[especificar](especificar.md), [planejar](planejar.md), [tarefas](tarefas.md),
da fase red do [implementar](implementar.md), da [segurança](seguranca.md) e do
[auditar](auditar.md). Depois da feature pronta, os gates passam ao
[release](release.md). O mapa
está na [ajuda](ajuda.md).
