-- Add email column to user_profiles table
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Update existing records with email from auth.users
UPDATE user_profiles 
SET email = (
  SELECT email 
  FROM auth.users 
  WHERE auth.users.id = user_profiles.user_id
);

-- Create a trigger to automatically sync email from auth.users
CREATE OR REPLACE FUNCTION sync_user_email()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO user_profiles (user_id, email, full_name, role, created_at, updated_at)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name', 'user', NOW(), NOW())
    ON CONFLICT (user_id) DO UPDATE SET
      email = EXCLUDED.email,
      updated_at = NOW();
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE user_profiles
    SET email = NEW.email
    WHERE user_id = NEW.id;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_change ON auth.users;
CREATE TRIGGER on_auth_user_change
AFTER INSERT OR UPDATE ON auth.users
FOR EACH ROW EXECUTE FUNCTION sync_user_email();
