-- Guardian: User device sessions (multi-device support)
-- One user can sign in on multiple devices.
-- Each device gets a unique session row tied to its refresh token.
CREATE TABLE IF NOT EXISTS user_sessions (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  -- Human-readable device name chosen by the user (e.g. "iPhone 15 Pro")
  device_name     VARCHAR(100) NOT NULL,
  -- OS + device model fingerprint for display in Settings
  device_model    VARCHAR(100),           -- e.g. "iPhone 16 Pro"
  platform        VARCHAR(10) NOT NULL CHECK (platform IN ('ios', 'android')),
  -- Hashed refresh token — only the hash is stored, never the raw token
  refresh_token_hash TEXT NOT NULL UNIQUE,
  -- When the refresh token expires (matches JWT exp)
  expires_at      TIMESTAMPTZ NOT NULL,
  last_active_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(refresh_token_hash);
