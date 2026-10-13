-- Insert user profile with email for existing auth user
INSERT INTO user_profiles (user_id, full_name, email, role, created_at, updated_at)
VALUES (
  '2ddca7db-b2c7-4013-bc8b-56615a46d4af',
  'arafathshaik',
  'arafathshaik121@gmail.com',
  'admin',
  NOW(),
  NOW()
)
ON CONFLICT (user_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  updated_at = NOW();
