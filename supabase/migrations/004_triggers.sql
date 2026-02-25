-- 004_triggers.sql
-- All database triggers for Velura
-- Depends on: 002_tables.sql

-- ============================================
-- TRIGGER 1: profile_creation
-- Auto-creates a profiles row when a new user signs up
-- ============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name',
    'shopper'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER profile_creation
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- TRIGGER 2: updated_at_trigger
-- Auto-sets updated_at = now() on products and orders
-- ============================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER set_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================
-- TRIGGER 3: order_transition_guard
-- Blocks invalid order status transitions at DB level
-- ============================================
CREATE OR REPLACE FUNCTION guard_order_transition()
RETURNS trigger AS $$
BEGIN
  -- delivered and cancelled are final states
  IF OLD.status = 'delivered' OR OLD.status = 'cancelled' THEN
    RAISE EXCEPTION 'Order status % is final and cannot be changed', OLD.status;
  END IF;

  -- pending can only move to shipped or cancelled
  IF OLD.status = 'pending' AND NEW.status = 'delivered' THEN
    RAISE EXCEPTION 'Invalid transition: pending -> delivered is not allowed';
  END IF;

  -- shipped can only move to delivered
  IF OLD.status = 'shipped' AND NEW.status NOT IN ('delivered') THEN
    RAISE EXCEPTION 'Invalid transition: shipped can only move to delivered';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_transition_guard
  BEFORE UPDATE ON orders
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION guard_order_transition();

-- ============================================
-- TRIGGER 4: stock_restore_on_cancel
-- Restores stock when payment fails or is refunded
-- ============================================
CREATE OR REPLACE FUNCTION restore_stock_on_cancel()
RETURNS trigger AS $$
BEGIN
  IF NEW.payment_status IN ('simulated_failed', 'simulated_refunded')
    AND OLD.payment_status NOT IN ('simulated_failed', 'simulated_refunded')
  THEN
    UPDATE products p
    SET stock = p.stock + oi.quantity
    FROM order_items oi
    WHERE oi.order_id = NEW.id
      AND p.id = oi.product_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER stock_restore_on_cancel
  AFTER UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION restore_stock_on_cancel();
