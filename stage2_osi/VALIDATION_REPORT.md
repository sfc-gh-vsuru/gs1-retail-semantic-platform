# OSI Validation Report
# Generated: 2026-08-05
# Spec Version: Apache Ossie 0.1 (Incubating)

## Validation Summary

| Check | Status | Details |
|-------|--------|---------|
| YAML syntax valid | PASS | All 5 YAML files parse without errors |
| osi_version field present | PASS | All files declare `osi_version: "0.1"` |
| type field present | PASS | dataset (3), metrics (1), dimensions (1), relationships (1) |
| dataset.name unique | PASS | product_classification_taxonomy, identifier_verification_lookups, supply_chain_event |
| columns have role field | PASS | All columns declare role (primary_key, dimension, measure, time_dimension, foreign_key, flag) |
| metrics have category | PASS | 10 metrics across 5 categories (timeliness, completeness, uniqueness, volume, distribution, stability) |
| dimensions have type | PASS | 7 dimensions across 3 types (hierarchical, temporal, categorical) |
| relationships reference valid datasets | PASS | All left/right datasets exist in package |
| No proprietary data values | PASS | No GTINs, GLNs, GCPs, member names, or thresholds in output |
| No PII | PASS | No email, phone, address, or contact data |
| Apache 2.0 license header | PASS | All files include license comment |

## Sanitisation Checks

| Rule | Status | Details |
|------|--------|---------|
| No actual GS1 identifier values (GTIN/GLN/SSCC) | PASS | Only structural patterns exported |
| No member company names | PASS | No "NovaBrand" or "FreshMart" in OSI output |
| No proprietary business rules or formulas | PASS | Metrics describe patterns, not implementations |
| No specific threshold values from GS1 SLAs | PASS | Quality tiers use generic ranges only |
| GPC taxonomy structure only (no brick codes) | PASS | Column schema exported, not actual classification data |
| EPCIS event schema is public ISO standard | PASS | Structure based on published EPCIS 2.0 spec |

## Files Validated

```
stage2_osi/
├── datasets/
│   ├── product_classification_taxonomy.yaml   ✓ VALID
│   ├── identifier_verification_lookups.yaml   ✓ VALID
│   └── supply_chain_event.yaml                ✓ VALID
├── metrics/
│   └── data_quality_metrics.yaml              ✓ VALID
├── dimensions/
│   └── supply_chain_dimensions.yaml           ✓ VALID
└── relationships/
    └── product_location_event.yaml            ✓ VALID
```

## Result: APPROVED FOR SUBMISSION

All checks passed. Package is safe to submit as a PR to the Apache Ossie repository.
