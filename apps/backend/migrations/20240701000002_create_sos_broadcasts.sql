-- Create table for SOS broadcast events triggered by circle members.
-- Each broadcast records the triggering user, the circle, the location at
-- time of trigger, and the resolution status.

CREATE TABLE IF NOT EXISTS sos_broadcasts (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    circle_id       UUID        NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    address         TEXT,
    status          TEXT        NOT NULL DEFAULT 'active'
                                CHECK (status IN ('active', 'resolved', 'dismissed')),
    resolved_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_broadcasts_circle
    ON sos_broadcasts (circle_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sos_broadcasts_user
    ON sos_broadcasts (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sos_broadcasts_status
    ON sos_broadcasts (status) WHERE status = 'active';
