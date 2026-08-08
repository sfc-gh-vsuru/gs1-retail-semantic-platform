# GS1 Retail Observability Platform — Setup Guide## 11b. AI Shopping Agent — Three-Way Grounding Comparison

> Aligns with: GS1 US + Snowflake Pilot Executive Brief (Joel Traugott, June 2026)

### Purpose

Test the hypothesis that GS1 standardized product data produces more accurate, complete, and cost-efficient AI shopping agent answers than retailer-internal or scraped web data.

### Tables Created

| Table | Type | Rows | Purpose |
|-------|------|------|---------|
| `GROUNDING_GS1` | View | 10 | Denormalized GS1 GDM + nutrition + allergens (Path A) |
| `GROUNDING_RETAILER` | Table | 10 | Degraded retailer PIM data: missing 40% of fields (Path B) |
| `GROUNDING_SCRAPED` | Table | 13 | Noisy web scrape: duplicates, wrong values, marketing copy (Path C) |
| `SHOPPING_QUESTIONS` | Table | 25 | Test suite with gold-standard answers across 5 categories |
| `AGENT_RESPONSES` | Table | TBD | Measurement results: accuracy, tokens, latency, cost |
| `PILOT_SUMMARY` | View | — | Aggregated comparison across paths |

### How Path B (Retailer) Differs from Path A (GS1)

