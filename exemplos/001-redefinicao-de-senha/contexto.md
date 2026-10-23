# Contexto 001-redefinicao-de-senha: o que a mudança toca

## Pedido analisado

Permitir que o usuário redefina a senha por e-mail quando esquecer.

## Pontos de entrada afetados

| Arquivo | Símbolo | Papel |
|---|---|---|
| `src/auth/auth.routes.ts:12` | `router.post('/login')` | Rotas de autenticação; a nova rota entra aqui |
| `src/auth/auth.service.ts:30` | `AuthService.login()` | Valida credenciais; usa `hashPassword()` |
| `src/auth/password.ts:5` | `hashPassword()`, `verifyPassword()` | bcrypt, custo 12 |
| `src/notifications/email.service.ts:18` | `EmailService.send()` | Envio via SMTP; já tem retry (3x) |
| `src/users/user.repository.ts:22` | `findByEmail()` | Busca case-insensitive |

## Modelo de dados envolvido

| Tabela / entidade | Campos relevantes | Onde é definido |
|---|---|---|
| `users` | `id uuid`, `email citext unique`, `password_hash text`, `updated_at` | `db/migrations/0003_users.sql` |

Não existe tabela de tokens.

## Contratos existentes

- `POST /auth/login`: resposta de erro padronizada `{ code, message }` (`src/http/errors.ts:8`).
- Evento `user.password_changed`? **Não existe.** Há eventos `user.created` em `src/events/user.events.ts`.

## Testes existentes relacionados

- `tests/auth/login.test.ts`: cobre login (sucesso, senha errada, usuário inexistente).
- `tests/notifications/email.test.ts`: usa `FakeEmailTransport`.

## Riscos de impacto

- `AuthService` mantém sessões em `sessions` (`src/auth/session.store.ts`). Trocar a senha **não** invalida sessões hoje.
- Rate limiting existe só para `/auth/login` (`src/http/rate-limit.ts:14`, 10 req/min por IP).

## Perguntas que o código não responde

- Trocar a senha deve encerrar as sessões abertas?
- Qual a validade desejada do link?
- O que responder quando o e-mail não está cadastrado?
