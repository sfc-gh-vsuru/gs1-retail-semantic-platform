-- ============================================================
-- GS1 Retail Observability Platform — Dummy Data
-- File: data/dummy/member_registry.sql
-- Participants: GS1 Global, NovaBrand Foods Ltd, FreshMart Retail Group
-- ============================================================

USE DATABASE GS1_RETAIL_DB;

-- GS1 Member Organisations
INSERT INTO GS1_RETAIL_DB.MEMBERS.GS1_MEMBER_REGISTRY VALUES
('GS1-GLOBAL', 'GS1 Global',              'BE', 'Belgium',        'https://www.gs1.org',    'info@gs1-demo.example.org',              1977),
('GS1-UK',     'GS1 UK',                  'GB', 'United Kingdom', 'https://www.gs1uk.org',  'info@gs1uk-demo.example.org',            1979),
('GS1-US',     'GS1 US',                  'US', 'United States',  'https://www.gs1us.org',  'info@gs1us-demo.example.org',            1972),
('GS1-DE',     'GS1 Germany',             'DE', 'Germany',        'https://www.gs1-germany.de','info@gs1de-demo.example.org',    1974),
('GS1-FR',     'GS1 France (GS1 ATOS)',   'FR', 'France',         'https://www.gs1.fr',     'info@gs1fr-demo.example.org',               1976);

-- Company Registry: NovaBrand + FreshMart
INSERT INTO GS1_RETAIL_DB.MEMBERS.COMPANY_REGISTRY VALUES
('COMP-NB-001', 'NovaBrand Foods Ltd',      'BRAND_OWNER', 'GS1-UK', '5901234', 'GB', 'ACTIVE', '2020-01-15'),
('COMP-FM-001', 'FreshMart Retail Group',   'RETAILER',    'GS1-UK', '5412345', 'GB', 'ACTIVE', '2019-06-01');

-- GS1 Company Prefix Registry
INSERT INTO GS1_RETAIL_DB.MEMBERS.GCP_REGISTRY VALUES
('5901234', 'NovaBrand Foods Ltd',    7, 'ACTIVE', '2020-01-15', 'GS1 UK'),
('5412345', 'FreshMart Retail Group', 7, 'ACTIVE', '2019-06-01', 'GS1 UK');
