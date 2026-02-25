-- seed.sql
-- Realistic fashion product data for Velura
-- Run this AFTER all 6 migrations have been executed
-- Uses service role only — never run this from app code

-- ============================================
-- CATEGORIES
-- ============================================
INSERT INTO categories (name, slug) VALUES
  ('Dresses',    'dresses'),
  ('Tops',       'tops'),
  ('Trousers',   'trousers'),
  ('Outerwear',  'outerwear'),
  ('Shoes',      'shoes'),
  ('Bags',       'bags'),
  ('Accessories','accessories');

-- ============================================
-- PRODUCTS
-- ============================================
INSERT INTO products (name, slug, description, price, stock, category_id, image_url, is_active)
VALUES

-- DRESSES (category_id = 1)
(
  'Silk Slip Dress',
  'silk-slip-dress',
  'A fluid, bias-cut slip dress in ivory silk. Features adjustable spaghetti straps and a delicate lace trim at the hem. Effortlessly elegant for evening occasions.',
  189.00, 24, 1, null, true
),
(
  'Linen Shirt Dress',
  'linen-shirt-dress',
  'Relaxed shirt dress crafted from 100% washed linen in a warm sand tone. Button-through front, belted waist, and side pockets. Perfect for warm days.',
  134.00, 18, 1, null, true
),
(
  'Knit Midi Dress',
  'knit-midi-dress',
  'Ribbed knit midi dress with long sleeves and a subtle turtleneck. Made from a soft wool-blend in deep forest green. A wardrobe staple for cooler months.',
  156.00, 12, 1, null, true
),
(
  'Floral Wrap Dress',
  'floral-wrap-dress',
  'A classic wrap silhouette in a bold botanical print on a cream base. V-neckline, flutter sleeves, and a self-tie waist. Fully lined.',
  118.00, 30, 1, null, true
),
(
  'Velvet Evening Gown',
  'velvet-evening-gown',
  'Floor-length gown in deep burgundy velvet. Features a draped cowl neck, open back, and a subtle train. Dry clean only.',
  320.00, 5, 1, null, true
),

-- TOPS (category_id = 2)
(
  'Oversized Linen Shirt',
  'oversized-linen-shirt',
  'Relaxed-fit linen shirt with dropped shoulders and a slightly cropped length. Available in off-white. Pairs perfectly with wide-leg trousers.',
  89.00, 40, 2, null, true
),
(
  'Ribbed Crop Top',
  'ribbed-crop-top',
  'Fitted ribbed crop top with a scoop neck and short sleeves. Made from a soft cotton-elastane blend. A versatile everyday essential.',
  45.00, 55, 2, null, true
),
(
  'Satin Cami Top',
  'satin-cami-top',
  'Lightweight satin cami with adjustable straps and a delicate lace trim. Available in champagne and midnight black. Can be styled day or night.',
  67.00, 35, 2, null, true
),
(
  'Structured Blazer Top',
  'structured-blazer-top',
  'A hybrid between a blazer and a crop top. Single-button fastening, structured shoulders, and a clean minimal silhouette. Wear alone or layered.',
  112.00, 20, 2, null, true
),
(
  'Cashmere Knit Vest',
  'cashmere-knit-vest',
  'Luxuriously soft cashmere vest in a relaxed fit. Ribbed trim at armholes and hem. A quiet luxury piece for layering.',
  145.00, 15, 2, null, true
),

-- TROUSERS (category_id = 3)
(
  'Wide Leg Linen Trousers',
  'wide-leg-linen-trousers',
  'High-waisted wide-leg trousers in breathable linen. Features a flat front, side zip, and subtle pleat detail. Tailored but relaxed.',
  128.00, 22, 3, null, true
),
(
  'Tailored Cigarette Pants',
  'tailored-cigarette-pants',
  'Slim cigarette-cut trousers in a stretch wool blend. Sits at the natural waist with a clean front and pressed crease. Office-ready.',
  138.00, 18, 3, null, true
),
(
  'Cargo Utility Trousers',
  'cargo-utility-trousers',
  'Relaxed-fit cargo trousers with multiple pockets and adjustable drawstring hem. Made from heavy cotton canvas in khaki. Functional and stylish.',
  98.00, 28, 3, null, true
),
(
  'Satin Slip Trousers',
  'satin-slip-trousers',
  'Fluid satin trousers with an elasticated waist and wide leg. Lightweight and versatile — dress up or down. Available in champagne.',
  105.00, 20, 3, null, true
),

