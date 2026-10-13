-- Clear existing timetable data
DELETE FROM timetable;

-- Copy data from prayer_timings to timetable
INSERT INTO timetable (date, sehri_time, iftar_time, fajr, dhuhr, asr, maghrib, isha, created_at, updated_at)
SELECT 
  TO_DATE(date, 'DD / MM / YYYY') as date,
  NULL as sehri_time,
  NULL as iftar_time,
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
  NOW(),
  NOW()
FROM prayer_timings;
