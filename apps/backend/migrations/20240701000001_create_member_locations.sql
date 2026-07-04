-- Create table for storing the live location of each circle member.
-- Location is upserted on each device ping (PUT /api/v1/location).
-- Indexed on circle_id + user_id for fast member-location fan-out queries.

CREATE TABLE IF NOT EXISTS member_locations (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    circle_id   UUID        NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
    latitude    DOUBLE PRECISION NOT NULL,
    longitude   DOUBLE PRECISION NOT NULL,
    accuracy    REAL,
    heading     REAL,
    speed       REAL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT member_locations_user_circle_unique UNIQUE (user_id, circle_id)
);

CREATE INDEX IF NOT EXISTS idx_member_locations_circle
    ON member_locations (circle_id);

CREATE INDEX IF NOT EXISTS idx_member_locations_user
    ON member_locations (user_id);
