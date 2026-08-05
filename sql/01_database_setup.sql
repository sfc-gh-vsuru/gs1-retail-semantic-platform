-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/01_database_setup.sql
-- Purpose: Create warehouses, databases, schemas, and roles
-- Run as: SYSADMIN / ACCOUNTADMIN
-- ============================================================

USE ROLE SYSADMIN;

-- ----------------------------
-- Warehouse
-- ----------------------------
CREATE WAREHOUSE IF NOT EXISTS GS1_WH
  WAREHOUSE_SIZE    = 'X-SMALL'
  AUTO_SUSPEND      = 60
  AUTO_RESUME       = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'GS1 Retail Observability Platform warehouse';

-- ----------------------------
-- Database
-- ----------------------------
CREATE DATABASE IF NOT EXISTS GS1_RETAIL_DB
  COMMENT = 'GS1 Retail Observability Platform — GS1 Global + NovaBrand Foods + FreshMart Retail';

-- ----------------------------
-- Schemas
-- ----------------------------
CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.IDENTITY
  COMMENT = 'GS1 identifier registries: GTIN, GLN, SSCC, GCP';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.PRODUCT_MASTER
  COMMENT = 'GDSN product master data: GDM attributes, nutritional, allergen';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.SUPPLY_CHAIN
  COMMENT = 'EPCIS supply chain events: object, aggregation, transaction, sensor';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.CLASSIFICATION
  COMMENT = 'GS1 GPC taxonomy: Segment, Family, Class, Brick';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.MEMBERS
  COMMENT = 'GS1 member organisations and company registry';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.VERIFICATION
  COMMENT = 'Verified by GS1 lookup history and audit trail';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.OBSERVABILITY
  COMMENT = 'Data quality scores, DMF results, pipeline health metrics';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.GOVERNANCE
  COMMENT = 'Tags, policies, and access control objects';

CREATE SCHEMA IF NOT EXISTS GS1_RETAIL_DB.SEMANTIC
  COMMENT = 'Snowflake Semantic Views and Cortex Analyst stage';

-- ----------------------------
-- Roles (run as ACCOUNTADMIN)
-- ----------------------------
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS GS1_PLATFORM_ADMIN
  COMMENT = 'Full access — GS1 platform engineers';
CREATE ROLE IF NOT EXISTS GS1_DATA_ENGINEER
  COMMENT = 'Pipeline, quality, and table access';
CREATE ROLE IF NOT EXISTS GS1_ANALYST
  COMMENT = 'Read-only: semantic views + Cortex Analyst';
CREATE ROLE IF NOT EXISTS GS1_AUDITOR
  COMMENT = 'ACCESS_HISTORY, TRUST_CENTER, SESSIONS views only';

-- Role hierarchy
GRANT ROLE GS1_ANALYST       TO ROLE GS1_DATA_ENGINEER;
GRANT ROLE GS1_DATA_ENGINEER TO ROLE GS1_PLATFORM_ADMIN;
GRANT ROLE GS1_PLATFORM_ADMIN TO ROLE SYSADMIN;

-- Warehouse
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_DATA_ENGINEER;
GRANT USAGE ON WAREHOUSE GS1_WH TO ROLE GS1_ANALYST;

-- Database + schemas
GRANT ALL PRIVILEGES ON DATABASE GS1_RETAIL_DB TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON DATABASE GS1_RETAIL_DB TO ROLE GS1_DATA_ENGINEER;
GRANT USAGE ON DATABASE GS1_RETAIL_DB TO ROLE GS1_ANALYST;

GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE GS1_RETAIL_DB TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON ALL SCHEMAS IN DATABASE GS1_RETAIL_DB TO ROLE GS1_DATA_ENGINEER;
GRANT USAGE ON SCHEMA GS1_RETAIL_DB.SEMANTIC TO ROLE GS1_ANALYST;

-- Future schemas
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE GS1_RETAIL_DB TO ROLE GS1_PLATFORM_ADMIN;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE GS1_RETAIL_DB TO ROLE GS1_DATA_ENGINEER;
