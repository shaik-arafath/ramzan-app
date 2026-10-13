-- Clean up time format - convert to lowercase
UPDATE timetable SET 
  fajr = LOWER(REPLACE(fajr, ' : ', ':')),
  dhuhr = LOWER(REPLACE(dhuhr, ' : ', ':')),
  asr = LOWER(REPLACE(asr, ' : ', ':')),
  maghrib = LOWER(REPLACE(maghrib, ' : ', ':')),
  isha = LOWER(REPLACE(isha, ' : ', ':'));
