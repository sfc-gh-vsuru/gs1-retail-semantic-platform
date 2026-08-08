-- ============================================================
-- GS1 Retail Observability Platform — Pilot Comparison
-- File: sql/08_grounding_paths.sql
-- Purpose: Three grounding paths for AI Shopping Agent benchmark
--
-- Path A: GS1 Standardized (full GDM, clean, complete)
-- Path B: Retailer Internal (partial, stale, inconsistent)
-- Path C: Scraped Web (noisy, duplicates, wrong values)
--
-- Reference: GS1 US + Snowflake Pilot Executive Brief (June 2026)
-- ============================================================

USE DATABASE GS1_DB;
USE SCHEMA DEMO;

-- ============================================================
-- PATH A: GS1 STANDARDIZED DATA
-- Denormalized view combining product + nutrition + allergen
-- This is the "gold" grounding — complete, structured, current
-- ============================================================

CREATE OR REPLACE VIEW GS1_DB.DEMO.GROUNDING_GS1 AS
SELECT
    p.gtin,
    p.brand_name,
    p.product_description,
    p.product_description_short,
    p.net_weight_value,
    p.net_weight_uom,
    p.width_mm,
    p.height_mm,
    p.depth_mm,
    p.gross_weight_g,
    p.packaging_type,
    p.units_per_case,
    p.gpc_brick_code,
    p.gpc_brick_name,
    p.country_of_origin,
    p.target_market_country,
    p.is_consumer_unit,
    p.gs1_digital_link_url,
    p.product_image_url,
    p.gtin_status,
    p.attribute_completeness_pct,
    p.gdsn_last_sync_date,
    -- Nutritional (structured, per 100g)
    n.energy_kcal_per100g,
    n.fat_g_per100g,
    n.saturates_g_per100g,
    n.carb_g_per100g,
    n.sugars_g_per100g,
    n.fibre_g_per100g,
    n.protein_g_per100g,
    n.salt_g_per100g,
    n.serving_size_g,
    -- Allergens (structured booleans)
    a.contains_gluten,
    a.contains_dairy,
    a.contains_nuts,
    a.contains_soy,
    a.contains_eggs,
    a.contains_fish,
    a.contains_celery,
    a.allergen_statement
FROM GS1_DB.DEMO.PRODUCT_ATTRIBUTES p
LEFT JOIN GS1_DB.DEMO.NUTRITIONAL_INFO n ON p.gtin = n.gtin
LEFT JOIN GS1_DB.DEMO.ALLERGEN_INFO a ON p.gtin = a.gtin;


-- ============================================================
-- PATH B: RETAILER INTERNAL DATA
-- Simulates a typical retailer PIM system:
-- - Missing 40% of attributes (no nutrition, no GPC hierarchy)
-- - Retailer-specific SKUs instead of GTINs
-- - Free-text allergens (not structured booleans)
-- - Stale (6-10 months old)
-- - Flat category (no hierarchy)
-- ============================================================

CREATE OR REPLACE TABLE GS1_DB.DEMO.GROUNDING_RETAILER (
    sku                 VARCHAR(20),
    item_name           VARCHAR(255),
    vendor              VARCHAR(100),
    category            VARCHAR(100),
    subcategory         VARCHAR(100),
    price_gbp           FLOAT,
    aisle_location      VARCHAR(50),
    stock_quantity      INTEGER,
    weight_text         VARCHAR(50),
    allergen_notes      VARCHAR(500),
    gtin                VARCHAR(14),
    image_filename      VARCHAR(255),
    last_updated        DATE,
    is_active           BOOLEAN
);

INSERT INTO GS1_DB.DEMO.GROUNDING_RETAILER VALUES
-- Oat Flakes: has GTIN, basic info, free-text allergen
('NB-OAT-500', 'Oat Flakes 500g', 'NovaBrand', 'Cereal', NULL,
 2.49, 'Aisle 7, Bay 3', 142, '500g', 'Gluten',
 '05901234100017', 'oat_flakes_v2.jpg', '2024-09-15', TRUE),

-- Muesli: has GTIN, incomplete allergen
('NB-MUS-750', 'Muesli Fruit 750g', 'NovaBrand', 'Cereal', NULL,
 3.79, 'Aisle 7, Bay 4', 89, '750g', 'Gluten, Nuts',
 '05901234100024', 'muesli_mixed.jpg', '2024-09-15', TRUE),

