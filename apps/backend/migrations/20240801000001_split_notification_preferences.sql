-- Restructure notification preferences and location pause
ALTER TABLE users
  DROP COLUMN IF EXISTS notifications_enabled,
  ADD COLUMN IF NOT EXISTS notify_sos BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS notify_broadcast BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS notify_new_member BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS location_paused_until TIMESTAMPTZ;
