# Data Standards Tool

This interactive reference helps you understand the data standards and validation rules for US Disease Tracker data submissions.

!!! info "About This Tool"
    This tool provides comprehensive information about:
    
    - Valid options for each data field
    - Field descriptions and requirements
    - Validation rules and constraints
    - Disease-specific requirements

## Disease-Specific Requirements

### Measles

- **Time Unit**: `week`
- **Valid Subtypes**: `total`
- **Confirmation Status**: `confirmed` only

### Pertussis

- **Time Unit**: `week`
- **Valid Subtypes**: `total`
- **Confirmation Status**: `confirmed and probable`

### Meningococcus

- **Time Unit**: `week`
- **Valid Subtypes**: `A`, `B`, `C`, `W`, `X`, `Y`, `Z`, `unknown`, `unspecified`, `total`
- **Confirmation Status**: `confirmed and probable`

## Field Reference

The following fields are required in all data submissions:

### `report_period_start` **(required)**

**Description**: Date of report period start (YYYY-MM-DD)

**Type**: string (date)

### `report_period_end` **(required)**

**Description**: Date of report period end (YYYY-MM-DD)

**Type**: string (date)

### `date_type` **(required)**

**Description**: Calculated Case Counting Date (cccd) or jurisdiction-defined date hierarchy. Details of jurisdiction date hierarchy should be provided in metadata.

**Type**: string

**Valid Values**:

- `cccd`
- `jurisdiction date hierarchy`

### `time_unit` **(required)**

**Description**: Time aggregation unit

**Type**: string

**Valid Values**:

- `week`

### `disease_name` **(required)**

**Description**: Name of the disease

**Type**: string

**Valid Values**:

- `measles`
- `pertussis`
- `meningococcus`

### `disease_subtype` **(required)**

**Description**: Disease subtype (meningococcal serogroup). Use 'total' for non-subtype-stratified aggregations or diseases without subtype reporting (measles, pertussis). Use 'unknown' when subtyping was not performed. Use 'unspecified' when subtype is known but suppressed.

**Type**: string

!!! note "Disease-Specific Subtypes"
    - For **measles** and **pertussis**: Use `total`
    - For **meningococcus**: Use specific serogroup (A, B, C, W, X, Y, Z) or `total`, `unknown`, `unspecified`

### `reporting_jurisdiction` **(required)**

**Description**: Abbreviation for the reporting state, city, or territory

**Type**: string

### `state` **(required)**

**Description**: 2-letter abbreviation for the state of the jurisdiction

**Type**: string

**Valid Values**:

- `AL`
- `AK`
- `AZ`
- `AR`
- `AS`
- `CA`
- `CO`
- `CT`
- `DE`
- `DC`
- `FL`
- `GA`
- `GU`
- `HI`
- `ID`
- `IL`
- `IN`
- `IA`
- `KS`
- `KY`
- `LA`
- `ME`
- `MD`
- `MA`
- `MI`
- `MN`
- `MS`
- `MO`
- `MT`
- `NE`
- `NV`
- `NH`
- `NJ`
- `NM`
- `NY`
- `NC`
- `ND`
- `MP`
- `OH`
- `OK`
- `OR`
- `PA`
- `PR`
- `RI`
- `SC`
- `SD`
- `TN`
- `TX`
- `TT`
- `UT`
- `VT`
- `VA`
- `VI`
- `WA`
- `WV`
- `WI`
- `WY`

### `geo_name` **(required)**

**Description**: Name of the geographic unit

**Type**: string

!!! tip "Special Values"
    - Use `international resident` for non-US residents
    - Use `unspecified` when geographic information is suppressed

### `geo_unit` **(required)**

**Description**: Geographic unit

**Type**: string

**Valid Values**:

- `county`
- `state`
- `region`
- `planning area`
- `hsa`
- `NA`

!!! warning "Geographic Unit NA"
    `NA` should only be used when `geo_name` is `international resident`

### `age_group` **(required)**

**Description**: Standardized age group

**Type**: string

**Valid Values**:

- `<1 y`
- `1-4 y`
- `5-11 y`
- `12-18 y`
- `19-22 y`
- `23-44 y`
- `45-64 y`
- `>=65 y`
- `total`
- `unknown`
- `unspecified`

### `confirmation_status` **(required)**

**Description**: Case classification status

**Type**: string

**Valid Values**:

- `confirmed`
- `confirmed and probable`

### `outcome` **(required)**

**Description**: Reported outcome type

**Type**: string

**Valid Values**:

- `cases`
- `hospitalizations`
- `deaths`

### `count` **(required)**

**Description**: Count of specified outcome for the specified group for this time period

**Type**: integer

**Minimum**: 0

## Validation Rules

The following validation rules apply to all data submissions:

### MMWR Week Validation

When `time_unit` is `week`:

- `report_period_start` **must be a Sunday** (MMWR week start)
- `report_period_end` **must be a Saturday** (MMWR week end)

!!! example "Example MMWR Week"
    - Start: 2026-02-08 (Sunday)
    - End: 2026-02-14 (Saturday)

### Date Range Validation

- `report_period_end` must be on or after `report_period_start`
- Dates should not be unreasonably far in the past or future

### State-Level Totals

When `geo_unit` is `state`:

- **Cannot** have both `age_group = total` AND `disease_subtype = total`
- State totals should be reported with age and/or disease subtype stratifications

!!! warning "State Total Restriction"
    This prevents duplicate reporting of state-level totals. Report state data stratified by at least one dimension (age group or disease subtype).

### International Residents

- When `geo_name` is `international resident`, `geo_unit` **must be** `NA`
- When `geo_unit` is `NA`, `geo_name` **must be** `international resident`

### NA Value Usage

`NA` is **only valid** for the `geo_unit` field. For other fields, use:

- `unknown` - when information is not known
- `unspecified` - when information is known but suppressed

### Jurisdiction Consistency

For standard 2-letter state abbreviations:

- `reporting_jurisdiction` should generally match `state`
- **Exceptions**: NYC, PR, DC, VI, GU, AS, MP, TT (cities and territories)
- For city-level jurisdictions within a state, set `state` appropriately

### Count Field

- Must be a **non-negative integer** (0 or greater)
- Zero counts are allowed and should be reported when applicable

## Related Resources

- [Data Technical Specifications](guides/data-technical-specs.md) - Detailed technical specifications
- [Validation Rules](guides/validation.md) - Complete validation requirements
- [Data Submission Guide](guides/data-submission-guide.md) - How to submit data
- [Data Transfer Guide](guides/data-transfer-guide.md) - Data transfer procedures
- [Examples & Templates](examples-and-templates.md) - Example files and templates

---

!!! info "Schema Version"
    This documentation is generated from `data_reporting_schema.json`.
    For the most up-to-date schema, see [examples-and-templates](examples-and-templates.md).
