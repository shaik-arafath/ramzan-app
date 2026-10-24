-- Insert sample masjids (run this if table already exists but is empty)
INSERT INTO masjids (name, address, city, state, latitude, longitude, phone, fajr_time, dhuhr_time, asr_time, maghrib_time, isha_time, jummah_time, description) VALUES
('Makkah Masjid', 'Charminar, Hyderabad', 'Hyderabad', 'Telangana', 17.3616, 78.4747, '+91-40-23456789', '05:30', '12:30', '15:45', '18:15', '19:45', '13:30', 'Historical mosque near Charminar'),
('Jama Masjid', 'Pathargatti, Hyderabad', 'Hyderabad', 'Telangana', 17.3633, 78.4695, '+91-40-23456790', '05:25', '12:25', '15:40', '18:10', '19:40', '13:25', 'One of the largest mosques in Hyderabad'),
('Masjid-e-Azizia', 'Asif Nagar, Hyderabad', 'Hyderabad', 'Telangana', 17.3850, 78.4450, '+91-40-23456791', '05:35', '12:35', '15:50', '18:20', '19:50', '13:35', 'Modern mosque with excellent facilities')
ON CONFLICT DO NOTHING;
