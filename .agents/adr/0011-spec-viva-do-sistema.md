# Uma spec viva do sistema, por capacidade, ao lado das specs das features

Cada feature tem a sua spec, que descreve uma **mudança**. Com o tempo, a
resposta para "o que o sistema faz hoje?" fica espalhada em dezenas de pastas,
algumas contrariadas por features mais novas. A próxima spec, o mapeador e o
testador de sistema não têm onde ler o comportamento vigente.

## Decisão

- `sistema/<capacidade>.md` descreve o comportamento vigente de uma capacidade (autenticação, pagamentos), na mesma notação EARS, com cada item ligado à origem (`origem: NNN/RF-NNN`).
- Toda feature declara a capacidade que muda (campo `capacidade` no estado e linha na spec).
- Quando a feature fica pronta, o agente reescreve a capacidade e o `sdd-sistema consolidar` registra a consolidação no histórico da feature, conferindo que o arquivo cita a feature.
- A consolidação é aviso, não bloqueio, no `sdd-verificar` e nas pendências.
- Em projeto existente, a capacidade nasce quando a primeira feature mexe nela, ou pelo `/sdd:sistema mapear`, uma capacidade por vez.

## Por quê

As specs das features são um registro histórico, e devem continuar assim. A spec
do sistema é a fotografia atual. As duas juntas respondem "o que faz" e "por que
faz assim". Por capacidade, e não por módulo de código, porque é assim que o
dono do produto pensa e é assim que as features são pedidas.

## Consequências

- O `especificar`, o `mapeador-de-contexto` e o `arquiteto-de-contratos` leem `sistema/` antes do código.
- O `testador-de-sistema` usa `sistema/` para decidir o que entra na regressão.
- A consolidação é feita pelo agente, com confirmação humana. O utilitário só confere a ligação e registra; não tenta mesclar texto.
