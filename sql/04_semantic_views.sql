-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/04_semantic_views.sql
-- Purpose: Create Snowflake Semantic Views for Cortex Analyst
-- Run as: GS1_PLATFORM_ADMIN
-- ============================================================

USE ROLE GS1_PLATFORM_ADMIN;
USE WAREHOUSE GS1_WH;
USE DATABASE GS1_RETAIL_DB;

-- ============================================================
-- GS1 Retail Semantic View
-- Covers: product, location, supply chain events, data quality
-- ============================================================

CREATE OR REPLACE SEMANTIC VIEW GS1_RETAIL_DB.SEMANTIC.GS1_RETAIL_SV
TABLES (

  product AS GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
    PRIMARY KEY (gtin)
    WITH SYNONYMS = ('product', 'trade item', 'GTIN', 'item', 'SKU'),

  gpc AS GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY
    PRIMARY KEY (brick_code)
    WITH SYNONYMS = ('category', 'product category', 'GPC', 'taxonomy'),

  location AS GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY
    PRIMARY KEY (gln)
    WITH SYNONYMS = ('location', 'party', 'store', 'warehouse', 'factory', 'DC'),

  gtin_reg AS GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
    PRIMARY KEY (gtin)
    WITH SYNONYMS = ('GTIN registry', 'identifier registry'),

  epcis AS GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
    PRIMARY KEY (event_id)
    WITH SYNONYMS = ('supply chain event', 'traceability event', 'EPCIS event', 'scan event'),

  gdsn_sync AS GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG
    PRIMARY KEY (sync_id)
    WITH SYNONYMS = ('GDSN sync', 'sync log', 'product data sync'),

  verification AS GS1_RETAIL_DB.VERIFICATION.VERIFIED_BY_GS1_LOOKUPS
    PRIMARY KEY (lookup_id)
    WITH SYNONYMS = ('verification lookup', 'barcode lookup', 'GTIN check')
)

RELATIONSHIPS (
  product   (gpc_brick_code)    REFERENCES gpc      (brick_code),
  product   (gtin)              REFERENCES gtin_reg (gtin),
  epcis     (biz_location_gln)  REFERENCES location (gln),
  epcis     (gtin)              REFERENCES product  (gtin),
  gdsn_sync (gtin)              REFERENCES product  (gtin)
)

FACTS (
  product (attribute_completeness_pct)
    AS "Product Data Completeness (%)"
    WITH SYNONYMS = ('completeness', 'data quality score', 'attribute fill rate')
)

DIMENSIONS (
  -- Product dimensions
  product (brand_name)                AS "Brand Name"
    WITH SYNONYMS = ('brand', 'manufacturer'),
  product (product_description_short) AS "Product Name"
    WITH SYNONYMS = ('product', 'item name', 'SKU name'),
  product (gtin_status)               AS "Product Status"
    WITH SYNONYMS = ('status', 'GTIN status', 'active or inactive'),
  product (packaging_type)            AS "Packaging Type"
    WITH SYNONYMS = ('pack type', 'packaging'),
  product (country_of_origin)         AS "Country of Origin"
    WITH SYNONYMS = ('origin country', 'made in', 'sourced from'),
  product (net_weight_uom)            AS "Weight Unit",
  product (gdsn_last_sync_date::DATE) AS "Last GDSN Sync Date"
    WITH SYNONYMS = ('sync date', 'last synced', 'data freshness date'),

  -- GPC Category dimensions
  gpc (brick_name)                    AS "Product Category"
    WITH SYNONYMS = ('category', 'GPC brick', 'product type'),
  gpc (class_name)                    AS "Product Class",
  gpc (family_name)                   AS "Product Family",
  gpc (segment_name)                  AS "Product Segment",

  -- Location dimensions
  location (party_name)               AS "Location Name"
    WITH SYNONYMS = ('party', 'company', 'location'),
  location (location_type)            AS "Location Type"
    WITH SYNONYMS = ('site type', 'facility type'),
  location (city)                     AS "City",
  location (country_code)             AS "Country",

  -- EPCIS event dimensions
  epcis (biz_step)                    AS "Business Step"
    WITH SYNONYMS = ('event type', 'supply chain step', 'EPCIS business step'),
  epcis (disposition)                 AS "Disposition"
    WITH SYNONYMS = ('status', 'product state'),
  epcis (event_time::DATE)            AS "Event Date"
    WITH SYNONYMS = ('event day', 'scan date'),

  -- Sync dimensions
  gdsn_sync (sync_status)             AS "Sync Status",
  gdsn_sync (sync_type)               AS "Sync Type",

  -- Verification dimensions
  verification (lookup_type)          AS "Lookup Type",
  verification (lookup_result)        AS "Verification Result"
    WITH SYNONYMS = ('lookup result', 'barcode valid', 'GTIN valid'),
  verification (requester_type)       AS "Requester Type",
  verification (requester_country)    AS "Requester Country",
  verification (lookup_timestamp::DATE) AS "Lookup Date"
)

