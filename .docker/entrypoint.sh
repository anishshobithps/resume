#!/bin/sh
set -e

# Create output directory
mkdir -p /latex/output

# Run XeLaTeX with proper output name
xelatex -interaction=nonstopmode \
        -output-directory=/latex/output \
        -jobname="Anish_Shobith_P_S_Resume" \
        "main.tex"

# Run again if needed for references
if grep -q "Rerun to get" "/latex/output/Anish_Shobith_P_S_Resume.log"; then
    xelatex -interaction=nonstopmode \
            -output-directory=/latex/output \
            -jobname="Anish_Shobith_P_S_Resume" \
            "main.tex"
fi

# Copy the final PDF to the mounted volume
cp /latex/output/Anish_Shobith_P_S_Resume.pdf /latex/
