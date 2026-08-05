-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/05_dmf_observability.sql
-- Purpose: Attach Data Metric Functions for continuous data quality
-- Run as: GS1_PLATFORM_ADMIN (Enterprise Edition required)
-- ============================================================

USE ROLE GS1_PLATFORM_ADMIN;
USE WAREHOUSE GS1_WH;
USE DATABASE GS1_RETAIL_DB;

-- ============================================================
-- PRODUCT_ATTRIBUTES — core product data quality
-- ============================================================

-- Freshness: time since last GDSN sync (critical SLA)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FRESHNESS
  ON (gdsn_last_sync_date)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Null rate on brand_name (required GDM field)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_PERCENT
  ON (brand_name)
  SCHEDULE = '60 MINUTE';

-- Null rate on product_description (required GDM field)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_PERCENT
  ON (product_description)
  SCHEDULE = '60 MINUTE';

-- Null rate on net_weight_value (required for logistics)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_PERCENT
  ON (net_weight_value)
  SCHEDULE = '60 MINUTE';

-- Blank description check
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.BLANK_PERCENT
  ON (product_description_short)
  SCHEDULE = '60 MINUTE';

-- Statistical distribution of completeness scores
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.AVG
  ON (attribute_completeness_pct)
  SCHEDULE = '60 MINUTE';

ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.MIN
  ON (attribute_completeness_pct)
  SCHEDULE = '60 MINUTE';

-- Schema change detection (alert if GDM attributes change)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.SCHEMA_CHANGE_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Row count (monitor for unexpected deletes)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- ============================================================
-- GTIN_REGISTRY — identifier integrity
-- ============================================================

-- Duplicate GTIN check (should always be 0)
ALTER TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Unique GTIN count
ALTER TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.UNIQUE_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Null GCP prefix check
ALTER TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
  ON (gcp_prefix)
  SCHEDULE = '60 MINUTE';

-- ============================================================
-- EPCIS_OBJECT_EVENTS — supply chain event health
-- ============================================================

-- Row count (should grow monotonically — detect pipeline stalls)
ALTER TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
  ON (event_id)
  SCHEDULE = '60 MINUTE';

-- Future timestamp detection (invalid event times)
ALTER TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FUTURE_TIMESTAMP_COUNT
  ON (event_time)
  SCHEDULE = '60 MINUTE';

-- Null GTIN in events (every event must link to a product)
ALTER TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
  ON (gtin)
  SCHEDULE = '60 MINUTE';

-- ============================================================
-- GDSN_SYNC_LOG — pipeline health
-- ============================================================

-- Row count on sync log (ensure pipeline is running)
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
  ON (sync_id)
  SCHEDULE = '60 MINUTE';

-- Freshness of most recent sync
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FRESHNESS
  ON (sync_timestamp)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- ============================================================
-- NUTRITIONAL_INFO — completeness of nutritional data
-- ============================================================

ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.NUTRITIONAL_INFO
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
  ON (energy_kcal_per100g)
  SCHEDULE = '60 MINUTE';

ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.NUTRITIONAL_INFO
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NEGATIVE_COUNT
  ON (fat_g_per100g)
  SCHEDULE = '60 MINUTE';

-- ============================================================
-- Query DMF results
-- ============================================================

-- View all DMF results across GS1 tables
SELECT
  measurement_time,
  table_database,
  table_schema,
  table_name,
  metric_name,
  value
FROM TABLE(
  SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS(
    ref_entity_name => 'GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES',
    ref_entity_domain => 'TABLE'
  )
)
ORDER BY measurement_time DESC, metric_name;
