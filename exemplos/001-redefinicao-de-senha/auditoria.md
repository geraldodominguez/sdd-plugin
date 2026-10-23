# Auditoria 001-redefinicao-de-senha: Redefinição de senha por e-mail

| Campo | Valor |
|---|---|
| Auditada em | 2026-10-22 |
| Base da comparação | `main` (a1c93e0) até HEAD (7f20b4d) |
| Veredito | **aprovada com ressalvas** |

## 1. Cobertura de requisitos

| ID | Implementado? | Evidência | Teste |
|---|---|---|---|
| RF-001 | sim | `src/auth/password-reset.service.ts:21` | CA-001, CA-002 |
| RF-002 | sim | `src/auth/reset-token.ts:14` | CA-003, CA-005 |
| RF-003 | sim | `src/auth/password-reset.service.ts:47` | CA-004 |
| RF-004 | sim | `src/auth/password-reset.routes.ts:33` | CA-003, CA-005, CA-006 |
| RF-005 | sim | `src/auth/password-reset.service.ts:28` | CA-006 |
| RNF-001 | sim | `src/auth/password-reset.routes.ts:12` | CA-007 |
| RNF-002 | sim | `src/auth/token-generator.ts:9` | CA-008 |
| RNF-003 | sim | `src/auth/password-reset.service.ts:41` | CA-009 |

## 2. Critérios de aceitação

| CA | Teste com marca | Resultado | Observação |
|---|---|---|---|
| CA-001 | `tests/auth/password-reset.test.ts:18` | ✓ | |
| CA-002 | `tests/auth/password-reset.test.ts:31` | ✓ | Verifica também que o corpo é idêntico ao do CA-001 |
| CA-003 | `tests/auth/reset-token.test.ts:12` | ✓ | Usa `Clock` falso |
| CA-004 | `tests/auth/password-reset.test.ts:52` | ✓ | |
| CA-005 | `tests/auth/reset-token.test.ts:27` | ✓ | |
| CA-006 | `tests/auth/password-reset.test.ts:70` | ✓ | |
| CA-007 | `tests/auth/password-reset.test.ts:88` | ✓ | Cobre só o limite por e-mail; ver desvio #2 |
| CA-008 | `tests/auth/token-generator.test.ts:8` | ✓ | |
| CA-009 | `tests/auth/password-reset.test.ts:104` | ✓ | |

## 3. Desvios encontrados (drift)

| # | Tipo | Descrição | Onde | Gravidade |
|---|---|---|---|---|
| 1 | comportamento não especificado | O IP da solicitação é registrado no log `password_reset.requested`. Nenhum requisito pede isso; há implicação de LGPD. | `src/auth/password-reset.service.ts:25` | média |
| 2 | CA incompleto | RNF-001 define 20/h por IP, mas nenhum CA nem teste cobre o limite por IP. O limite está implementado (`routes.ts:12`). | spec, CA-007 | baixa |

## 4. Conformidade com a constituição

| Regra | Situação | Evidência |
|---|---|---|
| Domínio sem dependência de infra | ✓ | `reset-token.ts` sem imports de `infra/` |
| Validação na fronteira | ✓ | `password-reset.routes.ts:8` (zod) |
| Logs estruturados | ✓ | `src/auth/password-reset.service.ts:25` |
| Segredos nunca em claro | ✓ | ADR-0007 seguido |

## 5. Rastreabilidade (`sdd-rastrear`)

```
Rastreabilidade: specs/001-redefinicao-de-senha
  requisitos: 8 | critérios: 9 | arquivos de teste: 3
  ✓ Nenhuma lacuna encontrada.
```

## 6. Delta spec proposta

**Desvio #1**: o registro de IP parece intencional e útil para detectar abuso.
Proposta:

- **ADICIONADO RNF-004**: O SISTEMA DEVE registrar o IP de origem das
  solicitações de redefinição para auditoria de segurança, com retenção máxima
  de 90 dias.
- **ADICIONADO CA-010** (valida RNF-004): Dado uma solicitação, Quando ela é
  processada, Então o log contém o IP e não contém o e-mail em claro.

**Desvio #2**: adicionar CA-011 para o limite por IP.

## 7. Recomendação

Aprovar com a delta spec (RNF-004, CA-010, CA-011), adicionar os dois testes
correspondentes e confirmar com o responsável por LGPD a retenção de 90 dias.
Alternativa: remover o registro de IP e manter a spec como está.
