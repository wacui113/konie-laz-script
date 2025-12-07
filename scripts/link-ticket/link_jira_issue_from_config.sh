#!/bin/bash

# Script to link Jira issues using credentials from a config file
# Usage: ./link_jira_issue_from_config.sh <INWARD_ISSUE_OR_FILE> <OUTWARD_ISSUE>

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/jira_config.properties"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' not found."
    echo "Please create it with the following content:"
    echo "DOMAIN=your-domain.atlassian.net"
    echo "EMAIL=user@email.com"
    echo "TOKEN=api_token"
    exit 1
fi

# Load config
# Using 'set -a' to automatically export variables from the config file
set -a
source "$CONFIG_FILE"
set +a

# Validate config variables
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ] || [ -z "$TOKEN" ]; then
    echo "Error: Config file must contain DOMAIN, EMAIL, and TOKEN."
    echo "Current values:"
    echo "DOMAIN=$DOMAIN"
    echo "EMAIL=$EMAIL"
    echo "TOKEN=${TOKEN:0:5}..." # Mask token for security
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <INWARD_ISSUE_OR_FILE> <OUTWARD_ISSUE>"
    echo "Example: $0 <ticket test ID> <epic/story ID>"
    echo "Example: $0 issues_list.txt <epic/story ID>"
    exit 1
fi

INPUT_ARG=$1
OUTWARD_KEY=$2

# Function to link a single pair
link_jira_issue() {
    local INWARD_KEY=$1
    local OUTWARD_KEY=$2

    # Clean the key (remove carriage returns and leading/trailing whitespace)
    INWARD_KEY=$(echo "$INWARD_KEY" | tr -d '\r' | xargs)

    if [ -z "$INWARD_KEY" ]; then
        return
    fi

    echo "Linking $OUTWARD_KEY (Outward) to $INWARD_KEY (Inward)..."

    curl --request POST \
      --url "https://$DOMAIN/rest/api/2/issueLink" \
      --user "$EMAIL:$TOKEN" \
      --header 'Accept: application/json' \
      --header 'Content-Type: application/json' \
      --data "{
      \"type\": {
        \"name\": \"Test\"
      },
      \"inwardIssue\": {
        \"key\": \"$INWARD_KEY\"
      },
      \"outwardIssue\": {
        \"key\": \"$OUTWARD_KEY\"
      }
    }"

    echo "" # Newline for readability
}

# Check if the first argument is a file
if [ -f "$INPUT_ARG" ]; then
    echo "Detected file input: $INPUT_ARG"
    echo "Iterating through issues..."
    while IFS= read -r line || [ -n "$line" ]; do
        link_jira_issue "$line" "$OUTWARD_KEY"
    done < "$INPUT_ARG"
else
    # Treat as a single issue key
    link_jira_issue "$INPUT_ARG" "$OUTWARD_KEY"
fi

echo "Done."
