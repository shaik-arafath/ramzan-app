-- Check if user email is confirmed
SELECT id, email, email_confirmed_at, confirmed_at, created_at 
FROM auth.users 
WHERE id = '2ddca7db-b2c7-4013-bc8b-56615a46d4af';
