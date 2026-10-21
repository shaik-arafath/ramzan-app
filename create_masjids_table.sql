-- Create masjids table
CREATE TABLE IF NOT EXISTS masjids (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    phone VARCHAR(20),
    website VARCHAR(255),
    image_url TEXT,
    
    -- Namaz timings
    fajr_time VARCHAR(10),
    dhuhr_time VARCHAR(10),
    asr_time VARCHAR(10),
    maghrib_time VARCHAR(10),
    isha_time VARCHAR(10),
    jummah_time VARCHAR(10),
    
    -- Additional info
    description TEXT,
    facilities TEXT[], -- Array of facilities like parking, wudu area, etc.
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS
ALTER TABLE masjids ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view masjids"
    ON masjids FOR SELECT
    USING (true);

CREATE POLICY "Only authenticated users can insert masjids"
    ON masjids FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Only authenticated users can update masjids"
    ON masjids FOR UPDATE
    USING (auth.uid() IS NOT NULL);

-- Create index for location-based queries
CREATE INDEX idx_masjids_location ON masjids USING GIST (point(longitude, latitude));

-- Create index for city search
CREATE INDEX idx_masjids_city ON masjids(city);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_masjids_updated_at
    BEFORE UPDATE ON masjids
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample masjids
INSERT INTO masjids (name, address, city, state, latitude, longitude, phone, fajr_time, dhuhr_time, asr_time, maghrib_time, isha_time, jummah_time, description) VALUES
('Makkah Masjid', 'Charminar, Hyderabad', 'Hyderabad', 'Telangana', 17.3616, 78.4747, '+91-40-23456789', '05:30', '12:30', '15:45', '18:15', '19:45', '13:30', 'Historical mosque near Charminar'),
('Jama Masjid', 'Pathargatti, Hyderabad', 'Hyderabad', 'Telangana', 17.3633, 78.4695, '+91-40-23456790', '05:25', '12:25', '15:40', '18:10', '19:40', '13:25', 'One of the largest mosques in Hyderabad'),
('Masjid-e-Azizia', 'Asif Nagar, Hyderabad', 'Hyderabad', 'Telangana', 17.3850, 78.4450, '+91-40-23456791', '05:35', '12:35', '15:50', '18:20', '19:50', '13:35', 'Modern mosque with excellent facilities')
ON CONFLICT DO NOTHING;
