-- Insert user profile for existing auth user
-- Run this in Supabase SQL Editor

INSERT INTO user_profiles (user_id, full_name, role, created_at, updated_at)
VALUES (
  '2ddca7db-b2c7-4013-bc8b-56615a46d4af',
  'arafathshaik',
  'admin',
  NOW(),
  NOW()
)
ON CONFLICT (user_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  updated_at = NOW();
