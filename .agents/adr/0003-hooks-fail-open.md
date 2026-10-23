# Hooks são fail-open e só agem em projetos com .sdd/

## Decisão

- Os hooks só fazem algo num projeto que tem `.sdd/`. Sem ela, saem sem bloquear.
- Qualquer erro inesperado (entrada vazia, JSON inválido, falta de `jq` e de `python3`, caminho estranho) **permite** a ação.
- Os hooks inspecionam ferramentas de edição de arquivo e `git commit` com mensagem inline. Não interpretam comandos de shell arbitrários.

## Por quê

- O plugin fica instalado de forma global. Se os hooks agissem em qualquer projeto, atrapalhariam repositórios que não usam SDD.
- Um bug num hook nunca deve travar o trabalho de alguém. O custo de um falso bloqueio é maior do que o de um deslize não pego, porque os gates e a auditoria pegam o deslize depois.
- Interpretar shell arbitrário é frágil e gera falsos bloqueios.

## Consequências

- A documentação diz com clareza o que os hooks não pegam (edição pelo shell, troca de fase pelo próprio agente).
- O `sdd-rastrear` existe também para rodar na CI, onde a garantia é determinística.
