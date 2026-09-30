# Example and Template Data Files

This directory contains example data files, templates, and guidance documents to help jurisdictions prepare and submit compliant USDT data files. These resources can be used to understand reporting requirements, review expected file structures, and create files for data submission.

## Jurisdiction Reporting Metadata Template
Before preparing USDT data files, jursidictions **must** complete the metadata template. The file provides information about reporting practices, geographic structures, suppression policies, and points of contact that are necessary for interpreting and validating submitted data.
An updated metadata file should be submitted each time there is a change in the jurisdictions’ data submission.

### Available Templates
Template for jurisdictions to provide required metadata about their data submission:
[disease-tracking-metadata-{jurisdiction}.yaml](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease-tracking-metadata-%7Bjurisdiction%7D.yaml)
### Supporting Guidance
The [metadata guidance](Metadata_Guidance_Final_20260901.pdf) provides detailed instructions for completing the jurisdiction reporting metadata YAML file used by USDT. It explains:
- How to document reporting practices and frequency
- Diseases to include
- Geographic reporting structures
- Data suppression and data lag policies
- Jurisdictional contact information

**File naming convention:**
When using this template, rename the file following the pattern:
```
disease-tracking-metadata-{jurisdiction}.yaml
```
Replace `{jurisdiction}` with your jurisdiction's two-letter abbreviation (e.g., `disease-tracking-metadata-WA.yaml`).

### Recommended Steps
1. Download [disease-tracking-metadata-{jurisdiction}.yaml](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease-tracking-metadata-%7Bjurisdiction%7D.yaml).
2. Complete all required fields with your jurisdiction's information following the [metadata guidance](Metadata_Guidance_Final_20260901.pdf).
3. Rename the file with your jurisdiction abbreviation.
4. Coordinate submission of the completed metadata file with your USDT onboarding coordinator.

## Disease Tracking Report
Example files are provided to demonstrate the required format and structure of compliant disease tracking reports.
### Available Templates
This template file includes all required headers with correct field structure for data submission.
- [`disease_tracking_report_{jurisdiction}_{report_date}.csv`](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/(state)_jurisdictions-EXAMPLE.csv)
### Supporting Guidance And Report Examples
The [annotated guidance](USDT_Annotated_Guidance_20260918.pdf) is a comprehensive onboarding and reference resource that walks jurisdictions through the USDT reporting process. It includes explanations, examples, and visual illustrations to help users understand reporting requirements, metadata configuration, data submission standards, and other key concepts needed to successfully participate in USDT.

**Disease Tracking Report Example**

The following are examples that can be used to understand the structure of compliant data and train users on data standards. They include multiple disease entries, different stratifications, age group and suppressed data handling.
- [`disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv`](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv) - Example data file with simulated measles and pertussis data from California state, demonstrating proper format and structure
- [`disease_tracking_report_WA-SIMULATED-EXAMPLE_2026-02-09.csv`](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_WA-SIMULATED-EXAMPLE_2026-02-09.csv) - Example data file with simulated measles and pertussis data from Washington state, demonstrating proper format and structure

**File naming convention:**

When using this template, rename the file following the pattern:
```
disease_tracking_report_{jurisdiction}_{report_date}.csv
```
Replace `{jurisdiction}` with your jurisdiction's two-letter abbreviation and put the `{report_date}` in YYYY-MM-DD format (e.g., disease_tracking_report_WA_2026-02-09.csv).

### Recommended Steps
1. Download the template file: [`disease_tracking_report_{jurisdiction}_{report_date}.csv`](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/(state)_jurisdictions-EXAMPLE.csv).
2. Fill in your jurisdiction's data following the field specifications.
3. Rename the file using the naming convention above.
4. Submit the file using one of the transfer methods described in the [Data Transfer Guide](../guides/data-transfer-guide.md).

## Related Files

- [Data Submission Guide](../guides/data-submission-guide.md) - High-level guidance on what and when to submit
- [Data Technical Specifications](../guides/data-technical-specs.md) - Complete field definitions and requirements
- [Data dictionary (CSV)](disease_tracking_data_dictionary.csv) - Reference table of all fields and valid values
- [MMWR Week Crosswalk](MMWR_week_to_month_crosswalk.csv) -Reference table for mapping MMWR weeks
