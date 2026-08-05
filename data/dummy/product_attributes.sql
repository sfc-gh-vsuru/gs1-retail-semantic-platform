-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/product_attributes.sql
-- NovaBrand Foods Ltd — full GDM product master attributes
-- + Nutritional Info + Allergen Info + GDSN Subscription + Sync Log
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

-- ============================================================
-- PRODUCT_ATTRIBUTES (GDM Global Core)
-- ============================================================

INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  (gtin, gcp_prefix, brand_name, product_description, product_description_short,
   net_weight_value, net_weight_uom, width_mm, height_mm, depth_mm, gross_weight_g,
   packaging_type, units_per_case,
   gpc_brick_code, gpc_brick_name,
   country_of_origin, target_market_country, is_consumer_unit,
   gs1_digital_link_url, product_image_url,
   gtin_status, gtin_registration_date, gdsn_publication_date,
   gdsn_last_sync_date, data_pool_id,
   attribute_completeness_pct, last_modified_date)
VALUES
-- Cereals
('05901234100017','5901234','NovaBrand',
  'NovaBrand Oat Flakes 500g - Wholegrain Rolled Oats','Oat Flakes 500g',
  500,'g',190,280,80,560,'BOX',12,
  '10000265','Breakfast Cereals/Grains - Prepared/Mixes (Shelf Stable)',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234100017',
  'https://assets.novabrand.example.com/images/05901234100017.jpg',
  'ACTIVE','2022-03-15','2022-04-01',
  '2025-07-20 06:00:00','AECOC DataPool',98.5,'2025-07-20 06:00:00'),

('05901234100024','5901234','NovaBrand',
  'NovaBrand Muesli Mixed Fruit 750g - Premium Swiss-Style Muesli','Muesli Mixed Fruit 750g',
  750,'g',210,310,90,850,'BAG',8,
  '10000265','Breakfast Cereals/Grains - Prepared/Mixes (Shelf Stable)',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234100024',
  'https://assets.novabrand.example.com/images/05901234100024.jpg',
  'ACTIVE','2022-03-15','2022-04-01',
  '2025-07-20 06:00:00','AECOC DataPool',95.0,'2025-07-20 06:00:00'),

-- Dairy
('05901234200016','5901234','NovaBrand',
  'NovaBrand Full Fat Milk 1L - Fresh British Whole Milk','Full Fat Milk 1L',
  1000,'ml',70,240,70,1080,'BOTTLE',6,
  '10005773','Milk Preparations - Liquid (Shelf Stable)',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234200016',
  'https://assets.novabrand.example.com/images/05901234200016.jpg',
  'ACTIVE','2021-06-01','2021-07-01',
  '2025-07-19 06:00:00','AECOC DataPool',100.0,'2025-07-19 06:00:00'),

('05901234200023','5901234','NovaBrand',
  'NovaBrand Greek Yoghurt 500g - Thick and Creamy Natural Yoghurt','Greek Yoghurt 500g',
  500,'g',115,180,115,560,'TUB',8,
  '10005779','Yoghurt/Soured Products',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234200023',
  'https://assets.novabrand.example.com/images/05901234200023.jpg',
  'ACTIVE','2021-06-01','2021-07-01',
  '2025-07-19 06:00:00','AECOC DataPool',100.0,'2025-07-19 06:00:00'),

('05901234200030','5901234','NovaBrand',
  'NovaBrand Mature Cheddar Cheese 400g - Aged 12 Months','Mature Cheddar 400g',
  400,'g',120,220,35,440,'WRAPPER',12,
  '10005774','Cheese',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234200030',
  'https://assets.novabrand.example.com/images/05901234200030.jpg',
  'ACTIVE','2021-06-01','2021-07-01',
  '2025-07-18 06:00:00','AECOC DataPool',97.0,'2025-07-18 06:00:00'),