- No nutrition data (field doesn't exist)
- No GPC hierarchy (flat single-level category)
- Free-text allergens ("Gluten") instead of structured booleans
- Missing GTIN on 30% of products
- 6-10 months stale
- Retailer-specific SKU instead of global identifier
- Inconsistent vendor naming ("NovaBrand" vs "Nova Brand" vs "NOVABRAND")

### How Path C (Scraped) Differs from Path A (GS1)

- No GTIN on any record (never exposed on web pages)
- 3 duplicate products (same item from different URLs)
- Marketing copy instead of structured product descriptions
- Wrong nutrition values on 2 products (columns swapped)
- 2 products miscategorized (Yoghurt as "Drinks", Tea as "Herbal Medicine")
- Inconsistent weight formatting ("500 g" / "500g" / "0.5kg" / "1 Litre" / "1000ml")
- Missing allergen data on 4 products
- Noise fields: star_rating, review_count, availability, promo_text

### Running the Comparison

```sql
-- Deploy grounding paths
-- Run: sql/08_grounding_paths.sql

-- Deploy test suite
-- Run: sql/09_shopping_questions.sql

-- Deploy measurement harness
-- Run: sql/10_agent_harness.sql

-- After running agent tests, view results:
SELECT * FROM GS1_DB.DEMO.PILOT_SUMMARY;
```

### Expected Outcome

| Path | Accuracy | Tokens | Latency | Why |
|------|----------|--------|---------|-----|
| GS1 | ~95% | Low (~450) | Fast (~1.2s) | Structured booleans, complete nutrition, standard taxonomy |
| Retailer | ~62% | Medium (~680) | Medium (~1.8s) | Missing fields force agent to guess or say "unknown" |
| Scraped | ~48% | High (~920) | Slow (~2.4s) | Noise, duplicates, wrong values require disambiguation |

---


> **Living document.** Updated at every implementation stage. Follow steps in order.
> Last updated: Stage 0 — Project Initialisation

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure & Repository Setup](#2-project-structure--repository-setup)
3. [Dummy Data Design — GS1, NovaBrand Foods, FreshMart Retail](#3-dummy-data-design)
4. [Snowflake Environment Setup](#4-snowflake-environment-setup)
5. [Database & Table Creation](#5-database--table-creation)
6. [Load Dummy Data](#6-load-dummy-data)
7. [Semantic Views](#7-semantic-views)
8. [Data Metric Functions (DMF Observability)](#8-data-metric-functions)
9. [Cortex Analyst — Natural Language Interface](#9-cortex-analyst)
10. [Access Control & Security Tags](#10-access-control--security-tags)
11. [Observability Dashboard (Streamlit)](#11-observability-dashboard)
12. [Stage 2 — OSI Bridge & Sanitisation Pipeline](#12-stage-2--osi-bridge)
13. [Git Repository & Publishing](#13-git-repository--publishing)

---

## 1. Prerequisites

### Snowflake Account Requirements
- Snowflake account on **Enterprise Edition** or higher
  - Required for: Data Metric Functions, Row Access Policies, Dynamic Data Masking, ACCESS_HISTORY
- Role with `SYSADMIN` or `ACCOUNTADMIN` privileges for initial setup
- Warehouse: `SNOWADHOC` (or create a dedicated warehouse)
- Cortex Analyst enabled on the account

### Local Tools
- [Snowflake CLI (`snow`)](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) — for deploying files to stages
- Python 3.10+ — for data generation scripts and OSI YAML tooling
- Git — for version control

### Install Snowflake CLI
```bash
pip install snowflake-cli-labs
snow --version
```

### Configure Snowflake Connection
Create `~/.snowflake/config.toml` (NOT committed to git):
```toml
[connections.gs1_dev]
account   = "YOUR_ACCOUNT_IDENTIFIER"
user      = "YOUR_USERNAME"
warehouse = "SNOWADHOC"
database  = "GS1_RETAIL_DB"
schema    = "PUBLIC"
authenticator = "externalbrowser"   # SSO — no password in file
```

Test connection:
```bash
snow connection test --connection gs1_dev
```

---

## 2. Project Structure & Repository Setup

### Directory Layout
```
GS1/
├── README.md
├── setup.md                      ← This file
├── .gitignore
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_dummy_data.sql
│   ├── 04_semantic_views.sql
│   ├── 05_dmf_observability.sql
│   ├── 06_access_control.sql
│   └── 07_cortex_analyst.sql
├── semantic/
│   └── gs1_retail_model.yaml
├── data/
│   └── dummy/
│       ├── gpc_taxonomy.sql
│       ├── gtin_registry.sql
│       ├── gln_registry.sql
│       ├── product_attributes.sql
│       ├── epcis_events.sql
│       └── member_registry.sql
├── docs/
│   ├── gs1_data_model.md
│   ├── osi_mapping.md
│   └── semantic_design.md
└── stage2_osi/
    ├── datasets/
    ├── metrics/
    ├── dimensions/
    ├── relationships/
    └── benchmarks/
```

### Initialise Git Repo
```bash
cd <project_root>
git init
git add .gitignore README.md setup.md
git commit -m "feat: initialise GS1 Retail Observability Platform project"
```

---

## 3. Dummy Data Design

### 3.1 Participants

#### GS1 Global (Standards Body)
- Operates the GDSN hub
- Issues GS1 Company Prefixes (GCPs) to members
- Maintains GPC taxonomy and CBV vocabulary
- Runs Verified by GS1 verification service

#### NovaBrand Foods Ltd (Brand Owner / Supplier)
```
Company Name    : NovaBrand Foods Ltd
GS1 Prefix      : 5901234        (fictional 7-digit GCP)
GLN (HQ)        : 5901234000002
GLN (Factory)   : 5901234000019
Country         : United Kingdom
GS1 Member Org  : GS1 UK
Industry        : Food & Beverage (FMCG)
Product Range   : Cereals, Dairy, Snacks, Beverages
GDSN Role       : Data Source (Publisher)
EPCIS Role      : Event Sender (shipping events)
```

**NovaBrand Products (10 GTINs across 4 categories):**

| GTIN | Product Name | Category | GPC Brick |
|------|-------------|----------|-----------|
| 05901234100017 | NovaBrand Oat Flakes 500g | Cereals | 10000265 |
| 05901234100024 | NovaBrand Muesli Mixed Fruit 750g | Cereals | 10000265 |
| 05901234200016 | NovaBrand Full Fat Milk 1L | Dairy | 10005773 |
| 05901234200023 | NovaBrand Greek Yoghurt 500g | Dairy | 10005779 |
| 05901234200030 | NovaBrand Cheddar Cheese 400g | Dairy | 10005774 |
| 05901234300015 | NovaBrand Sea Salt Crisps 150g | Snacks | 10000338 |
| 05901234300022 | NovaBrand Dark Chocolate Bar 100g | Snacks | 10000359 |
| 05901234400014 | NovaBrand Orange Juice 1L | Beverages | 10005840 |
| 05901234400021 | NovaBrand Sparkling Water 500ml | Beverages | 10005842 |
| 05901234400038 | NovaBrand Green Tea 20 Bags | Beverages | 10005847 |

#### FreshMart Retail Group (Retailer)
```
Company Name    : FreshMart Retail Group
GS1 Prefix      : 5412345        (fictional 7-digit GCP)
GLN (HQ)        : 5412345000001
GLN (DC South)  : 5412345000018
GLN (Store 001) : 5412345100010   ← London Flagship
GLN (Store 002) : 5412345100027   ← Manchester
GLN (Store 003) : 5412345100034   ← Birmingham
GLN (Store 004) : 5412345100041   ← Edinburgh
GLN (Store 005) : 5412345100058   ← Bristol
Country         : United Kingdom
GS1 Member Org  : GS1 UK
Store Format    : Supermarket (2,000–5,000 sqm)
GDSN Role       : Data Recipient (Subscriber)
EPCIS Role      : Event Sender (receiving, inventory events)
```

### 3.2 Data Relationships

```
GS1 GLOBAL
├── Issues GCP prefix to NovaBrand Foods Ltd  (prefix: 5901234)
├── Issues GCP prefix to FreshMart Retail Group (prefix: 5412345)
├── Maintains GPC Taxonomy
└── Operates GDSN Hub
         │
         ├─── NovaBrand Foods Ltd
         │    ├── Registers 10 GTINs in GTIN Registry
         │    ├── Publishes product master data to GDSN (for all 10 GTINs)
         │    ├── Factory (GLN 5901234000019) generates EPCIS OBJECT_EVENTs
         │    │   └── business_step: commissioning (product manufactured)
         │    └── Shipping Dock generates EPCIS AGGREGATION_EVENTs + TRANSACTION_EVENTs
         │        └── business_step: shipping → FreshMart DC
         │
         └─── FreshMart Retail Group
              ├── Subscribes to NovaBrand GDSN data (receives all 10 GTINs)
              ├── DC (GLN 5412345000018) generates EPCIS OBJECT_EVENTs
              │   └── business_step: receiving
              └── Stores (GLN 5412345100010-058) generate EPCIS OBJECT_EVENTs
                  └── business_step: stocking
```

### 3.3 EPCIS Event Flow (NovaBrand → FreshMart)

```
Step 1: commissioning   NovaBrand Factory → items produced, GTIN serialised
Step 2: packing         Items → cases → pallets (AGGREGATION_EVENT)
Step 3: shipping        NovaBrand Shipping Dock → dispatched to FreshMart DC
Step 4: receiving       FreshMart DC → goods received, SSCC scanned
Step 5: unpacking       Pallet → cases at DC
Step 6: stocking        Cases → store shelves at FreshMart stores
```

### 3.4 Product Attributes (GDM Global Core — per GTIN)

Each GTIN in PRODUCT_ATTRIBUTES will carry:

| Attribute Group | Fields |
|----------------|--------|
| **Identification** | gtin, gcp_prefix, brand_name, product_description |
| **Dimensions** | net_weight_value, net_weight_uom, width_mm, height_mm, depth_mm, gross_weight_g |
| **Packaging** | packaging_type, quantity_of_children, units_per_case |
| **Classification** | gpc_brick_code, gpc_brick_name |
| **Regulatory** | country_of_origin, target_market_country, is_trade_item_a_consumer_unit |
| **Allergens** | contains_gluten, contains_dairy, contains_nuts, contains_soy |
| **Nutritional** | energy_kcal_per100g, fat_g_per100g, carb_g_per100g, protein_g_per100g |
| **Digital** | gs1_digital_link_url, product_image_url |
| **Lifecycle** | gtin_status (ACTIVE/INACTIVE), gtin_registration_date, last_modified_date |
| **GDSN** | gdsn_publication_date, gdsn_last_sync_date, data_pool_id |

### 3.5 Data Volume (Dummy Dataset)

| Table | Rows | Notes |
|-------|------|-------|
| GPC_TAXONOMY | ~50 | 5 Segments, 10 Families, 20 Classes, 15 Bricks (food/bev focus) |
| GS1_MEMBER_REGISTRY | 5 | GS1 Global + GS1 UK + 3 regional orgs |
| COMPANY_REGISTRY | 2 | NovaBrand + FreshMart |
| GCP_REGISTRY | 2 | One per company |
| GTIN_REGISTRY | 10 | NovaBrand's 10 products |
| GLN_REGISTRY | 9 | 2 NovaBrand + 7 FreshMart |
| PRODUCT_ATTRIBUTES | 10 | Full GDM attributes per GTIN |
| NUTRITIONAL_INFO | 10 | One record per GTIN |
| ALLERGEN_INFO | 10 | One record per GTIN |
| GDSN_SUBSCRIPTION | 1 | NovaBrand → FreshMart |
| GDSN_SYNC_LOG | 30 | Daily sync records (last 30 days) |
| EPCIS_OBJECT_EVENTS | ~60 | commissioning + receiving + stocking |
| EPCIS_AGGREGATION_EVENTS | ~20 | packing + unpacking |
| EPCIS_TRANSACTION_EVENTS | ~10 | shipment transactions |
| VERIFICATION_LOOKUPS | ~50 | Verified by GS1 lookup history |

---

## 4. Snowflake Environment Setup

Run `sql/01_database_setup.sql`:

```sql
-- ============================================================
-- GS1 Retail Platform — Environment Setup
-- Role: ACCOUNTADMIN or SYSADMIN
-- ============================================================

USE ROLE SYSADMIN;

-- Warehouse (dedicated for GS1 project)
CREATE WAREHOUSE IF NOT EXISTS GS1_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'GS1 Retail Observability Platform warehouse';

-- Main database
CREATE DATABASE IF NOT EXISTS GS1_RETAIL_DB
  COMMENT = 'GS1 Retail Observability Platform — all GS1, NovaBrand and FreshMart data';

-- Schemas by domain
CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.IDENTITY
  COMMENT = 'GS1 identifier registries: GTIN, GLN, SSCC, GCP';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.PRODUCT_MASTER
  COMMENT = 'GDSN product master data — GDM attributes, nutritional, allergen, images';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.SUPPLY_CHAIN
  COMMENT = 'EPCIS supply chain events — object, aggregation, transaction, sensor';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.CLASSIFICATION
  COMMENT = 'GS1 GPC taxonomy — Segment, Family, Class, Brick';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.MEMBERS
  COMMENT = 'GS1 member organisations and company registry';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.VERIFICATION
  COMMENT = 'Verified by GS1 lookup history and audit';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.OBSERVABILITY
  COMMENT = 'Data quality scores, DMF results, pipeline health';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.SEMANTIC
  COMMENT = 'Snowflake Semantic Views for Cortex Analyst';

-- Roles
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS GS1_PLATFORM_ADMIN
  COMMENT = 'Full access — GS1 platform engineers';
CREATE ROLE IF NOT EXISTS GS1_DATA_ENGINEER
  COMMENT = 'Pipeline + quality views access';
CREATE ROLE IF NOT EXISTS GS1_ANALYST
  COMMENT = 'Read-only semantic view + Cortex Analyst access';
CREATE ROLE IF NOT EXISTS GS1_AUDITOR
  COMMENT = 'ACCESS_HISTORY and TRUST_CENTER only';

-- Grant hierarchy
GRANT ROLE GS1_ANALYST       TO ROLE GS1_DATA_ENGINEER;
GRANT ROLE GS1_DATA_ENGINEER TO ROLE GS1_PLATFORM_ADMIN;
GRANT ROLE GS1_PLATFORM_ADMIN TO ROLE SYSADMIN;

-- Warehouse grants
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_DATA_ENGINEER;
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_ANALYST;

-- Database grants
GRANT ALL PRIVILEGES ON DATABASE GS1_RETAIL_DB TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE GS1_RETAIL_DB TO ROLE GS1_DATA_ENGINEER;
GRANT USAGE ON DATABASE GS1_RETAIL_DB TO ROLE GS1_ANALYST;
```

---

## 5. Database & Table Creation

Run `sql/02_create_tables.sql`. Key tables:

### 5.1 IDENTITY Schema

```sql
-- GTIN Registry
CREATE OR REPLACE TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY (
    gtin                    VARCHAR(14)   NOT NULL,   -- 14-digit GTIN
    gcp_prefix              VARCHAR(12)   NOT NULL,   -- GS1 Company Prefix
    company_name            VARCHAR(255),
    product_description     VARCHAR(500),
    brand_name              VARCHAR(255),
    gtin_status             VARCHAR(20),              -- ACTIVE / INACTIVE / RETIRED
    gtin_type               VARCHAR(30),              -- CONSUMER_UNIT / CASE / PALLET
    registration_date       DATE,
    last_modified_date      TIMESTAMP_NTZ,
    gs1_member_org          VARCHAR(100),
    check_digit_valid       BOOLEAN,
    CONSTRAINT pk_gtin PRIMARY KEY (gtin)
)
COMMENT = 'GS1 GTIN Registry — all registered product identifiers';

-- GLN Registry
CREATE OR REPLACE TABLE GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY (
    gln                     VARCHAR(13)   NOT NULL,   -- 13-digit GLN
    gcp_prefix              VARCHAR(12)   NOT NULL,
    party_name              VARCHAR(255),
    location_type           VARCHAR(50),              -- HQ / FACTORY / WAREHOUSE / STORE / DC
    street_address          VARCHAR(500),
    city                    VARCHAR(100),
    postal_code             VARCHAR(20),
    country_code            VARCHAR(3),               -- ISO 3166-1 alpha-2
    latitude                FLOAT,
    longitude               FLOAT,
    gln_status              VARCHAR(20),              -- ACTIVE / INACTIVE
    registration_date       DATE,
    CONSTRAINT pk_gln PRIMARY KEY (gln)
)
COMMENT = 'GS1 GLN Registry — party and location identifiers';
```

### 5.2 PRODUCT_MASTER Schema

```sql
-- Product Attributes (GDM Global Core)
CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES (
    gtin                        VARCHAR(14)   NOT NULL,
    gcp_prefix                  VARCHAR(12),
    brand_name                  VARCHAR(255),
    product_description         VARCHAR(500),
    product_description_short   VARCHAR(200),
    -- Dimensions
    net_weight_value            FLOAT,
    net_weight_uom              VARCHAR(10),           -- g / kg / ml / L
    width_mm                    FLOAT,
    height_mm                   FLOAT,
    depth_mm                    FLOAT,
    gross_weight_g              FLOAT,
    -- Packaging
    packaging_type              VARCHAR(100),          -- BAG / BOTTLE / BOX / TUB
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
    data_pool_id                VARCHAR(100),          -- which GDSN data pool
    attribute_completeness_pct  FLOAT,                 -- % of required fields populated
    last_modified_date          TIMESTAMP_NTZ,
    CONSTRAINT pk_product_attrs PRIMARY KEY (gtin)
)
COMMENT = 'GDM Global Core product attributes per GTIN — synced via GDSN';

-- Nutritional Info
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
COMMENT = 'Nutritional panel per 100g per GTIN';

-- Allergen Info
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
```

### 5.3 SUPPLY_CHAIN Schema (EPCIS)

```sql
-- EPCIS Object Events
CREATE OR REPLACE TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS (
    event_id                VARCHAR(50)   NOT NULL,
    event_time              TIMESTAMP_NTZ NOT NULL,
    event_timezone_offset   VARCHAR(10),
    epc_list                ARRAY,                    -- list of EPCs (GTIN+serial)
    action                  VARCHAR(20),              -- ADD / OBSERVE / DELETE
    biz_step                VARCHAR(100),             -- commissioning / shipping / receiving / stocking
    disposition             VARCHAR(100),             -- active / in_transit / in_progress
    read_point_gln          VARCHAR(13),              -- where the scan happened
    biz_location_gln        VARCHAR(13),              -- business location context
    source_party_gln        VARCHAR(13),
    destination_party_gln   VARCHAR(13),
    gtin                    VARCHAR(14),
    serial_number           VARCHAR(50),
    lot_number              VARCHAR(50),
    expiry_date             DATE,
    CONSTRAINT pk_obj_event PRIMARY KEY (event_id)
)
COMMENT = 'EPCIS 2.0 Object Events — commissioning, shipping, receiving, stocking';

-- EPCIS Aggregation Events
CREATE OR REPLACE TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_AGGREGATION_EVENTS (
    event_id                VARCHAR(50)   NOT NULL,
    event_time              TIMESTAMP_NTZ NOT NULL,
    parent_id               VARCHAR(50),              -- SSCC of pallet/case
    child_epcs              ARRAY,                    -- child EPCs contained
    action                  VARCHAR(20),              -- ADD (packing) / DELETE (unpacking)
    biz_step                VARCHAR(100),             -- packing / unpacking
    disposition             VARCHAR(100),
    read_point_gln          VARCHAR(13),
    biz_location_gln        VARCHAR(13),
    CONSTRAINT pk_agg_event PRIMARY KEY (event_id)
)
COMMENT = 'EPCIS 2.0 Aggregation Events — packing items into cases/pallets';

-- GDSN Sync Log
CREATE OR REPLACE TABLE GS1_RETAIL_DB.PRODUCT_MASTER.GDSN_SYNC_LOG (
    sync_id                 VARCHAR(50)   NOT NULL,
    gtin                    VARCHAR(14),
    source_gln              VARCHAR(13),              -- NovaBrand data pool GLN
    target_gln              VARCHAR(13),              -- FreshMart data pool GLN
    sync_timestamp          TIMESTAMP_NTZ,
    sync_status             VARCHAR(20),              -- SUCCESS / FAILED / PENDING
    attributes_changed      INTEGER,
    sync_type               VARCHAR(20),              -- FULL / DELTA
    CONSTRAINT pk_sync PRIMARY KEY (sync_id)
)
COMMENT = 'GDSN synchronisation log — tracks product data sync between NovaBrand and FreshMart';
```

### 5.4 CLASSIFICATION Schema

```sql
-- GPC Taxonomy
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
COMMENT = 'GS1 GPC taxonomy — Segment / Family / Class / Brick hierarchy';
```

---

## 6. Load Dummy Data

Run `sql/03_load_dummy_data.sql` (or individual files in `data/dummy/`).

### 6.1 GPC Taxonomy (selected food/beverage bricks)

```sql
INSERT INTO GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY VALUES
-- Segment: Food/Beverage/Tobacco
('10000265','Breakfast Cereals/Grains - Prepared/Mixes (Shelf Stable)','10001545','Breakfast Cereals','10006319','Grain Based Products','50000000','Food/Beverage/Tobacco'),
('10005773','Milk Preparations - Liquid (Shelf Stable)','10001546','Dairy Products','10006319','Grain Based Products','50000000','Food/Beverage/Tobacco'),
('10005779','Yoghurt/Soured Products','10001547','Dairy Products','10006319','Grain Based Products','50000000','Food/Beverage/Tobacco'),
('10005774','Cheese','10001547','Dairy Products','10006319','Grain Based Products','50000000','Food/Beverage/Tobacco'),
('10000338','Snacks - Savoury','10001548','Snacks/Confectionery','10006320','Snack Foods','50000000','Food/Beverage/Tobacco'),
('10000359','Chocolate/Chocolate Substitutes','10001549','Confectionery','10006320','Snack Foods','50000000','Food/Beverage/Tobacco'),
('10005840','Juices - Fruit/Vegetable (Shelf Stable)','10001550','Beverages','10006321','Beverages','50000000','Food/Beverage/Tobacco'),
('10005842','Water - Sparkling (Shelf Stable)','10001550','Beverages','10006321','Beverages','50000000','Food/Beverage/Tobacco'),
('10005847','Tea - Shelf Stable','10001551','Hot Beverages','10006321','Beverages','50000000','Food/Beverage/Tobacco');
```

### 6.2 GTIN Registry — NovaBrand Products

```sql
INSERT INTO GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY VALUES
('05901234100017','5901234','NovaBrand Foods Ltd','NovaBrand Oat Flakes 500g','NovaBrand','ACTIVE','CONSUMER_UNIT','2022-03-15','2024-11-01 09:00:00','GS1 UK',TRUE),
('05901234100024','5901234','NovaBrand Foods Ltd','NovaBrand Muesli Mixed Fruit 750g','NovaBrand','ACTIVE','CONSUMER_UNIT','2022-03-15','2024-11-01 09:00:00','GS1 UK',TRUE),
('05901234200016','5901234','NovaBrand Foods Ltd','NovaBrand Full Fat Milk 1L','NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-01-10 12:00:00','GS1 UK',TRUE),
('05901234200023','5901234','NovaBrand Foods Ltd','NovaBrand Greek Yoghurt 500g','NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-01-10 12:00:00','GS1 UK',TRUE),
('05901234200030','5901234','NovaBrand Foods Ltd','NovaBrand Cheddar Cheese 400g','NovaBrand','ACTIVE','CONSUMER_UNIT','2021-06-01','2025-02-20 14:00:00','GS1 UK',TRUE),
('05901234300015','5901234','NovaBrand Foods Ltd','NovaBrand Sea Salt Crisps 150g','NovaBrand','ACTIVE','CONSUMER_UNIT','2023-01-10','2024-12-05 11:30:00','GS1 UK',TRUE),
('05901234300022','5901234','NovaBrand Foods Ltd','NovaBrand Dark Chocolate Bar 100g','NovaBrand','ACTIVE','CONSUMER_UNIT','2023-01-10','2024-12-05 11:30:00','GS1 UK',TRUE),
('05901234400014','5901234','NovaBrand Foods Ltd','NovaBrand Orange Juice 1L','NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2025-03-01 08:00:00','GS1 UK',TRUE),
('05901234400021','5901234','NovaBrand Foods Ltd','NovaBrand Sparkling Water 500ml','NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2025-03-01 08:00:00','GS1 UK',TRUE),
('05901234400038','5901234','NovaBrand Foods Ltd','NovaBrand Green Tea 20 Bags','NovaBrand','ACTIVE','CONSUMER_UNIT','2020-09-05','2024-10-15 16:00:00','GS1 UK',TRUE);
```

### 6.3 GLN Registry — NovaBrand & FreshMart Locations

```sql
INSERT INTO GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY VALUES
-- NovaBrand
('5901234000002','5901234','NovaBrand Foods Ltd','HQ',          'Innovation House, 12 Commerce Park','Reading',   'RG1 4AB','GB', 51.4543,-0.9781,'ACTIVE','2020-01-01'),
('5901234000019','5901234','NovaBrand Foods Ltd','FACTORY',     'Unit 4, Eastfield Industrial Estate','Swindon',  'SN2 2DL','GB', 51.5696,-1.7822,'ACTIVE','2020-01-01'),
-- FreshMart
('5412345000001','5412345','FreshMart Retail Group','HQ',       'One Retail Tower, City Road',         'London',   'EC1V 2PX','GB', 51.5268,-0.0920,'ACTIVE','2019-06-01'),
('5412345000018','5412345','FreshMart Retail Group','DC',       'Northgate Distribution Park, Unit 1', 'Coventry', 'CV6 5RS','GB', 52.4450,-1.5230,'ACTIVE','2019-06-01'),
('5412345100010','5412345','FreshMart Store 001 - London Flagship','STORE','88 Oxford Street',         'London',   'W1D 1LP','GB', 51.5154,-0.1336,'ACTIVE','2019-09-01'),
('5412345100027','5412345','FreshMart Store 002 - Manchester',   'STORE','34 Market Street',            'Manchester','M1 1PW','GB', 53.4808,-2.2426,'ACTIVE','2019-09-01'),
('5412345100034','5412345','FreshMart Store 003 - Birmingham',   'STORE','55 New Street',               'Birmingham','B2 4DU','GB', 52.4796,-1.8977,'ACTIVE','2020-02-01'),
('5412345100041','5412345','FreshMart Store 004 - Edinburgh',    'STORE','101 Princes Street',          'Edinburgh', 'EH2 3AB','GB', 55.9505,-3.1880,'ACTIVE','2020-02-01'),
('5412345100058','5412345','FreshMart Store 005 - Bristol',      'STORE','22 Cabot Circus',             'Bristol',   'BS1 3BX','GB', 51.4565,-2.5839,'ACTIVE','2021-04-01');
```

### 6.4 Product Attributes (GDM Global Core)

```sql
INSERT INTO GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES VALUES
-- gtin, gcp_prefix, brand_name, product_description, short_desc,
-- net_weight_value, net_weight_uom, width_mm, height_mm, depth_mm, gross_weight_g,
-- packaging_type, units_per_case, gpc_brick_code, gpc_brick_name,
-- country_of_origin, target_market_country, is_consumer_unit,
-- gs1_digital_link_url, product_image_url,
-- gtin_status, gtin_reg_date, gdsn_pub_date, gdsn_last_sync, data_pool_id, completeness_pct, last_modified
('05901234100017','5901234','NovaBrand','NovaBrand Oat Flakes 500g','Oat Flakes 500g',
 500,'g',190,280,80,560,'BOX',12,'10000265','Breakfast Cereals/Grains',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234100017','https://assets.novabrand.example.com/img/05901234100017.jpg',
 'ACTIVE','2022-03-15','2022-04-01','2025-07-20 06:00:00','AECOC DataPool',98.5,'2025-07-20 06:00:00'),

('05901234100024','5901234','NovaBrand','NovaBrand Muesli Mixed Fruit 750g','Muesli 750g',
 750,'g',210,310,90,850,'BAG',8,'10000265','Breakfast Cereals/Grains',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234100024','https://assets.novabrand.example.com/img/05901234100024.jpg',
 'ACTIVE','2022-03-15','2022-04-01','2025-07-20 06:00:00','AECOC DataPool',95.0,'2025-07-20 06:00:00'),

('05901234200016','5901234','NovaBrand','NovaBrand Full Fat Milk 1L','Full Fat Milk 1L',
 1000,'ml',70,240,70,1080,'BOTTLE',6,'10005773','Milk Preparations',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234200016','https://assets.novabrand.example.com/img/05901234200016.jpg',
 'ACTIVE','2021-06-01','2021-07-01','2025-07-19 06:00:00','AECOC DataPool',100.0,'2025-07-19 06:00:00'),

('05901234200023','5901234','NovaBrand','NovaBrand Greek Yoghurt 500g','Greek Yoghurt 500g',
 500,'g',115,180,115,560,'TUB',8,'10005779','Yoghurt/Soured Products',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234200023','https://assets.novabrand.example.com/img/05901234200023.jpg',
 'ACTIVE','2021-06-01','2021-07-01','2025-07-19 06:00:00','AECOC DataPool',100.0,'2025-07-19 06:00:00'),

('05901234200030','5901234','NovaBrand','NovaBrand Cheddar Cheese 400g','Cheddar 400g',
 400,'g',120,220,35,440,'WRAPPER',12,'10005774','Cheese',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234200030','https://assets.novabrand.example.com/img/05901234200030.jpg',
 'ACTIVE','2021-06-01','2021-07-01','2025-07-18 06:00:00','AECOC DataPool',97.0,'2025-07-18 06:00:00'),

('05901234300015','5901234','NovaBrand','NovaBrand Sea Salt Crisps 150g','Sea Salt Crisps 150g',
 150,'g',200,280,40,175,'BAG',24,'10000338','Snacks - Savoury',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234300015','https://assets.novabrand.example.com/img/05901234300015.jpg',
 'ACTIVE','2023-01-10','2023-02-01','2025-07-15 06:00:00','AECOC DataPool',92.5,'2025-07-15 06:00:00'),

('05901234300022','5901234','NovaBrand','NovaBrand Dark Chocolate Bar 100g','Dark Choc 100g',
 100,'g',65,180,10,115,'WRAPPER',24,'10000359','Chocolate',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234300022','https://assets.novabrand.example.com/img/05901234300022.jpg',
 'ACTIVE','2023-01-10','2023-02-01','2025-07-15 06:00:00','AECOC DataPool',90.0,'2025-07-15 06:00:00'),

('05901234400014','5901234','NovaBrand','NovaBrand Orange Juice 1L','Orange Juice 1L',
 1000,'ml',73,256,73,1100,'CARTON',12,'10005840','Juices - Fruit/Vegetable',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234400014','https://assets.novabrand.example.com/img/05901234400014.jpg',
 'ACTIVE','2020-09-05','2020-10-01','2025-07-01 06:00:00','AECOC DataPool',100.0,'2025-07-01 06:00:00'),

('05901234400021','5901234','NovaBrand','NovaBrand Sparkling Water 500ml','Sparkling Water 500ml',
 500,'ml',65,220,65,560,'BOTTLE',24,'10005842','Water - Sparkling',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234400021','https://assets.novabrand.example.com/img/05901234400021.jpg',
 'ACTIVE','2020-09-05','2020-10-01','2025-07-01 06:00:00','AECOC DataPool',100.0,'2025-07-01 06:00:00'),

('05901234400038','5901234','NovaBrand','NovaBrand Green Tea 20 Bags','Green Tea 20 Bags',
 40,'g',120,180,60,55,'BOX',24,'10005847','Tea - Shelf Stable',
 'GB','GB',TRUE,
 'https://id.gs1.org/01/05901234400038','https://assets.novabrand.example.com/img/05901234400038.jpg',
 'ACTIVE','2020-09-05','2020-10-01','2025-06-15 06:00:00','AECOC DataPool',88.0,'2025-06-15 06:00:00');
```

### 6.5 EPCIS Events (representative sample)

Sample commissioning event at NovaBrand factory and receiving event at FreshMart DC — full set in `data/dummy/epcis_events.sql`.

```sql
-- Commissioning: NovaBrand Factory produces Oat Flakes
INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS VALUES
('EVT-NB-001','2025-07-20 07:30:00','+01:00',
 ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),
 'ADD','commissioning','active',
 '5901234000019','5901234000019',
 NULL,NULL,
 '05901234100017','00001','LOT-NB-2507-01','2026-07-20');

-- Shipping: NovaBrand dispatches to FreshMart DC
INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS VALUES
('EVT-NB-011','2025-07-21 14:00:00','+01:00',
 ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),
 'OBSERVE','shipping','in_transit',
 '5901234000019','5901234000019',
 '5901234000002','5412345000018',
 '05901234100017','00001','LOT-NB-2507-01','2026-07-20');

-- Receiving: FreshMart DC accepts delivery
INSERT INTO GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS VALUES
('EVT-FM-001','2025-07-22 09:15:00','+01:00',
 ARRAY_CONSTRUCT('urn:epc:id:sgtin:5901234.010001.00001'),
 'OBSERVE','receiving','in_progress',
 '5412345000018','5412345000018',
 '5901234000002','5412345000018',
 '05901234100017','00001','LOT-NB-2507-01','2026-07-20');
```

---

## 7. Semantic Views

Run `sql/04_semantic_views.sql`.

Snowflake Semantic Views are the core of the GS1 observability platform and the primary OSI-aligned asset.

```sql
CREATE OR REPLACE SEMANTIC VIEW GS1_RETAIL_DB.SEMANTIC.GS1_RETAIL_SV
TABLES (
  product_attrs AS GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
    PRIMARY KEY (gtin)
    WITH SYNONYMS = ('product', 'trade item', 'GTIN record'),
  gln AS GS1_RETAIL_DB.IDENTITY.GLN_REGISTRY
    PRIMARY KEY (gln)
    WITH SYNONYMS = ('location', 'party', 'store', 'warehouse'),
  gpc AS GS1_RETAIL_DB.CLASSIFICATION.GPC_TAXONOMY
    PRIMARY KEY (brick_code),
  epcis AS GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
    PRIMARY KEY (event_id)
    WITH SYNONYMS = ('supply chain event', 'traceability event')
)
RELATIONSHIPS (
  product_attrs (gpc_brick_code) REFERENCES gpc (brick_code),
  product_attrs (gcp_prefix) REFERENCES gln (gcp_prefix),
  epcis (biz_location_gln) REFERENCES gln (gln)
)
FACTS (
  product_attrs (attribute_completeness_pct) AS "Product Data Completeness (%)"
    WITH SYNONYMS = ('completeness', 'data quality score')
)
DIMENSIONS (
  product_attrs (brand_name)         AS "Brand",
  product_attrs (gtin_status)        AS "Product Status",
  product_attrs (packaging_type)     AS "Packaging Type",
  product_attrs (country_of_origin)  AS "Country of Origin",
  gpc (brick_name)                   AS "Product Category (Brick)",
  gpc (family_name)                  AS "Product Family",
  gpc (segment_name)                 AS "Product Segment",
  gln (party_name)                   AS "Party Name",
  gln (location_type)                AS "Location Type",
  gln (country_code)                 AS "Country",
  gln (city)                         AS "City",
  epcis (biz_step)                   AS "Business Step",
  epcis (disposition)                AS "Disposition",
  epcis (event_time::DATE)           AS "Event Date"
)
METRICS (
  COUNT(product_attrs.gtin)
    AS "Total Registered GTINs"
    WITH SYNONYMS = ('gtin count', 'product count'),
  COUNT_IF(product_attrs.gtin_status = 'ACTIVE')
    AS "Active GTINs",
  AVG(product_attrs.attribute_completeness_pct)
    AS "Average Data Completeness (%)",
  COUNT(epcis.event_id)
    AS "Total Supply Chain Events",
  COUNT(DISTINCT epcis.gtin)
    AS "GTINs with Traceability Events"
);
```

---

## 8. Data Metric Functions

Run `sql/05_dmf_observability.sql`.

Attach system DMFs to key tables to enable continuous data quality monitoring:

```sql
-- Freshness: how recently was product data synced via GDSN?
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FRESHNESS
  ON (gdsn_last_sync_date)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Null completeness on critical product fields
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_PERCENT
  ON (brand_name)
  SCHEDULE = '60 MINUTE';

ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_PERCENT
  ON (net_weight_value)
  SCHEDULE = '60 MINUTE';

-- Duplicate GTINs in registry (should be zero)
ALTER TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';

-- Row count tracking on EPCIS events
ALTER TABLE GS1_RETAIL_DB.SUPPLY_CHAIN.EPCIS_OBJECT_EVENTS
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.ROW_COUNT
  ON (event_id)
  SCHEDULE = '60 MINUTE';

-- Schema change detection on product master
ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.SCHEMA_CHANGE_COUNT
  ON (gtin)
  SCHEDULE = 'TRIGGER_ON_CHANGES';
```

---

## 9. Cortex Analyst

Run `sql/07_cortex_analyst.sql` to create the stage and upload `semantic/gs1_retail_model.yaml`.

```sql
-- Create internal stage for semantic model
CREATE STAGE IF NOT EXISTS GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'Hosts Cortex Analyst semantic model YAML for GS1 retail';
```

Upload model via Snowflake CLI:
```bash
snow stage copy semantic/gs1_retail_model.yaml @GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE \
  --connection gs1_dev
```

Sample Cortex Analyst questions the model should answer:
- "How many active GTINs does NovaBrand have?"
- "What is the average product data completeness score by product category?"
- "Which GTINs have not been synced via GDSN in the last 30 days?"
- "How many EPCIS receiving events did FreshMart generate last week?"
- "Show traceability coverage for dairy products"
- "Which products have a completeness score below 95%?"

---

## 10. Access Control & Security Tags

Run `sql/06_access_control.sql`.

```sql
-- Object Tags
CREATE TAG IF NOT EXISTS GS1_RETAIL_DB.GOVERNANCE.GS1_PROPRIETARY
  ALLOWED_VALUES = 'TRUE', 'FALSE'
  COMMENT = 'Marks objects containing GS1 proprietary IP — must not leave Snowflake perimeter';

CREATE TAG IF NOT EXISTS GS1_RETAIL_DB.GOVERNANCE.OSI_ELIGIBLE
  ALLOWED_VALUES = 'TRUE', 'FALSE'
  COMMENT = 'Marks objects approved for sanitised OSI export';

CREATE TAG IF NOT EXISTS GS1_RETAIL_DB.GOVERNANCE.MEMBER_CONFIDENTIAL
  ALLOWED_VALUES = 'TRUE', 'FALSE'
  COMMENT = 'Marks objects containing GS1 member-specific confidential data';

-- Apply tags
ALTER TABLE GS1_RETAIL_DB.IDENTITY.GTIN_REGISTRY
  SET TAG GS1_RETAIL_DB.GOVERNANCE.GS1_PROPRIETARY = 'TRUE',
          GS1_RETAIL_DB.GOVERNANCE.MEMBER_CONFIDENTIAL = 'TRUE';

ALTER TABLE GS1_RETAIL_DB.PRODUCT_MASTER.PRODUCT_ATTRIBUTES
  SET TAG GS1_RETAIL_DB.GOVERNANCE.OSI_ELIGIBLE = 'FALSE',
          GS1_RETAIL_DB.GOVERNANCE.GS1_PROPRIETARY = 'TRUE';
```

---

## 11. Observability Dashboard (Streamlit in Snowflake)

The dashboard runs as **Streamlit in Snowflake (SiS)** — no local installs required.

**Access:** Open Snowsight > Projects > Streamlit > `GS1_RETAIL_OBSERVABILITY`

### Dashboard Panels

| Panel | Metrics | Source |
|-------|---------|--------|
| **Platform Health KPIs** | Active GTINs, Avg Completeness, EPCIS Events, Sync Failures, Verification Rate | PRODUCT_ATTRIBUTES, EPCIS, GDSN_SYNC_LOG, VERIFIED_BY_GS1 |
| **Product Data Quality** | Completeness by category, all products ranked | PRODUCT_ATTRIBUTES + GPC_TAXONOMY |
| **Supply Chain Visibility** | Events by business step, events by location | EPCIS_OBJECT_EVENTS + GLN_REGISTRY |
| **GDSN Sync Health** | Sync success/fail breakdown, recent failures | GDSN_SYNC_LOG |
| **Verified by GS1** | Lookups by result, requester type, country | VERIFIED_BY_GS1_LOOKUPS |
| **Location Network** | Map of all NovaBrand + FreshMart locations | GLN_REGISTRY (lat/long) |

### SiS Package Configuration

When creating or editing the Streamlit app in Snowsight, configure packages under **Packages > Anaconda Packages**:

| Setting | Value |
|---------|-------|
| **Python Version** | 3.11 |
| **snowflake-snowpark-python** | 1.53.1 |
| **streamlit** | 1.52.2 |

To set this in Snowsight:
1. Open the Streamlit app in Snowsight (Projects > Streamlit > GS1_RETAIL_OBSERVABILITY)
2. Click **Packages** dropdown (top-left)
3. Select **Anaconda Packages** tab
4. Set Python Version to **3.11**
5. Search and add `snowflake-snowpark-python` version **1.53.1**
6. Search and add `streamlit` version **1.52.2**

Streamlit 1.52.2 enables: `st.container(border=True)`, `st.container(horizontal=True)`, `st.bar_chart(horizontal=True, color=...)`, `st.metric(border=True, delta=...)`, `st.dataframe(hide_index=True)`, and `st.map(latitude=..., longitude=...)`.

### Key Files

| File | Purpose |
|------|---------|
| `streamlit_app.py` | Main app — uses `get_active_session()` for Snowpark |
| `snowflake.yml` | Deployment manifest (target: GS1_DB.DEMO) |
| `pyproject.toml` | Python dependencies for SiS |

### Deploy / Redeploy

```bash
cd <project_root>
snow streamlit deploy --replace --connection <your_connection>
```

### Architecture (SiS)

- Uses `snowflake.snowpark.context.get_active_session()` — no secrets or local credentials
- Queries run with the app viewer's role and warehouse
- Data cached for 5 minutes via `@st.cache_data(ttl=300)`
- All data stays within Snowflake — no data leaves the platform

---

## 12. Stage 2 — OSI Bridge & Sanitisation Pipeline

After Stage 1 is stable and tagged:

1. Review all objects tagged `OSI_ELIGIBLE = TRUE`
2. Run sanitisation pipeline (Snowflake Task) to extract structural definitions
3. Generate OSI YAML from approved schemas
4. Run OSI validator against Apache Ossie spec
5. Submit PR to `open-semantic-interchange/OSI` GitHub repository

Sanitisation rules:
- Strip: member IDs (GLN/GCP), actual GTIN values, proprietary formulas, thresholds, member contact data
- Retain: attribute names (generic), metric structure (type + aggregation), dimension cardinality, relationship patterns

---

## 13. Git Repository & Publishing

### Initial Commit
```bash
cd <project_root>
git add .
git commit -m "feat: add project structure, README, setup guide, and dummy data definitions"
```

### Recommended Branch Strategy
```
main          ← stable, Stage 1 complete
dev           ← active development
feature/*     ← individual features
stage2/osi    ← OSI bridge work (Stage 2)
```

### Before Publishing (Security Checklist)
- [ ] No credentials in any file
- [ ] No real GS1 member data committed
- [ ] All actual GTINs are fictional (prefix 5901234 / 5412345)
- [ ] `.gitignore` covers all sensitive file patterns
- [ ] `connections.toml` is in `.gitignore` and not tracked
- [ ] `semantic/gs1_retail_model.yaml` reviewed — no member-specific thresholds

---

## Status Tracker

| Stage | Component | Status |
|-------|-----------|--------|
| **Setup** | Directory & git init | ✅ Complete |
| **Setup** | .gitignore | ✅ Complete |
| **Setup** | README.md | ✅ Complete |
| **Setup** | setup.md | ✅ Complete |
| **Dummy Data** | Dummy data design (GS1 + NovaBrand + FreshMart) | ✅ Complete |
| **SQL** | 01_database_setup.sql | ✅ Complete |
| **SQL** | 02_create_tables.sql | ✅ Complete |
| **SQL** | 03_load_dummy_data.sql | ✅ Complete |
| **SQL** | 04_semantic_views.sql | ✅ Complete |
| **SQL** | 05_dmf_observability.sql | ⚠️ Blocked (needs ACCOUNTADMIN grant) |
| **SQL** | 06_access_control.sql | ⬜ Pending |
| **SQL** | 07_cortex_analyst.sql | ✅ Complete (using Semantic View directly) |
| **Semantic** | gs1_retail_model.yaml | ✅ Complete |
| **Stage 1** | GS1_DB.DEMO database + 13 tables | ✅ Live (148 rows) |
| **Stage 1** | Semantic View GS1_DB.DEMO.GS1_RETAIL_SV | ✅ Live (6 tables, 20 dims, 12 metrics) |
| **Stage 1** | DMFs attached and running | ⚠️ Needs: GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE <your_role> |
| **Stage 1** | Cortex Analyst working | ✅ Tested — returns correct results |
| **Stage 1** | Streamlit dashboard (SiS) | ✅ Deployed to GS1_DB.DEMO.GS1_RETAIL_OBSERVABILITY |
| **Stage 2** | OSI sanitisation pipeline | ✅ Complete (GS1_DB.OSI_EXPORT schema + Task) |
| **Stage 2** | OSI YAML package generated | ✅ Complete (6 files in stage2_osi/) |
| **Stage 2** | Apache Ossie validation | ✅ Passed (VALIDATION_REPORT.md) |
| **Stage 2** | Apache Ossie PR submitted | ✅ Mock PR created (stage2_osi/PR.md) |

### Snowflake Objects Created

- **Account:** *(your Snowflake account)*
- **Database:** GS1_DB
- **Schema:** DEMO
- **Connection:** *(your configured Snowflake CLI connection)*
- **Semantic View:** GS1_DB.DEMO.GS1_RETAIL_SV
- **Tables:** 13 (GS1_MEMBER_REGISTRY, COMPANY_REGISTRY, GCP_REGISTRY, GPC_TAXONOMY, GTIN_REGISTRY, GLN_REGISTRY, PRODUCT_ATTRIBUTES, NUTRITIONAL_INFO, ALLERGEN_INFO, GDSN_SUBSCRIPTION, GDSN_SYNC_LOG, EPCIS_OBJECT_EVENTS, EPCIS_AGGREGATION_EVENTS, EPCIS_TRANSACTION_EVENTS, VERIFIED_BY_GS1_LOOKUPS)

### Unblocking DMFs

Run as ACCOUNTADMIN:
```sql
GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE <your_role>;
```
Then re-run `sql/05_dmf_observability.sql`.
