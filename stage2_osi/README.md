# Stage 2: OSI Bridge — Apache Ossie Contribution Package

> **Back to:** [Main README](../README.md) | **Implementation details:** [setup.md](../setup.md)

---

## What This Is

This directory contains the **sanitised, open-source-ready** semantic patterns extracted from the Stage 1 GS1 Retail Observability Platform. These files are formatted as OSI-compliant YAML for contribution to the [Apache Ossie](https://ossie.apache.org/) (formerly Open Semantic Interchange) open standard.

**Key principle:** Only structural patterns leave the Snowflake perimeter — never actual data, member identifiers, or proprietary business rules.

---

## Package Contents

```
stage2_osi/
├── README.md                  ← This file
├── PR.md                      ← Mock pull request (what would be submitted to Apache Ossie)
├── VALIDATION_REPORT.md       ← Spec compliance + IP safety validation
│
├── datasets/                  ← Entity schema templates
│   ├── product_classification_taxonomy.yaml    ← 4-level hierarchy (Segment > Family > Class > Brick)
│   ├── supply_chain_event.yaml                 ← EPCIS what/when/where/why/how pattern
│   └── identifier_verification_lookups.yaml    ← Trust verification request pattern
│
├── metrics/                   ← Data quality measurement definitions
│   └── data_quality_metrics.yaml               ← 10 generic metrics (freshness, completeness, uniqueness, etc.)
│
├── dimensions/                ← Grouping and filtering patterns
│   └── supply_chain_dimensions.yaml            ← 7 dimensions (category, geography, time, role, event type, etc.)
│
└── relationships/             ← Standard join paths
    └── product_location_event.yaml             ← 4 relationships connecting products, locations, events, and verification
```

---

## How This Was Generated

```
┌──────────────────────────────────────────────────────────┐
│         Stage 1: GS1 Snowflake Secure Perimeter         │
│                                                          │
│  Snowflake Semantic Views (GS1_DB.DEMO.GS1_RETAIL_SV)   │
│  14 Data Metric Functions (DMFs)                         │
│  Object Tags: GS1_PROPRIETARY, OSI_ELIGIBLE             │
│                                                          │
│         ┌──────────────────────────────┐                 │
│         │  SANITISATION PIPELINE       │                 │
│         │                              │                 │
│         │  1. Scan OSI_ELIGIBLE tags   │                 │
│         │  2. Extract column schemas   │                 │
│         │  3. Generate metric patterns │                 │
│         │  4. Generate dim patterns    │                 │
│         │  5. Validate no PII/IP       │                 │
│         └──────────────┬───────────────┘                 │
│                        │                                 │
│              GS1_DB.OSI_EXPORT schema                    │
│              (4 export tables)                           │
└────────────────────────┼─────────────────────────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  stage2_osi/ (YAML)   │  ← You are here
            │  Apache Ossie format  │
            └────────────────────────┘
```

### Snowflake Objects Involved

| Object | Purpose |
|--------|---------|
| `GS1_DB.OSI_EXPORT.OSI_ELIGIBLE_OBJECTS` | Which tables are approved for export |
| `GS1_DB.OSI_EXPORT.OSI_DATASET_SCHEMAS` | Column-level metadata (names, types — no data) |
| `GS1_DB.OSI_EXPORT.OSI_METRIC_PATTERNS` | Generic metric definitions (DMF-derived) |
| `GS1_DB.OSI_EXPORT.OSI_DIMENSION_PATTERNS` | Dimension structures and hierarchies |
| `GS1_DB.OSI_EXPORT.OSI_SANITISATION_TASK` | Weekly automated Task (CRON Mon 6am PT) |

---

## Sanitisation Rules

These rules determine what is allowed to leave the Snowflake perimeter:

| Rule | Check | Status |
|------|-------|--------|
| Only `OSI_ELIGIBLE = TRUE` objects exported | Tag scan | Enforced |
| No actual GTIN/GLN/SSCC values | Content scan | Enforced |
| No member company names (NovaBrand, FreshMart) | Text check | Enforced |
| No proprietary formulas or business rules | Structure-only export | Enforced |
| No GS1-specific SLA thresholds | Generic ranges only | Enforced |
| No contact info, email, or PII | No PII columns exported | Enforced |
| Public standards only (EPCIS 2.0 = ISO/IEC 19987) | Standard verification | Confirmed |

---

## What Each File Contains

### Datasets (structural schemas)

| File | Pattern | Based On |
|------|---------|----------|
| `product_classification_taxonomy.yaml` | 4-level hierarchical product taxonomy | GS1 GPC structure (public standard) |
| `supply_chain_event.yaml` | What-When-Where-Why-How event pattern | EPCIS 2.0 (ISO standard) |
| `identifier_verification_lookups.yaml` | Trust verification request/response pattern | Verified by GS1 service structure |

### Metrics (quality measurement patterns)

| Metric | Category | What It Measures |
|--------|----------|-----------------|
| data_freshness | timeliness | Seconds since last modification |
| null_count | completeness | Missing required values |
| null_percent | completeness | Fill rate normalised to % |
| duplicate_count | uniqueness | Key column integrity |
| unique_count | uniqueness | Cardinality of identifier columns |
| row_count | volume | Dataset size and anomaly detection |
| avg_value | distribution | Central tendency drift |
| min_value | distribution | Floor violations |
| blank_percent | completeness | Empty string density |
| schema_change_count | stability | Unexpected schema modifications |

### Dimensions (grouping patterns)

| Dimension | Type | Levels/Values |
|-----------|------|---------------|
| product_category | hierarchical | Segment > Family > Class > Brick |
| geography | hierarchical | Continent > Country > Region > City |
| time | temporal | Year > Quarter > Month > Week > Day > Hour |
| supply_chain_role | categorical | brand_owner, retailer, logistics_provider, regulator |
| event_type | categorical | commissioning, shipping, receiving, stocking, etc. |
| identifier_status | categorical | active, inactive, retired, suspended |
| data_quality_tier | categorical | excellent, good, needs_enrichment |

---

## For Reviewers

### Is this safe to publish?

Yes. See [VALIDATION_REPORT.md](VALIDATION_REPORT.md) for the full compliance check. Key points:
- Contains **zero rows of actual data** — only structural definitions
- All YAML describes patterns, not implementations
- Based on **publicly available** GS1 standards (EPCIS 2.0 is ISO/IEC 19987)
- GPC taxonomy structure is public; specific brick codes/names remain in Stage 1

### What would this enable for the community?

1. Any platform (dbt, Databricks, Tableau, Sigma) could adopt these dataset/metric/dimension patterns for supply chain analytics
2. AI/LLM tools could understand supply chain semantics without needing access to GS1 proprietary data
3. New GS1 members could bootstrap their semantic layer using these templates
4. Other standards bodies could contribute complementary patterns (healthcare, logistics, finance)

### How to submit for real

1. Fork `https://github.com/apache/ossie`
2. Create branch `contrib/gs1-supply-chain-patterns`
3. Copy `datasets/`, `metrics/`, `dimensions/`, `relationships/` into the fork
4. Open PR (see [PR.md](PR.md) for the full PR body)
5. Engage Apache Ossie PMC reviewers

---

## Next Steps (Beyond MVP)

- Add `benchmarks/` with anonymised, aggregated query performance distributions
- Expand to healthcare vertical (GLN for hospitals, GTIN for medical devices)
- Add a location/party dataset template
- Integrate with dbt Semantic Layer converter (OSI → MetricFlow YAML)
- Automate YAML generation directly from `GS1_DB.OSI_EXPORT` tables via Python UDF
