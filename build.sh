#!/usr/bin/env bash

set -euo pipefail

export TYPST_FEATURES=html

DIST="dist"
SRC="src"

echo "========================================"
echo " Building Typst Course Website"
echo "========================================"

############################################################
# Clean output directory
############################################################

rm -rf "$DIST"
mkdir -p "$DIST"

############################################################
# Copy static assets
############################################################

echo "📋 Copying assets..."

if [[ -f "$SRC/style.css" ]]; then
    cp "$SRC/style.css" "$DIST/"
fi

############################################################
# Locate lecture files
############################################################

FILES=$(find "$SRC" -maxdepth 1 -name "lec*.typ" | sort -V)

if [[ -z "$FILES" ]]; then
    echo "No lecture files found."
    exit 1
fi

############################################################
# Build lectures
############################################################

LECTURE_ROWS=""

count=$(echo "$FILES" | wc -l | tr -d ' ')

i=1

while IFS= read -r file
do

    filename=$(basename "$file" .typ)

    ############################################################
    # Read lecture title (portable: macOS + Linux)
    ############################################################

    title=$(sed -n 's/^#let lecture_title = "\(.*\)"/\1/p' "$file")

    if [[ -z "$title" ]]; then
        title="Lecture ${filename#lec}"
    fi

    echo "[$i/$count] HTML : $filename"
    typst compile "$file" "$DIST/$filename.html" --input format=html

    echo "[$i/$count] PDF  : $filename"
    typst compile "$file" "$DIST/$filename.pdf" --input format=pdf

    LECTURE_ROWS+="
        <div class=\"lecture-row\">
            <span>${title}</span>

            <div class=\"lecture-links\">
                <a class=\"btn btn-web\" href=\"${filename}.html\">
                    🌐 View Web
                </a>

                <a class=\"btn btn-pdf\" href=\"${filename}.pdf\" download>
                    📄 Download PDF
                </a>
            </div>
        </div>
"

    i=$((i+1))

done <<< "$FILES"

############################################################
# Generate index
############################################################

echo "📝 Generating index.html"

cat > "$DIST/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1">

<title>Mathematics Lecture Series</title>

<link rel="stylesheet" href="style.css">

</head>

<body>

<div class="index-container">

<header class="index-header">

<h1>🧮 Mathematics Lecture Series</h1>

<p>Course Materials &amp; Practice Sets</p>

</header>

<h2>Course Modules</h2>

<div class="lecture-list">

$LECTURE_ROWS

</div>

</div>

</body>

</html>

EOF

############################################################
# Finished
############################################################

echo
echo "========================================"
echo " Build completed successfully."
echo " Output directory: $DIST"
echo "========================================"
