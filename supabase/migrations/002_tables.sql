-- 002_tables.sql
-- Create all database tables for Velura
-- Depends on: 001_enums.sql (must run first)

-- Profiles: auto-created via trigger when user signs up
CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name   text,
  role        user_role NOT NULL DEFAULT 'shopper',
  created_at  timestamp NOT NULL DEFAULT now(),
  updated_at  timestamp NOT NULL DEFAULT now()
);

-- Categories: product groupings (e.g. Dresses, Tops, Shoes)
CREATE TABLE categories (
  id         integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name       text NOT NULL UNIQUE,
  slug       text NOT NULL UNIQUE,
  created_at timestamp NOT NULL DEFAULT now()
);

-- Products: soft delete only — never hard delete
CREATE TABLE products (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  description text,
  price       numeric(10,2) NOT NULL CHECK (price > 0),
  stock       integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
  category_id integer REFERENCES categories ON DELETE SET NULL,
  image_url   text,
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamp NOT NULL DEFAULT now(),
  updated_at  timestamp NOT NULL DEFAULT now()
);

-- Cart items: one row per user per product
CREATE TABLE cart_items (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products ON DELETE CASCADE,
  quantity   integer NOT NULL CHECK (quantity >= 1),
  created_at timestamp NOT NULL DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Orders: total_amount always calculated in DB, never from frontend
CREATE TABLE orders (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid NOT NULL REFERENCES auth.users ON DELETE RESTRICT,
  status           order_status NOT NULL DEFAULT 'pending',
  payment_status   payment_status NOT NULL DEFAULT 'simulated_pending',
  total_amount     numeric(10,2) NOT NULL,
  shipping_address jsonb NOT NULL CHECK (
    shipping_address ? 'full_name' AND
    shipping_address ? 'address_line' AND
    shipping_address ? 'city' AND
    shipping_address ? 'country'
  ),
  created_at  timestamp NOT NULL DEFAULT now(),
  updated_at  timestamp NOT NULL DEFAULT now()
);

-- Order items: price_at_purchase is a snapshot — never changes
CREATE TABLE order_items (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id          uuid NOT NULL REFERENCES orders ON DELETE RESTRICT,
  product_id        uuid NOT NULL REFERENCES products ON DELETE RESTRICT,
  quantity          integer NOT NULL CHECK (quantity >= 1),
  price_at_purchase numeric(10,2) NOT NULL,
  created_at        timestamp NOT NULL DEFAULT now()
);
