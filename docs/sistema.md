# /sdd:sistema

## O que faz

Mantém a **spec viva do sistema**: um arquivo por capacidade em
`sistema/<capacidade>.md`, descrevendo o que o sistema faz **hoje**. As specs
das features contam o que cada mudança alterou; esta diz o resultado de todas
elas. Cada item cita a origem (`origem: 004/RF-002`), então dá para ir do
comportamento atual até a decisão que o criou. Ele consolida a feature só
depois que ela fica pronta, e só com a sua confirmação do texto.

## Quando usar

Você digita `/sdd:sistema`; o agente não o usa por conta própria. O
[`/sdd:aprovar`](aprovar.md) já conduz a consolidação quando uma feature fica
pronta; use o comando direto para:

| Você quer | Digite |
|---|---|
| ver as capacidades e o que falta consolidar | `/sdd:sistema` |
| saber o que o sistema faz numa área | `/sdd:sistema ver <capacidade>` |
| consolidar features prontas pendentes | `/sdd:sistema consolidar` |
| descrever uma área de um sistema antigo | `/sdd:sistema mapear` |

## O problema que ela resolve

Depois de dez features mexendo no cadastro, qual spec descreve o cadastro? Sem
a spec do sistema, nenhuma: cada uma descreve uma mudança, e a resposta exige
ler as dez em ordem. Com ela, há um lugar só, sempre atual, que é a primeira
leitura de quem vai mexer na área (o `mapeador-de-contexto` e o
`arquiteto-de-contratos` a leem antes de tudo).

## Uma capacidade

| Seção | Conteúdo |
|---|---|
| Propósito | o que a capacidade entrega e para quem |
| Comportamento vigente | requisitos funcionais, não funcionais e regras, cada um com a origem |
| Contratos públicos | APIs e eventos, com o arquivo e a feature |
| Fora desta capacidade | o que parece ser dela, mas é de outra |
| Histórico de consolidação | uma linha por feature, gravada pelo utilitário |

Escreva no presente, como o sistema é. Quando uma feature muda um requisito, o
texto antigo é substituído e a origem passa a ser a feature nova.

## Perguntas frequentes

**Preciso descrever o sistema inteiro antes de começar?**

Não. Num sistema existente, mapeie a área que mais muda; as outras entram
conforme as features as tocarem. Mapear tudo de uma vez produz um documento
grande que envelhece antes de ser lido.

**Uma correção de bug também consolida?**

Se ela só faz o sistema cumprir o que já estava descrito, consolide com
`--sem-mudanca`: fica registrado que foi conferido.

## Está funcionando se

- Para entender uma área, você lê `sistema/` antes de ler código.
- `sdd-sistema pendentes` costuma estar vazio.
- Toda linha de comportamento tem uma origem rastreável.

## Onde se encaixa

Entre a feature pronta e a [release](release.md); conduzida pelo
[aprovar](aprovar.md) e lida pelo [especificar](especificar.md) da próxima
mudança. O mapa está na [ajuda](ajuda.md).
