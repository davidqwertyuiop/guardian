-- Add preferences to users table
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS location_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN NOT NULL DEFAULT FALSE;
