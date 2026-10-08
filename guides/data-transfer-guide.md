---
title: Data Transfer Guide
permalink: /docs/data-transfer-guide/
---

# Data Transfer Guide

??? info "**Version 2.0.3** (updated 2026-10-06)"
    
    - Removed the jurisdiction geography CSV example as part of the transition to a single jurisdiction metadata file in YAML format

    (Version 2.0.2)
    - Updated repository/site references and links to use the DataStandards GitHub Pages path and repository name.
    - Renamed `USDiseaseTracker-Docs` references to US Disease Tracker Data Standards throughout the documentation.

    (Version 2.0.1)
    - Changed outcomes for Influenza-Associated Pediatric Mortality to "cases" (from "deaths")
    - Changed Perinatal Hepatitis B to require age groups (only one age group: "<2 y"), to maintain validation and system consistency

    (Version 2.0.0)
    - Added 7 new diseases: hepatitis A, acute hepatitis B, perinatal hepatitis B, mumps, mpox, varicella, and influenza-associated pediatric mortality
    - Added `disease_metadata.csv` in `examples-and-templates` with condition-specific metadata details
    
---

## Overview

This guide describes the technical methods for transferring data from participating jurisdictions to the Johns Hopkins University (JHU) project database.

- [Transfer Frequency](#transfer-frequency)
- [Transfer Methods](#transfer-methods)
- [Pilot Phase Implementation](#pilot-phase-implementation)
- [File Format Specifications](#file-format-specifications)
- [Validation](#validation)
- [Security and Authentication](#security-and-authentication)
- [Troubleshooting](#troubleshooting)
- [Support](#support)
- [Version Control](#version-control)
- [Future Enhancements](#future-enhancements)



## Transfer Frequency

**Recommended:** Weekly

Data should be transferred to the project database on a weekly basis unless an exception has been agreed to by the project team.

### Weekly Transfer Requirements

- Submit a single file with all diseases and cases aggregated by week
- Use the calculated case counting date (or alternative hierarchical date)
- Update file each week with new data and changes to previous aggregate values
- If no updates are available, submit either:
  - A statement: "No data updates for this week"
  - The current file with no changes (to ensure data are not assumed missing)

## Transfer Methods

The project team is working with submitting jurisdictions to provide multiple mechanisms for data transfer. During the pilot, mechanisms matching current capabilities of jurisdictions will be prioritized.

### Option 1: Manual File Upload (Web Portal)

**Best for:** Jurisdictions without automated data export capabilities

#### Process

1. User opens the USDT data upload website in a web browser
2. User logs in with credentials (includes 2-factor authentication)
3. User uploads data file
4. System validates file (format, data types, data reasonableness checks)

#### Success Scenario

- File is uploaded successfully
- Success message displayed to user
- Log entry created recording successful upload
- Email confirmation sent to jurisdiction's registered email address

#### Error Scenario

- File is not stored
- Error message displayed with description of problems
- Log entry created recording unsuccessful attempt and errors
- Email notification sent to jurisdiction's registered email address

<br>

### Option 2: Scheduled Pull by JHU (Automated)

**Best for:** Jurisdictions with existing public data portals

#### Requirements

- Jurisdiction has an existing data portal with accessible data
- Jurisdiction provides example script/documentation for data access
- Jurisdiction provides point of contact for troubleshooting

#### Process

1. JHU connects to jurisdiction's data portal on scheduled basis using provided script
2. JHU retrieves data file automatically
3. System validates file (format, data types, data reasonableness checks)

#### Success Scenario

- File retrieved and stored successfully
- Log entry created recording successful retrieval
- Email confirmation sent to jurisdiction's registered email address

#### Error Scenarios

**Connection Failure:**

- Logged to extent possible
- Log contents emailed to monitored JHU email address

**Validation Failure:**

- File not stored
- Log entry created recording unsuccessful attempt and errors
- Email notification sent to jurisdiction's registered email address

#### Implementation Notes

- Requires separate script/connector for each participating jurisdiction
- Some commonality possible if states use same data portal software (e.g., Socrata with published API)
- Each script requires ongoing maintenance
- Assumes jurisdiction has defined process and schedule for storing data in their portal

<br>

### Option 3: Scheduled Push by Jurisdiction (Automated)

**Best for:** Jurisdictions with IT capability to implement automated uploads

#### Requirements

- Jurisdiction can implement and troubleshoot provided script
- Jurisdiction has scheduling capability for automated execution
- Jurisdiction provides point of contact for coordination

#### Process

1. Jurisdiction connects to JHU portal on scheduled basis using JHU-provided script
2. Jurisdiction pushes data file to JHU's data portal
3. System validates file (format, data types, data reasonableness checks)

#### Success Scenario

- File stored successfully
- Log entry created recording successful push
- Email confirmation sent to jurisdiction's registered email address

#### Error Scenarios

**Connection Failure:**

- Jurisdiction monitors/logs connection failures
- Jurisdiction notifies JHU if warranted

**Validation Failure:**

- File not stored
- Log entry created recording unsuccessful attempt and errors
- Email notification sent to jurisdiction's registered email address

#### Implementation Notes

- Jurisdiction responsible for implementing script (with JHU support)
- Jurisdiction responsible for ongoing troubleshooting
- Jurisdiction should have automated scheduling capability
- Without automated scheduling, provides no benefit over manual upload

## Pilot Phase Implementation

For the production environment, JHU intends to provide all three transfer methods. However, the pilot timeline may not allow development of all three methods.

### Jurisdiction Input Needed

To prioritize development efforts, jurisdictions should indicate preferences for the pilot phase:

**Ranking Instructions:**

- Rank methods 1-3 based on your preference
- Omit methods that are not possible for your jurisdiction
- If only one method is possible, provide only that ranking

**Important:** These rankings are for pilot phase only. Production system will have all methods available.

### Data Portal Information

If your jurisdiction has a data portal, please provide:

- Software/platform name
- Link to developer documentation (if available)
- Point of contact for technical coordination

<br>

## File Format Specifications

### Naming Convention

Jurisdictions should name submitted files according to the following convention:

```
disease_tracking_report_{jurisdiction}_{report_date}.csv
```

Where:

- `{state}` = Two-letter state/territory code or NYC (e.g., WA, CA, NYC, PR)
- `{report_date}` = Date of submission in YYYY-MM-DD format

**Examples:**

```
disease_tracking_report_CA_2026-02-09.csv
disease_tracking_report_WA_2025-10-15.csv
disease_tracking_report_NYC_2025-11-01.csv
```

JHU may add additional metadata to filenames for internal tracking purposes (e.g., submission timestamp, username) but will preserve the original file content.

### File Content

Files should not be altered after generation. JHU will not modify file contents, only may add metadata to filenames for internal tracking.

For detailed field specifications, see the [Data Technical Specifications](data-technical-specs.md).

### Template and Examples

Use the official data submission template and examples:

- [Empty template](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_{jurisdiction}_{report_date}.csv) - Template with correct field structure
- [Example data file](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_report_CA-SIMULATED-EXAMPLE_2026-02-09.csv) - Sample data demonstrating proper format
- [Data dictionary (CSV)](https://github.com/USDiseaseTracker/DataStandards/blob/main/examples-and-templates/disease_tracking_data_dictionary.csv) - Reference table of all fields and valid values

<br>

## Validation

### Automated Validation Checks

All submitted files undergo automated validation:

- **Format checks:** File structure, CSV formatting
- **Data type checks:** Field data types match specifications
- **Value checks:** Values within acceptable ranges/enumerations
- **Reasonableness checks:** Logical consistency (dates, counts, etc.)

See the [Validation Rules](validation.md) for detailed validation requirements.

### Validation Errors

If validation fails:
1. File is not imported into the system
2. Detailed error report is generated
3. Error report is provided to submitting user
4. Email notification sent to jurisdiction
5. Jurisdiction should correct errors and resubmit

### Validation Success

If validation succeeds:
1. File is imported into the system
2. Data becomes available for dashboard
3. Confirmation message provided to user
4. Email notification sent to jurisdiction

<br>

## Security and Authentication

### Authentication Requirements

All data transfer methods require secure authentication:

- **Username/password** for system access
- **Two-factor authentication (2FA)** for added security
- **Secure credentials** for automated transfers (API keys, tokens)

### Data Security

- All transfers use encrypted connections (HTTPS/TLS)
- Files stored securely on JHU servers
- Access limited to authorized project team members
- Audit logs maintained for all data access

<br>

## Troubleshooting

### Common Issues

**File Upload Fails:**

- Check file format (must be CSV)
- Verify file follows template structure
- Check for special characters or encoding issues
- Ensure file size is within limits

**Validation Errors:**

- Review error message for specific issues
- Check field values against valid value sets
- Verify date formats (YYYY-MM-DD)
- Ensure required fields are populated

**Authentication Issues:**

- Verify username and password
- Check 2FA device/app is working
- Contact JHU support for account issues

**Automated Transfer Failures:**

- Verify network connectivity
- Check credentials/API keys are valid
- Review firewall/security settings
- Contact JHU technical support

<br>

## Support

### Technical Support

For technical issues with data transfer:

- Email: [to be provided]
- Phone: [to be provided]
- Support hours: [to be provided]

### Escalation

For urgent issues or escalation:

- Contact your jurisdiction's project liaison
- Liaison will coordinate with JHU project team

<br>

## Version Control

### Data Versioning

- Each file submission is timestamped
- Previous versions are retained
- Changes to historical data are tracked
- Revision history available for review

### Metadata Tracking

For each submission, the system records:

- Submission date/time
- Submitting jurisdiction
- Submitting user
- File name
- Validation status
- Any errors or warnings

<br>

## Future Enhancements

Post-pilot enhancements may include:

- Additional transfer methods based on jurisdiction needs
- Enhanced validation with more detailed feedback
- Real-time data quality dashboards for submitters
- Automated data quality reports
- API access for jurisdictions to retrieve their own data


## Questions

For questions about data transfer methods or technical requirements, contact the project team through your jurisdiction's liaison.
