-- Add phonepe_transaction_id column to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS phonepe_transaction_id TEXT;

-- Add comment to the column
COMMENT ON COLUMN orders.phonepe_transaction_id IS 'PhonePe transaction ID for payment confirmation';
