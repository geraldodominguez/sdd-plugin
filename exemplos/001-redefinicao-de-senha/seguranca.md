# Revisão de segurança 001-redefinicao-de-senha: Redefinição de senha por e-mail

| Campo | Valor |
|---|---|
| Revisada em | 2026-10-22 (segunda rodada, depois da correção de S-001) |
| Base da comparação | `develop` (a1c93e0) até HEAD (6e41b0a) |
| Veredito | **aprovada com riscos aceitos** |

> Escrita pelo subagent `revisor-de-seguranca`, com contexto limpo. Ele não
> corrige nada: aponta os riscos e recomenda. A decisão (aprovar, aceitar o
> risco ou corrigir) é humana, pelo `/sdd:aprovar`.

## 1. Superfície de ataque

| Entrada | Quem alcança | Dados que trafegam | Validação |
|---|---|---|---|
| `POST /auth/password-reset` | qualquer pessoa, sem login | e-mail | formato de e-mail, limite por e-mail e por IP (RNF-001) |
| `POST /auth/password-reset/confirm` | quem tem o link | token, nova senha | token pelo hash, política de senha (RNF-003) |
| E-mail com o link | dono da caixa de e-mail | token em claro, na URL | token de 256 bits, 30 minutos, uso único |

## 2. Modelagem de ameaças (STRIDE)

| Ameaça | Categoria | Onde | Mitigação existente | Situação |
|---|---|---|---|---|
| Descobrir quais e-mails têm conta | vazamento de informação | `POST /auth/password-reset` | resposta idêntica (RF-001, CA-002) | mitigada |
| Adivinhar um token válido | falsificação de identidade | `confirm` | 256 bits aleatórios, 30 minutos, limite por IP | mitigada |
| Medir o tempo de comparação do token | vazamento de informação | `reset-token.repository.ts` | comparação em tempo constante (correção de S-001) | mitigada |
| Token vazado do banco | falsificação de identidade | tabela `password_reset_tokens` | só o hash SHA-256 é guardado (RNF-002, ADR-0007) | mitigada |
| Sessão antiga continua ativa depois da troca | elevação de privilégio | `password-reset.service.ts` | todas as sessões são encerradas (RF-003) | mitigada |
| Inundar a caixa de alguém com e-mails | negação de serviço | `POST /auth/password-reset` | 5 por hora por e-mail (RNF-001) | mitigada |
| Negar ter pedido a redefinição | repúdio | `password-reset.service.ts` | IP registrado (RNF-004, da delta spec) | mitigada |

## 3. Varreduras automáticas

| Varredura | Comando | Resultado |
|---|---|---|
| Dependências vulneráveis | `npm audit --omit=dev` | 0 vulnerabilidades |
| Segredos no código | `gitleaks detect --no-banner` | nenhum segredo |
| Análise estática | `semgrep --config p/owasp-top-ten src/auth` | 0 achados (na primeira rodada, 1: S-001) |

## 4. Dados pessoais (LGPD)

| Dado | Finalidade | Base legal | Retenção | Proteção |
|---|---|---|---|---|
| E-mail | enviar o link | execução de contrato | o da conta | não aparece em log (conferido em `logger.ts`) |
| IP da solicitação | auditoria de segurança | legítimo interesse | 90 dias (RNF-004) | tabela separada, sem o e-mail |

## 5. Achados

| # | Gravidade | Achado | Onde (arquivo:linha) | Recomendação |
|---|---|---|---|---|
| S-001 | alta | **Corrigido.** O hash do token era comparado com `===`, sujeito a ataque de tempo. | `src/auth/reset-token.repository.ts:31` | `crypto.timingSafeEqual` |
| S-002 | baixa | A página de link expirado mostra o horário do servidor, o que revela o fuso e ajuda a calcular a janela de validade. | `src/auth/password-reset.routes.ts:58` | remover o horário da mensagem |

## 6. Conformidade com a constituição (seção de segurança)

| Regra | Situação | Evidência |
|---|---|---|
| Segredos só por variável de ambiente | cumpre | `RESET_LINK_BASE_URL` em `config.ts` |
| Nenhum dado pessoal em log | cumpre | `logger.ts` mascara e-mail |
| Toda rota pública tem limite de requisições | cumpre | `password-reset.routes.ts:12` |

## 7. Recomendação

Aprovar aceitando S-002, que tem baixo impacto e já está no backlog para a
próxima sprint.

## Decisão

| Achado | Decisão | Por | Justificativa |
|---|---|---|---|
| S-001 | corrigir (primeira rodada) | Geraldo Dominguez | gravidade alta |
| S-002 | aceitar o risco | Geraldo Dominguez | baixo impacto; corrigido no B-007, até 2026-11-14 |
