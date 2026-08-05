-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/gln_registry.sql
-- NovaBrand Foods Ltd (2 locations) + FreshMart Retail Group (7 locations)
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

INSERT INTO GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY
  (gln, gcp_prefix, party_name, location_type,
   street_address, city, postal_code, country_code,
   latitude, longitude, gln_status, registration_date)
VALUES
-- ── NovaBrand Foods Ltd ──────────────────────────────────────
('5901234000002','5901234',
  'NovaBrand Foods Ltd - Head Office','HQ',
  'Innovation House, 12 Commerce Park','Reading','RG1 4AB','GB',
  51.4543,-0.9781,'ACTIVE','2020-01-15'),

('5901234000019','5901234',
  'NovaBrand Foods Ltd - Swindon Factory','FACTORY',
  'Unit 4, Eastfield Industrial Estate','Swindon','SN2 2DL','GB',
  51.5696,-1.7822,'ACTIVE','2020-01-15'),

-- ── FreshMart Retail Group ───────────────────────────────────
('5412345000001','5412345',
  'FreshMart Retail Group - Head Office','HQ',
  'One Retail Tower, City Road','London','EC1V 2PX','GB',
  51.5268,-0.0920,'ACTIVE','2019-06-01'),

('5412345000018','5412345',
  'FreshMart Retail Group - Coventry Distribution Centre','DC',
  'Northgate Distribution Park, Unit 1','Coventry','CV6 5RS','GB',
  52.4450,-1.5230,'ACTIVE','2019-06-01'),

('5412345100010','5412345',
  'FreshMart Store 001 - London Flagship','STORE',
  '88 Oxford Street','London','W1D 1LP','GB',
  51.5154,-0.1336,'ACTIVE','2019-09-01'),

('5412345100027','5412345',
  'FreshMart Store 002 - Manchester','STORE',
  '34 Market Street','Manchester','M1 1PW','GB',
  53.4808,-2.2426,'ACTIVE','2019-09-01'),

('5412345100034','5412345',
  'FreshMart Store 003 - Birmingham','STORE',
  '55 New Street','Birmingham','B2 4DU','GB',
  52.4796,-1.8977,'ACTIVE','2020-02-01'),

('5412345100041','5412345',
  'FreshMart Store 004 - Edinburgh','STORE',
  '101 Princes Street','Edinburgh','EH2 3AB','GB',
  55.9505,-3.1880,'ACTIVE','2020-02-01'),

('5412345100058','5412345',
  'FreshMart Store 005 - Bristol','STORE',
  '22 Cabot Circus','Bristol','BS1 3BX','GB',
  51.4565,-2.5839,'ACTIVE','2021-04-01');
