# /sdd:metodologia

## O que faz

Guarda a disciplina do SDD: as fases, os níveis de rigor, as regras de
rastreabilidade e como escrever cada artefato (requisitos em EARS, critérios em
Dado, Quando, Então, planos, tarefas, ADRs). É uma referência, não um comando:
ela não conduz o fluxo, ensina o agente a seguir o fluxo bem.

## Quando usar

Digite `/sdd:metodologia`, ou o agente recorre a ela quando a tarefa pede: num
projeto com `.sdd/`, ao escrever ou revisar specs e planos, ou quando você pede
uma mudança de comportamento sem usar um comando. Todos os comandos de fase a
carregam no início.

## O que ela carrega

| Arquivo | Assunto |
|---|---|
| `EARS.md` | os cinco padrões de frase para requisitos sem ambiguidade |
| `CRITERIOS-DE-ACEITACAO.md` | Dado, Quando, Então, cobertura mínima e a marca de teste |
| `DECOMPOSICAO-DE-TAREFAS.md` | o tamanho certo, a ordem e o formato da linha |
| `NIVEIS-DE-RIGOR.md` | como classificar uma mudança e o que cada nível exige |
| `QUALIDADE-DA-SPEC.md` | o checklist antes de entregar uma spec |
| `CICLO-DE-VIDA.md` | as transições da feature, da release e do incidente, e quem decide cada uma |
| `GIT-FLOW.md` | as branches com nomes fixos e o que acontece no git em cada momento do ciclo |
| `VERSIONAMENTO.md` | SemVer, Conventional Commits e o `CHANGELOG.md`: como o tipo do commit decide a versão |
| `templates/` | constituição, specs (completa, leve e hotfix), contexto, plano, tarefas, transição (adoção), segurança, ADR, auditoria, delta spec, capacidade, backlog, sprint, incidente, release (`release/`) e pipeline (`pipeline/`) |

Os templates são copiados para `.sdd/templates/` pelo `/sdd:iniciar`, para
cada projeto poder adaptar os seus.

## Invariantes

Oito regras que ela impõe em qualquer fase: não implementar fora das tarefas,
não editar teste na green, não mexer em contrato na implementação, não avançar
fase nem registrar aprovação sem o `/sdd:aprovar` do usuário, mandar para o
backlog o que está fora do escopo, resolver divergência primeiro na spec, não
implantar sem o go nem mitigar um incidente sem confirmação, e não reabrir
feature em produção (mudança nova é feature nova; defeito é incidente).

Ela também ensina o modelo de acompanhamento: o que é um item de backlog, uma
sprint, a fase de cada feature e o histórico.

## Está funcionando se

- Num projeto com `.sdd/`, um pedido informal ("adiciona o campo X") recebe uma classificação de nível antes de virar código.
- Os requisitos que o agente escreve seguem os padrões EARS.

## Onde se encaixa

Camada de vocabulário por baixo de todos os comandos. O mapa dos comandos está
na [ajuda](ajuda.md), e os termos estão no [glossário](../GLOSSARIO.md).
