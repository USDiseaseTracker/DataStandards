#!/usr/bin/env python3
"""
Generate data-standards-tool.md from data_reporting_schema.json
This script creates a Markdown version of the data standards tool that uses
the MkDocs Material theme.
"""

import json
import sys
from pathlib import Path


def load_schema(schema_path):
    """Load the JSON schema file."""
    with open(schema_path, 'r') as f:
        return json.load(f)


def get_enum_values(property_def):
    """Extract enum values from a property definition."""
    if 'enum' in property_def:
        return property_def['enum']
    return None


def get_disease_specific_rules(schema):
    """Extract disease-specific validation rules from schema."""
    rules = {}
    
    # Parse allOf rules to extract disease-specific constraints
    if 'items' in schema and 'allOf' in schema['items']:
        for rule in schema['items']['allOf']:
            if 'oneOf' in rule:
                for option in rule['oneOf']:
                    if 'properties' in option and 'disease_name' in option['properties']:
                        disease = option['properties']['disease_name'].get('const')
                        if disease:
                            if disease not in rules:
                                rules[disease] = {}
                            
                            # Extract time_unit
                            if 'time_unit' in option['properties']:
                                rules[disease]['time_unit'] = option['properties']['time_unit'].get('const')
                            
                            # Extract disease_subtype
                            if 'disease_subtype' in option['properties']:
                                rules[disease]['disease_subtype'] = option['properties']['disease_subtype'].get('enum', [])
    
    return rules


