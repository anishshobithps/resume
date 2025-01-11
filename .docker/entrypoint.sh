#!/bin/bash
set -e

INPUT_FILE="$1"
OUTPUT_NAME="${2:-output.pdf}"  # Default to output.pdf if no name specified

# Compile the LaTeX document
latexmk -pdf "$INPUT_FILE"

# Get the base name of the input file without extension
BASE_NAME=$(basename "$INPUT_FILE" .tex)

# Rename the output file
mv "${BASE_NAME}.pdf" "$OUTPUT_NAME"
