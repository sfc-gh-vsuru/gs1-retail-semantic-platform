-- ============================================================
-- GS1 Retail Observability Platform
-- File: sql/07_cortex_analyst.sql
-- Purpose: Stage setup for Cortex Analyst semantic model YAML
-- Run as: GS1_PLATFORM_ADMIN
-- ============================================================

USE ROLE GS1_PLATFORM_ADMIN;
USE WAREHOUSE GS1_WH;
USE DATABASE GS1_RETAIL_DB;

-- Internal stage (encrypted) for semantic model
CREATE STAGE IF NOT EXISTS GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'Hosts Cortex Analyst YAML semantic model for GS1 retail platform';

-- After uploading semantic/gs1_retail_model.yaml via Snowflake CLI:
--   snow stage copy semantic/gs1_retail_model.yaml \
--     @GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE --connection gs1_dev

-- Verify the file is on stage
LIST @GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE;

-- Test Cortex Analyst (run from Snowsight or via REST API)
-- Example REST payload:
-- POST /api/v2/cortex/analyst/message
-- {
--   "messages": [{"role": "user", "content": [{"type": "text",
--     "text": "How many active GTINs does NovaBrand have?"}]}],
--   "semantic_model_file": "@GS1_RETAIL_DB.SEMANTIC.GS1_SEMANTIC_STAGE/gs1_retail_model.yaml"
-- }

-- Sample questions the model should answer:
-- "How many active GTINs does NovaBrand have?"
-- "What is the average product data completeness score by category?"
-- "Which GTINs have not been synced via GDSN in the last 30 days?"
-- "How many EPCIS receiving events did FreshMart generate last week?"
-- "Show traceability coverage for dairy products"
-- "Which products have a completeness score below 95%?"
-- "How many verification lookups were valid vs not found?"
-- "Which FreshMart stores received stock this week?"
-- "What is the average net weight of NovaBrand products in the beverages category?"
-- "How many GDSN sync failures occurred in the last 7 days?"
