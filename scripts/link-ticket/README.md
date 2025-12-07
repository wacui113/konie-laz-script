
# Link Ticket Scripts

## Purpose

This folder contains scripts to link JIRA tickets using the **"Test"** relationship.  
- In the **inward ticket**, the GUI displays: `is a test for <outward_ticket_id>`.
- In the **outward ticket**, the GUI displays: `is tested by <inward_ticket_id>`.

You can link a single ticket or multiple tickets provided in a CSV file.

---

## Workflow Overview

### 1. Configure JIRA Access

Set up the ticketing system information in `jira_config.properties`:
- **domain**: Your JIRA domain URL
- **email**: Your JIRA account email
- **jira_token**: Your JIRA API token

Example:
```
domain=https://your-domain.atlassian.net
email=your-email@example.com
jira_token=your-jira-api-token
```

---

### 2. Preparing Ticket IDs in a CSV

**If you already have a CSV** with only ticket IDs (one per line, no header), skip to the next step.

**If your CSV has ticket IDs in the first column (with other columns or headers):**
- Use the `extract_first_column` script to create a CSV with just the ticket IDs.

#### Usage

```bash
# Bash
./extract_first_column.sh <original_csv_file_path> <output_csv_file_path>
```
or
```powershell
# PowerShell
.\extract_first_column.ps1 <original_csv_file_path> <output_csv_file_path>
```

---

### 3. Linking Tickets

Use the `link_jira_issue_from_config` script to link tickets as "Test" relationship.

**Arguments:**
1. A single inward ticket ID  
   **OR**  
   A CSV file with one ticket ID per line (from the previous step).
2. The outward ticket ID

#### Usage

```bash
# Bash
./link_jira_issue_from_config.sh <inward_ticket_id_or_csv_file> <outward_ticket_id>
```
or
```powershell
# PowerShell
.\link_jira_issue_from_config.ps1 <inward_ticket_id_or_csv_file> <outward_ticket_id>
```

#### Example

```bash
./link_jira_issue_from_config.sh abc-123 abc-456
# Links ticket abc-123 to abc-456 as "is a test for"
```
or, using a list:
```bash
./link_jira_issue_from_config.sh output_ticket_ids.csv abc-456
# Links each ticket in output_ticket_ids.csv to abc-456 as "is a test for"
```

---

## Notes

- The scripts require `jira_config.properties` to be configured.
- Make sure your JIRA API token has permission to link issues.
- The relationship will display as "is a test for" (inward) and "is tested by" (outward) in JIRA.
- The CSV file should contain only ticket IDs, one per line.

---

## Example CSV

```
abc-101
abc-102
abc-103
```

---

## License

Refer to the main repository license for usage terms.
