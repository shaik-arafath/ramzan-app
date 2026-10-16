-- Disable email confirmation for new signups
ALTER TABLE auth.users 
ALTER COLUMN email_confirmed_at SET DEFAULT NOW();

-- Update existing users to be confirmed
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;
