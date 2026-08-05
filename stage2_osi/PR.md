# Pull Request: GS1 Supply Chain Semantic Patterns

> **Mock PR** — This represents what would be submitted to `apache/ossie` (formerly `open-semantic-interchange/OSI`)

---

## PR Title

**feat: Add GS1 supply chain semantic patterns — datasets, metrics, dimensions, relationships**

---

## Target Repository

`https://github.com/apache/ossie`

**Branch:** `main`
**PR Branch:** `contrib/gs1-supply-chain-patterns`

---

## Summary

This contribution adds a set of vendor-neutral semantic patterns derived from GS1's retail supply chain standards (GTIN, GLN, GDSN, EPCIS, GPC). All patterns are structural templates only — no proprietary GS1 data, member identifiers, or confidential business rules are included.

### What's included:

- **3 dataset templates** — product classification taxonomy, supply chain events, identifier verification lookups
- **10 data quality metric patterns** — freshness, completeness, uniqueness, volume, distribution, stability
- **7 dimension patterns** — product category (hierarchical), geography, time, supply chain role, event type, identifier status, data quality tier
- **4 relationship definitions** — product-to-category, event-to-location, event-to-product, product-to-verification

### Source:

- Built on Snowflake Semantic Views + Data Metric Functions
- Sanitised via automated pipeline (Snowflake Task) with tag-based governance gate
- Validated against Apache Ossie 0.1 spec

---

## Motivation

GS1 standards (GTIN, GLN, EPCIS, GPC) are used by 2+ million companies in 116 countries. By contributing structural semantic patterns to Apache Ossie, we enable:

1. **Any supply chain platform** to adopt consistent dataset/metric/dimension definitions
2. **AI/LLM tools** to understand supply chain data semantics without proprietary access
3. **Interoperability** between dbt Semantic Layer, Snowflake Semantic Views, Databricks Unity Catalog, and other OSI-compatible tools

---

## Files Changed

```
contrib/gs1-supply-chain/
├── datasets/
│   ├── product_classification_taxonomy.yaml   [NEW] — 4-level product hierarchy
│   ├── identifier_verification_lookups.yaml   [NEW] — trust verification pattern
│   └── supply_chain_event.yaml                [NEW] — EPCIS what/when/where/why/how
├── metrics/
│   └── data_quality_metrics.yaml              [NEW] — 10 DMF-backed quality metrics
├── dimensions/
│   └── supply_chain_dimensions.yaml           [NEW] — 7 generic dimension patterns
├── relationships/
│   └── product_location_event.yaml            [NEW] — 4 standard join paths
└── VALIDATION_REPORT.md                       [NEW] — Spec compliance validation
```

---

## Checklist

- [x] All YAML files valid against OSI 0.1 schema
- [x] `osi_version: "0.1"` declared in all files
- [x] No proprietary data values (GTINs, GLNs, member names)
- [x] No PII or confidential business rules
- [x] Apache 2.0 license headers on all files
- [x] Validation report attached
- [x] GS1 legal/IP review gate passed (tag: `OSI_ELIGIBLE = TRUE`)
- [x] Tested via Snowflake sanitisation pipeline (GS1_DB.OSI_EXPORT schema)

---

## Reviewers

- @gs1-standards-team (GS1 Global)
- @ossie-spec-maintainers (Apache Ossie PMC)
- @snowflake-osi-wg (Snowflake OSI Working Group)

---

## Related Issues

- apache/ossie#42 — "Add supply chain domain patterns"
- apache/ossie#38 — "Data quality metric standardisation"

---

## How to validate locally

```bash
# Clone and check out PR branch
git clone https://github.com/apache/ossie.git
cd ossie
git checkout contrib/gs1-supply-chain-patterns

# Validate YAML syntax
pip install pyyaml
python -c "
import yaml, glob
for f in glob.glob('contrib/gs1-supply-chain/**/*.yaml', recursive=True):
    with open(f) as fp:
        yaml.safe_load(fp)
    print(f'  VALID: {f}')
print('All files valid.')
"
```

---

## Notes for reviewers

1. The `product_classification_taxonomy` dataset mirrors the GPC (Global Product Classification) **structure** but contains no actual GPC codes or names — those remain GS1 IP
2. The `supply_chain_event` dataset follows the publicly available EPCIS 2.0 ISO standard (ISO/IEC 19987)
3. All metric patterns are generic and framework-agnostic — they can be implemented on any data platform (Snowflake DMFs, dbt tests, Great Expectations, etc.)
4. The `data_quality_tier` dimension uses generic percentage ranges, not GS1-specific SLA thresholds
