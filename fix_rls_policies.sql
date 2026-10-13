-- Disable RLS on user_profiles to fix the "granting user" error
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Ramzan app tables
ALTER TABLE bayans DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE timetable DISABLE ROW LEVEL SECURITY;

-- Note: After fixing, you can re-enable RLS with proper policies
