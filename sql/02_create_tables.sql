-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/02_create_tables.sql
-- Purpose: DDL for all GS1, NovaBrand, and FreshMart tables
-- Run as: GS1_PLATFORM_ADMIN
-- ============================================================

USE ROLE GS1_PLATFORM_ADMIN;
USE WAREHOUSE GS1_WH;
USE DATABASE GS1_RETAIL_DB;

-- ============================================================
-- MEMBERS schema
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.MEMBERS.GS1_MEMBER_REGISTRY (
    member_org_id           VARCHAR(20)   NOT NULL,
    organisation_name       VARCHAR(255),
    country_code            VARCHAR(3),
    country_name            VARCHAR(100),
    website_url             VARCHAR(255),
    contact_email           VARCHAR(255),
    member_since_year       INTEGER,
    CONSTRAINT pk_gs1_member PRIMARY KEY (member_org_id)
)
COMMENT = 'GS1 national member organisations';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.MEMBERS.COMPANY_REGISTRY (
    company_id              VARCHAR(20)   NOT NULL,
    company_name            VARCHAR(255),
    company_role            VARCHAR(50),   -- BRAND_OWNER / RETAILER / LOGISTICS / DATA_POOL
    gs1_member_org_id       VARCHAR(20),
    gcp_prefix              VARCHAR(12),
    country_code            VARCHAR(3),
    company_status          VARCHAR(20),   -- ACTIVE / INACTIVE
    member_since_date       DATE,
    CONSTRAINT pk_company PRIMARY KEY (company_id)
)
COMMENT = 'GS1 member companies — NovaBrand Foods Ltd and FreshMart Retail Group';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.MEMBERS.GCP_REGISTRY (
    gcp_prefix              VARCHAR(12)   NOT NULL,
    company_name            VARCHAR(255),
    gcp_length              INTEGER,
    gcp_status              VARCHAR(20),
    assigned_date           DATE,
    gs1_member_org          VARCHAR(100),
    CONSTRAINT pk_gcp PRIMARY KEY (gcp_prefix)
)
COMMENT = 'GS1 Company Prefix assignments — one per member company';

-- ============================================================
-- IDENTITY schema
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY (
    gtin                    VARCHAR(14)   NOT NULL,
    gcp_prefix              VARCHAR(12)   NOT NULL,
    company_name            VARCHAR(255),
    product_description     VARCHAR(500),
    brand_name              VARCHAR(255),
    gtin_status             VARCHAR(20),               -- ACTIVE / INACTIVE / RETIRED
    gtin_type               VARCHAR(30),               -- CONSUMER_UNIT / INNER_PACK / CASE / PALLET / DISPLAY
    registration_date       DATE,
    last_modified_date      TIMESTAMP_NTZ,
    gs1_member_org          VARCHAR(100),
    check_digit_valid       BOOLEAN,
    CONSTRAINT pk_gtin PRIMARY KEY (gtin)
)
COMMENT = 'GS1 GTIN Registry — all registered product identifiers for NovaBrand Foods Ltd';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY (
    gln                     VARCHAR(13)   NOT NULL,
    gcp_prefix              VARCHAR(12)   NOT NULL,
    party_name              VARCHAR(255),
    location_type           VARCHAR(50),               -- HQ / FACTORY / WAREHOUSE / STORE / DC
    street_address          VARCHAR(500),
    city                    VARCHAR(100),
    postal_code             VARCHAR(20),
    country_code            VARCHAR(3),
    latitude                FLOAT,
    longitude               FLOAT,
    gln_status              VARCHAR(20),               -- ACTIVE / INACTIVE
    registration_date       DATE,
    CONSTRAINT pk_gln PRIMARY KEY (gln)
)
COMMENT = 'GS1 GLN Registry — party and location identifiers for NovaBrand and FreshMart';

-- ============================================================
-- CLASSIFICATION schema
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY (
    brick_code              VARCHAR(10)   NOT NULL,
    brick_name              VARCHAR(255),
    class_code              VARCHAR(10),
    class_name              VARCHAR(255),
    family_code             VARCHAR(10),
    family_name             VARCHAR(255),
    segment_code            VARCHAR(10),
    segment_name            VARCHAR(255),
    CONSTRAINT pk_gpc PRIMARY KEY (brick_code)
)
COMMENT = 'GS1 GPC taxonomy — Segment / Family / Class / Brick hierarchy (food & beverage focus)';

