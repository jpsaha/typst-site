#!/bin/bash

# Terminate execution if any step fails
set -e

# Initialize asset production target directories
mkdir -p dist

# Turn on experimental native HTML building extensions inside the Typst binary
export TYPST_FEATURES=html

echo "🚀 Beginning compilation pipeline..."

# 1. Compile the Main Landing Index Directory Dashboard
echo "Building Landing Dashboard..."
typst compile src/index-page.typ dist/index.html --input format=html
typst compile src/index-page.typ dist/index.pdf --input format=pdf

# 2. Compile every distinct Lecture file inside the source folder
for file in src/lec*.typ; do
    filename=$(basename "$file" .typ)
    
    echo "Processing module: $filename"
    
    # Render interactive webpage with native MathML layout rendering
    typst compile "$file" "dist/${filename}.html" --input format=html
    
    # Render crisp layout page configurations for standardized print PDFs
    typst compile "$file" "dist/${filename}.pdf" --input format=pdf
done

echo "🎉 Build finished successfully! The static webpage files reside in './dist/'"
