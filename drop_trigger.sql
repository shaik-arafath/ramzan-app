-- Drop the trigger that might be causing the issue
DROP TRIGGER IF EXISTS on_auth_user_change ON auth.users;

-- Drop the function
DROP FUNCTION IF EXISTS sync_user_email();
