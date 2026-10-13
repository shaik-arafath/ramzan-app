-- Disable RLS on prayer_timings table
ALTER TABLE prayer_timings DISABLE ROW LEVEL SECURITY;

-- Or if you want to keep RLS enabled, use this instead:
-- ALTER TABLE prayer_timings ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Admins can manage prayer_timings" ON prayer_timings
--   FOR ALL USING (
--     EXISTS (
--       SELECT 1 FROM user_profiles 
--       WHERE user_id = auth.uid() AND role = 'admin'
--     )
--   );
