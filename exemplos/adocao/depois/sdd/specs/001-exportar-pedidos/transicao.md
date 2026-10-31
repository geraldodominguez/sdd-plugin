# Transição 001-exportar-pedidos: de outro processo para o SDD

> Criado pelo `sdd-adotar` quando a feature foi adotada. Mostra como ela era
> antes do plugin e como fica dentro dele. Enquanto a situação da feature é
> `transicao`, este é o documento que o usuário aprova (`/sdd:aprovar`): a
> aprovação registra a spec, o plano e as tarefas convertidos, com o hash de
> cada um, e leva a feature à fase de destino, para o plugin continuar de onde
> o outro processo parou.
>
> Tarefas `[O]` foram feitas fora do plugin, sem gate. Elas não são refeitas:
> na fase red, os testes dos critérios delas são escritos e devem passar já de
> início. Se um falhar, o trabalho de fora está errado, e a tarefa volta a
> `[ ]` com a sua decisão.

| Campo | Valor |
|---|---|
| Feature | 001-exportar-pedidos |
| Adotada em | 2026-10-29 |
| Fase de destino | red |
| Por quê | spec e tarefas claras; CSV e botão já implementados (src/pedidos/exportar.ts:1) |

## Como era

### Arquivos

O conteúdo original de cada arquivo está no git: o hash abaixo é o do arquivo
como ele chegou, antes da conversão (`git log --follow <arquivo>`).

| Arquivo original | Hash do original | Agora em |
|---|---|---|
| `docs/specs/exportar-pedidos.md` | ad347b30563f | `spec.md` |
| `tasks/exportar-pedidos.md` | 138bc4003898 | `tarefas.md` |

### Situação encontrada

Feito: CSV (src/pedidos/exportar.ts:1) e botão; teste em tests/exportar.test.ts:1.
Aberto: PDF e a restrição ao dono (nada no código).

## Como vai ficar

### Requisitos e critérios

| Como era (trecho original) | Como vai ficar |
|---|---|
| Exportar em CSV, com data, cliente e valor. | RF-001, CA-001 |
| Exportar em PDF, com o logo da loja. | RF-002, CA-002 |
| Só o dono da loja pode exportar. | RF-003, CA-003 |

### Tarefas

| Como era (linha original) | Como vai ficar | Marca |
|---|---|---|
| `- [x] gerar CSV com data, cliente e valor` | T-001 | O: feita fora do plugin |
| `- [x] botão de exportar na tela de pedidos` | T-002 | O: feita fora do plugin |
| `- [ ] gerar PDF com o logo` | T-003 | aberta: o plugin continua daqui |
| `- [ ] restringir ao dono da loja` | T-004 | aberta: o plugin continua daqui |

### Testes que já existiam

A marca é acrescentada na fase red, quando os testes podem ser editados.

| Arquivo | Teste | Cobre | Marca a acrescentar |
|---|---|---|---|
| tests/exportar.test.ts | "exporta csv" | CA-001 | `sdd:001:CA-001` |

## O que ficou de fora

Nada: as três frases da spec original viraram RF-001 a RF-003, e as quatro
tarefas viraram T-001 a T-004.
