-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/gpc_taxonomy.sql
-- GS1 Global Product Classification (food & beverage focus)
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

INSERT INTO GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY
  (brick_code, brick_name, class_code, class_name, family_code, family_name, segment_code, segment_name)
VALUES
-- Segment: Food/Beverage/Tobacco (50000000)
-- Family: Grain Based Products
('10000265','Breakfast Cereals/Grains - Prepared/Mixes (Shelf Stable)',
  '10001545','Breakfast Cereals/Grains - Prepared/Mixes',
  '10006319','Grain Based Products','50000000','Food/Beverage/Tobacco'),

-- Family: Dairy Products
('10005773','Milk Preparations - Liquid (Shelf Stable)',
  '10001546','Milk',
  '10006320','Dairy Products/Alternatives','50000000','Food/Beverage/Tobacco'),

('10005779','Yoghurt/Soured Products',
  '10001547','Yoghurt/Fermented Milk Products',
  '10006320','Dairy Products/Alternatives','50000000','Food/Beverage/Tobacco'),

('10005774','Cheese',
  '10001548','Cheese - Hard',
  '10006320','Dairy Products/Alternatives','50000000','Food/Beverage/Tobacco'),

-- Family: Snacks/Confectionery
('10000338','Snacks - Savoury',
  '10001549','Savoury Snack Products',
  '10006321','Snack/Cereal/Pulse Bar Products','50000000','Food/Beverage/Tobacco'),

('10000359','Chocolate/Chocolate Substitutes',
  '10001550','Chocolate - Dark',
  '10006321','Snack/Cereal/Pulse Bar Products','50000000','Food/Beverage/Tobacco'),

-- Family: Beverages
('10005840','Juices - Fruit/Vegetable (Shelf Stable)',
  '10001551','Fruit Juices',
  '10006322','Beverages (Non-Alcoholic)','50000000','Food/Beverage/Tobacco'),

('10005842','Water - Sparkling (Shelf Stable)',
  '10001552','Water',
  '10006322','Beverages (Non-Alcoholic)','50000000','Food/Beverage/Tobacco'),

('10005847','Tea - Shelf Stable',
  '10001553','Tea',
  '10006322','Beverages (Non-Alcoholic)','50000000','Food/Beverage/Tobacco'),

-- Additional bricks for realism
('10005780','Butter/Fat Spreads',
  '10001554','Butter',
  '10006320','Dairy Products/Alternatives','50000000','Food/Beverage/Tobacco'),

('10005841','Juices - Vegetable (Shelf Stable)',
  '10001551','Vegetable Juices',
  '10006322','Beverages (Non-Alcoholic)','50000000','Food/Beverage/Tobacco'),

('10000360','Confectionery - Sugar/Gum',
  '10001550','Confectionery',
  '10006321','Snack/Cereal/Pulse Bar Products','50000000','Food/Beverage/Tobacco');
