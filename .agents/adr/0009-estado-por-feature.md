# Cada feature guarda a própria fase; a feature ativa é pessoal

Na primeira versão, `.sdd/estado` guardava a feature ativa e a fase dela. Com
duas features em andamento, a fase da outra se perdia, e não havia como montar
um quadro.

## Decisão

- Cada feature tem `specs/NNN-slug/estado` (fase, nível, origem, atualização), versionado.
- `.sdd/estado` guarda só ponteiros pessoais (feature ativa e sprint atual) e fica fora do git, pelo `.sdd/.gitignore`.
- As funções que leem `fase` e `nivel` resolvem pela feature ativa, então hooks e skills não mudaram de interface.

## Por quê

O quadro, a sprint e as pendências precisam da fase de todas as features ao
mesmo tempo. E num time, cada pessoa trabalha numa feature: o ponteiro não pode
ser compartilhado, mas a fase de cada feature precisa ser.

## Consequências

- `sdd-estado usar` troca de feature sem perder a fase de nenhuma.
- Um conflito de merge no `estado` de uma feature é raro (cada feature tem o seu) e simples de resolver.
