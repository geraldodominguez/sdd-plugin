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
| especificação ou clarificação | a `spec.md` | plano (nível 2) ou tarefas (nível 1) |
| plano | o `plano.md` e os `contratos/` | tarefas |
| tarefas | o `tarefas.md` | red |
| red | os testes escritos pelo `escritor-de-testes` | green |
| green, nível 1 | a entrega, sem auditoria | concluída |
| auditoria | a decisão: aprovar, aprovar a delta spec ou corrigir | concluída ou green |

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

É o elo entre todas as fases do fluxo principal: aparece depois de
[especificar](especificar.md), [planejar](planejar.md), [tarefas](tarefas.md),
da fase red do [implementar](implementar.md) e do [auditar](auditar.md). O mapa
está na [ajuda](ajuda.md).
