-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/verification_lookups.sql
-- Verified by GS1 — GTIN and GLN lookup history
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

INSERT INTO GS1_RETAIL_DB.VERIFICATION.VERIFIED_BY_GS1_LOOKUPS
  (lookup_id, lookup_timestamp, lookup_type, identifier_queried,
   lookup_result, company_name_returned, requester_type, requester_country)
VALUES
-- Valid GTIN lookups
('LKP-001','2025-07-20 10:15:00','GTIN','05901234100017','VALID',  'NovaBrand Foods Ltd','RETAILER','GB'),
('LKP-002','2025-07-20 10:22:00','GTIN','05901234200016','VALID',  'NovaBrand Foods Ltd','RETAILER','GB'),
('LKP-003','2025-07-20 11:05:00','GTIN','05901234200030','VALID',  'NovaBrand Foods Ltd','CONSUMER','GB'),
('LKP-004','2025-07-20 11:30:00','GTIN','05901234300015','VALID',  'NovaBrand Foods Ltd','RETAILER','DE'),
('LKP-005','2025-07-20 12:00:00','GTIN','05901234400014','VALID',  'NovaBrand Foods Ltd','CONSUMER','FR'),
('LKP-006','2025-07-21 09:00:00','GTIN','05901234100024','VALID',  'NovaBrand Foods Ltd','RETAILER','GB'),
('LKP-007','2025-07-21 09:30:00','GTIN','05901234200023','VALID',  'NovaBrand Foods Ltd','REGULATOR','GB'),
('LKP-008','2025-07-21 10:00:00','GTIN','05901234300022','VALID',  'NovaBrand Foods Ltd','CONSUMER','GB'),
('LKP-009','2025-07-21 10:30:00','GTIN','05901234400021','VALID',  'NovaBrand Foods Ltd','RETAILER','US'),
('LKP-010','2025-07-21 11:00:00','GTIN','05901234400038','VALID',  'NovaBrand Foods Ltd','CONSUMER','AU'),

-- Invalid/not-found lookups (simulating bad barcodes or expired GTINs)
('LKP-011','2025-07-20 14:00:00','GTIN','09999999999990','NOT_FOUND',NULL,'CONSUMER','GB'),
('LKP-012','2025-07-21 15:00:00','GTIN','09999999999996','NOT_FOUND',NULL,'RETAILER','GB'),
('LKP-013','2025-07-22 09:30:00','GTIN','00000000000000','INVALID', NULL,'CONSUMER','DE'),

-- GLN lookups
('LKP-014','2025-07-20 08:00:00','GLN','5412345100010','VALID','FreshMart Store 001 - London','RETAILER','GB'),
('LKP-015','2025-07-21 08:30:00','GLN','5412345000018','VALID','FreshMart DC - Coventry',     'RETAILER','GB'),
('LKP-016','2025-07-22 09:00:00','GLN','5901234000019','VALID','NovaBrand Factory - Swindon', 'REGULATOR','GB'),

-- More valid GTIN lookups across days (volume simulation)
('LKP-017','2025-07-22 10:00:00','GTIN','05901234100017','VALID','NovaBrand Foods Ltd','CONSUMER','GB'),
('LKP-018','2025-07-22 10:15:00','GTIN','05901234200016','VALID','NovaBrand Foods Ltd','RETAILER','IE'),
('LKP-019','2025-07-22 11:00:00','GTIN','05901234400014','VALID','NovaBrand Foods Ltd','CONSUMER','US'),
('LKP-020','2025-07-23 09:00:00','GTIN','05901234100017','VALID','NovaBrand Foods Ltd','CONSUMER','GB'),
('LKP-021','2025-07-23 09:30:00','GTIN','05901234300015','VALID','NovaBrand Foods Ltd','RETAILER','GB'),
('LKP-022','2025-07-23 10:00:00','GTIN','05901234200030','VALID','NovaBrand Foods Ltd','CONSUMER','GB'),
('LKP-023','2025-07-23 11:00:00','GTIN','05901234400038','VALID','NovaBrand Foods Ltd','CONSUMER','JP'),
('LKP-024','2025-07-23 14:00:00','GTIN','09999999111111','NOT_FOUND',NULL,'CONSUMER','GB'),
('LKP-025','2025-07-24 09:00:00','GTIN','05901234100024','VALID','NovaBrand Foods Ltd','RETAILER','FR');
