# /sdd:planejar

## O que faz

Gera o plano técnico (o como) e os **contratos** da feature, as fronteiras do
sistema: entidades, interfaces, rotas, schemas, DDL. O trabalho é feito pelo
subagent `arquiteto-de-contratos`, em contexto próprio, e a sessão principal só
revisa e apresenta. Nos contratos não entra regra de negócio, só assinaturas e
tipos.

## Quando usar

Você digita `/sdd:planejar`; o agente não a usa por conta própria. Use em
features de nível 2, depois que a spec estiver sem marcadores. No nível 1 ela
diz que o plano é dispensável e sugere ir direto às [tarefas](tarefas.md).

## Pré-requisitos

Uma spec **aprovada e inalterada** desde a aprovação (o comando confere com
`sdd-estado aprovado spec.md`) e uma constituição preenchida.

## Contratos congelados

Depois de aprovados, os contratos ficam **congelados** durante a
implementação. Mudar um contrato no meio exige voltar ao plano, com a sua
aprovação. Na proteção estrita, um hook impede a edição dos arquivos que casam
com `globs_de_contrato` na fase green.

Toda decisão durável (tecnologia, padrão, trade-off) vira um ADR em `docs/adr/`,
com situação "proposta" até você aprovar o plano com `/sdd:aprovar`. O hash
registrado na aprovação cobre o `plano.md` e todos os arquivos de `contratos/`:
mudar um contrato depois invalida a aprovação.

## Além da arquitetura

O plano também traz três seções que antecipam as etapas seguintes:

| Seção | Antecipa |
|---|---|
| Ameaças e mitigação | a [revisão de segurança](seguranca.md): problema de arquitetura é barato no plano e caro depois |
| Implantação e rollback | o plano de implantação da [release](release.md): migrations reversíveis, ordem, configuração |
| Observabilidade | a operação: o que logar e medir para saber, em produção, que funciona |

## Perguntas frequentes

**Por que um subagent, e não a própria sessão?**

Para a sessão principal chegar à implementação com a janela limpa, e para o
desenho ser feito por alguém sem pressa de implementar. Ver o
[ADR 0002](../.agents/adr/0002-subagents-isolam-contexto.md).

## Está funcionando se

- Todo componente do plano aponta para um requisito, e nenhum requisito fica sem componente.
- A tabela de checagem da constituição está preenchida, com as exceções justificadas.
- Os contratos não têm corpo de função.

## Onde se encaixa

Terceiro passo do fluxo principal, só no nível 2. Vem depois da spec aprovada e
termina no [aprovar](aprovar.md); depois vêm as [tarefas](tarefas.md). O mapa
está na [ajuda](ajuda.md).
