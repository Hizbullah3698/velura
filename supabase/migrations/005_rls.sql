-- 005_rls.sql
-- Row Level Security policies for Velura
-- Depends on: 002_tables.sql
-- CRITICAL: All policies use auth.jwt() ->> 'role'
-- NEVER join the profiles table inside a policy

-- ============================================
-- Enable RLS on all tables
-- ============================================
ALTER TABLE profiles    ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories  ENABLE ROW LEVEL SECURITY;
ALTER TABLE products    ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items  ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders      ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES
-- ============================================
CREATE POLICY "Anyone can read profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "User can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ============================================
-- CATEGORIES
-- ============================================
CREATE POLICY "Anyone can read categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admin full CRUD on categories"
  ON categories FOR ALL
  USING ((auth.jwt() ->> 'role') = 'admin');

-- ============================================
-- PRODUCTS
-- ============================================
CREATE POLICY "Anyone can read active products"
  ON products FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admin can read all products"
  ON products FOR SELECT
  USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Admin can insert products"
  ON products FOR INSERT
  WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Admin can update products"
  ON products FOR UPDATE
  USING ((auth.jwt() ->> 'role') = 'admin');

-- No DELETE policy — products are never hard deleted

-- ============================================
-- CART ITEMS
-- ============================================
CREATE POLICY "User owns their cart items"
  ON cart_items FOR ALL
  USING (auth.uid() = user_id);

-- ============================================
-- ORDERS
-- ============================================
CREATE POLICY "Shopper can read own orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admin can read all orders"
  ON orders FOR SELECT
  USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Admin can update order status"
  ON orders FOR UPDATE
  USING ((auth.jwt() ->> 'role') = 'admin');

-- No INSERT policy for orders — only the RPC can insert

-- ============================================
-- ORDER ITEMS
-- ============================================
CREATE POLICY "Shopper can read own order items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can read all order items"
  ON order_items FOR SELECT
  USING ((auth.jwt() ->> 'role') = 'admin');

-- No INSERT policy for order_items — only the RPC can insert
