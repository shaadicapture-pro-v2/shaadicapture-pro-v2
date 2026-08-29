-- ShaadiCapture Pro Database Schema v2.0

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  location_id INT,
  city VARCHAR(100),
  state VARCHAR(100),
  wedding_date DATE,
  budget_min INT,
  budget_max INT,
  preferences TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Photographers table
CREATE TABLE IF NOT EXISTS photographers (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  location_id INT,
  city VARCHAR(100),
  state VARCHAR(100),
  bio TEXT,
  experience_years INT,
  portfolio_url VARCHAR(500),
  price_per_day INT,
  rating DECIMAL(3,2) DEFAULT 0,
  total_shoots INT DEFAULT 0,
  available BOOLEAN DEFAULT true,
  specialization TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leads table
CREATE TABLE IF NOT EXISTS leads (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  city VARCHAR(100),
  state VARCHAR(100),
  wedding_date DATE,
  budget_min INT,
  budget_max INT,
  event_type VARCHAR(100),
  status VARCHAR(50) DEFAULT 'new',
  assigned_photographer_id INT REFERENCES photographers(id),
  is_duplicate BOOLEAN DEFAULT false,
  duplicate_of INT REFERENCES leads(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
  photographer_id INT REFERENCES photographers(id) ON DELETE CASCADE,
  lead_id INT REFERENCES leads(id),
  booking_date DATE NOT NULL,
  event_date DATE NOT NULL,
  event_type VARCHAR(100),
  venue VARCHAR(255),
  location_id INT,
  duration_hours INT DEFAULT 8,
  total_price INT,
  advance_paid INT DEFAULT 0,
  balance_due INT,
  status VARCHAR(50) DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Photographer availability table
CREATE TABLE IF NOT EXISTS photographer_availability (
  id SERIAL PRIMARY KEY,
  photographer_id INT REFERENCES photographers(id) ON DELETE CASCADE,
  available_date DATE NOT NULL,
  is_available BOOLEAN DEFAULT true,
  booked_hours INT DEFAULT 0,
  max_hours INT DEFAULT 24,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(photographer_id, available_date)
);

-- Locations table (State → District → City → Village)
CREATE TABLE IF NOT EXISTS locations (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  level VARCHAR(50),
  name VARCHAR(255) NOT NULL,
  parent_id INT REFERENCES locations(id),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'India',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SEO Keywords table
CREATE TABLE IF NOT EXISTS keywords (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  keyword VARCHAR(255) UNIQUE NOT NULL,
  search_volume INT,
  difficulty_level VARCHAR(50),
  location_id INT REFERENCES locations(id),
  city VARCHAR(100),
  state VARCHAR(100),
  category VARCHAR(100),
  search_count INT DEFAULT 0,
  last_searched TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
  id SERIAL PRIMARY KEY,
  uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  username VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'admin',
  permissions TEXT,
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_city ON customers(city);
CREATE INDEX IF NOT EXISTS idx_photographers_email ON photographers(email);
CREATE INDEX IF NOT EXISTS idx_photographers_city ON photographers(city);
CREATE INDEX IF NOT EXISTS idx_photographers_rating ON photographers(rating DESC);
CREATE INDEX IF NOT EXISTS idx_leads_customer_id ON leads(customer_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_city ON leads(city);
CREATE INDEX IF NOT EXISTS idx_leads_duplicate ON leads(is_duplicate);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_photographer_id ON bookings(photographer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_event_date ON bookings(event_date);
CREATE INDEX IF NOT EXISTS idx_photographer_availability_date ON photographer_availability(available_date);
CREATE INDEX IF NOT EXISTS idx_keywords_keyword ON keywords(keyword);
CREATE INDEX IF NOT EXISTS idx_keywords_city ON keywords(city);

-- Insert sample locations (India - State level)
INSERT INTO locations (level, name, country) VALUES 
('state', 'Rajasthan', 'India'),
('state', 'Maharashtra', 'India'),
('state', 'Delhi', 'India'),
('state', 'Gujarat', 'India'),
('state', 'Uttar Pradesh', 'India')
ON CONFLICT DO NOTHING;

-- Insert sample keywords
INSERT INTO keywords (keyword, search_volume, difficulty_level, city, state, category) VALUES
('wedding photographer rajasthan', 1200, 'high', 'Jaipur', 'Rajasthan', 'photography'),
('pre wedding shoots jaipur', 850, 'medium', 'Jaipur', 'Rajasthan', 'photography'),
('bridal photographer india', 2100, 'high', 'Delhi', 'Delhi', 'photography'),
('candid wedding photographer', 1500, 'high', 'Mumbai', 'Maharashtra', 'photography'),
('wedding videography services', 950, 'medium', 'Bangalore', 'Karnataka', 'videography')
ON CONFLICT DO NOTHING;

-- Insert sample admin user (password: admin123 - hashed)
INSERT INTO admin_users (username, email, password_hash, role) VALUES
('admin', 'admin@shaadicapture.com', '$2a$10$YourHashedPasswordHere', 'admin')
ON CONFLICT DO NOTHING;
