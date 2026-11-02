-- Create stitchers table
CREATE TABLE IF NOT EXISTS stitchers (
  id TEXT PRIMARY KEY,
  password TEXT NOT NULL,
  aadhar_card TEXT NOT NULL,
  mobile_number TEXT NOT NULL UNIQUE,
  address TEXT NOT NULL,
  shop_address TEXT NOT NULL,
  shop_latitude DOUBLE PRECISION NOT NULL,
  shop_longitude DOUBLE PRECISION NOT NULL,
  verification_status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Create index on mobile_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_stitchers_mobile_number ON stitchers(mobile_number);

-- Create index on verification_status for admin queries
CREATE INDEX IF NOT EXISTS idx_stitchers_verification_status ON stitchers(verification_status);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_stitchers_updated_at BEFORE UPDATE ON stitchers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
