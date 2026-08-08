# GS1 Retail Observability Platform

## For Reviewers: Start Here

This repository demonstrates a **two-stage approach** to building semantic observability for GS1's retail supply chain standards on Snowflake, with a bridge to the **OSI (Open Semantic Interchange / Apache Ossie)** open-source standard.

### Reading Order

| # | Document | What You'll Learn |
|---|----------|------------------|
| 1 | **This file (README.md)** | Project vision, architecture, GS1 context, technology choices |
| 2 | [setup.md](setup.md) | Full implementation walkthrough — from Snowflake setup to dummy data to deployment |
| 3 | [stage2_osi/README.md](stage2_osi/README.md) | Stage 2 OSI bridge — what gets exported, sanitisation rules, YAML package |
| 4 | [stage2_osi/PR.md](stage2_osi/PR.md) | Mock pull request to Apache Ossie — shows what a real submission looks like |
| 5 | [stage2_osi/VALIDATION_REPORT.md](stage2_osi/VALIDATION_REPORT.md) | Spec compliance validation — proves no proprietary data leaks |

### Live Demo (Snowflake)

| Asset | URL / Location |
|-------|---------------|
| **Streamlit Dashboard** | `GS1_DB.DEMO.GS1_RETAIL_OBSERVABILITY` (open via Snowsight > Projects > Streamlit) |
| **Semantic View** | `GS1_DB.DEMO.GS1_RETAIL_SV` (query via Cortex Analyst in Snowsight) |
| **Database** | `GS1_DB.DEMO` — 13 tables, 148 rows of synthetic data |
| **OSI Export** | `GS1_DB.OSI_EXPORT` — 4 sanitised export tables |
| **Account** | *(your Snowflake account — see setup.md for configuration)* |

---

## Project Overview

This project builds a **two-stage semantic observability platform** for GS1's retail vertical on Snowflake, with a bridge to the **OSI (Open Semantic Interchange / Apache Ossie)** open-source standard.

GS1 is the global non-profit standards body behind every barcode on every retail product. They manage GTIN (product identifiers), GLN (location identifiers), GDSN (product data network), and EPCIS (supply chain event protocol). This platform delivers operational observability over that data ecosystem, and contributes sanitised semantic patterns to the open-source community.

---

## Fictional Participants (Dummy Data)

| Role | Organisation | GS1 Prefix | Description |
|------|-------------|-----------|-------------|
| **Standards Body** | GS1 Global | — | Issues identifiers, runs GDSN network, owns standards |
| **Brand Owner / Supplier** | NovaBrand Foods Ltd | 5901234 | Fictional FMCG manufacturer — cereals, dairy, beverages, snacks |
| **Retailer** | FreshMart Retail Group | 5412345 | Fictional grocery chain — HQ, DC, and 5 store locations |

**Data flow:**
```
GS1 Global ──issues prefixes──► NovaBrand Foods (brand owner)
                                    │
                    registers 10 GTINs + publishes to GDSN
                    generates EPCIS events (commissioning, shipping)
                                    │
                                    ▼
                              FreshMart Retail (retailer)
                                    │
                    subscribes via GDSN + receives product data
                    generates EPCIS events (receiving, stocking)
                    operates 5 stores + 1 DC across UK
```

---

## Two-Stage Architecture

### Stage 1 — GS1 Retail Observability Platform (Snowflake-native)

> **Principle:** All proprietary GS1 IP, member data, and business logic stays within Snowflake's secure perimeter.

| Component | What It Does | Snowflake Feature |
|-----------|-------------|-------------------|
| Semantic Layer | Unified business view over 6 tables | Semantic Views |
| Natural Language | "How many active GTINs does NovaBrand have?" | Cortex Analyst |
| Data Quality | 14 DMFs monitoring freshness, completeness, uniqueness | Data Metric Functions |
| Dashboard | 6-panel observability app | Streamlit in Snowflake |
| Access Control | IP/data classification on all objects | Object Tags + Masking Policies |
| Pipeline | Weekly OSI export automation | Snowflake Tasks |