METRICS (
  COUNT(product.gtin)
    AS "Total Registered GTINs"
    WITH SYNONYMS = ('GTIN count', 'product count', 'number of products'),

  COUNT_IF(product.gtin_status = 'ACTIVE')
    AS "Active GTINs"
    WITH SYNONYMS = ('active products', 'live GTINs'),

  COUNT_IF(product.gtin_status = 'INACTIVE')
    AS "Inactive GTINs",

  AVG(product.attribute_completeness_pct)
    AS "Average Data Completeness (%)"
    WITH SYNONYMS = ('avg completeness', 'mean data quality', 'average attribute fill rate'),

  MIN(product.attribute_completeness_pct)
    AS "Lowest Data Completeness (%)"
    WITH SYNONYMS = ('worst completeness', 'minimum quality score'),

  COUNT_IF(product.attribute_completeness_pct < 95)
    AS "GTINs Below 95% Completeness"
    WITH SYNONYMS = ('incomplete products', 'products needing data enrichment'),

  DATEDIFF('day', MAX(product.gdsn_last_sync_date), CURRENT_TIMESTAMP())
    AS "Max Days Since Last GDSN Sync"
    WITH SYNONYMS = ('data staleness', 'sync freshness', 'days since sync'),

  COUNT(epcis.event_id)
    AS "Total Supply Chain Events"
    WITH SYNONYMS = ('event count', 'EPCIS events', 'traceability events'),

  COUNT(DISTINCT epcis.gtin)
    AS "GTINs with Traceability Events"
    WITH SYNONYMS = ('traceable products', 'GTINs with events'),

  COUNT_IF(epcis.biz_step = 'commissioning')
    AS "Commissioning Events",

  COUNT_IF(epcis.biz_step = 'shipping')
    AS "Shipping Events",

  COUNT_IF(epcis.biz_step = 'receiving')
    AS "Receiving Events",

  COUNT_IF(epcis.biz_step = 'stocking')
    AS "Stocking Events",

  COUNT(gdsn_sync.sync_id)
    AS "Total GDSN Syncs",

  COUNT_IF(gdsn_sync.sync_status = 'FAILED')
    AS "Failed GDSN Syncs"
    WITH SYNONYMS = ('sync failures', 'failed syncs'),

  COUNT(verification.lookup_id)
    AS "Total Verification Lookups"
    WITH SYNONYMS = ('barcode lookups', 'GTIN checks', 'verification requests'),

  COUNT_IF(verification.lookup_result = 'VALID')
    AS "Valid Verifications"
    WITH SYNONYMS = ('successful lookups', 'valid GTINs checked'),

  COUNT_IF(verification.lookup_result = 'NOT_FOUND')
    AS "Not Found Lookups"
    WITH SYNONYMS = ('unknown GTINs', 'unregistered barcodes'),

  ROUND(
    COUNT_IF(verification.lookup_result = 'VALID') * 100.0 /
    NULLIF(COUNT(verification.lookup_id), 0), 2
  )
    AS "GTIN Verification Success Rate (%)"
    WITH SYNONYMS = ('verification rate', 'lookup success rate', 'barcode validity rate')
);

-- Grant semantic view access to analysts
GRANT SELECT ON SEMANTIC VIEW GS1_RETAIL_DB.SEMANTIC.GS1_RETAIL_SV
  TO ROLE GS1_ANALYST;
