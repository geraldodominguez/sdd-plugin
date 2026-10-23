# Três níveis de rigor, escolhidos por mudança

## Decisão

Toda mudança é classificada em um de três níveis: 0 (direto, sem feature), 1
(spec leve, tarefas, TDD) ou 2 (fluxo completo, com plano, contratos e
auditoria). O `/sdd:especificar` sugere o nível e a pessoa confirma. Regra de
ouro: mudou comportamento observável, nível 1 no mínimo.

## Por quê

Um processo único falha dos dois lados. Se for completo para tudo, vira
burocracia e é abandonado em semanas. Se for leve para tudo, não protege as
mudanças que importam (domínio, schema, contrato, segurança, dinheiro).

## Consequências

- O nível fica no `.sdd/estado` e pode subir no meio do caminho.
- O hook de commits e a proteção de testes valem para os níveis 1 e 2.