-- Snacks
('05901234300015','5901234','NovaBrand',
  'NovaBrand Sea Salt Crisps 150g - Hand-Cooked Potato Crisps','Sea Salt Crisps 150g',
  150,'g',200,280,40,175,'BAG',24,
  '10000338','Snacks - Savoury',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234300015',
  'https://assets.novabrand.example.com/images/05901234300015.jpg',
  'ACTIVE','2023-01-10','2023-02-01',
  '2025-07-15 06:00:00','AECOC DataPool',92.5,'2025-07-15 06:00:00'),

('05901234300022','5901234','NovaBrand',
  'NovaBrand Dark Chocolate Bar 100g - 72% Cocoa Dark Chocolate','Dark Chocolate 100g',
  100,'g',65,180,10,115,'WRAPPER',24,
  '10000359','Chocolate/Chocolate Substitutes',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234300022',
  'https://assets.novabrand.example.com/images/05901234300022.jpg',
  'ACTIVE','2023-01-10','2023-02-01',
  '2025-07-15 06:00:00','AECOC DataPool',90.0,'2025-07-15 06:00:00'),

-- Beverages
('05901234400014','5901234','NovaBrand',
  'NovaBrand Orange Juice 1L - Freshly Squeezed Not From Concentrate','Orange Juice 1L',
  1000,'ml',73,256,73,1100,'CARTON',12,
  '10005840','Juices - Fruit/Vegetable (Shelf Stable)',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234400014',
  'https://assets.novabrand.example.com/images/05901234400014.jpg',
  'ACTIVE','2020-09-05','2020-10-01',
  '2025-07-01 06:00:00','AECOC DataPool',100.0,'2025-07-01 06:00:00'),

('05901234400021','5901234','NovaBrand',
  'NovaBrand Sparkling Water 500ml - Natural Mineral Water with Bubbles','Sparkling Water 500ml',
  500,'ml',65,220,65,560,'BOTTLE',24,
  '10005842','Water - Sparkling (Shelf Stable)',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234400021',
  'https://assets.novabrand.example.com/images/05901234400021.jpg',
  'ACTIVE','2020-09-05','2020-10-01',
  '2025-07-01 06:00:00','AECOC DataPool',100.0,'2025-07-01 06:00:00'),

('05901234400038','5901234','NovaBrand',
  'NovaBrand Green Tea 20 Bags - Japanese Sencha Green Tea','Green Tea 20 Bags',
  40,'g',120,180,60,55,'BOX',24,
  '10005847','Tea - Shelf Stable',
  'GB','GB',TRUE,
  'https://id.gs1.org/01/05901234400038',
  'https://assets.novabrand.example.com/images/05901234400038.jpg',
  'ACTIVE','2020-09-05','2020-10-01',
  '2025-06-15 06:00:00','AECOC DataPool',88.0,'2025-06-15 06:00:00');


-- ============================================================
-- NUTRITIONAL_INFO (per 100g)
-- ============================================================

INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.NUTRITIONAL_INFO VALUES
--  gtin                   kcal   fat  sat  carb  sug  fib  pro  salt  serv_g
('05901234100017',         375,   7.2, 1.3, 63.0, 1.1, 9.8, 12.4, 0.01, 50),   -- Oat Flakes
('05901234100024',         380,   9.5, 1.8, 61.0, 18.5, 7.5, 9.2, 0.08, 50),   -- Muesli
('05901234200016',          61,   3.5, 2.3,  4.8,  4.8, 0.0, 3.2, 0.10, 200),  -- Full Fat Milk
('05901234200023',         115,   9.2, 6.1,  3.3,  3.3, 0.0, 5.5, 0.06, 150),  -- Greek Yoghurt
('05901234200030',         416,  34.4,21.7,  0.1,  0.1, 0.0,25.4, 1.76, 30),   -- Cheddar Cheese
('05901234300015',         536,  34.0, 3.0, 53.0,  0.3, 3.8, 5.8, 1.20, 40),   -- Sea Salt Crisps
('05901234300022',         565,  39.0,22.5, 47.0, 28.0, 9.0, 5.8, 0.01, 25),   -- Dark Chocolate
('05901234400014',          44,   0.1, 0.0, 10.4,  9.2, 0.3, 0.7, 0.01, 200),  -- Orange Juice
('05901234400021',           0,   0.0, 0.0,  0.0,  0.0, 0.0, 0.0, 0.01, 500),  -- Sparkling Water
('05901234400038',           1,   0.0, 0.0,  0.2,  0.0, 0.0, 0.0, 0.00, 200);  -- Green Tea