### Stage 2 — OSI Bridge (Apache Ossie Contribution)

> **Principle:** Only structural patterns (schemas, metric definitions, dimension hierarchies) leave the perimeter — never actual data or business rules.

| Component | What It Does | Output |
|-----------|-------------|--------|
| Sanitisation Pipeline | Scans `OSI_ELIGIBLE` tagged objects, extracts structure | `GS1_DB.OSI_EXPORT` tables |
| Dataset Templates | Generic supply chain entity schemas | `stage2_osi/datasets/*.yaml` |
| Metric Patterns | DMF-derived quality measurement definitions | `stage2_osi/metrics/*.yaml` |
| Dimension Patterns | Hierarchical/categorical grouping templates | `stage2_osi/dimensions/*.yaml` |
| Relationship Defs | Standard join paths between entities | `stage2_osi/relationships/*.yaml` |
| Validation | Confirms no proprietary data leakage | `stage2_osi/VALIDATION_REPORT.md` |

### What Crosses the Boundary

| Stays in Stage 1 (Proprietary) | Goes to Stage 2 (OSI-safe) |
|-------------------------------|---------------------------|
| Actual GTIN/GLN values | Column schemas (names + types only) |
| Member company names & contacts | Generic role labels (brand_owner, retailer) |
| Product master data (weights, prices) | Attribute structure (what fields exist) |
| EPCIS events with trading partner GLNs | Event type vocabulary (public standard) |
| GS1-specific quality SLA thresholds | Generic metric patterns (no thresholds) |
| GDSN subscription relationships | Relationship patterns (join paths) |

---

## Repository Structure

```
GS1/
├── README.md                    ← This file — start here
├── setup.md                     ← Detailed implementation guide (Stage 1 + Stage 2)
├── .gitignore                   ← Security-first: no credentials committed
│
├── streamlit_app.py             ← Streamlit in Snowflake dashboard (SiS)
├── snowflake.yml                ← SiS deployment manifest
├── pyproject.toml               ← Python dependencies for SiS
│
├── sql/                         ← All Snowflake DDL and DML
│   ├── 01_database_setup.sql    ← Database, schemas, warehouse, roles
│   ├── 02_create_tables.sql     ← 13 table definitions
│   ├── 03_load_dummy_data.sql   ← Orchestration + verification query
│   ├── 04_semantic_views.sql    ← Semantic View DDL (6 tables, 20 dims, 12 metrics)
│   ├── 05_dmf_observability.sql ← 14 DMF attachments across 5 tables
│   ├── 06_access_control.sql    ← Tags, masking policies, role grants
│   ├── 07_cortex_analyst.sql    ← Internal stage for Cortex Analyst YAML
│   ├── 08_grounding_paths.sql   ← Three-way AI agent comparison datasets
│   ├── 09_shopping_questions.sql← 25 test questions + gold-standard answers
│   └── 10_agent_harness.sql     ← Measurement table + scoring views
│
├── semantic/
│   └── gs1_retail_model.yaml    ← Cortex Analyst semantic model (6 tables + VQRs)
│
├── data/dummy/                  ← Synthetic data files (148 rows total)
│   ├── member_registry.sql      ← GS1 orgs + NovaBrand + FreshMart companies
│   ├── gpc_taxonomy.sql         ← 12 GPC bricks (food & beverage)
│   ├── gtin_registry.sql        ← 10 NovaBrand product identifiers
│   ├── gln_registry.sql         ← 9 locations (2 NovaBrand + 7 FreshMart)
│   ├── product_attributes.sql   ← Full GDM attributes + nutritional + allergen
│   ├── epcis_events.sql         ← 19 object + 3 aggregation + 2 transaction events
│   └── verification_lookups.sql ← 25 Verified by GS1 lookup records
│
└── stage2_osi/                  ← OSI/Apache Ossie contribution package
    ├── README.md                ← Stage 2 overview and sanitisation rules
    ├── PR.md                    ← Mock pull request for Apache Ossie repo
    ├── VALIDATION_REPORT.md     ← Spec compliance validation results
    ├── datasets/
    │   ├── product_classification_taxonomy.yaml
    │   ├── supply_chain_event.yaml
    │   └── identifier_verification_lookups.yaml
    ├── metrics/
    │   └── data_quality_metrics.yaml
    ├── dimensions/
    │   └── supply_chain_dimensions.yaml
    └── relationships/
        └── product_location_event.yaml
```

