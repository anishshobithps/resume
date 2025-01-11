#!/bin/sh
set -e

# Create output directory
mkdir -p /latex/output

# Ensure TeX can find the files
texhash

# Run XeLaTeX with proper output name
xelatex -interaction=nonstopmode \
        -output-directory=/latex/output \
        -jobname="Anish_Shobith_P_S_Resume" \
        "main.tex"

# Run again for references if needed
if grep -q "Rerun to get" "/latex/output/Anish_Shobith_P_S_Resume.log"; then
    xelatex -interaction=nonstopmode \
            -output-directory=/latex/output \
            -jobname="Anish_Shobith_P_S_Resume" \
            "main.tex"
fi

# Copy the final PDF to the mounted volume
cp /latex/output/Anish_Shobith_P_S_Resume.pdf /latex/

# Show compilation log in case of errors
if [ ! -f "/latex/Anish_Shobith_P_S_Resume.pdf" ]; then
    echo "Compilation failed. Log output:"
    cat /latex/output/Anish_Shobith_P_S_Resume.log
    exit 1
fi