-- ============================================================
-- ALLERGEN_INFO
-- ============================================================

INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.ALLERGEN_INFO VALUES
-- gtin                   gluten  dairy  nuts   soy    eggs   fish  celery  statement
('05901234100017',        TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
  'Contains gluten (oats). May contain traces of nuts and milk.'),
('05901234100024',        TRUE,  FALSE, TRUE,  FALSE, FALSE, FALSE, FALSE,
  'Contains gluten (oats) and nuts. May contain traces of milk.'),
('05901234200016',        FALSE, TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE,
  'Contains milk. Suitable for vegetarians.'),
('05901234200023',        FALSE, TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE,
  'Contains milk. Suitable for vegetarians.'),
('05901234200030',        FALSE, TRUE,  FALSE, FALSE, FALSE, FALSE, FALSE,
  'Contains milk. Suitable for vegetarians.'),
('05901234300015',        FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
  'Free from major allergens. May contain traces of milk.'),
('05901234300022',        FALSE, TRUE,  FALSE, TRUE,  FALSE, FALSE, FALSE,
  'Contains milk and soy (as emulsifier). May contain traces of nuts.'),
('05901234400014',        FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
  'Free from major allergens. Suitable for vegans.'),
('05901234400021',        FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
  'Free from all major allergens. Suitable for vegans.'),
('05901234400038',        FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
  'Free from all major allergens. Suitable for vegans.');


-- ============================================================
-- GDSN_SUBSCRIPTION — NovaBrand publishes to FreshMart
-- ============================================================

INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SUBSCRIPTION VALUES
('SUB-NB-FM-001',
  'NovaBrand Foods Ltd', '5901234000002',
  'FreshMart Retail Group','5412345000001',
  'AECOC DataPool','ACTIVE','2021-01-10', 10);


-- ============================================================
-- GDSN_SYNC_LOG — last 30 days of sync activity
-- ============================================================

INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG
  (sync_id, gtin, source_gln, target_gln, sync_timestamp, sync_status, attributes_changed, sync_type, error_message)
SELECT
  'SYNC-' || LPAD(seq::VARCHAR, 5, '0') AS sync_id,
  gtin,
  '5901234000002' AS source_gln,
  '5412345000001' AS target_gln,
  DATEADD('day', -FLOOR(seq / 10), CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS sync_timestamp,
  IFF(seq % 15 = 0, 'FAILED', 'SUCCESS') AS sync_status,
  IFF(seq % 15 = 0, 0, FLOOR(RANDOM() * 5)::INTEGER) AS attributes_changed,
  'DELTA' AS sync_type,
  IFF(seq % 15 = 0, 'GDSN_ERR_401: Subscription timeout', NULL) AS error_message
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY seq4()) - 1 AS seq,
         COLUMN1 AS gtin
  FROM VALUES
    ('05901234100017'),('05901234100024'),('05901234200016'),('05901234200023'),
    ('05901234200030'),('05901234300015'),('05901234300022'),('05901234400014'),
    ('05901234400021'),('05901234400038')
)
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY seq4()) - 1 AS seq FROM TABLE(GENERATOR(ROWCOUNT => 30)))
WHERE seq < 30
ORDER BY sync_timestamp DESC;