-- ============================================================
-- PRODUCT_MASTER schema
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES (
    gtin                        VARCHAR(14)   NOT NULL,
    gcp_prefix                  VARCHAR(12),
    brand_name                  VARCHAR(255),
    product_description         VARCHAR(500),
    product_description_short   VARCHAR(200),
    -- Physical dimensions
    net_weight_value            FLOAT,
    net_weight_uom              VARCHAR(10),            -- g / kg / ml / L
    width_mm                    FLOAT,
    height_mm                   FLOAT,
    depth_mm                    FLOAT,
    gross_weight_g              FLOAT,
    -- Packaging
    packaging_type              VARCHAR(100),           -- BAG / BOTTLE / BOX / TUB / CARTON / WRAPPER
    units_per_case              INTEGER,
    -- Classification
    gpc_brick_code              VARCHAR(10),
    gpc_brick_name              VARCHAR(255),
    -- Regulatory
    country_of_origin           VARCHAR(3),
    target_market_country       VARCHAR(3),
    is_consumer_unit            BOOLEAN,
    -- Digital
    gs1_digital_link_url        VARCHAR(500),
    product_image_url           VARCHAR(500),
    -- Lifecycle
    gtin_status                 VARCHAR(20),
    gtin_registration_date      DATE,
    gdsn_publication_date       DATE,
    gdsn_last_sync_date         TIMESTAMP_NTZ,
    data_pool_id                VARCHAR(100),
    attribute_completeness_pct  FLOAT,
    last_modified_date          TIMESTAMP_NTZ,
    CONSTRAINT pk_product_attrs PRIMARY KEY (gtin)
)
COMMENT = 'GDM Global Core product attributes per GTIN — synced via GDSN from NovaBrand';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.NUTRITIONAL_INFO (
    gtin                    VARCHAR(14)   NOT NULL,
    energy_kcal_per100g     FLOAT,
    fat_g_per100g           FLOAT,
    saturates_g_per100g     FLOAT,
    carb_g_per100g          FLOAT,
    sugars_g_per100g        FLOAT,
    fibre_g_per100g         FLOAT,
    protein_g_per100g       FLOAT,
    salt_g_per100g          FLOAT,
    serving_size_g          FLOAT,
    CONSTRAINT pk_nutrition PRIMARY KEY (gtin)
)
COMMENT = 'Nutritional panel data per 100g — per GTIN';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.ALLERGEN_INFO (
    gtin                    VARCHAR(14)   NOT NULL,
    contains_gluten         BOOLEAN,
    contains_dairy          BOOLEAN,
    contains_nuts           BOOLEAN,
    contains_soy            BOOLEAN,
    contains_eggs           BOOLEAN,
    contains_fish           BOOLEAN,
    contains_celery         BOOLEAN,
    allergen_statement      VARCHAR(500),
    CONSTRAINT pk_allergen PRIMARY KEY (gtin)
)
COMMENT = 'Allergen declarations per GTIN';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SUBSCRIPTION (
    subscription_id         VARCHAR(50)   NOT NULL,
    source_company_name     VARCHAR(255),               -- NovaBrand Foods Ltd
    source_gln              VARCHAR(13),
    target_company_name     VARCHAR(255),               -- FreshMart Retail Group
    target_gln              VARCHAR(13),
    data_pool_id            VARCHAR(100),
    subscription_status     VARCHAR(20),                -- ACTIVE / INACTIVE / PENDING
    subscription_start_date DATE,
    gtins_subscribed        INTEGER,
    CONSTRAINT pk_gdsn_sub PRIMARY KEY (subscription_id)
)
COMMENT = 'GDSN subscription — NovaBrand publishes product data, FreshMart subscribes';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG (
    sync_id                 VARCHAR(50)   NOT NULL,
    gtin                    VARCHAR(14),
    source_gln              VARCHAR(13),
    target_gln              VARCHAR(13),
    sync_timestamp          TIMESTAMP_NTZ,
    sync_status             VARCHAR(20),                -- SUCCESS / FAILED / PENDING
    attributes_changed      INTEGER,
    sync_type               VARCHAR(20),                -- FULL / DELTA
    error_message           VARCHAR(500),
    CONSTRAINT pk_sync PRIMARY KEY (sync_id)
)
COMMENT = 'GDSN sync log — tracks product data synchronisation between NovaBrand and FreshMart';

