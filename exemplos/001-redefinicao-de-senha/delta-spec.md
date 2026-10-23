# Delta spec 001-redefinicao-de-senha

> Proposta de mudança na spec para absorver uma divergência considerada
> **correta**. Só entra na spec depois de aprovação humana.

| Campo | Valor |
|---|---|
| Origem | auditoria de 2026-10-22, desvios #1 e #2 |
| Situação | aprovada |

## Motivo

O serviço passou a registrar o IP de cada solicitação, o que nenhum requisito
pedia. O registro é útil para detectar abuso e foi mantido, com retenção limitada
por causa da LGPD. A auditoria também notou que o limite por IP do RNF-001 não
tinha critério nem teste.

## Alterações

### Adicionado

- **RNF-004**: O SISTEMA DEVE registrar o IP de origem das solicitações de redefinição para auditoria de segurança, sem o e-mail em claro, com retenção máxima de 90 dias.
- **CA-010** (valida RNF-004): o log da solicitação contém o IP e não contém o e-mail.
- **CA-011** (valida RNF-001): a 21ª solicitação do mesmo IP na mesma hora recebe 429.

### Modificado

Nada.

### Removido

Nada.

## Impacto

- Testes afetados: dois testes novos (CA-010 e CA-011), na tarefa T-009.
- Contratos afetados: nenhum.
- Precisa de ADR? Não: a retenção de 90 dias foi registrada na spec.
