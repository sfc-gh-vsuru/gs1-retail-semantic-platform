-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/epcis_events.sql
-- Supply chain event flow: NovaBrand Factory → FreshMart DC → FreshMart Stores
-- Covers: commissioning, packing, shipping, receiving, stocking
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

-- ============================================================
-- EPCIS OBJECT EVENTS
-- ============================================================

INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
  (event_id, event_time, event_timezone_offset, epc_list, action,
   biz_step, disposition, read_point_gln, biz_location_gln,
   source_party_gln, destination_party_gln,
   gtin, serial_number, lot_number, expiry_date)
VALUES

-- ── COMMISSIONING: NovaBrand Factory produces items ──────────
('EVT-NB-C001','2025-07-18 06:30:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234100017','00001','LOT-NB-2507A','2026-07-18'),

('EVT-NB-C002','2025-07-18 06:35:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00002'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234100017','00002','LOT-NB-2507A','2026-07-18'),

('EVT-NB-C003','2025-07-18 07:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00001'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234200016','00001','LOT-NB-2507B','2025-09-18'),

('EVT-NB-C004','2025-07-18 07:05:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00002'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234200016','00002','LOT-NB-2507B','2025-09-18'),

('EVT-NB-C005','2025-07-18 07:30:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.030001.00001'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234300015','00001','LOT-NB-2507C','2026-01-18'),

('EVT-NB-C006','2025-07-18 07:35:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.040001.00001'),'ADD',
  'commissioning','active',
  '5901234000019','5901234000019',NULL,NULL,
  '05901234400014','00001','LOT-NB-2507D','2026-07-18'),

-- ── SHIPPING: NovaBrand ships to FreshMart DC ─────────────────
('EVT-NB-S001','2025-07-19 14:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001','urn:epc:id:sgtin:5901234.010001.00002'),
  'OBSERVE','shipping','in_transit',
  '5901234000019','5901234000019',
  '5901234000002','5412345000018',
  '05901234100017',NULL,'LOT-NB-2507A','2026-07-18'),

('EVT-NB-S002','2025-07-19 14:05:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00001','urn:epc:id:sgtin:5901234.020001.00002'),
  'OBSERVE','shipping','in_transit',
  '5901234000019','5901234000019',
  '5901234000002','5412345000018',
  '05901234200016',NULL,'LOT-NB-2507B','2025-09-18'),

('EVT-NB-S003','2025-07-19 14:10:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.030001.00001'),
  'OBSERVE','shipping','in_transit',
  '5901234000019','5901234000019',
  '5901234000002','5412345000018',
  '05901234300015',NULL,'LOT-NB-2507C','2026-01-18'),

-- ── RECEIVING: FreshMart DC accepts delivery ──────────────────
('EVT-FM-R001','2025-07-20 09:30:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001','urn:epc:id:sgtin:5901234.010001.00002'),
  'OBSERVE','receiving','in_progress',
  '5412345000018','5412345000018',
  '5901234000002','5412345000018',
  '05901234100017',NULL,'LOT-NB-2507A','2026-07-18'),

('EVT-FM-R002','2025-07-20 09:45:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00001','urn:epc:id:sgtin:5901234.020001.00002'),
  'OBSERVE','receiving','in_progress',
  '5412345000018','5412345000018',
  '5901234000002','5412345000018',
  '05901234200016',NULL,'LOT-NB-2507B','2025-09-18'),

('EVT-FM-R003','2025-07-20 10:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.030001.00001'),
  'OBSERVE','receiving','in_progress',
  '5412345000018','5412345000018',
  '5901234000002','5412345000018',
  '05901234300015',NULL,'LOT-NB-2507C','2026-01-18'),

-- ── STOCKING: FreshMart Stores put items on shelves ───────────
-- London Flagship (Store 001)
('EVT-FM-K001','2025-07-21 08:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),
  'OBSERVE','stocking','active',
  '5412345100010','5412345100010',
  '5412345000018',NULL,
  '05901234100017',NULL,'LOT-NB-2507A','2026-07-18'),

('EVT-FM-K002','2025-07-21 08:05:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00001'),
  'OBSERVE','stocking','active',
  '5412345100010','5412345100010',
  '5412345000018',NULL,
  '05901234200016',NULL,'LOT-NB-2507B','2025-09-18'),

