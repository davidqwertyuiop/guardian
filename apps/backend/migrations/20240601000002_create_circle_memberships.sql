-- Guardian: Circle memberships (many-to-many: users ↔ circles)
CREATE TABLE IF NOT EXISTS circle_memberships (
  id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id UUID        NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
  user_id   UUID        NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
  role      VARCHAR(20) NOT NULL DEFAULT 'member',  -- 'owner' | 'member'
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(circle_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_cm_user_id   ON circle_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_cm_circle_id ON circle_memberships(circle_id);
