# Autenticação

| Campo | Valor |
|---|---|
| Capacidade | autenticacao |
| Criada em | 2026-10-22 |
| Atualizada em | 2026-11-11 |
| Última feature | 003-invalidar-link-apos-o-uso |

> **Spec viva do sistema.** Este arquivo diz o que o sistema FAZ HOJE nesta
> capacidade. Ele não conta a história (isso está nas features, em `specs/`):
> mostra só o comportamento vigente. Quando uma feature que toca esta
> capacidade fica pronta, os requisitos dela entram aqui, substituindo os que
> ela mudou. Cada item cita a origem no formato `origem: NNN/ID`.

## Propósito

Permite que o usuário prove quem é e recupere o acesso à própria conta sem
depender do suporte. Login e cadastro existiam antes do SDD e ainda não foram
mapeados; esta capacidade cobre, por enquanto, a recuperação de acesso.

## Comportamento vigente

### Requisitos funcionais

- QUANDO alguém solicitar redefinição informando um e-mail, O SISTEMA DEVE responder com a mesma mensagem genérica, exista ou não uma conta com esse e-mail, e enviar o link apenas se a conta existir. (origem: 001/RF-001)
- O SISTEMA DEVE gerar links de redefinição válidos por 30 minutos e de uso único. (origem: 001/RF-002)
- QUANDO duas confirmações chegarem ao mesmo tempo com o mesmo link, O SISTEMA DEVE aceitar no máximo uma. (origem: 003/RF-001)
- QUANDO o usuário definir uma nova senha com um link válido, O SISTEMA DEVE substituir a senha, invalidar o link e encerrar todas as sessões abertas do usuário. (origem: 001/RF-003)
- SE o link estiver expirado, já utilizado ou for inválido, ENTÃO O SISTEMA DEVE recusar a redefinição e oferecer o envio de um novo link. (origem: 001/RF-004)
- QUANDO uma nova solicitação for feita para a mesma conta, O SISTEMA DEVE invalidar os links anteriores ainda não utilizados. (origem: 001/RF-005)

### Requisitos não funcionais

- O SISTEMA DEVE limitar as solicitações de redefinição a 5 por hora por e-mail e 20 por hora por IP. (origem: 001/RNF-001)
- O SISTEMA DEVE armazenar apenas o hash do token de redefinição, nunca o token em claro. (origem: 001/RNF-002)
- A nova senha DEVE seguir a política vigente do cadastro (mínimo de 10 caracteres). (origem: 001/RNF-003)
- O SISTEMA DEVE registrar o IP de origem das solicitações de redefinição, sem o e-mail em claro, com retenção máxima de 90 dias. (origem: 001/RNF-004)

### Regras de negócio

- A resposta a um pedido de redefinição nunca revela se o e-mail tem conta. (origem: 001/RF-001)

## Contratos públicos

| Contrato | Onde está | Origem |
|---|---|---|
| `POST /auth/password-reset` | `specs/001-redefinicao-de-senha/contratos/api.yaml` | 001 |
| `POST /auth/password-reset/confirm` | `specs/001-redefinicao-de-senha/contratos/api.yaml` | 001 |
| tabela `password_reset_tokens` | `specs/001-redefinicao-de-senha/contratos/persistencia.sql` | 001 |

## Fora desta capacidade

- O envio do e-mail em si (fila, provedor, modelo): capacidade `notificacoes`.
- Perfil do usuário e data do último acesso: capacidade `perfil` (feature 002).

## Histórico de consolidação

> Uma linha por feature consolidada, gravada pelo `sdd-sistema consolidar`.

| Data | Feature | Título |
|---|---|---|
| 2026-10-22 | 001 | Redefinição de senha por e-mail |
| 2026-11-11 | 003 | Invalidar link após o uso |
