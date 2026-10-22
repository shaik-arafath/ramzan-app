-- Create wazifas table
CREATE TABLE IF NOT EXISTS wazifas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    time TEXT,
    namaz TEXT,
    dua TEXT,
    ziker TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE wazifas ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Allow anyone to read wazifas
CREATE POLICY "Allow read access to all users"
    ON wazifas FOR SELECT
    USING (true);

-- Allow authenticated users to insert wazifas (admin functionality)
CREATE POLICY "Allow insert for authenticated users"
    ON wazifas FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update wazifas (admin functionality)
CREATE POLICY "Allow update for authenticated users"
    ON wazifas FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to delete wazifas (admin functionality)
CREATE POLICY "Allow delete for authenticated users"
    ON wazifas FOR DELETE
    USING (auth.role() = 'authenticated');

-- Create index on category for faster filtering
CREATE INDEX IF NOT EXISTS idx_wazifas_category ON wazifas(category);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_wazifas_created_at ON wazifas(created_at DESC);

-- Insert sample wazifas
INSERT INTO wazifas (title, category, description, time, namaz, dua, ziker) VALUES
('Wazifa for Rizq', 'Rizq', 'This wazifa is for increasing sustenance and blessings in livelihood. Recite this daily after Fajr prayer.', 'After Fajr', '2 Rakat Nafil', 'Ya Razzaqu Ya Wahhabu', 'SubhanAllah 100 times'),
('Wazifa for Health', 'Health', 'This wazifa is for healing and good health. Recite this with faith and patience.', 'Any time', '2 Rakat Shifa', 'Ya Shafi Ya Kafi', 'Alhamdulillah 100 times'),
('Wazifa for Marriage', 'Marriage', 'This wazifa is for those seeking marriage. Recite this with sincere intention.', 'After Isha', '2 Rakat Hajat', 'Ya Wahhabu Ya Qayyum', 'La ilaha illallah 100 times'),
('Wazifa for Protection', 'Protection', 'This wazifa is for protection from harm and evil. Recite this daily.', 'Morning and Evening', '2 Rakat Nafil', 'Ya Hafizu Ya Muqit', 'Ayatul Kursi 3 times'),
('Wazifa for Peace of Mind', 'Peace', 'This wazifa is for inner peace and tranquility. Recite this when feeling stressed.', 'Before sleeping', '2 Rakat Nafil', 'Ya Salamu Ya Mumin', 'Astaghfirullah 100 times');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_wazifas_updated_at
    BEFORE UPDATE ON wazifas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