-- ============================================================
-- SUPPLY_CHAIN schema (EPCIS 2.0)
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS (
    event_id                VARCHAR(50)   NOT NULL,
    event_time              TIMESTAMP_NTZ NOT NULL,
    event_timezone_offset   VARCHAR(10),
    epc_list                ARRAY,
    action                  VARCHAR(20),                -- ADD / OBSERVE / DELETE
    biz_step                VARCHAR(100),               -- commissioning / shipping / receiving / stocking
    disposition             VARCHAR(100),               -- active / in_transit / in_progress
    read_point_gln          VARCHAR(13),
    biz_location_gln        VARCHAR(13),
    source_party_gln        VARCHAR(13),
    destination_party_gln   VARCHAR(13),
    gtin                    VARCHAR(14),
    serial_number           VARCHAR(50),
    lot_number              VARCHAR(50),
    expiry_date             DATE,
    CONSTRAINT pk_obj_event PRIMARY KEY (event_id)
)
COMMENT = 'EPCIS 2.0 Object Events — commissioning (NovaBrand), shipping, receiving, stocking (FreshMart)';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_AGGREGATION_EVENTS (
    event_id                VARCHAR(50)   NOT NULL,
    event_time              TIMESTAMP_NTZ NOT NULL,
    parent_id               VARCHAR(50),                -- SSCC of parent (pallet or case)
    child_epcs              ARRAY,
    action                  VARCHAR(20),                -- ADD (packing) / DELETE (unpacking)
    biz_step                VARCHAR(100),               -- packing / unpacking
    disposition             VARCHAR(100),
    read_point_gln          VARCHAR(13),
    biz_location_gln        VARCHAR(13),
    CONSTRAINT pk_agg_event PRIMARY KEY (event_id)
)
COMMENT = 'EPCIS 2.0 Aggregation Events — items packed into cases and cases onto pallets';

CREATE OR REPLACE TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_TRANSACTION_EVENTS (
    event_id                VARCHAR(50)   NOT NULL,
    event_time              TIMESTAMP_NTZ NOT NULL,
    biz_transaction_type    VARCHAR(100),               -- po / desadv / inv
    biz_transaction_id      VARCHAR(100),
    epc_list                ARRAY,
    action                  VARCHAR(20),
    biz_step                VARCHAR(100),               -- shipping / receiving
    biz_location_gln        VARCHAR(13),
    source_party_gln        VARCHAR(13),
    destination_party_gln   VARCHAR(13),
    CONSTRAINT pk_txn_event PRIMARY KEY (event_id)
)
COMMENT = 'EPCIS 2.0 Transaction Events — links supply chain events to business documents (PO, DESADV)';

-- ============================================================
-- VERIFICATION schema
-- ============================================================

CREATE OR REPLACE TABLE GS1_RETAIL_DB.VERIFICATION.VERIFIED_BY_GS1_LOOKUPS (
    lookup_id               VARCHAR(50)   NOT NULL,
    lookup_timestamp        TIMESTAMP_NTZ,
    lookup_type             VARCHAR(20),                -- GTIN / GLN
    identifier_queried      VARCHAR(14),
    lookup_result           VARCHAR(20),                -- VALID / INVALID / NOT_FOUND
    company_name_returned   VARCHAR(255),
    requester_type          VARCHAR(50),                -- RETAILER / CONSUMER / REGULATOR
    requester_country       VARCHAR(3),
    CONSTRAINT pk_lookup PRIMARY KEY (lookup_id)
)
COMMENT = 'Verified by GS1 lookup history — GTIN and GLN verification requests';
