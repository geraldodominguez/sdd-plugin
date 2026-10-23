# Spec 001-redefinicao-de-senha: Redefinição de senha por e-mail

| Campo | Valor |
|---|---|
| Nível | 2 (completo) |
| Situação | aprovada |
| Criada em | 2026-10-20 |
| Contexto | [contexto.md](./contexto.md) |
| Origem | B-001 |

## 1. Contexto e objetivo

**Problema:** usuários que esquecem a senha abrem chamado no suporte, com espera
média de 1 dia útil.

**Objetivo:** permitir que o próprio usuário redefina a senha com segurança, por
e-mail.

**Quem se beneficia:** usuários finais e equipe de suporte.

**Indicador de sucesso:** queda de 80% nos chamados de "esqueci a senha" em 60 dias.

## 2. Histórias de usuário

- **US-001**: Como usuário que esqueceu a senha, quero receber um link por e-mail, para definir uma nova senha sem depender do suporte.

## 3. Requisitos funcionais

- **RF-001**: QUANDO alguém solicitar redefinição informando um e-mail, O SISTEMA DEVE responder com a mesma mensagem genérica, exista ou não uma conta com esse e-mail, e enviar o link apenas se a conta existir.
- **RF-002**: O SISTEMA DEVE gerar links de redefinição válidos por 30 minutos e de uso único.
- **RF-003**: QUANDO o usuário definir uma nova senha com um link válido, O SISTEMA DEVE substituir a senha, invalidar o link e encerrar todas as sessões abertas do usuário.
- **RF-004**: SE o link estiver expirado, já utilizado ou for inválido, ENTÃO O SISTEMA DEVE recusar a redefinição e oferecer o envio de um novo link.
- **RF-005**: QUANDO uma nova solicitação for feita para a mesma conta, O SISTEMA DEVE invalidar os links anteriores ainda não utilizados.

## 4. Requisitos não funcionais

- **RNF-001**: O SISTEMA DEVE limitar as solicitações a 5 por hora por e-mail e 20 por hora por IP.
- **RNF-002**: O SISTEMA DEVE armazenar apenas o hash do token, nunca o token em claro.
- **RNF-003**: A nova senha DEVE seguir a política vigente do cadastro (mínimo de 10 caracteres).
- **RNF-004**: O SISTEMA DEVE registrar o IP de origem das solicitações de redefinição para auditoria de segurança, sem o e-mail em claro, com retenção máxima de 90 dias. *(Adicionado pela [delta spec](./delta-spec.md) da auditoria de 2026-10-22.)*

## 5. Critérios de aceitação

- **CA-001** (valida RF-001)
  - **Dado** uma conta com o e-mail `ana@exemplo.com`
  - **Quando** é solicitada a redefinição para `ana@exemplo.com`
  - **Então** a resposta é 202 com a mensagem genérica
  - **E** um e-mail com o link é enviado para `ana@exemplo.com`

- **CA-002** (valida RF-001)
  - **Dado** que não existe conta com `ninguem@exemplo.com`
  - **Quando** é solicitada a redefinição para `ninguem@exemplo.com`
  - **Então** a resposta é 202 com a **mesma** mensagem genérica
  - **E** nenhum e-mail é enviado

- **CA-003** (valida RF-002, RF-004)
  - **Dado** um link gerado há 31 minutos
  - **Quando** o usuário tenta redefinir a senha com ele
  - **Então** a resposta é 410 com o código `RESET_LINK_EXPIRED`
  - **E** a senha não é alterada

- **CA-004** (valida RF-003)
  - **Dado** um link válido e o usuário com duas sessões abertas
  - **Quando** ele define a nova senha `nova-senha-segura`
  - **Então** o login funciona com a nova senha
  - **E** as duas sessões anteriores deixam de ser aceitas

- **CA-005** (valida RF-002, RF-004)
  - **Dado** um link já utilizado com sucesso
  - **Quando** é usado de novo
  - **Então** a resposta é 410 com o código `RESET_LINK_USED`

- **CA-006** (valida RF-005)
  - **Dado** dois links solicitados em sequência para a mesma conta
  - **Quando** o primeiro link é usado
  - **Então** a resposta é 410 com o código `RESET_LINK_SUPERSEDED`

- **CA-007** (valida RNF-001)
  - **Dado** 5 solicitações para o mesmo e-mail na última hora
  - **Quando** é feita a sexta solicitação
  - **Então** a resposta é 429

- **CA-008** (valida RNF-002)
  - **Dado** um link recém-gerado
  - **Quando** a tabela de tokens é consultada
  - **Então** o valor do token enviado por e-mail não aparece em nenhuma coluna

- **CA-009** (valida RNF-003)
  - **Dado** um link válido
  - **Quando** o usuário define a senha `curta`
  - **Então** a resposta é 422 com o código `PASSWORD_POLICY`
  - **E** o link continua válido

- **CA-010** (valida RNF-004)
  - **Dado** uma solicitação de redefinição vinda do IP `203.0.113.7`
  - **Quando** ela é processada
  - **Então** o log `password_reset.requested` contém o IP
  - **E** não contém o e-mail em claro

- **CA-011** (valida RNF-001)
  - **Dado** 20 solicitações do mesmo IP na última hora, para e-mails diferentes
  - **Quando** é feita a 21ª solicitação
  - **Então** a resposta é 429

## 6. Escopo

**Dentro do escopo:** solicitação por e-mail, link de uso único, definição da
nova senha, encerramento de sessões.

**Fora do escopo (explicitamente):**
- redefinição por SMS ou app autenticador;
- alteração de senha por usuário logado (feature separada);
- telas de front-end (esta feature entrega a API).

## 7. Restrições e premissas

- Mensagens ao usuário em português.
- Reaproveitar o serviço de e-mail existente.

## 8. Riscos e dependências

- Entregabilidade do e-mail (fora do controle do sistema).

## 9. Dúvidas em aberto

Nenhuma.

## 10. Histórico de clarificação

| Data | Pergunta | Resposta | Seção alterada |
|---|---|---|---|
| 2026-10-20 | Validade do link? | 30 minutos | RF-002, CA-003 |
| 2026-10-20 | Resposta para e-mail não cadastrado? | Mesma mensagem genérica (evita enumeração) | RF-001, CA-002 |
| 2026-10-20 | Encerrar sessões abertas ao trocar a senha? | Sim, todas | RF-003, CA-004 |
| 2026-10-20 | Nova solicitação invalida links anteriores? | Sim | RF-005, CA-006 (novo) |
| 2026-10-22 | Delta da auditoria: manter o registro de IP? | Sim, com retenção de 90 dias (confirmado com o responsável por LGPD) | RNF-004, CA-010, CA-011 (novos) |
