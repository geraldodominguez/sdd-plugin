# Constituição do projeto {{NOME_DO_PROJETO}}

> Regras inegociáveis que valem para **todas** as features. Todo plano é
> checado contra este documento. Alterar a constituição é uma decisão
> arquitetural: registre um ADR em `docs/adr/`.
>
> Preencha os campos `{{...}}` e apague o que não se aplica. Seja
> específico: "usar boas práticas" não é verificável; "toda função pública
> tem teste" é.

## 1. Propósito

{{Uma ou duas frases: o que este sistema faz e para quem.}}

## 2. Stack obrigatória

| Camada | Tecnologia | Versão mínima | Observação |
|---|---|---|---|
| Linguagem | {{ex.: TypeScript}} | {{5.x}} | |
| Runtime ou framework | {{ex.: Node 22, NestJS}} | | |
| Banco de dados | {{ex.: PostgreSQL 16 com pgvector}} | | |
| Testes | {{ex.: Vitest}} | | |
| Infraestrutura | {{ex.: Docker, Hetzner}} | | |

Dependências novas exigem justificativa no plano (seção "Dependências").

## 3. Arquitetura

- **Estilo:** {{ex.: domain-first ou hexagonal; o domínio não depende de infraestrutura}}
- **Camadas e direção de dependência:** {{ex.: interface depende de aplicação, que depende de domínio}}
- **Onde ficam os contratos:** {{ex.: src/domain/contracts/}}
- **Proibido:** {{ex.: regra de negócio em controllers; acesso ao banco fora dos repositórios}}

## 4. Qualidade e testes

- {{ex.: Teste primeiro: nenhum código de produção sem um teste falhando antes.}}
- {{ex.: Todo critério de aceitação tem ao menos um teste com a marca `sdd:NNN:CA-XXX`.}}
- {{ex.: Cobertura mínima de 80% nas camadas de domínio e aplicação.}}
- {{ex.: Lint e checagem de tipos sem erros para fazer merge.}}

## 5. Segurança e dados

- {{ex.: Segredos só em variáveis de ambiente, nunca no repositório.}}
- {{ex.: Dados pessoais seguem a LGPD: minimização, finalidade e base legal registrada.}}
- {{ex.: Toda entrada externa é validada na fronteira, por schema.}}

## 6. Convenções

- **Commits:** `tipo(NNN): T-XXX descrição`, por exemplo `feat(004): T-002 valida token expirado`
- **Branches:** {{ex.: feat/NNN-slug}}
- **Nomenclatura:** {{ex.: código em inglês, documentação em português}}

## 7. Observabilidade e operação

- {{ex.: Logs estruturados em JSON, com correlation id.}}
- {{ex.: Toda falha de integração externa é registrada e tem retry com backoff.}}

## 8. Exceções aprovadas

| Regra | Exceção | Motivo | ADR |
|---|---|---|---|
| | | | |
