---
title: Data Submission Guide
permalink: /docs/data-submission-guide/
---

# Data Submission Guide

??? info "**Version 2.0.3** (updated 2026-10-06)"
    
    - Removed the jurisdiction geography CSV example as part of the transition to a single jurisdiction metadata file in YAML format

    (Version 2.0.2)
    - Updated repository/site references and links to use the DataStandards GitHub Pages path and repository name
    - Renamed `USDiseaseTracker-Docs` references to US Disease Tracker Data Standards throughout the documentation

    (Version 2.0.1)
    - Changed outcomes for Influenza-Associated Pediatric Mortality to "cases" (from "deaths")
    - Changed Perinatal Hepatitis B to require age groups (only one age group: "<2 y"), to maintain validation and system consistency
    
    - Added guidance for the expanded disease set now supported by the reporting standards.
    - Updated aggregation expectations for newly supported diseases and their applicable dimensions.
    - Aligned submission guidance with current metadata and validation references.

---


This guide provides detailed specifications for health departments participating in the US Disease Tracker project to contribute reportable disease count data. To date, this project is seeking data only from jurisdictions already sending case notification data through NNDSS.

## Overview

1. [Reportable Data Specifications](#reportable-data-specifications)
2. [Data Elements](#data-elements)
3. [Data Suppression](#data-suppression)
4. [Data Format](#data-format)
5. [Metadata Requirements](#metadata-requirements)
6. [Validation](#validation)

<br>

## Reportable Data Specifications

<br>

### Time Period

**Start Date:** December 29, 2024 (start of MMWR week 1, 2025)  
**End Date:** Through present

<br>

### Time Aggregation

| Disease | Weekly |
|---------|--------|
| Measles | ✓ |
| Pertussis | ✓ |
| Invasive Meningococcal Disease | ✓ |
| Hepatitis A | ✓ |
| Acute Hepatitis B | ✓ |
| Perinatal Hepatitis B | ✓ |
| Mumps | ✓ |
| Mpox | ✓ |
| Varicella | ✓ |
| Influenza-Associated Pediatric Mortality | ✓ |

<br>

### Confirmation Status

*Required confirmation status by disease:*

| Disease | Confirmation Status |
|---------|---------------------|
| Measles | Confirmed only |
| Pertussis | Confirmed and probable combined |
| Invasive Meningococcal Disease | Confirmed and probable combined |
| Hepatitis A | Confirmed only |
| Acute Hepatitis B | Confirmed and probable combined |
| Perinatal Hepatitis B | Confirmed only |
| Mumps | Confirmed and probable combined |
| Mpox | Confirmed and probable combined |
| Varicella | Confirmed and probable combined |
| Influenza-Associated Pediatric Mortality | Confirmed only |

<br>


### Required Data Stratifications

Disease counts for different breakdowns are collected separately (e.g., age, sub-jurisdiction, disease subtype, etc.). We call these versions of the data the "data stratifications". Each data stratification should provide complete data from December 29, 2024 through the present, with each having equivalent total counts over time (e.g., cumulative measles cases in the age group stratification must equal cumulative measles cases in the sub-jurisdiction stratification). For each stratification, the counts by time period (i.e., week, cumulative) should sum to the equivalent time period for the full jurisdication (e.g., the sum of county-level cases of measles for state Y should equal the number of total cases in state Y for all time points); data suppression should not result in underreporting through use of "unspecified" strata (see [Data Suppression](#data-suppression)). See [Case Classification by Time](#case-classification-by-time) below for details on assignment of cases to time periods. Only the data stratifications listed below will be accepted; new stratifications will be added as needed for new demographics, diseases, conditions or outcomes, etc.

!!! info "Important"
    
    All stratifications must sum to the same count (by time period and total). This sum should be equivalent to the jurisdication-level count for that time period. Do not drop counts in reporting. Follow [Data Suppression](#data-suppression) instructions to ensure complete reporting.

<br>

#### Data Stratifications:

    Measles
    - Cases × week × sub-jurisdiction unit (county, planning area, sub-state region, etc.)
    - Cases × week × age group × jurisdiction (state, DC, NYC, or territory)

    Pertussis
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction 

    Invasive Meningococcal Disease
    - Cases × week × sub-jurisdiction unit 
    - Cases × week × age group × jurisdiction 
    - Cases × week × serogroup × jurisdiction

    Hepatitis A
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Acute Hepatitis B
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Perinatal Hepatitis B
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Mumps
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Mpox
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Varicella
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

    Influenza-Associated Pediatric Mortality
    - Cases × week × sub-jurisdiction unit
    - Cases × week × age group × jurisdiction

<br>

!!! info "Note: Sub-jurisdiction or age group counts"
    
    For conditions where stratified counts by sub-jurisdiction or age group are not feasible due to small numbers or other reasons, jurisdiction-level (e.g., state-level) reporting can be accomplished by using the "unspecified" value for `geo_name` or `age_group`. See [Data Technical Specifications](data-technical-specs.md) for details.

<br>


### Reporting Frequency

Data should be reported **weekly** by Thursday during non-emergency periods. Data can also be uploaded on any other day, but will not be updated on USDT until the next Friday. For each data submission, complete data for all diseases should be included, even if there are no updates.

*Note: During large outbreaks or public health emergencies, more frequent updates may be requested to improve situational awareness.*

<br>

### Case Classification by Time

Cases should be classified in time according to a hierarchical date algorithm. 

!!! tip "**Recommended:** Use the **Calculated Case Counting Date (CCCD)**" 

    See [CSTE Data Standardization Guidelines](https://cdn.ymaws.com/www.cste.org/resource/resmgr/2015weston/DSWG_BestPracticeGuidelines_.pdf) for details.

   The CCCD employs a hierarchy and assigns the case to the earliest of:

      1. Symptom onset date
      2. Clinical diagnosis date
      3. Earliest specimen collection date associated with a positive lab result
      4. Earliest result date for a positive lab result
      5. Date first received by a public health agency
      6. Date entered/record initiated

**Alternative:** If CCCD is not implemented, use a similar hierarchical algorithm or an existing case classification date such as Event Date in your system.

**Required:** Provide metadata on the algorithm used by your jurisdiction.

<br>

### Time Period Assignment

- **Weekly counts:** Classify by MMWR week (see [MMWR week table](https://ndc.services.cdc.gov/wp-content/uploads/MMWR-Week-Log-2025-2026.pdf))

<br>


### Geographic Assignment

Cases should be included in aggregated counts according to their **place of residence**, in accordance with standard epidemiologic practice in the US (see [CSTE Position Statement 11-SI-04](https://learn.cste.org/images/dH42Qhmof6nEbdvwIIL6F4zvNjU1NzA0MjAxMTUy/Course_Content/Case_based_Surveillance_for_Syphilis/CSTE_Revised_Guidelines_for_Determining_Residency_for_Disease_Reporting_Purposes.pdf)).

#### Sub-jurisdiction Reporting

Sub-jurisdiction level reporting (below state, territory, or city level) is optimal to maximize usefulness for preparedness and response.

- County-level reporing is preferred, but alternate aggregations (region, HSA, etc.) are acceptable.
- Each jurisdiction should decide the geographic unit to use and provide a list of geographic units as metadata

<br>
<br>

### Age Groups

Age groups are defined to be relevant to both disease epidemiology and vaccine schedules. The same age groupings are used for all diseases\* to simplify visualizations.

| Age Group | Description |
|-----------|-------------|
| <1 y | From birth up to but not including 1 year birthday |
| 1-4 y | From 1 year birthday up to but not including 5 year birthday |
| 5-11 y | From 5 year birthday up to but not including 12 year birthday |
| 12-18 y | From 12 year birthday up to but not including 19 year birthday |
| 19-22 y | From 19 year birthday up to but not including 23 year birthday |
| 23-44 y | From 23 year birthday up to but not including 45 year birthday |
| 45-64 y | From 45 year birthday up to but not including 65 year birthday |
| >=65 y | From 65 year birthday and older |
| total | Total counts, all ages |
| unknown | Counts of individuals with unknown age |
| unspecified | Aggregated counts of individuals from age groups being suppressed |

*Age groupings differ for Perinatal Hepatitis B, which only uses <2 y

!!! info "Important"
    
    Age groups will only be shared and displayed at the jurisdiction level, not at sub-jurisdiction level, unless otherwise agreed to by individual jurisdictions.

<br>
<br>


## Data Elements

For complete field definitions, data types, valid values, and detailed validation rules, see the [Data Technical Specifications](data-technical-specs.md).

### Summary of Required Fields

All data submissions must include the following types of information:

- **Time fields:** When the cases occurred (report period dates and time unit)
- **Disease fields:** What disease is being reported, case confirmation status, and outcome
- **Geographic fields:** Where the cases occurred (jurisdiction and geographic unit)
- **Count field:** Number of cases for this combination
- **Demographic fields:** Age group (for age-stratified aggregations)

### Summary of Optional Fields

- **disease_subtype:** For meningococcal serogroup reporting.

For detailed specifications of each field including exact field names, data types, and valid value sets, see the [Data Technical Specifications](data-technical-specs.md).

<br>
<br>


## International Residents

International residents (residents of countries outside the US but who had a case identified in that jurisdiction) can be included in reported data. These counts will be excluded from displayed totals and epidemic curves for stratifications and jurisdiction totals. To ensure they are included correctly:

- Designate as "international resident" using:
  * `geo_name = "international resident"`
  * `geo_unit = "NA"`

<br>
<br>


## Data Lags and Incompleteness

- Jurisdictions should share all cases as soon as they are adjudicated as confirmed or probable, and are ready for public release
- The project team recognizes that data from recent weeks is likely to be incomplete but encourages as timely submission of data as possible
- The project team will **not** censor data reported by jurisdictions will display data as they are reported
- The project team will clearly indicate provisional data according to jurisdiction guidance through:
    - Dashed lines on epidemic curves
    - Asterisks and notes detailing data completeness limitations

<br>
<br>

## Data Suppression

### Small Count Suppression

Jurisdictions should use their existing policies regarding suppression of small numerators or where underlying populations are small enough to risk reidentification. All <u>data should have suppression applied by the jurisdiction prior to submission</u>, in accordance with their institutional policies. To ensure clear understanding of the data and transparency, jurisdictions should share applicable documentation of small count suppression policies with the project team if possible.

<br>

### Handling Suppressed Data

To ensure total counts add to 100% of cases:

1. All cases that cannot be assigned to specific values (i.e., counties, age groups) should be aggregated in an "unspecified" category for that variable.
2. All other non-suppressed cases should be assigned to their appropriate values.   
3. Allocation of suppression rules and "unspecified" aggregation must be performed prior to data transfer/submission.
4. Suppression rules should be shared with the project team for accurate description/footnoting.

!!! example "Example"

    A jurisdiction with a suppression rule that requires suppression of any count <5, records 31 total cases of measles during a week. County A has 1 case, County B has 3 cases, County C and D have 12 and 15 cases, respectively. For the `county-level` aggregation of these counts, these should be reported as:
   
    1. Include a row for each `geo_name = "County C"` and `geo_name = "County D"` with `count = 12` and `count = 15`.
    2. Include a row with `geo_name = "unspecified"` and a value in `count` that sums all suppressed county counts for this week. In this case `count = 4`.
    3. **Do not** include a row for `geo_name = "County A"` or `geo_name = "County B"`. 

<br>

### Measles Exception

For measles, the project team recommends **not suppressing data** as a default and releasing any cases that have already been publicly released. This is to ensure comparability with counts being produced through various "web-scraping" efforts that exist, which often capture cases reported individually through press releases. Individual requests to suppress data can be discussed with the project team.
<br>
<br>

## Data Format

### No Zero Reporting

- Report only non-zero counts (i.e., do not include rows in data where the count equals 0)
- For example, if an age group had no reported outcome during a timeframe, no entry is required (e.g., if age group >= 65 has 0 cases of measles for that week for a state, do *not* include a row with `count = 0` for `age_group = ">=65"`)
- If a jurisdiction had no reported counts of any disease or outcome during a timeframe, they should still submit the data, even if it has no new additional rows since the prior week's submission. This will enable us to limit missingness and uncertainty in the data.
- The database system will automatically add 0s at higher spatial aggregations
<br>

### File Format

Data should be submitted in CSV format following the standard template structure. 

**Template and Example Files:**

- [Data submission template](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_{jurisdiction}_{report_date}.csv) - Empty template with correct field structure
- [Example data file](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv) - Sample data demonstrating proper format

**File Submission Requirements:**

- Submit a file with all incident disease counts since December 29, 2024
- Each submission should include all updates to current and prior data, with new rows for new time periods
- Files will be date-stamped by the system for version control
- Changes to prior observation counts will be taken as revisions

**File Naming:** Jurisdictions should name files following the pattern:
```
disease_tracking_report_{jurisdiction}_{report_date}.csv
```
Example: `disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv`

See the [Data Transfer Guide](data-transfer-guide.md) for technical details on data submission methods and the [Data Technical Specifications](data-technical-specs.md) for complete field requirements.

<br>
<br>


## Metadata Requirements

Jurisdictions should provide accompanying metadata using the [Jurisdiction Reporting Metadata Template](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease-tracking-metadata-{jurisdiction}.yaml). For specifics on metadata, see [Data Technical Specifications](data-technical-specs.md). Metadata required includes:

- Algorithm used to classify cases in time (e.g., CCCD or alternative)
- List of substate geographic units used by jurisdiction
- Data suppression policies and rules
- Any jurisdiction-specific notes or caveats

<br>
<br>


## Validation

All submitted data must meet validation requirements to ensure data quality and consistency.

**What is validated:**

- Field formats and data types
- Values are within acceptable ranges and valid value sets
- Logical consistency across fields
- Required fields are present

**Resources:**

- [Data Technical Specifications](data-technical-specs.md) - Complete field definitions and valid value sets
- [Data dictionary (CSV)](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_data_dictionary.csv) - Reference table of all fields and valid values
- [Validation Rules](validation.md) - Comprehensive validation requirements
  
Values submitted must align with valid value sets. Values not in alignment may result in validation errors. The [Data Transfer Guide](data-transfer-guide.md) describes what happens when validation succeeds or fails.

<br>

## Questions

For questions about data submission requirements, contact the project team.