-- Milk: missing GTIN, minimal info
('FM-MILK-1L', 'Full Fat Milk 1L', 'NovaBrand', 'Dairy', NULL,
 1.25, 'Chilled, Bay 1', 340, '1 litre', 'Milk',
 NULL, 'milk_whole_1l.jpg', '2024-11-02', TRUE),

-- Yoghurt: has GTIN, stale
('NB-YOG-500', 'Greek Yoghurt 500g', 'NovaBrand', 'Dairy', NULL,
 2.19, 'Chilled, Bay 3', 67, '500g', 'Milk',
 '05901234200023', 'greek_yog.jpg', '2024-08-20', TRUE),

-- Cheddar: missing GTIN
('FM-CHED-400', 'Cheddar 400g', 'Nova Brand', 'Dairy', NULL,
 3.49, 'Chilled, Bay 5', 55, '400g', 'Milk',
 NULL, 'cheddar_mature.jpg', '2024-10-01', TRUE),

-- Crisps: missing GTIN, no allergen info
('NB-CRISP-150', 'Sea Salt Crisps 150g', 'NovaBrand', 'Snacks', NULL,
 1.89, 'Aisle 4, Bay 2', 200, '150g', NULL,
 NULL, 'crisps_salt.jpg', '2025-01-10', TRUE),

-- Chocolate: has GTIN
('NB-CHOC-100', 'Dark Choc Bar 100g', 'NovaBrand', 'Confectionery', NULL,
 1.99, 'Aisle 4, Bay 8', 175, '100g', 'Milk, Soy',
 '05901234300022', 'dark_choc_bar.jpg', '2024-12-05', TRUE),

-- Orange Juice: has GTIN, inconsistent vendor name
('NB-OJ-1L', 'Orange Juice 1L', 'NOVABRAND', 'Beverages', NULL,
 2.29, 'Aisle 3, Bay 1', 88, '1L', NULL,
 '05901234400014', 'oj_carton.jpg', '2024-11-20', TRUE),

-- Sparkling Water: has GTIN
('NB-WATER-500', 'Sparkling Water 500ml', 'NovaBrand', 'Beverages', NULL,
 0.89, 'Aisle 3, Bay 6', 312, '500ml', NULL,
 '05901234400021', 'sparkling_water.jpg', '2025-02-01', TRUE),

-- Green Tea: has GTIN, stale
('NB-TEA-20', 'Green Tea 20s', 'NovaBrand', 'Hot Drinks', NULL,
 1.69, 'Aisle 5, Bay 2', 95, '20 bags', NULL,
 '05901234400038', 'green_tea_box.jpg', '2024-07-15', TRUE);


-- ============================================================
-- PATH C: SCRAPED WEB DATA
-- Simulates web scraping output:
-- - No GTIN (never exposed on product pages)
-- - Duplicate entries (same product from different URLs)
-- - Marketing copy instead of structured descriptions
-- - Inconsistent formatting (weight, brand name)
-- - Wrong nutrition values for 2 products
-- - Missing allergens for 4 products
-- - Noise fields (reviews, ratings, availability, promo)
-- - 2 products miscategorized
-- ============================================================

CREATE OR REPLACE TABLE GS1_DB.DEMO.GROUNDING_SCRAPED (
    scraped_id          VARCHAR(50),
    page_title          VARCHAR(500),
    page_url            VARCHAR(500),
    brand_text          VARCHAR(100),
    description_text    VARCHAR(1000),
    weight_text         VARCHAR(50),
    category_breadcrumb VARCHAR(255),
    price_text          VARCHAR(50),
    allergen_text       VARCHAR(500),
    nutrition_energy    VARCHAR(50),
    nutrition_fat       VARCHAR(50),
    nutrition_carbs     VARCHAR(50),
    nutrition_protein   VARCHAR(50),
    nutrition_sugar     VARCHAR(50),
    star_rating         FLOAT,
    review_count        INTEGER,
    availability        VARCHAR(50),
    promo_text          VARCHAR(255),
    image_url           VARCHAR(500),
    scraped_at          TIMESTAMP_NTZ
);