-- Manchester (Store 002)
('EVT-FM-K003','2025-07-21 09:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00002'),
  'OBSERVE','stocking','active',
  '5412345100027','5412345100027',
  '5412345000018',NULL,
  '05901234100017',NULL,'LOT-NB-2507A','2026-07-18'),

('EVT-FM-K004','2025-07-21 09:05:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.030001.00001'),
  'OBSERVE','stocking','active',
  '5412345100027','5412345100027',
  '5412345000018',NULL,
  '05901234300015',NULL,'LOT-NB-2507C','2026-01-18'),

-- Birmingham (Store 003)
('EVT-FM-K005','2025-07-22 08:30:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.020001.00002'),
  'OBSERVE','stocking','active',
  '5412345100034','5412345100034',
  '5412345000018',NULL,
  '05901234200016',NULL,'LOT-NB-2507B','2025-09-18'),

-- Edinburgh (Store 004)
('EVT-FM-K006','2025-07-22 10:00:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.040001.00001'),
  'OBSERVE','stocking','active',
  '5412345100041','5412345100041',
  '5412345000018',NULL,
  '05901234400014',NULL,'LOT-NB-2507D','2026-07-18'),

-- Bristol (Store 005)
('EVT-FM-K007','2025-07-22 11:15:00','+01:00',
  ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),
  'OBSERVE','stocking','active',
  '5412345100058','5412345100058',
  '5412345000018',NULL,
  '05901234100017',NULL,'LOT-NB-2507A','2026-07-18');


-- ============================================================
-- EPCIS AGGREGATION EVENTS — packing at NovaBrand factory
-- ============================================================

INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_AGGREGATION_EVENTS
  (event_id, event_time, parent_id, child_epcs, action,
   biz_step, disposition, read_point_gln, biz_location_gln)
VALUES
-- Pack individual Oat Flakes units into case
('EVT-NB-AGG001','2025-07-18 08:00:00',
  'urn:epc:id:sscc:5901234.0000000001',
  ARRAY_CONSTRUCT(
    'urn:epc:id:sgtin:5901234.010001.00001',
    'urn:epc:id:sgtin:5901234.010001.00002'
  ),
  'ADD','packing','in_progress',
  '5901234000019','5901234000019'),

-- Pack Milk units into case
('EVT-NB-AGG002','2025-07-18 08:30:00',
  'urn:epc:id:sscc:5901234.0000000002',
  ARRAY_CONSTRUCT(
    'urn:epc:id:sgtin:5901234.020001.00001',
    'urn:epc:id:sgtin:5901234.020001.00002'
  ),
  'ADD','packing','in_progress',
  '5901234000019','5901234000019'),

-- Unpack at FreshMart DC
('EVT-FM-AGG001','2025-07-20 10:30:00',
  'urn:epc:id:sscc:5901234.0000000001',
  ARRAY_CONSTRUCT(
    'urn:epc:id:sgtin:5901234.010001.00001',
    'urn:epc:id:sgtin:5901234.010001.00002'
  ),
  'DELETE','unpacking','in_progress',
  '5412345000018','5412345000018');


-- ============================================================
-- EPCIS TRANSACTION EVENTS — links to business documents
-- ============================================================

INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_TRANSACTION_EVENTS
  (event_id, event_time, biz_transaction_type, biz_transaction_id,
   epc_list, action, biz_step, biz_location_gln,
   source_party_gln, destination_party_gln)
VALUES
-- Despatch Advice (DESADV): NovaBrand ships to FreshMart
('EVT-TXN-001','2025-07-19 13:55:00',
  'desadv','DESADV-NB-FM-20250719-001',
  ARRAY_CONSTRUCT(
    'urn:epc:id:sgtin:5901234.010001.00001',
    'urn:epc:id:sgtin:5901234.010001.00002',
    'urn:epc:id:sgtin:5901234.020001.00001'
  ),
  'ADD','shipping',
  '5901234000019',
  '5901234000002','5412345000018'),

-- Purchase Order confirmation
('EVT-TXN-002','2025-07-15 09:00:00',
  'po','PO-FM-NB-20250715-001',
  ARRAY_CONSTRUCT(
    'urn:epc:id:sgtin:5901234.010001.00001'
  ),
  'ADD','ordering',
  '5412345000001',
  '5412345000001','5901234000002');
