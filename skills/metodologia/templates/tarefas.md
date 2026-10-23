# Tarefas {{FEATURE}}: {{TITULO}}

> Cada tarefa é pequena (cabe num ciclo do agente), verificável e ligada a
> pelo menos um RF, RNF ou CA. `[P]` marca tarefas que podem rodar em paralelo
> com as demais `[P]` do mesmo grupo. Marque `[x]` quando a tarefa estiver
> concluída **e** com os testes verdes.
>
> Formato obrigatório da linha, lido pelo `sdd-rastrear`:
> `- [ ] T-NNN [P] descrição (atende: RF-NNN, CA-NNN; depende de: T-NNN)`

## Grupo 1: contratos e fundação

- [ ] T-001 {{descrição}} (atende: RF-001; depende de: nada)

## Grupo 2: comportamento

- [ ] T-002 {{descrição}} (atende: RF-001, CA-001; depende de: T-001)

## Grupo 3: integração e acabamento

- [ ] T-003 {{descrição}} (atende: RNF-001; depende de: T-002)

## Definição de pronto da feature

- [ ] Todo CA tem teste com a marca `sdd:{{NUM}}:CA-XXX`, e todos estão verdes
- [ ] `sdd-rastrear` sem lacunas
- [ ] Lint e checagem de tipos sem erros
- [ ] Auditoria (`/sdd:auditar`) aprovada
