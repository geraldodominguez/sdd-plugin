# /sdd:incidente

## O que faz

Conduz um incidente em produção do registro ao post-mortem: severidade,
mitigação, **hotfix** e aprendizado. O hotfix é uma feature de correção que
começa direto na fase red, com o teste que reproduz o incidente, para não
atrasar a resposta; mas a spec é obrigatória antes da entrega. A urgência dobra
o processo, não o quebra.

## Quando usar

Você digita `/sdd:incidente`; o agente não o usa por conta própria. Use quando
algo está errado **em produção**. Defeito encontrado antes da produção é
correção na própria feature (`sdd-estado reabrir`); melhoria é item de backlog.

| Severidade | Quando |
|---|---|
| S1 | sistema fora do ar, perda ou vazamento de dados |
| S2 | função crítica indisponível, sem contorno |
| S3 | função degradada, com contorno |
| S4 | incômodo sem impacto relevante (em geral, item de backlog) |

## O incidente passo a passo

```
aberto -> mitigado -> resolvido -> encerrado
```

| Passo | Comando | O que você decide |
|---|---|---|
| Registrar | `/sdd:incidente abrir <o que aconteceu>` | a severidade |
| Mitigar | rollback (`/sdd:release reverter`), desligar a função ou contorno | qual opção, com confirmação |
| Corrigir | `/sdd:incidente hotfix`, depois `/sdd:implementar` e `/sdd:aprovar` | a spec retroativa |
| Entregar | `/sdd:release` com `--hotfix` (versão patch) | o aceite, mesmo expresso |
| Aprender | post-mortem e `sdd-incidente encerrar` | as ações que vão para o backlog |

## O hotfix

| Etapa | Normal | Hotfix |
|---|---|---|
| Spec | antes de tudo, aprovada | depois da correção, aprovada antes da entrega |
| Tarefas | obrigatórias | dispensadas |
| Testes | um por critério | o teste de regressão do incidente, antes da correção |
| Segurança | conforme nível e área | conforme a área tocada |
| Release | normal | patch, homologação expressa |

## O post-mortem

Sem culpados. As perguntas que importam: qual foi a causa raiz, e **qual etapa
do processo deveria ter pegado e não pegou** (spec, testes, segurança,
auditoria, homologação, monitoramento). Cada ação vira item de backlog com
origem no incidente. O incidente só se encerra com o post-mortem completo.

## Perguntas frequentes

**Em S1, preciso mesmo abrir o incidente antes de agir?**

Mitigue primeiro, registre em seguida: abrir leva segundos e a linha do tempo
aceita eventos com o horário real. O que não pode é corrigir em produção sem
deixar rastro.

## Está funcionando se

- Todo hotfix em produção tem teste de regressão e spec aprovada.
- Os post-mortems apontam etapas do processo, não pessoas.
- As ações do post-mortem aparecem no backlog com origem `INC-NNN`.

## Onde se encaixa

Etapa de manutenção, depois da [release](release.md). O hotfix percorre o
[implementar](implementar.md), o [aprovar](aprovar.md) e uma release de
correção; as ações alimentam o [backlog](backlog.md). O mapa está na
[ajuda](ajuda.md).
