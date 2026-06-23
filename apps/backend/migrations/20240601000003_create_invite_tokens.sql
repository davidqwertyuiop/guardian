-- Guardian: Invite tokens
-- code  → 4-char human-readable, expires 3 days
-- token → URL-safe 32-byte random, expires 60 days
CREATE TABLE IF NOT EXISTS invite_tokens (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id       UUID        NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
  code            CHAR(4)     NOT NULL,
  token           TEXT        NOT NULL UNIQUE,
  created_by      UUID        NOT NULL REFERENCES users(id),
  code_expires_at TIMESTAMPTZ NOT NULL,   -- NOW() + 3 days
  link_expires_at TIMESTAMPTZ NOT NULL,   -- NOW() + 60 days
  used_count      INT         NOT NULL DEFAULT 0,
  max_uses        INT,                    -- NULL = unlimited
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index on code to quickly lookup invites
CREATE INDEX IF NOT EXISTS idx_invite_code_active ON invite_tokens(code);

CREATE INDEX IF NOT EXISTS idx_invite_token ON invite_tokens(token);
CREATE INDEX IF NOT EXISTS idx_invite_circle ON invite_tokens(circle_id);
