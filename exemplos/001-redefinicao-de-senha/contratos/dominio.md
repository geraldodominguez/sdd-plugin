# Contratos de domínio da feature 001

> Só assinaturas e invariantes. Nenhuma regra implementada aqui.

## Entidade `ResetToken`

```ts
type ResetTokenStatus = 'active' | 'used' | 'superseded';

interface ResetToken {
  readonly id: string;          // uuid
  readonly userId: string;
  readonly tokenHash: string;   // sha256 hex (RNF-002)
  readonly createdAt: Date;
  readonly expiresAt: Date;     // createdAt + 30 min (RF-002)
  readonly status: ResetTokenStatus;
}
```

**Invariantes:**

- `expiresAt - createdAt = 30 min` (RF-002)
- só tokens `active` e não expirados podem ser consumidos (RF-002, RF-004)
- consumir muda `status` para `used`, de forma irreversível (RF-002)
- um novo token para o mesmo usuário torna os `active` anteriores `superseded` (RF-005)

## Erros de domínio

```ts
type ResetError =
  | { code: 'RESET_LINK_EXPIRED' }      // CA-003
  | { code: 'RESET_LINK_USED' }         // CA-005
  | { code: 'RESET_LINK_SUPERSEDED' }   // CA-006
  | { code: 'RESET_LINK_INVALID' }
  | { code: 'PASSWORD_POLICY' };        // CA-009
```

## Interfaces

```ts
interface ResetTokenRepository {
  save(token: ResetToken): Promise<void>;
  findByHash(tokenHash: string): Promise<ResetToken | null>;
  supersedeActiveFor(userId: string): Promise<void>;
  markUsed(id: string): Promise<void>;
}

interface TokenGenerator {
  generate(): { plain: string; hash: string }; // plain vai no e-mail; hash é persistido
}

interface Clock {
  now(): Date;
}

interface PasswordResetService {
  requestReset(email: string): Promise<void>;                                   // RF-001, RF-005
  completeReset(plainToken: string, newPassword: string): Promise<ResetError | null>; // RF-003, RF-004
}
```