INSERT INTO GS1_DB.DEMO.GROUNDING_SCRAPED VALUES
-- Oat Flakes (record 1)
('SCR-001', 'NovaBrand Oat Flakes 500g | Breakfast Cereals | FreshMart',
 'https://freshmart.example.com/products/novabrand-oat-flakes-500g',
 'NovaBrand', 'Delicious wholegrain oat flakes, perfect for a healthy breakfast. High in fibre and naturally low in sugar. Start your day right!',
 '500 g', 'Home > Breakfast > Cereals > Oats',
 '2.49', 'Contains: Gluten (oats). May contain: Nuts, Milk.',
 '375kcal', '7.2g', '63g', '12.4g', '1.1g',
 4.3, 127, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/oatflakes_500g.webp', '2025-07-18 03:42:00'),

-- Oat Flakes DUPLICATE (scraped from different page)
('SCR-001-DUP', 'Oat Flakes by NovaBrand - 500g Box | Best Cereals',
 'https://freshmart.example.com/cereals/oat-flakes-novabrand',
 'Nova Brand', 'Wholegrain rolled oats. 500g box. A breakfast staple.',
 '500g', 'Cereals > Porridge & Oats',
 '2.49 (was 2.99)', NULL,
 '375 kcal', '7.2 g', '63.0 g', '12.4 g', '1.1 g',
 4.3, 127, 'In Stock', 'Save 50p this week!',
 'https://cdn.freshmart.example.com/img/oatflakes_alt.webp', '2025-07-15 02:18:00'),

-- Muesli
('SCR-002', 'NovaBrand Muesli Mixed Fruit 750g | FreshMart Online',
 'https://freshmart.example.com/products/novabrand-muesli-750g',
 'NovaBrand', 'Premium Swiss-style muesli packed with real dried fruits and crunchy nuts. A nutritious way to fuel your morning.',
 '750 grams', 'Home > Breakfast > Cereals > Muesli',
 '3.79', 'Contains: Gluten (oats), Tree Nuts. May contain: Milk.',
 '380kcal', '9.5g', '61g', '9.2g', '18.5g',
 4.1, 89, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/muesli_750.webp', '2025-07-18 03:44:00'),

-- Milk (duplicate)
('SCR-003', 'Fresh Whole Milk 1L - NovaBrand | Dairy | FreshMart',
 'https://freshmart.example.com/products/novabrand-whole-milk-1l',
 'NovaBrand', 'Fresh British whole milk. Pasteurised. Keep refrigerated. Use within 3 days of opening.',
 '1 Litre', 'Home > Dairy & Eggs > Milk > Whole Milk',
 '1.25', 'Contains: Milk.',
 '61kcal', '3.5g', '4.8g', '3.2g', '4.8g',
 4.6, 203, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/milk_whole_1l.webp', '2025-07-18 03:45:00'),

-- Milk DUPLICATE
('SCR-003-DUP', 'NovaBrand Full Fat Milk 1 Litre | Free Delivery',
 'https://freshmart.example.com/offers/milk-deals',
 'NOVABRAND', 'Full fat milk, 1 litre bottle. British farm assured.',
 '1L', 'Offers > Dairy Deals',
 '1.25', NULL,
 NULL, NULL, NULL, NULL, NULL,
 4.6, 203, 'In Stock', 'Buy 2 for 2.00!',
 'https://cdn.freshmart.example.com/img/milk_promo.webp', '2025-07-12 01:30:00'),

-- Yoghurt (MISCATEGORIZED as "Drinks" by scraper)
('SCR-004', 'NovaBrand Greek Yoghurt 500g - Thick & Creamy',
 'https://freshmart.example.com/products/novabrand-greek-yoghurt',
 'NovaBrand', 'Luxuriously thick and creamy Greek-style yoghurt. Made with fresh British milk. Perfect with fruit or honey.',
 '500g', 'Home > Drinks > Smoothies & Yoghurt',
 '2.19', 'Contains: Milk.',
 '115kcal', '9.2g', '3.3g', '5.5g', '3.3g',
 4.5, 156, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/greek_yog_500.webp', '2025-07-18 03:46:00'),

-- Cheddar (WRONG NUTRITION: protein and carbs swapped)
('SCR-005', 'Mature Cheddar Cheese 400g - NovaBrand',
 'https://freshmart.example.com/products/novabrand-cheddar-400g',
 'Nova Brand', 'Aged 12 months for a rich, sharp flavour. Perfect for sandwiches, cooking, or a cheeseboard.',
 '400 g', 'Home > Dairy & Eggs > Cheese > Cheddar',
 '3.49', 'Contains: Milk.',
 '416kcal', '34.4g', '25.4g', '0.1g', '0.1g',
 4.4, 91, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/cheddar_400.webp', '2025-07-18 03:47:00'),

-- Crisps (MISSING allergen info)
('SCR-006', 'Sea Salt Crisps 150g - Hand Cooked | NovaBrand',
 'https://freshmart.example.com/products/novabrand-sea-salt-crisps',
 'NovaBrand', 'Hand-cooked potato crisps with a pinch of sea salt. Gluten free. Vegan friendly.',
 '150g', 'Home > Snacks > Crisps > Sharing Bags',
 '1.89', NULL,
 '536kcal', '34g', '53g', '5.8g', '0.3g',
 4.0, 64, 'In Stock', '3 for 5.00',
 'https://cdn.freshmart.example.com/img/crisps_salt_150.webp', '2025-07-18 03:48:00'),

-- Chocolate (WRONG NUTRITION: protein and fat swapped)
('SCR-007', 'NovaBrand Dark Chocolate 100g - 72% Cocoa',
 'https://freshmart.example.com/products/novabrand-dark-choc-100g',
 'NovaBrand', 'Indulgent 72% cocoa dark chocolate. Rich and intense flavour. Ethically sourced cocoa beans.',
 '100g', 'Home > Snacks > Chocolate > Dark Chocolate',
 '1.99', 'Contains: Milk, Soya.',
 '565kcal', '5.8g', '47g', '39g', '28g',
 4.7, 218, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/dark_choc_100.webp', '2025-07-18 03:49:00'),

-- Orange Juice (duplicate)
('SCR-008', 'NovaBrand Orange Juice 1L - Not From Concentrate',
 'https://freshmart.example.com/products/novabrand-orange-juice-1l',
 'NovaBrand', 'Freshly squeezed orange juice. Not from concentrate. No added sugar. Keep refrigerated after opening.',
 '1 Litre', 'Home > Drinks > Juice > Orange Juice',
 '2.29', NULL,
 '44kcal', '0.1g', '10.4g', '0.7g', '9.2g',
 4.2, 142, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/oj_1l.webp', '2025-07-18 03:50:00'),

-- Orange Juice DUPLICATE (from offers page)
('SCR-008-DUP', 'Fresh OJ 1L NovaBrand | Juice Deals',
 'https://freshmart.example.com/offers/juice-deals',
 'Novabrand', 'Orange juice, 1L carton. Fresh not from concentrate.',
 '1000ml', 'Offers > Drink Deals',
 '2.29 (was 2.79)', NULL,
 NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, 'Low Stock', 'Price Drop!',
 'https://cdn.freshmart.example.com/img/oj_promo.webp', '2025-07-10 04:22:00'),

-- Sparkling Water (MISSING allergen — fine since it has none, but field is empty)
('SCR-009', 'Sparkling Mineral Water 500ml - NovaBrand',
 'https://freshmart.example.com/products/novabrand-sparkling-water',
 'NovaBrand', 'Natural mineral water with fine bubbles. Refreshing and pure. Zero calories.',
 '500 ml', 'Home > Drinks > Water > Sparkling',
 '0.89', NULL,
 '0kcal', '0g', '0g', '0g', '0g',
 3.9, 45, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/sparkling_500.webp', '2025-07-18 03:51:00'),

-- Green Tea (MISCATEGORIZED as "Herbal Medicine")
('SCR-010', 'NovaBrand Green Tea 20 Bags - Japanese Sencha',
 'https://freshmart.example.com/products/novabrand-green-tea-20',
 'NovaBrand', 'Premium Japanese Sencha green tea. Light, refreshing and full of antioxidants. Naturally caffeine-light.',
 '20 bags (40g)', 'Home > Health > Herbal Medicine > Teas',
 '1.69', NULL,
 '1kcal', '0g', '0.2g', '0g', '0g',
 4.0, 73, 'In Stock', NULL,
 'https://cdn.freshmart.example.com/img/green_tea_20.webp', '2025-07-18 03:52:00');