---

## GS1 Standards Covered

| Standard | Description | Data Domain |
|----------|-------------|-------------|
| **GTIN** | Global Trade Item Number — 14-digit product identifier | Identity |
| **GLN** | Global Location Number — party/location identifier | Identity |
| **SSCC** | Serial Shipping Container Code — logistics unit identifier | Identity |
| **GCP** | GS1 Company Prefix — member organisation prefix | Identity |
| **GDSN** | Global Data Synchronisation Network — product data exchange | Product Master |
| **GDM** | Global Data Model — standardised product attribute schema | Product Master |
| **GPC** | Global Product Classification — Segment/Family/Class/Brick taxonomy | Classification |
| **EPCIS 2.0** | Electronic Product Code Information Services — supply chain events | Events |
| **CBV** | Core Business Vocabulary — standard EPCIS event vocabulary | Events |
| **GS1 Digital Link** | URI syntax for GS1 identifiers (QR codes) | Digital |
| **Verified by GS1** | GTIN/GLN public verification service | Verification |

---

## Key Metrics Tracked (Stage 1)

| Metric | Description | Source |
|--------|-------------|--------|
| GTIN Registration Rate | Active GTINs as % of total registered | GTIN_REGISTRY + DMF |
| Product Data Completeness | % of GDM required attributes populated per product | PRODUCT_ATTRIBUTES + DMF |
| GDSN Sync Freshness | Days since last successful GDSN synchronisation | GDSN_SYNC_LOG + DMF |
| Traceability Coverage | % of GTINs with ≥1 EPCIS event per business step | EPCIS + SEMANTIC_METRICS |
| EPCIS Event Volume | Events per day by business step and trading partner | EPCIS_EVENTS |
| Data Quality Score | Composite: completeness + freshness + uniqueness | DMF composite |
| GTIN Verification Rate | % of Verified by GS1 lookups returning valid result | VERIFICATION_LOOKUPS |
| GDSN Sync Failure Rate | Failed syncs as % of total | GDSN_SYNC_LOG |

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Data Platform | Snowflake | All compute, storage, and governance |
| Semantic Layer | Snowflake Semantic Views | Unified business model over raw tables |
| Natural Language | Cortex Analyst | Text-to-SQL over semantic view |
| Data Quality | Data Metric Functions (14 DMFs) | Continuous quality monitoring |
| Dashboard | Streamlit in Snowflake (v1.52.2) | Observability UI — no local installs |
| Access Control | Object Tags + Dynamic Masking | IP classification and protection |
| Pipeline | Snowflake Tasks | Automated weekly OSI export |
| OSI Exchange | Apache Ossie YAML format | Vendor-neutral semantic interchange |

---

## OSI / Apache Ossie Alignment

This project is a reference implementation for GS1's contribution to the [Open Semantic Interchange](https://open-semantic-interchange.org/) standard, now governed as [Apache Ossie (Incubating)](https://ossie.apache.org/).

