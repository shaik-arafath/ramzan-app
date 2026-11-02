-- Drop products table if it exists (to recreate with correct schema)
DROP TABLE IF EXISTS products CASCADE;

-- Create products table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  stitcher_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DOUBLE PRECISION NOT NULL,
  category TEXT NOT NULL,
  images TEXT[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  FOREIGN KEY (stitcher_id) REFERENCES stitchers(id) ON DELETE CASCADE
);

-- Create index on stitcher_id for faster lookups
CREATE INDEX idx_products_stitcher_id ON products(stitcher_id);

-- Create index on category for filtering
CREATE INDEX idx_products_category ON products(category);
