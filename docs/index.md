# US Disease Tracker Data Standards

Welcome to the US Disease Tracker Data Standards site. This repository houses the data standards, templates, examples, and validation documentation for the US Disease Tracker project.

??? info "Version 2.0.3 (updated 2026-10-06)"
    
    - Removed the jurisdiction geography CSV example as part of the transition to a single jurisdiction metadata file in YAML format

    (Changed in Version 2.0.2)
    - Updated repository/site references and links to use the DataStandards GitHub Pages path and repository name
    - Renamed `USDiseaseTracker-Docs` references to US Disease Tracker Data Standards throughout the documentation

    (Version 2.0.1)
    - Changed outcomes for Influenza-Associated Pediatric Mortality to "cases" (from "deaths")
    - Changed Perinatal Hepatitis B to require age groups (only one age group: "<2 y"), to maintain validation and system consistency

    (Version 2.0.0)
    - Added 7 new diseases: hepatitis A, acute hepatitis B, perinatal hepatitis B, mumps, mpox, varicella, and influenza-associated pediatric mortality
    - Added `disease_metadata.csv` in `examples-and-templates` with condition-specific metadata details


---

## About The US Disease Tracker

The goal of the US Disease Tracker is to provide consolidated epidemiologically sound data, analytics, and insights for monitoring and responding to disease threats across the United States. This project aims to produce data that are as standardized as possible, while recognizing individual variations in how and when data are collected and made available to participating health departments.

Data are reported by jurisdictions to USDT <u>weekly on Thursdays</u>, with <u>new data published on Fridays</u>.

**Note**: USDT data are now publicly available at [usdiseasetracker.org](https://usdiseasetracker.org). This data standards documentation is hosted separately at [usdiseasetracker.github.io/DataStandards](https://usdiseasetracker.github.io/DataStandards/).


---

Our **Key Principles** are:

1. Provision of data is voluntary.
2. Only aggregate data will be collected to minimize the risk of reidentification.
3. Data are be updated and back-populated on a regular basis, acknowledging that recent data may be incomplete as investigations proceed. Records of prior versions will be maintained.
4. We do not suppress or manipulate data once received; jurisdictions should submit data in manner in accordance with heir data release policies.

<br>

---

## Quick Reference

!!! tip "Interactive Tool!"

    **[USDT Data Standards Tool](data-standards-tool.md)** - Interactive tool to explore valid data field options and generate example data


### 🦠 Current Diseases Collected

| Disease | [Time Aggregation](guides/data-submission-guide.md#time-aggregation) | [Confirmation Status](guides/data-submission-guide.md#confirmation-status) | [Outcomes](guides/data-technical-specs.md#disease-fields) | [Age groups](guides/data-technical-specs.md#valid-age-groups-by-condition) | [Disease Subtypes](guides/data-technical-specs.md#disease-specific-fields) |
|---------|------------------|---------------------|----------|------------|------------------|
| Measles | Weekly | Confirmed only | Cases | *multiple* | *not collected* |
| Pertussis | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *not collected* |
| Invasive Meningococcal Disease | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *collected* |
| Hepatitis A | Weekly | Confirmed only | Cases | *multiple* | *not collected* |
| Acute Hepatitis B | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *not collected* |
| Perinatal Hepatitis B | Weekly | Confirmed only | Cases | *not collected* | *not collected* |
| Mumps | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *not collected* |
| Mpox | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *not collected* |
| Varicella | Weekly | Confirmed and probable (combined) | Cases | *multiple* | *not collected* |
| Influenza-Associated Pediatric Mortality | Weekly | Confirmed only | Deaths | *multiple* | *not collected* |
*Click column name to go to more detailed documentation on each field.*


### 📚 Guides and Specifications

1. **[Data Submission Guide](guides/data-submission-guide.md)** - High-level overview of what and when to submit
2. **[Data Technical Specifications](guides/data-technical-specs.md)** - Detailed field specifications and requirements
3. **[Data Transfer Guide](guides/data-transfer-guide.md)** - Technical transfer methods
4. **[Validation Rules](guides/validation.md)** - Data validation requirements

### 📄 Templates and Examples
- [Data submission template](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_{jurisdiction}_{report_date}.csv)
- [Example data file](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv)
- [Data dictionary (CSV)](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_data_dictionary.csv) - Reference table of all fields and valid values
---

## Data Validation

Data are validated upon submission for completeness, format, and errors. See the [Validation Rules](guides/validation.md) for detailed validation requirements. Data can be submitted to the dashboard at any time to check the validation.

To check what combinations of values are valid, check out the [USDT Data Standards Tool](https://usdiseasetracker.github.io/DataStandards/data-standards-tool/).


---

## The US Disease Tracker Data Standards Repository
This repository houses the data standards, templates, examples, and validation documentation for the US Disease Tracker. It provides a centralized location for standardized formats and guidelines for disease surveillance data. The goal of this repository is to establish the processes, standards, and data formats that will enable construction of a consolidated database and dashboard to track infectious diseases across the US in real-time. 

While we aim to limit changes once data standards and processes are established, they may change intermittently as this project evolves, including adding new diseases, modifying data elements, and adding features. All changes will be reflected and described here.
<br>

This repository is organized as follows:

- **`guides/`** - Documentation guides (data-submission-guide.md, data-technical-specs.md, etc.)
- **`examples-and-templates/`** - Data templates, examples, and the data dictionary
- **`data_standards_tool/`** - Interactive data standards tool
- **`scripts/`** - Validation scripts and schema generators
- **`docs/`** - MkDocs documentation source files (website content)

<br>
<br>


---

## Contributing

We welcome contributions to the data standards! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed instructions.

---

## License

This project is licensed under the GNU General Public License v3.0 or later. See [LICENSE](https://github.com/USDiseaseTracker/DataStandards/blob/main/LICENSE) for details.