| OSI Concept | Stage 1 (Snowflake) | Stage 2 (OSI YAML) |
|------------|--------------------|--------------------|
| Dataset | Semantic View tables | `stage2_osi/datasets/*.yaml` |
| Metric | Semantic View metrics + DMFs | `stage2_osi/metrics/*.yaml` |
| Dimension | Semantic View dimensions | `stage2_osi/dimensions/*.yaml` |
| Relationship | Semantic View relationships | `stage2_osi/relationships/*.yaml` |
| Context | Synonyms + comments | YAML descriptions + license headers |

---

## GS1 US Pilot Brief Alignment

This MVP directly supports the **GS1 US + Snowflake Pilot Executive Brief** (Joel Traugott, June 2026) which proposes testing whether AI shopping agents give better, faster, cheaper answers when grounded on GS1 standardized product data versus scraped web data or internal retailer data.

### Three-Way Grounding Comparison

The pilot's core test runs the same AI agent on the same shopping questions across three data paths:

| Path | Table | Attributes | Quality | Simulates |
|------|-------|-----------|---------|-----------|
| **A: GS1 Standardized** | `GROUNDING_GS1` (view) | 33 per product | Complete, structured, current | Authoritative GS1 GDM data |
| **B: Retailer Internal** | `GROUNDING_RETAILER` | 14 per product | Partial (40% missing), stale, flat category | Typical retailer PIM system |
| **C: Scraped Web** | `GROUNDING_SCRAPED` | ~12 useful + noise | Duplicates, wrong values, marketing copy | Web crawler output |

### Shopping Question Test Suite

25 standardized questions (`SHOPPING_QUESTIONS` table) across 5 categories:
- **Allergen** (5 Qs) — "Which products are gluten-free?"
- **Nutrition** (5 Qs) — "Which product has the highest protein?"
- **Discovery** (5 Qs) — "Show me all beverages"
- **Attribute** (5 Qs) — "What is the net weight of the Cheddar?"
- **Multi-criteria** (5 Qs) — "Find a dairy-free beverage under 50 calories"

Each question has a validated gold-standard answer for scoring agent accuracy.

### Measurement Harness

The `AGENT_RESPONSES` table captures per-question, per-path:
- **Accuracy** — does the answer match gold standard?
- **Completeness** — did it include all required attributes?
- **Token use** — input + output tokens consumed
- **Latency** — response time in milliseconds
- **Cost** — Snowflake credits used

The `PILOT_SUMMARY` view aggregates results to prove the hypothesis: GS1 data = higher accuracy + lower cost.

### Hypothesis to Prove

> Standardized GS1 product data produces more accurate AI agent answers while consuming fewer tokens, lower latency, and less compute cost than retailer-internal or scraped web data.

---

## Security & IP Protection

| Control | Implementation |
|---------|---------------|
| **Data Classification Tags** | `GS1_PROPRIETARY`, `OSI_ELIGIBLE`, `MEMBER_CONFIDENTIAL` on all tables |
| **Dynamic Masking** | GCP prefix masked for non-admin roles |
| **Sanitisation Gate** | Only objects tagged `OSI_ELIGIBLE = TRUE` can be exported |
| **Validation Report** | Automated check confirms no proprietary data in OSI output |
| **No credentials in repo** | `.gitignore` blocks all secrets, keys, and connection configs |
| **Row-level security** | Member data visible only to authorised roles (design, not yet enforced in demo) |

---

## Related Resources

- [GS1 Official Website](https://www.gs1.org)
- [GS1 GDSN](https://www.gs1.org/services/gdsn)
- [EPCIS & CBV Standard](https://www.gs1.org/standards/epcis)
- [GS1 Global Data Model](https://www.gs1.org/standards/gs1-global-data-model)
- [Apache Ossie (OSI)](https://ossie.apache.org/)
- [Snowflake Semantic Views](https://docs.snowflake.com/en/user-guide/views-semantic)
- [Snowflake Data Metric Functions](https://docs.snowflake.com/en/sql-reference/functions-data-metric)
- [Snowflake ACCOUNT_USAGE](https://docs.snowflake.com/en/sql-reference/account-usage)