-- OUTERWEAR (category_id = 4)
(
  'Wool Blend Overcoat',
  'wool-blend-overcoat',
  'Classic double-breasted overcoat in a charcoal wool blend. Fully lined with a satin interior. A timeless investment piece.',
  380.00, 8, 4, null, true
),
(
  'Quilted Puffer Jacket',
  'quilted-puffer-jacket',
  'Lightweight quilted jacket with a glossy finish and high collar. Packable design with an internal storage pouch. Water-resistant.',
  210.00, 14, 4, null, true
),
(
  'Leather Biker Jacket',
  'leather-biker-jacket',
  'Genuine lambskin leather biker jacket with asymmetric zip, quilted shoulder panels, and silver hardware. A wardrobe icon.',
  450.00, 4, 4, null, true
),
(
  'Trench Coat',
  'trench-coat',
  'A refined take on the classic trench. Double-breasted with storm flap, belted waist, and wrist tabs. In a warm camel tone.',
  295.00, 10, 4, null, true
),

-- SHOES (category_id = 5)
(
  'Pointed Kitten Heels',
  'pointed-kitten-heels',
  'Elegant kitten heel mules in nude patent leather. Pointed toe, slip-on silhouette, and a 5cm heel. Versatile enough for office and evening.',
  165.00, 16, 5, null, true
),
(
  'Leather Ankle Boots',
  'leather-ankle-boots',
  'Classic ankle boots in smooth black leather. Block heel, inside zip fastening, and a slightly pointed toe. Built to last.',
  220.00, 12, 5, null, true
),
(
  'Strappy Barely-There Sandals',
  'strappy-sandals',
  'Minimalist strappy sandals with a delicate ankle strap and thin toe thong. Low block heel. In warm gold and silver tones.',
  138.00, 20, 5, null, true
),
(
  'White Leather Sneakers',
  'white-leather-sneakers',
  'Clean minimal leather sneakers with a low profile sole. No branding, no fuss. The perfect everyday shoe.',
  125.00, 30, 5, null, true
),

-- BAGS (category_id = 6)
(
  'Mini Shoulder Bag',
  'mini-shoulder-bag',
  'Compact structured shoulder bag in pebbled leather. Gold-tone hardware, adjustable chain strap, and suede lining. Fits essentials only.',
  195.00, 10, 6, null, true
),
(
  'Canvas Tote Bag',
  'canvas-tote-bag',
  'Oversized heavyweight canvas tote with reinforced handles and a zip-top closure. Interior slip pocket. Minimal branding.',
  78.00, 35, 6, null, true
),
(
  'Leather Crossbody Bag',
  'leather-crossbody-bag',
  'Slim crossbody bag in smooth tan leather. Adjustable strap, magnetic snap closure, and card slots inside. Everyday carry.',
  168.00, 18, 6, null, true
),
(
  'Suede Clutch',
  'suede-clutch',
  'Evening clutch in soft blush suede with a fold-over top and magnetic closure. Gold-tone frame detail. Comes with a detachable wrist strap.',
  112.00, 8, 6, null, true
),

-- ACCESSORIES (category_id = 7)
(
  'Merino Wool Scarf',
  'merino-wool-scarf',
  'Generously sized scarf in 100% merino wool. Soft, warm, and non-itchy. Available in camel, charcoal, and ivory.',
  65.00, 40, 7, null, true
),
(
  'Leather Belt',
  'leather-belt',
  'Slim leather belt in black and tan with a brushed gold buckle. Classic minimalist design that works with everything.',
  55.00, 45, 7, null, true
),
(
  'Gold Hoop Earrings',
  'gold-hoop-earrings',
  '18k gold-plated oversized hoop earrings. Lightweight despite their size. A statement piece that goes with everything.',
  48.00, 50, 7, null, true
),
(
  'Silk Hair Scarf',
  'silk-hair-scarf',
  'Pure silk square scarf in a painterly floral print. Wear in your hair, around your neck, or tied to your bag. 90x90cm.',
  72.00, 30, 7, null, true
),
(
  'Sunglasses',
  'sunglasses',
  'Oversized square-frame sunglasses with UV400 protection. Acetate frame in tortoiseshell. Comes with a hard case and cleaning cloth.',
  95.00, 25, 7, null, true
);
