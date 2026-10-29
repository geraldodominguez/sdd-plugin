# Transição {{FEATURE}}: de outro processo para o SDD

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
| Feature | {{FEATURE}} |
| Adotada em | {{DATA}} |
| Fase de destino | {{especificacao, plano, tarefas ou red}} |
| Por quê | {{o que já existia e justifica o destino, com evidência no código}} |

## Como era

### Arquivos

O conteúdo original de cada arquivo está no git: o hash abaixo é o do arquivo
como ele chegou, antes da conversão (`git log --follow <arquivo>`).

| Arquivo original | Hash do original | Agora em |
|---|---|---|
{{ARQUIVOS}}

### Situação encontrada

{{o que estava feito, o que estava em andamento e o que nem tinha começado,
com caminho:linha do código que comprova cada afirmação}}

## Como vai ficar

### Requisitos e critérios

| Como era (trecho original) | Como vai ficar |
|---|---|
| {{texto do arquivo original}} | {{RF-001, CA-001}} |

### Tarefas

| Como era (linha original) | Como vai ficar | Marca |
|---|---|---|
| {{`- [x] fazer o login`}} | {{T-001}} | {{O: feita fora do plugin}} |
| {{`- [ ] redefinir senha`}} | {{T-004}} | {{aberta: o plugin continua daqui}} |

### Testes que já existiam

A marca é acrescentada na fase red, quando os testes podem ser editados.

| Arquivo | Teste | Cobre | Marca a acrescentar |
|---|---|---|---|
| {{tests/login.test.ts}} | {{"entra com e-mail e senha"}} | {{CA-001}} | {{`sdd:NNN:CA-001`}} |

## O que ficou de fora

{{trechos do original que não viraram requisito nem tarefa, e para onde foram
(backlog, legado, descartados com o motivo); ou "nada"}}
