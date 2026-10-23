-- Feature 001: tabela de tokens de redefinição de senha.
-- RNF-002: apenas o hash é armazenado.

CREATE TABLE password_reset_tokens (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  char(64)    NOT NULL UNIQUE,          -- sha256 hex
    status      text        NOT NULL DEFAULT 'active'
                            CHECK (status IN ('active', 'used', 'superseded')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    expires_at  timestamptz NOT NULL,
    used_at     timestamptz
);

-- RF-005: localizar rapidamente os tokens ativos de um usuário.
CREATE INDEX password_reset_tokens_user_active_idx
    ON password_reset_tokens (user_id)
    WHERE status = 'active';
