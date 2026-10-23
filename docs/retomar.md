# /sdd:retomar

## O que faz

Conta a história de uma feature desde a última vez: as aprovações e mudanças de
fase do histórico, as tarefas concluídas, os commits correspondentes, o que está
pela metade e o próximo passo. Ele só junta fatos (histórico, git e estado) e
aponta divergências em vez de supor; não altera nada.

## Quando usar

Você digita `/sdd:retomar`; o agente não o usa por conta própria. Use quando
voltar a uma feature depois de uma pausa, ao abrir uma sessão nova, ao trocar de
máquina ou ao assumir o trabalho de outra pessoa. Para ver só "onde estou", o
[status](status.md) é mais rápido.

| Argumento | Efeito |
|---|---|
| nenhum | a feature ativa |
| `NNN-slug` | outra feature |
| `desde AAAA-MM-DD` | só o que aconteceu a partir da data |

## A história em quatro partes

1. **Onde paramos:** fase, nível e se a feature está na sprint.
2. **O que aconteceu:** eventos do histórico, tarefas e commits.
3. **O que está pela metade:** arquivos não commitados, tarefa em andamento, artefato alterado depois de aprovado.
4. **Próximo passo:** um comando.

## Perguntas frequentes

**Funciona numa sessão nova, sem a conversa anterior?**

Sim, é para isso que ele existe. Ele não depende da memória do agente: lê o
`historico.md`, o estado da feature e o git.

## Está funcionando se

- Você entende onde a feature está sem abrir nenhum arquivo.
- Divergências (tarefa marcada sem commit, artefato alterado) aparecem apontadas, não escondidas.

## Onde se encaixa

Uso avulso, no começo de uma sessão de trabalho. Vizinhas: [status](status.md),
para a visão do projeto inteiro, e [pendencias](pendencias.md), para o que
depende de você. O mapa está na [ajuda](ajuda.md).
