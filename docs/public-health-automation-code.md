# Public Health Automation Code

This section contains the R automation script used to clean and transform disease-tracking data for USDT reporting workflows.

## Script

- [`usdt_file_cleaning.R`](../public-health-automation/USDT_File_cleaning.R)

## What it does

- Prompts for input and metadata files
- Maps source columns to USDT fields
- Standardizes dates and derives MMWR report periods
- Aggregates measles, pertussis, and meningococcus outputs
- Applies suppression rules and writes the final CSV file

## Notes

- Run this script in an R environment with the required packages installed.
- Use the metadata workbook expected by the script (`Variables`, `disease_name`, `Suppression`, `default` sheets).
