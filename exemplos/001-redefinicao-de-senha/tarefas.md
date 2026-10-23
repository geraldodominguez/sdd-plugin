# Tarefas 001-redefinicao-de-senha: Redefinição de senha por e-mail

## Grupo 1: contratos e fundação

- [x] T-001 migration da tabela password_reset_tokens (atende: RNF-002, RF-005; depende de: nada)
- [x] T-002 [P] entidade ResetToken com expiração, uso único e substituição (atende: RF-002, RF-004, RF-005, CA-003, CA-005, CA-006; depende de: nada)
- [x] T-003 [P] TokenGenerator com hash SHA-256 (atende: RNF-002, CA-008; depende de: nada)

## Grupo 2: comportamento

- [x] T-004 solicitar redefinição sem enumeração de usuários (atende: RF-001, CA-001, CA-002; depende de: T-001, T-002, T-003)
- [x] T-005 concluir redefinição e encerrar sessões (atende: RF-003, CA-004; depende de: T-004)
- [x] T-006 [P] validar política de senha sem consumir o token (atende: RNF-003, CA-009; depende de: T-004)

## Grupo 3: integração e acabamento

- [x] T-007 rate limit por e-mail e por IP (atende: RNF-001, CA-007; depende de: T-004)
- [x] T-008 rotas HTTP e mapeamento de erros de domínio (atende: RF-004, CA-003, CA-005, CA-006; depende de: T-005, T-006)

## Grupo 4: delta da auditoria

- [x] T-009 testes do registro de IP e do limite por IP (atende: RNF-004, CA-010, CA-011; depende de: T-007)

## Definição de pronto da feature

- [x] Todo CA tem teste com a marca `sdd:001:CA-XXX`, e todos estão verdes
- [x] `sdd-rastrear` sem lacunas
- [x] Lint e checagem de tipos sem erros
- [x] Auditoria (`/sdd:auditar`) aprovada
