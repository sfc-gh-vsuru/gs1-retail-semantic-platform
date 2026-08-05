-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/gtin_registry.sql
-- NovaBrand Foods Ltd — 10 product GTINs
-- GCP Prefix: 5901234
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

INSERT INTO GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  (gtin, gcp_prefix, company_name, product_description, brand_name,
   gtin_status, gtin_type, registration_date, last_modified_date, gs1_member_org, check_digit_valid)
VALUES
('05901234100017','5901234','NovaBrand Foods Ltd','NovaBrand Oat Flakes 500g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2022-03-15','2024-11-01 09:00:00','GS1 UK',TRUE),

('05901234100024','5901234','NovaBrand Foods Ltd','NovaBrand Muesli Mixed Fruit 750g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2022-03-15','2024-11-01 09:00:00','GS1 UK',TRUE),

('05901234200016','5901234','NovaBrand Foods Ltd','NovaBrand Full Fat Milk 1L',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-01-10 12:00:00','GS1 UK',TRUE),

('05901234200023','5901234','NovaBrand Foods Ltd','NovaBrand Greek Yoghurt 500g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-01-10 12:00:00','GS1 UK',TRUE),

('05901234200030','5901234','NovaBrand Foods Ltd','NovaBrand Cheddar Cheese 400g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-02-20 14:00:00','GS1 UK',TRUE),

('05901234300015','5901234','NovaBrand Foods Ltd','NovaBrand Sea Salt Crisps 150g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2023-01-10','2024-12-05 11:30:00','GS1 UK',TRUE),

('05901234300022','5901234','NovaBrand Foods Ltd','NovaBrand Dark Chocolate Bar 100g',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2023-01-10','2024-12-05 11:30:00','GS1 UK',TRUE),

('05901234400014','5901234','NovaBrand Foods Ltd','NovaBrand Orange Juice 1L',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2025-03-01 08:00:00','GS1 UK',TRUE),

('05901234400021','5901234','NovaBrand Foods Ltd','NovaBrand Sparkling Water 500ml',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2025-03-01 08:00:00','GS1 UK',TRUE),

('05901234400038','5901234','NovaBrand Foods Ltd','NovaBrand Green Tea 20 Bags',
  'NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2024-10-15 16:00:00','GS1 UK',TRUE);
