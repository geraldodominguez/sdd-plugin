# Passo a passo: uma feature do começo ao fim

Este guia acompanha uma feature real, **redefinição de senha por e-mail**, num
projeto existente, no nível 2 (fluxo completo). Os artefatos que ela produz
estão em [exemplos/001-redefinicao-de-senha/](../../exemplos/001-redefinicao-de-senha/).

> No nível 1 o caminho é o mesmo, sem o `/sdd:planejar` e com uma spec mais
> curta. Ver [níveis de rigor](niveis-de-rigor.md).

## 0. Preparar o repositório, uma vez

```
/sdd:iniciar
```

O agente pergunta o nível padrão e a proteção, cria a estrutura, lê o projeto e
rascunha a constituição só com o que observou. **A sua parte:** revisar a
constituição com calma, porque ela vale para todas as features. Depois, faça
commit de `.sdd/`, `specs/`, `docs/adr/`, `CLAUDE.md` e `AGENTS.md`.

## 1. Especificar

```
/sdd:especificar permitir que o usuário redefina a senha por e-mail quando esquecer
```

O agente classifica ("nível 2: segurança, contrato de API novo e tabela nova;
confirma?"), cria `specs/001-redefinicao-de-senha/`, pede ao
`mapeador-de-contexto` o mapa do código de autenticação, escreve a spec e marca o
que não sabe:

```markdown
- [PRECISA ESCLARECER: quanto tempo o link deve valer?]
- [PRECISA ESCLARECER: o que responder quando o e-mail não está cadastrado?]
```

**A sua parte:** ler a spec e responder à pergunta "é isso que eu quero?".
Peça ajustes em linguagem natural.

## 2. Clarificar

```
/sdd:clarificar
```

> **1. Validade do link** (RF-002): por quanto tempo o link vale?
> - 15 minutos
> - **30 minutos (recomendado: equilíbrio entre segurança e e-mail lento)**
> - 24 horas
>
> **2. E-mail não cadastrado** (RF-001): o que o sistema responde?
> - **A mesma mensagem genérica (recomendado: evita enumeração de usuários)**
> - "E-mail não encontrado"

Você responde. A spec é atualizada e cada resposta vai para o histórico.

## 3. Planejar

```
/sdd:planejar
```

O `arquiteto-de-contratos` decide os componentes, desenha os contratos em
`contratos/` (entidade, interfaces, OpenAPI, DDL), preenche a checagem contra a
constituição e propõe um ADR: "guardar só o hash SHA-256 do token". **A sua
parte:** aprovar ou ajustar.

## 4. Tarefas

```
/sdd:tarefas
```

```markdown
## Grupo 1: contratos e fundação
- [ ] T-001 migration da tabela password_reset_tokens (atende: RNF-002, RF-005; depende de: nada)
- [ ] T-002 [P] entidade ResetToken com expiração, uso único e substituição (atende: RF-002, RF-004, RF-005, CA-003, CA-005, CA-006; depende de: nada)
- [ ] T-003 [P] TokenGenerator com hash SHA-256 (atende: RNF-002, CA-008; depende de: nada)

## Grupo 2: comportamento
- [ ] T-004 solicitar redefinição sem enumeração de usuários (atende: RF-001, CA-001, CA-002; depende de: T-001, T-002, T-003)
```

O `sdd-rastrear` confirma que todo requisito tem tarefa.

## 5. Implementar

```
/sdd:implementar
```

**Red.** O `escritor-de-testes` recebe só a spec, as tarefas e os contratos, e
escreve um teste por critério:

```ts
// sdd:001:CA-003
it('recusa link de redefinição com mais de 30 minutos', async () => { ... })
```

Os testes falham por falta de comportamento. O agente mostra a lista e pede um "ok".

**Green.** O agente implementa tarefa por tarefa, com os testes congelados. Se
tentar editar um teste, o hook bloqueia:

```
SDD (proteção leve) bloqueou a edição de 'tests/password-reset.test.ts' na fase 'green' da feature 001-redefinicao-de-senha.
Na fase green os testes estão congelados: implemente o código para fazê-los passar.
```

Cada tarefa vira um commit: `feat(001): T-004 solicitar redefinição sem enumeração`.

## 6. Auditar

```
/sdd:auditar main
```

O `auditor-de-drift` recebe só a pasta da feature e a ref base, e grava a
`auditoria.md`. Exemplo de achado:

> **Desvio #1 (média):** comportamento não especificado.
> `src/auth/password-reset.service.ts:25` registra o IP da solicitação, e nenhum
> requisito pede isso, com implicação de LGPD. **Delta spec proposta:** RNF-004,
> registro de IP para auditoria de segurança, com retenção de 90 dias.

**A sua decisão:** aprovar, aprovar a delta spec ou mandar corrigir o código.

## No dia a dia

| Situação | O que fazer |
|---|---|
| Não sei onde parei | `/sdd:status` |
| Pedi algo informal num projeto SDD | o agente classifica o nível e propõe `/sdd:especificar` |
| Duas features ao mesmo tempo | `sdd-estado usar 002-outra-feature` |
| A mudança cresceu no meio | `sdd-estado definir nivel=2` e siga para `/sdd:planejar` |
| Revisar o trabalho | revise a spec, não o diff: duas páginas bem lidas valem mais que duas mil linhas passadas por cima |
