-- 003_indexes.sql
-- Create indexes to speed up the most common queries
-- Depends on: 002_tables.sql (tables must exist first)

-- Products: filtered by category on homepage
CREATE INDEX ON products(category_id);

-- Products: looked up by slug on product detail page
CREATE INDEX ON products(slug);

-- Cart items: all queries filter by user_id
CREATE INDEX ON cart_items(user_id);

-- Orders: shopper views their own order history
CREATE INDEX ON orders(user_id);

-- Order items: always fetched by order_id
CREATE INDEX ON order_items(order_id);
