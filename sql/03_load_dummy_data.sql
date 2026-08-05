-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/03_load_dummy_data.sql
-- Purpose: Load all synthetic dummy data
--          Calls individual files in data/dummy/
-- Run as: GS1_PLATFORM_ADMIN
-- ============================================================

USE ROLE GS1_PLATFORM_ADMIN;
USE WAREHOUSE GS1_WH;
USE DATABASE GS1_RETAIL_DB;

-- Run in order:
-- 1. GPC Taxonomy (no foreign key dependencies)
-- 2. GS1 Members + Companies + GCPs
-- 3. GTIN Registry + GLN Registry
-- 4. Product Attributes + Nutritional + Allergen
-- 5. GDSN Subscription + Sync Log
-- 6. EPCIS Events (Object, Aggregation, Transaction)
-- 7. Verified by GS1 Lookups

-- See data/dummy/ directory for each file.
-- To run all at once via Snowflake CLI:
--   snow sql -f data/dummy/gpc_taxonomy.sql        --connection gs1_dev
--   snow sql -f data/dummy/member_registry.sql      --connection gs1_dev
--   snow sql -f data/dummy/gtin_registry.sql        --connection gs1_dev
--   snow sql -f data/dummy/gln_registry.sql         --connection gs1_dev
--   snow sql -f data/dummy/product_attributes.sql   --connection gs1_dev
--   snow sql -f data/dummy/epcis_events.sql         --connection gs1_dev
--   snow sql -f data/dummy/verification_lookups.sql --connection gs1_dev

-- Verification queries after load:
SELECT 'GPC_TAXONOMY'            AS table_name, COUNT(*) AS row_count FROM GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY
UNION ALL SELECT 'GS1_MEMBER_REGISTRY',  COUNT(*) FROM GS1_RETAIL_DB.MEMBERS.GS1_MEMBER_REGISTRY
UNION ALL SELECT 'COMPANY_REGISTRY',     COUNT(*) FROM GS1_RETAIL_DB.MEMBERS.COMPANY_REGISTRY
UNION ALL SELECT 'GCP_REGISTRY',         COUNT(*) FROM GS1_RETAIL_DB.MEMBERS.GCP_REGISTRY
UNION ALL SELECT 'GTIN_REGISTRY',        COUNT(*) FROM GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
UNION ALL SELECT 'GLN_REGISTRY',         COUNT(*) FROM GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY
UNION ALL SELECT 'PRODUCT_ATTRIBUTES',   COUNT(*) FROM GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
UNION ALL SELECT 'NUTRITIONAL_INFO',     COUNT(*) FROM GS1_RETAIL_DB.PRODUCT_MASTER.NUTRITIONAL_INFO
UNION ALL SELECT 'ALLERGEN_INFO',        COUNT(*) FROM GS1_RETAIL_DB.PRODUCT_MASTER.ALLERGEN_INFO
UNION ALL SELECT 'GDSN_SUBSCRIPTION',    COUNT(*) FROM GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SUBSCRIPTION
UNION ALL SELECT 'GDSN_SYNC_LOG',        COUNT(*) FROM GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG
UNION ALL SELECT 'EPCIS_OBJECT_EVENTS',  COUNT(*) FROM GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
UNION ALL SELECT 'EPCIS_AGG_EVENTS',     COUNT(*) FROM GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_AGGREGATION_EVENTS
UNION ALL SELECT 'EPCIS_TXN_EVENTS',     COUNT(*) FROM GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_TRANSACTION_EVENTS
UNION ALL SELECT 'VERIFICATION_LOOKUPS', COUNT(*) FROM GS1_RETAIL_DB.VERIFICATION.VERIFIED_BY_GS1_LOOKUPS
ORDER BY 1;
