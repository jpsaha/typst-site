#!/bin/bash
set -e

# Initialize output folder
mkdir -p dist
export TYPST_FEATURES=html

echo "🚀 Starting automated build..."

# FIX: Copy the tracked CSS asset into the gitignored output directory dynamically
if [ -f "src/style.css" ]; then
    cp src/style.css dist/style.css
    echo "📋 Synced style.css to dist/"
else
    echo "⚠️ Warning: src/style.css not found"
fi

# Part 1: Gather lecture metadata dynamically
LECTURES_JSON="["

# Find all lecture files sorted numerically (lec1, lec2, lec10, etc.)
FILES=$(ls src/lec*.typ 2>/dev/null | sort -V)

if [ -z "$FILES" ]; then
    echo "❌ No lecture files found matching src/lec*.typ"
    exit 1
fi

FIRST=true
for file in $FILES; do
    filename=$(basename "$file" .typ)
    
    # Extract the main title from the file
    title=$(grep -oP '(?<=\)\[)Lecture.*(?=\])' "$file" | head -n 1)
    if [ -z "$title" ]; then
        title=$(grep -oP '(?<="bold")\[Lecture.*(?=\])' "$file" | head -n 1)
    fi
    if [ -z "$title" ]; then
        title="Lecture ${filename#lec}"
    fi

    echo "Processing module: $title ($filename)"
    
    # Compile Web HTML version
    typst compile "$file" "dist/${filename}.html" --input format=html
    # Compile Print PDF version
    typst compile "$file" "dist/${filename}.pdf" --input format=pdf
done