def generate_markdown(schema, output_path):
    """Generate the Markdown file from schema."""
    
    # Get properties from schema
    properties = schema['items']['properties']
    required_fields = schema['items'].get('required', [])
    
    # Extract disease-specific rules
    disease_rules = get_disease_specific_rules(schema)
    
    # Start building markdown content
    md_content = []
    
    # Header
    md_content.append("# Data Standards Tool")
    md_content.append("")
    md_content.append("This interactive reference helps you understand the data standards and validation rules for US Disease Tracker data submissions.")
    md_content.append("")
    md_content.append("!!! info \"About This Tool\"")
    md_content.append("    This tool provides comprehensive information about:")
    md_content.append("    ")
    md_content.append("    - Valid options for each data field")
    md_content.append("    - Field descriptions and requirements")
    md_content.append("    - Validation rules and constraints")
    md_content.append("    - Disease-specific requirements")
    md_content.append("")
    
    # Disease-specific rules section
    md_content.append("## Disease-Specific Requirements")
    md_content.append("")
    
    # Get disease enum
    disease_enum = properties.get('disease_name', {}).get('enum', [])
    
    for disease in disease_enum:
        md_content.append(f"### {disease.title()}")
        md_content.append("")
        
        # Add rules from schema
        if disease in disease_rules:
            rules = disease_rules[disease]
            
            if 'time_unit' in rules:
                md_content.append(f"- **Time Unit**: `{rules['time_unit']}`")
            
            if 'disease_subtype' in rules and rules['disease_subtype']:
                subtypes = ', '.join([f'`{s}`' for s in rules['disease_subtype']])
                md_content.append(f"- **Valid Subtypes**: {subtypes}")
        
        # Add confirmation status rules (from HTML validation)
        if disease == 'measles':
            md_content.append("- **Confirmation Status**: `confirmed` only")
        elif disease in ['pertussis', 'meningococcus']:
            md_content.append("- **Confirmation Status**: `confirmed and probable`")
        
        md_content.append("")
    
    # Field Reference section
    md_content.append("## Field Reference")
    md_content.append("")
    md_content.append("The following fields are required in all data submissions:")
    md_content.append("")
    
    # Define field order (same as in HTML)
    field_order = [
        'report_period_start',
        'report_period_end',
        'date_type',
        'time_unit',
        'disease_name',
        'disease_subtype',
        'reporting_jurisdiction',
        'state',
        'geo_name',
        'geo_unit',
        'age_group',
        'confirmation_status',
        'outcome',
        'count'
    ]
    
    for field in field_order:
        if field in properties:
            prop = properties[field]
            
            # Field header
            is_required = field in required_fields
            req_marker = " **(required)**" if is_required else ""
            md_content.append(f"### `{field}`{req_marker}")
            md_content.append("")
            
            # Description
            if 'description' in prop:
                md_content.append(f"**Description**: {prop['description']}")
                md_content.append("")
            
            # Type
            field_type = prop.get('type', 'string')
            format_info = prop.get('format', '')
            if format_info:
                md_content.append(f"**Type**: {field_type} ({format_info})")
            else:
                md_content.append(f"**Type**: {field_type}")
            md_content.append("")
            
            # Enum values
            enum_values = get_enum_values(prop)
            if enum_values:
                md_content.append("**Valid Values**:")
                md_content.append("")
                for value in enum_values:
                    md_content.append(f"- `{value}`")
                md_content.append("")
            
            # Additional constraints
            if field_type == 'integer' and 'minimum' in prop:
                md_content.append(f"**Minimum**: {prop['minimum']}")
                md_content.append("")
            
            # Special notes for specific fields
            if field == 'disease_subtype':
                md_content.append("!!! note \"Disease-Specific Subtypes\"")
                md_content.append("    - For **measles** and **pertussis**: Use `total`")
                md_content.append("    - For **meningococcus**: Use specific serogroup (A, B, C, W, X, Y, Z) or `total`, `unknown`, `unspecified`")
                md_content.append("")
            
            if field == 'geo_name':
                md_content.append("!!! tip \"Special Values\"")
                md_content.append("    - Use `international resident` for non-US residents")
                md_content.append("    - Use `unspecified` when geographic information is suppressed")
                md_content.append("")
            
            if field == 'geo_unit':
                md_content.append("!!! warning \"Geographic Unit NA\"")
                md_content.append("    `NA` should only be used when `geo_name` is `international resident`")
                md_content.append("")
    
    # Validation Rules section
    md_content.append("## Validation Rules")
    md_content.append("")
    md_content.append("The following validation rules apply to all data submissions:")
    md_content.append("")
    
    # MMWR week validation
    md_content.append("### MMWR Week Validation")
    md_content.append("")
    md_content.append("When `time_unit` is `week`:")
    md_content.append("")
    md_content.append("- `report_period_start` **must be a Sunday** (MMWR week start)")
    md_content.append("- `report_period_end` **must be a Saturday** (MMWR week end)")
    md_content.append("")
    md_content.append("!!! example \"Example MMWR Week\"")
    md_content.append("    - Start: 2026-02-08 (Sunday)")
    md_content.append("    - End: 2026-02-14 (Saturday)")
    md_content.append("")
    
    # Date range validation
    md_content.append("### Date Range Validation")
    md_content.append("")
    md_content.append("- `report_period_end` must be on or after `report_period_start`")
    md_content.append("- Dates should not be unreasonably far in the past or future")
    md_content.append("")
    
    # State-level totals validation
    md_content.append("### State-Level Totals")
    md_content.append("")
    md_content.append("When `geo_unit` is `state`:")
    md_content.append("")
    md_content.append("- **Cannot** have both `age_group = total` AND `disease_subtype = total`")
    md_content.append("- State totals should be reported with age and/or disease subtype stratifications")
    md_content.append("")
    md_content.append("!!! warning \"State Total Restriction\"")
    md_content.append("    This prevents duplicate reporting of state-level totals. Report state data stratified by at least one dimension (age group or disease subtype).")
    md_content.append("")
    
    # International resident validation
    md_content.append("### International Residents")
    md_content.append("")
    md_content.append("- When `geo_name` is `international resident`, `geo_unit` **must be** `NA`")
    md_content.append("- When `geo_unit` is `NA`, `geo_name` **must be** `international resident`")
    md_content.append("")
    
    # NA usage validation
    md_content.append("### NA Value Usage")
    md_content.append("")
    md_content.append("`NA` is **only valid** for the `geo_unit` field. For other fields, use:")
    md_content.append("")
    md_content.append("- `unknown` - when information is not known")
    md_content.append("- `unspecified` - when information is known but suppressed")
    md_content.append("")
    
    # Jurisdiction consistency
    md_content.append("### Jurisdiction Consistency")
    md_content.append("")
    md_content.append("For standard 2-letter state abbreviations:")
    md_content.append("")
    md_content.append("- `reporting_jurisdiction` should generally match `state`")
    md_content.append("- **Exceptions**: NYC, PR, DC, VI, GU, AS, MP, TT (cities and territories)")
    md_content.append("- For city-level jurisdictions within a state, set `state` appropriately")
    md_content.append("")
    
    # Count validation
    md_content.append("### Count Field")
    md_content.append("")
    md_content.append("- Must be a **non-negative integer** (0 or greater)")
    md_content.append("- Zero counts are allowed and should be reported when applicable")
    md_content.append("")
    
    # Related resources
    md_content.append("## Related Resources")
    md_content.append("")
    md_content.append("- [Data Technical Specifications](guides/data-technical-specs.md) - Detailed technical specifications")
    md_content.append("- [Validation Rules](guides/validation.md) - Complete validation requirements")
    md_content.append("- [Data Submission Guide](guides/data-submission-guide.md) - How to submit data")
    md_content.append("- [Data Transfer Guide](guides/data-transfer-guide.md) - Data transfer procedures")
    md_content.append("- [Examples & Templates](examples-and-templates.md) - Example files and templates")
    md_content.append("")
    
    # Footer note
    md_content.append("---")
    md_content.append("")
    md_content.append("!!! info \"Schema Version\"")
    md_content.append("    This documentation is generated from `data_reporting_schema.json`.")
    md_content.append("    For the most up-to-date schema, see [examples-and-templates](examples-and-templates.md).")
    md_content.append("")
    
    # Write to file
    with open(output_path, 'w') as f:
        f.write('\n'.join(md_content))
    
    print(f"✅ Generated {output_path}")


def main():
    # Get paths
    repo_root = Path(__file__).parent.parent
    schema_path = repo_root / 'examples-and-templates' / 'data_reporting_schema.json'
    output_path = repo_root / 'docs' / 'data-standards-tool.md'
    
    # Validate schema exists
    if not schema_path.exists():
        print(f"❌ Schema file not found: {schema_path}", file=sys.stderr)
        sys.exit(1)
    
    # Load schema
    schema = load_schema(schema_path)
    
    # Generate markdown
    generate_markdown(schema, output_path)
    
    print("✅ Data standards tool Markdown generated successfully!")


if __name__ == '__main__':
    main()
