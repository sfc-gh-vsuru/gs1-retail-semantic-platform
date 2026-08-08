-- ============================================================
-- GS1 Retail Observability Platform — Pilot Comparison
-- File: sql/10_agent_harness.sql
-- Purpose: Measurement harness for AI shopping agent benchmarking
--          Captures per-question, per-path results with scoring
--
-- Reference: GS1 US + Snowflake Pilot Executive Brief (June 2026)
-- Metrics: accuracy, completeness, consistency, tokens, latency, cost
-- ============================================================

USE DATABASE GS1_DB;
USE SCHEMA DEMO;

-- ============================================================
-- AGENT_RESPONSES — raw results per question per grounding path
-- ============================================================

CREATE OR REPLACE TABLE GS1_DB.DEMO.AGENT_RESPONSES (
    response_id         VARCHAR(50)   NOT NULL,
    question_id         VARCHAR(10)   NOT NULL,
    grounding_path      VARCHAR(20)   NOT NULL,
    response_text       VARCHAR(5000),
    is_correct          BOOLEAN,
    accuracy_score      FLOAT,
    completeness_score  FLOAT,
    tokens_in           INTEGER,
    tokens_out          INTEGER,
    latency_ms          INTEGER,
    credits_used        FLOAT,
    run_number          INTEGER       DEFAULT 1,
    run_timestamp       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    notes               VARCHAR(500),
    CONSTRAINT pk_response PRIMARY KEY (response_id)
) COMMENT = 'AI Shopping Agent benchmark results — one row per question x grounding path x run';


-- ============================================================
-- PILOT_SUMMARY — aggregated comparison view (the "results table")
-- ============================================================

CREATE OR REPLACE VIEW GS1_DB.DEMO.PILOT_SUMMARY AS
SELECT
    grounding_path,
    COUNT(*) AS total_responses,
    -- Accuracy
    ROUND(AVG(accuracy_score) * 100, 1) AS avg_accuracy_pct,
    COUNT_IF(is_correct) AS correct_count,
    ROUND(COUNT_IF(is_correct) * 100.0 / NULLIF(COUNT(*), 0), 1) AS correct_pct,
    -- Completeness
    ROUND(AVG(completeness_score) * 100, 1) AS avg_completeness_pct,
    -- Efficiency
    ROUND(AVG(tokens_in), 0) AS avg_tokens_in,
    ROUND(AVG(tokens_out), 0) AS avg_tokens_out,
    ROUND(AVG(tokens_in + tokens_out), 0) AS avg_total_tokens,
    -- Latency
    ROUND(AVG(latency_ms), 0) AS avg_latency_ms,
    ROUND(MEDIAN(latency_ms), 0) AS p50_latency_ms,
    -- Cost
    ROUND(SUM(credits_used), 4) AS total_credits,
    ROUND(AVG(credits_used), 6) AS avg_credits_per_query
FROM GS1_DB.DEMO.AGENT_RESPONSES
GROUP BY grounding_path
ORDER BY avg_accuracy_pct DESC;


-- ============================================================
-- PILOT_BY_CATEGORY — breakdown by question category
-- ============================================================

CREATE OR REPLACE VIEW GS1_DB.DEMO.PILOT_BY_CATEGORY AS
SELECT
    q.question_category,
    r.grounding_path,
    COUNT(*) AS questions_asked,
    ROUND(AVG(r.accuracy_score) * 100, 1) AS avg_accuracy_pct,
    ROUND(AVG(r.completeness_score) * 100, 1) AS avg_completeness_pct,
    ROUND(AVG(r.tokens_in + r.tokens_out), 0) AS avg_total_tokens,
    ROUND(AVG(r.latency_ms), 0) AS avg_latency_ms
FROM GS1_DB.DEMO.AGENT_RESPONSES r
JOIN GS1_DB.DEMO.SHOPPING_QUESTIONS q ON r.question_id = q.question_id
GROUP BY q.question_category, r.grounding_path
ORDER BY q.question_category, avg_accuracy_pct DESC;


-- ============================================================
-- PILOT_CONSISTENCY — same question run multiple times
-- Measures: do you get the same answer each run?
-- ============================================================

CREATE OR REPLACE VIEW GS1_DB.DEMO.PILOT_CONSISTENCY AS
SELECT
    question_id,
    grounding_path,
    COUNT(DISTINCT run_number) AS total_runs,
    COUNT(DISTINCT response_text) AS unique_responses,
    IFF(COUNT(DISTINCT response_text) = 1, TRUE, FALSE) AS is_consistent,
    STDDEV(accuracy_score) AS accuracy_variance
FROM GS1_DB.DEMO.AGENT_RESPONSES
GROUP BY question_id, grounding_path
HAVING COUNT(DISTINCT run_number) > 1;


-- ============================================================
-- Expected outcome when pilot runs:
--
-- PILOT_SUMMARY will show something like:
--
-- | GROUNDING_PATH | AVG_ACCURACY_PCT | AVG_TOTAL_TOKENS | AVG_LATENCY_MS |
-- |----------------|------------------|------------------|----------------|
-- | GS1            | 95.0             | 450              | 1200           |
-- | RETAILER       | 62.0             | 680              | 1800           |
-- | SCRAPED        | 48.0             | 920              | 2400           |
--
-- This proves:
-- 1. GS1 data = higher accuracy (structured, complete attributes)
-- 2. GS1 data = fewer tokens (clean schema, no disambiguation needed)
-- 3. GS1 data = lower latency (smaller context, less processing)
-- ============================================================
