---
title: Validation
permalink: /docs/validation/
---

# Validation

??? info "**Version 2.0.3** (updated 2026-10-06)"

    - Removed the jurisdiction geography CSV example as part of the transition to a single jurisdiction metadata file in YAML format

    (Version 2.0.2)
    - Updated repository/site references and links to use the DataStandards GitHub Pages path and repository name
    - Renamed `USDiseaseTracker-Docs` references to US Disease Tracker Data Standards throughout the documentation

    (Version 2.0.1)
    - Changed outcomes for Influenza-Associated Pediatric Mortality to "cases" (from "deaths")
    - Changed Perinatal Hepatitis B to require age groups (only one age group: "<2 y"), to maintain validation and system consistency
    
    - Updated validation references to reflect the current supported disease set.
    - Clarified disease-specific cross-field expectations for `confirmation_status` and `disease_subtype`.
    - Aligned validation guidance language with current standards and templates.


---

The validation process checks:

- File format and structure
- Required field presence
- Data type compliance
- Valid value adherence
- Logical consistency
- Cross-field rules

Validation errors will be reported back to submitters with specific error descriptions.

<br>

## Validation Rules

### Format Validation

- File must be valid CSV format
- Required fields must be present in all rows
- Field names must match specification exactly (case-sensitive)
- No extra columns are permitted beyond the defined field set
- Each submitted file must contain data for a single reporting jurisdiction (state) only

### Data Type Validation

- Dates must be in YYYY-MM-DD format
- Counts must be positive integers (strictly greater than zero)
- String fields must use exact valid values (case-sensitive)

### Field Value Validation

- `disease_name` must be one of the supported disease values: `measles`, `pertussis`, `meningococcus`, `hepatitis a`, `acute hepatitis b`, `perinatal hepatitis b`, `mumps`, `mpox`, `varicella`, `pediatric flu mortality`
- `time_unit` must be `week`
- `date_type` must be `cccd` or `jurisdiction date hierarchy`
- `geo_unit` must be one of: `county`, `state`, `region`, `planning area`, `hsa`, `NA`
- `outcome` must be one of: `cases`
- `confirmation_status` must be `confirmed` or `confirmed and probable`
- `age_group` must be one of the recognized age group values (see [Valid Age Groups by Condition](data-technical-specs.md#demographic-fields))
- `disease_subtype` must be a valid value for the submitted `disease_name` (see [Valid Subtypes by Condition](data-technical-specs.md#disease-specific-fields))

### Logical Validation

- `report_period_end` must be after `report_period_start`
- Date ranges must align with MMWR week boundaries (`report_period_start` must be a Sunday; `report_period_end` must be a Saturday)
- `reporting_jurisdiction` must match either `state` or `geo_name` in each row
  - For `geo_name = "international resident"` rows, `reporting_jurisdiction` must match `state`

### Geographic Validation

- `geo_name` must equal `state` when `geo_unit` is `state`
- `geo_unit` must be `NA` when `geo_name` is `international resident`; conversely, `geo_unit = "NA"` is only valid when `geo_name` is `international resident`
- For jurisdictions with registered sub-state geographic units, `geo_name` must be one of the recognized sub-state jurisdiction names for the given `state`

### Cross-Field Validation

#### Confirmation Status
- `measles`, `hepatitis a`, `perinatal hepatitis b`, and `pediatric flu mortality`: `confirmation_status` must be `confirmed`
- `pertussis`, `meningococcus`, `acute hepatitis b`, `mumps`, `mpox`, and `varicella`: `confirmation_status` must be `confirmed and probable`

#### Age Group and Disease Subtype Breakdown Rules
- **Sub-state level** (`geo_unit` ≠ `state`): both `age_group` and `disease_subtype` must be `total`
- **Perinatal hepatitis b** (age group stratification): `age_group` must always be `<2 y`
- **All diseases in age stratifications** at state level: `age_group` must **not** be `total`
- **Meningococcus** at state level: exactly one of `age_group` or `disease_subtype` must be `total` (age breakdown rows use `disease_subtype = "total"`; subtype breakdown rows use `age_group = "total"`)

#### Disease-Specific Age Group Values
- Most diseases accept the full age group set (`<1 y`, `1-4 y`, `5-11 y`, `12-18 y`, `19-22 y`, `23-44 y`, `45-64 y`, `>=65 y`, `total`, `unknown`, `unspecified`)
- `pediatric flu mortality` only accepts: `<1 y`, `1-4 y`, `5-11 y`, `12-18 y`, `total`, `unknown`, `unspecified`
- `perinatal hepatitis b` only accepts: `<2 y`, `total`

### Count Totals Validation

For each combination of `(report_period_start, report_period_end, disease_name, outcome)`:

- **Diseases with subtype breakdown** (`meningococcus`): the sum of state-level age breakdown rows (`disease_subtype = "total"`) must equal the sum of state-level subtype breakdown rows (`age_group = "total"`), and both must equal the sum of sub-state rows
- **All other diseases**: the sum of state-level rows must equal the sum of sub-state rows
- International resident rows (`geo_name = "international resident"`) are excluded from all count total checks
