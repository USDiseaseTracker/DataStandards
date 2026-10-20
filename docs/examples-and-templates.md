# Examples & Templates

This section provides templates, examples, guidance documents and reference materials to help jurisdictions prepare and submit USDT data files.

## How to Use These Resources

The resources on this page are provided to help users prepare and submit a valid USDT data file.
-	Review the Annotated Guidance to understand USDT reporting requirements and the submission process.
-	Download the Disease Tracking Report template and example data files to understand the required data structure and format.
-	Complete the Jurisdiction Reporting Metadata Template with your jurisdiction’s information, including geographic units.
-	Utilize additional resources to ensure data matches the appropriate USDT format.
-	Validate either by uploading a file to check for errors or using the Schema Files.

## Disease Tracking Report

The standard template file includes all required headers with correct field structure for submitting disease tracking data:

**📄 [disease_tracking_report_{jurisdiction}_{report_date}.csv](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_{jurisdiction}_{report_date}.csv)**

### Annotated Guidance

The annotated guidance is a comprehensive onboarding and reference resource that walks jurisdictions through the USDT reporting process. It includes explanations, examples, and visual illustrations to help users understand reporting requirements, metadata configuration, data submission standards, and other key concepts needed to successfully participate in USDT. 

### Example Disease Tracking Reports

The following are examples that can be used to understand the structure of compliant data and train users on data standards.

- Proper formatting for each field
- Multiple disease entries
- Different stratification levels
- Age group and demographic data
- Suppressed data handling

**📄 [disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv)**

**📄 [disease_tracking_report_WA-SIMULATED-EXAMPLE_2026-02-09.csv](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_WA-SIMULATED-EXAMPLE_2026-02-09.csv)**

Note: These data were generated from available data at the state-level from NNDSS, with age and county counts simulated using population size to define probability sampling.

## Jurisdiction Reporting Metadata Template

Before submission of USDT data files, jurisdictions must complete the metadata template. The file provides information on reporting practices, geographic structures, suppression policies, and points of contact that are necessary for interpreting and validating submitted data.
Updated metadata files should be submitted each time there is a change in the jurisdiction’s data submission.
The template for submitting required metadata about your jurisdiction's data:

**📄 [disease-tracking-metadata-{jurisdiction}.yaml](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease-tracking-metadata-{jurisdiction}.yaml)**

This template includes:

- Date classification method (CCCD or custom hierarchy)
- Geographic units and their relationships
- Data suppression policies and rules
- Contact information for technical and data quality questions

When using this template, rename it with your jurisdiction's two-letter abbreviation (e.g., `disease-tracking-metadata-WA.yaml`).

### Supporting Guidance

The metadata guidance provides detailed instructions for completing the jurisdiction reporting metadata YAML file used by USDT. It explains how to:
-	Document reporting practices and frequency
-	Detail which diseases are included in your data file
-	Define your geographic reporting structures
-	Describe your data suppression and data lag policies
-	Designate jurisdictional contacts

## Schema Files

A schema is used to define the structure of a valid, correctly formatted file by stating certain characteristics of the data elements within it. Use of a schema can help identify data formatting issues that need to be addressed prior to submission.

### YAML Schema

The formal YAML schema defining the data structure:

**📄 [data_reporting_schema.yaml](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/data_reporting_schema.yaml)**

Use this schema for:

- Automated validation
- Integration with validation tools
- Understanding field relationships
- Building your own tools

### Python Schema

The Python Pydantic schema used for validation:

**📄 [data_reporting_schema.py](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/data_reporting_schema.py)**

This schema includes:

- Field definitions with types
- Validation logic
- Custom validators
- Helper functions

## Reference Materials

### Data Dictionary

The comprehensive data dictionary defines all fields and their valid values:

**📄 [disease_tracking_data_dictionary.csv](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_data_dictionary.csv)**

The data dictionary includes:

- Field names and descriptions
- Data types and formats
- Valid values for each field
- Required vs. optional fields
- Validation rules


### MMWR Week Crosswalk

A reference table mapping MMWR weeks to calendar months:

**📄 [MMWR_week_to_month_crosswalk.csv](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/MMWR_week_to_month_crosswalk.csv)**

This crosswalk helps you:

- Convert between MMWR weeks and calendar dates
- Understand week boundaries (Sunday to Saturday)
- Plan your reporting schedule


## Related Guides

- [Data Technical Specifications](guides/data-technical-specs.md) - Detailed field requirements
- [Data Submission Guide](guides/data-submission-guide.md) - Submission process
- [Validation Rules](guides/validation.md) - Validation requirements
- [Data Standards Tool](data-standards-tool.md) - Interactive tool

---
