# /sdd:seguranca

## O que faz

Faz a revisão de segurança da feature por um subagent independente, o
`revisor-de-seguranca`, que não participou da implementação. Ele mapeia a
superfície de ataque, modela as ameaças (STRIDE), roda as varreduras de
dependências, segredos e análise estática, confere o tratamento de dados
pessoais (LGPD) e a seção de segurança da constituição, e grava `seguranca.md`.
Ele não corrige nada: aponta, com `arquivo:linha`, e a decisão é sua.

## Quando usar

Você digita `/sdd:seguranca`; o agente não o usa por conta própria. Use quando a
fase green terminar (todas as tarefas concluídas, suíte verde).

| Feature | Revisão |
|---|---|
| nível 2 | obrigatória, antes da auditoria |
| nível 1 que tocou `areas_sensiveis` | obrigatória (o `/sdd:implementar` marca sozinho, com `sdd-estado sensivel`) |
| nível 1 marcada como sensível na especificação | obrigatória |
| outras de nível 1 | opcional |

Para conferir se o código bate com a spec, use o [auditar](auditar.md); são
revisões diferentes e complementares.

## Pré-requisitos

A fase green concluída. Para as varreduras automáticas, o `comando_seguranca`
no `.sdd/config.yml` (ex.: `npm audit --omit=dev && gitleaks detect`). Sem ele,
o revisor tenta o que a stack oferece e registra o que não pôde rodar.

## As três decisões

| Decisão | Quando | O que acontece |
|---|---|---|
| Aprovar | nenhum achado crítico ou alto | segue para a auditoria (nível 2) ou fica pronta (nível 1) |
| Aceitar o risco | há achado, e o negócio convive com ele por ora | segue, com a nota de quem aceitou, por quê e até quando; a correção vai para o backlog |
| Corrigir | o achado precisa ser resolvido antes | a feature volta ao green |

O **aceite de risco** é uma decisão legítima, desde que tenha dono e prazo. Ele
fica no histórico da feature e o auditor confere que existe.

## Segurança desde o desenho

No nível 2, o plano já traz uma seção de **ameaças e mitigação**, escrita pelo
`arquiteto-de-contratos`. A revisão confere se as mitigações previstas foram
implementadas. Problema de arquitetura descoberto só aqui é caro de corrigir;
descoberto no plano, é barato.

## Perguntas frequentes

**A revisão substitui um pentest?**

Não. Ela pega a maioria dos problemas comuns de código e configuração, no
momento em que corrigir é barato. Para sistemas críticos, a constituição pode
exigir testes de intrusão periódicos, fora do plugin.

**Por que testes congelados também nesta fase?**

Porque a fase de revisão não corrige nada. Se um achado exige mudança, a
decisão "corrigir" devolve a feature ao green, onde o código pode mudar.

## Está funcionando se

- Todo achado tem `arquivo:linha` e uma recomendação.
- As varreduras que não puderam rodar aparecem escritas, não omitidas.
- Riscos aceitos têm nome, motivo e prazo no histórico.

## Onde se encaixa

Etapa de revisão do fluxo da feature, entre o [implementar](implementar.md) e o
[auditar](auditar.md) (ou a entrega, no nível 1). A decisão passa pelo
[aprovar](aprovar.md). O mapa está na [ajuda](ajuda.md).
