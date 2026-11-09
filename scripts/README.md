# Scripts

This directory contains utility scripts for the US Disease Tracker Data Standards repository.

## generate_yaml_schema.py

This script generates `data_reporting_schema.yaml` from the Pydantic model definitions in `examples-and-templates/data_reporting_schema.py`.

**The Pydantic model (`data_reporting_schema.py`) is the source of truth.** This script ensures that the YAML schema stays synchronized with the Pydantic model.

### Usage

**Generate the YAML schema:**
```bash
python3 scripts/generate_yaml_schema.py
```

This will:
1. Import the Pydantic `DiseaseReport` model
2. Extract field definitions, types, and validation rules
3. Generate a schema file
4. Write the YAML output to `examples-and-templates/data_reporting_schema.yaml`

### What it generates

The script generates a complete schema in YAML format including:
- **Field definitions**: All field types and descriptions
- **Enum constraints**: For fields like `disease_name`, `state`, `age_group`, etc.
- **Validation rules**: Cross-field validations (e.g., disease-specific time_unit constraints)
- **Required fields**: Based on the Pydantic model configuration
- **Type constraints**: Date formats, integer ranges, etc.

### Automated generation

This script runs automatically via GitHub Actions when:
- `examples-and-templates/data_reporting_schema.py` is modified
- Changes are pushed to the `main` branch
- A pull request modifies the Pydantic schema file

The workflow will automatically:
1. Run the generation script
2. Commit the updated YAML schema if changes are detected
3. Validate the generated schema against documentation

## validate_schema_specs.py

This script validates that the technical specifications in `guides/data-technical-specs.md` and the data dictionary in `examples-and-templates/disease_tracking_data_dictionary.csv` match the YAML schema in `examples-and-templates/data_reporting_schema.yaml`.

**The YAML schema is the source of truth.** The script ensures that documentation and the data dictionary stay synchronized with the schema.

### Usage

**Check for mismatches:**
```bash
python3 scripts/validate_schema_specs.py
```

**Auto-update markdown and data dictionary from schema:**
```bash
python3 scripts/validate_schema_specs.py --update
```

### What it checks

**Markdown specifications:**
- **Age groups**: Validates that age group enumerations match between schema and markdown
- **Disease subtype values**: Checks that disease subtype values (meningococcal serogroups) are consistent
- **Geographic unit values**: Ensures geo_unit enumerations match
- **Required fields**: Verifies that required fields are consistent

**Data dictionary:**
- **Age groups**: Validates age_group values match the schema
- **Disease subtype values**: Checks disease_subtype values match the schema
- **Geographic unit values**: Ensures geo_unit values match the schema

### Automated checks

This script runs automatically via GitHub Actions on:
- Every push to the `main` branch
- Every pull request to `main`

If mismatches are detected, the workflow will automatically update the markdown file and data dictionary to match the schema and commit the changes.

### Exit codes

- `0`: All checks passed
- `1`: One or more checks failed (without `--update` flag)
- `0`: Checks failed but files were updated successfully (with `--update` flag)

## update_data_standards.py

This is an orchestration script that combines both `generate_yaml_schema.py` and `validate_schema_specs.py` to perform a complete update of the data standards tool and documentation.

**This script ensures that all data standards artifacts stay synchronized with the validation schema.**

### Usage

**Perform a complete update:**
```bash
python3 scripts/update_data_standards.py
```

### What it does

This script performs the following steps in sequence:

1. **Generate YAML schema**: Runs `generate_yaml_schema.py` to create the YAML schema from the Pydantic model
2. **Update data standards**: Runs `validate_schema_specs.py --update` to update:
   - Data dictionary CSV (`examples-and-templates/disease_tracking_data_dictionary.csv`)
   - Technical specifications markdown (`guides/data-technical-specs.md`)
3. **Validate consistency**: Runs `validate_schema_specs.py` to ensure all files are synchronized

### When to use

Use this script when you have manually modified the Pydantic schema (`data_reporting_schema.py`) and want to:
- Update all derived artifacts (YAML schema, data dictionary, documentation)
- Verify that everything is consistent
- Prepare changes for commit

### Automated execution

The GitHub Actions workflow (`.github/workflows/generate-yaml-schema.yml`) automatically performs these steps when the Pydantic schema is modified, so manual execution is typically only needed for:
- Local development and testing
- Troubleshooting schema inconsistencies
- Generating updates before committing schema changes

## Automated Data Standards Updates

The repository uses GitHub Actions to automatically keep the data standards tool synchronized with validation schemas:

### Workflow: Generate Schema (`generate-yaml-schema.yml`)

**Triggers when:**
- `examples-and-templates/data_reporting_schema.py` is modified
- Changes are pushed to `main` or opened in a pull request

**Actions performed:**
1. Generates YAML schema from Pydantic model
2. Updates data dictionary CSV from YAML schema
3. Updates markdown documentation from YAML schema
4. Validates final consistency
5. Commits and pushes changes automatically (on push to main)

This ensures that whenever the validation schema changes, the data standards tool (CSV data dictionary) and documentation are automatically updated to reflect the new values.

### Source of Truth

The data flow is:
```
Pydantic Model (data_reporting_schema.py)
    ↓ [generate_yaml_schema.py]
YAML Schema (data_reporting_schema.yaml)
    ↓ [validate_schema_specs.py --update]
Data Dictionary CSV + Markdown Documentation
```

**Pydantic model is the ultimate source of truth.** All other files are derived from it.

## generate_data_standards_tool.py

This script generates the Data Standards Tool documentation page (`docs/data-standards-tool.md`) from the JSON schema.

**Usage:**

```bash
python3 scripts/generate_data_standards_tool.py
```

**What it does:**

- Reads `examples-and-templates/data_reporting_schema.json`
- Extracts field definitions, enumerations, and descriptions
- Generates Markdown documentation with:
  - Field reference with all valid values
  - Disease-specific requirements
  - Validation rules (including those not in the schema)
  - Related resources
- Outputs to `docs/data-standards-tool.md`

**When to run:**

Run this script whenever the JSON schema is updated to regenerate the documentation:

```bash
python3 scripts/generate_data_standards_tool.py
git add docs/data-standards-tool.md
git commit -m "Update data standards tool from schema"
```

**Validation Rules Included:**

The script includes validation rules from both the schema and additional business rules:

- MMWR week validation (Sunday start, Saturday end)
- State-level totals (cannot have both age_group and disease_subtype as "total")
- International resident geo_unit validation
- NA value usage restrictions
- Jurisdiction consistency checks
- Date range validation
- Count non-negativity
