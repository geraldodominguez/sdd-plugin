# ADR-0007: Armazenar apenas o hash SHA-256 do token de redefinição

| Campo | Valor |
|---|---|
| Situação | aceita |
| Data | 2026-10-21 |
| Feature de origem | 001-redefinicao-de-senha |

## Contexto

Tokens de redefinição dão acesso à conta. Se a tabela vazar (backup, réplica,
SQL injection), tokens em claro e ainda válidos permitiriam tomar contas.

## Decisão

Persistir somente `sha256(token)` em hexadecimal. O token em claro existe só na
memória do processo e no e-mail enviado.

## Alternativas consideradas

| Alternativa | Prós | Contras | Por que não |
|---|---|---|---|
| Token em claro | Simples | Vazamento = tomada de conta | Viola RNF-002 |
| bcrypt/argon2 do token | Resistente a força bruta | Impede busca por índice; lento sem necessidade | Token de 32 bytes aleatórios já tem entropia suficiente |
| JWT assinado sem persistência | Sem tabela | Não permite uso único nem invalidação (RF-002, RF-005) | Requisitos exigem estado |

## Consequências

- **Positivas:** um vazamento da tabela não expõe tokens utilizáveis.
- **Negativas:** não dá para reenviar o mesmo link; um novo é sempre gerado.
- **O que passa a ser obrigatório:** qualquer token de uso único do sistema segue este padrão. Proposto para a constituição, seção 5.
