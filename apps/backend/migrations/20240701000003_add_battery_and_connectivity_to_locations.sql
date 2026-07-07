-- Add battery_level and connectivity_type to member_locations
ALTER TABLE member_locations
ADD COLUMN battery_level INTEGER,
ADD COLUMN connectivity_type VARCHAR(20);
