-- Add new columns to orders table for payment screenshot and tracking
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_screenshot TEXT,
ADD COLUMN IF NOT EXISTS tracking_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS current_location TEXT,
ADD COLUMN IF NOT EXISTS estimated_delivery_date TIMESTAMP WITH TIME ZONE;
