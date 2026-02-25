-- 006_rpc.sql
-- The handle_checkout RPC function
-- Depends on: 002_tables.sql, 005_rls.sql
-- SECURITY DEFINER: runs with elevated privileges, bypasses RLS intentionally
-- This is safe because all business rules are enforced inside this function

CREATE OR REPLACE FUNCTION handle_checkout(
  shipping_address jsonb,
  items jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id        uuid;
  v_order_id       uuid;
  v_total_amount   numeric(10,2) := 0;
  v_item           jsonb;
  v_product_id     uuid;
  v_quantity       integer;
  v_price          numeric(10,2);
  v_stock_updated  integer;
BEGIN

  -- STEP 1: Get user from auth — never trust user_id from frontend
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('status', 'error', 'code', 'UNAUTHORIZED');
  END IF;

  -- STEP 2: Validate all products exist and are active
  FOR v_item IN SELECT * FROM jsonb_array_elements(items)
  LOOP
    v_product_id := (v_item ->> 'product_id')::uuid;

    IF NOT EXISTS (
      SELECT 1 FROM products
      WHERE id = v_product_id AND is_active = true
    ) THEN
      RETURN jsonb_build_object(
        'status', 'error',
        'code', 'PRODUCT_NOT_FOUND',
        'product_id', v_product_id
      );
    END IF;
  END LOOP;

  -- STEP 3: Decrement stock atomically for each item
  -- If any item has insufficient stock, roll back entire transaction
  FOR v_item IN SELECT * FROM jsonb_array_elements(items)
  LOOP
    v_product_id := (v_item ->> 'product_id')::uuid;
    v_quantity   := (v_item ->> 'quantity')::integer;

    UPDATE products
    SET stock = stock - v_quantity
    WHERE id = v_product_id
      AND stock >= v_quantity;

    GET DIAGNOSTICS v_stock_updated = ROW_COUNT;

    IF v_stock_updated = 0 THEN
      RETURN jsonb_build_object(
        'status', 'error',
        'code', 'INSUFFICIENT_STOCK',
        'product_id', v_product_id
      );
    END IF;
  END LOOP;

  -- STEP 4: Calculate total from DB prices — never use frontend price
  SELECT COALESCE(SUM(
    p.price * (item ->> 'quantity')::integer
  ), 0)
  INTO v_total_amount
  FROM jsonb_array_elements(items) AS item
  JOIN products p ON p.id = (item ->> 'product_id')::uuid;

  -- STEP 5: Insert the order
  INSERT INTO orders (user_id, status, payment_status, total_amount, shipping_address)
  VALUES (
    v_user_id,
    'pending',
    'simulated_pending',
    v_total_amount,
    shipping_address
  )
  RETURNING id INTO v_order_id;

  -- STEP 6: Insert all order items with price snapshot
  INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
  SELECT
    v_order_id,
    (item ->> 'product_id')::uuid,
    (item ->> 'quantity')::integer,
    p.price
  FROM jsonb_array_elements(items) AS item
  JOIN products p ON p.id = (item ->> 'product_id')::uuid;

  -- STEP 7: Return success with new order id
  RETURN jsonb_build_object(
    'status', 'order_id',
    'order_id', v_order_id
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'status', 'error',
      'code', 'UNEXPECTED_ERROR'
    );

END;
$$;
