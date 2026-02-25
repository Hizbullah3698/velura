-- 001_enums.sql
-- Create all custom enum types for Velura
-- Must run before 002_tables.sql because tables depend on these types

CREATE TYPE user_role AS ENUM ('shopper', 'admin');

CREATE TYPE order_status AS ENUM ('pending', 'shipped', 'delivered', 'cancelled');

CREATE TYPE payment_status AS ENUM (
  'simulated_pending',
  'simulated_paid',
  'simulated_failed',
  'simulated_refunded'
);
