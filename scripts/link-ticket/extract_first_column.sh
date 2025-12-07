#!/bin/bash

# Check if input file is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <input_csv_file> [output_file]"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi

# Use awk to extract the first column, skipping the first line (header)
# -F, sets delimiter to comma
if [ -n "$OUTPUT_FILE" ]; then
    awk -F, 'NR>1 {print $1}' "$INPUT_FILE" > "$OUTPUT_FILE"
    echo "Done. Saved to $OUTPUT_FILE"
else
    awk -F, 'NR>1 {print $1}' "$INPUT_FILE"
fi
