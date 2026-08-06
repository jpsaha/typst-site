#!/usr/bin/env bash
set -euo pipefail

python3 scripts/generate_metadata.py

# Initialize isolated web assets folder
mkdir -p dist
export TYPST_FEATURES=html

echo "🚀 Launching modular artifact compile pipeline..."

if [ -f "assets/css/style.css" ]; then
    cp assets/css/style.css dist/style.css
    echo "📋 Copied style.css"
else
    echo "⚠️ Warning: assets/css/style.css not found"
fi

# --------------------------------------------------------------------
# Find ALL Typst files (instead of only lec*.typ)
# --------------------------------------------------------------------
FILES=$(find content -maxdepth 1 -type f -name "*.typ" | sort -V)

if [ -z "$FILES" ]; then
    echo "❌ No Typst source files found in content/"
    exit 1
fi

# --------------------------------------------------------------------
# Collect titles
# --------------------------------------------------------------------
LECTURES_ARR=()

for file in $FILES; do
    filename=$(basename "$file" .typ)

    title=$(grep -m1 "^// Title:" "$file" \
        | sed 's#// Title:##' \
        | xargs || true)

    if [ -z "$title" ]; then
        title="$filename"
    fi

    LECTURES_ARR+=("$filename|$title")
done

# --------------------------------------------------------------------
# Build navigation string for Typst
# Format:
# lec1|Lecture 1;lec2|Lecture 2;fun|Fun Problems
# --------------------------------------------------------------------
NAV_ITEMS=""

for item in "${LECTURES_ARR[@]}"; do
    if [ -n "$NAV_ITEMS" ]; then
        NAV_ITEMS+=";"
    fi
    NAV_ITEMS+="$item"
done

# --------------------------------------------------------------------
# Write landing page header
# --------------------------------------------------------------------
echo "🌐 Writing landing page..."

cat << 'EOF' > dist/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mathematics Lecture Portal</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="index-container">
        <header class="index-header">
            <h1>🧮 Mathematics Lecture Portal</h1>
            <p>Interactive web modules & downloadable print-ready course material</p>
        </header>

        <main class="lecture-list">
EOF

# --------------------------------------------------------------------
# Compile lectures
# --------------------------------------------------------------------
for item in "${LECTURES_ARR[@]}"; do
    IFS='|' read -r fname ftitle <<< "$item"

    echo "📖 Compiling $ftitle"

    typst compile \
        --root . \
        "content/${fname}.typ" \
        "dist/${fname}.html" \
        --input format=html \
        --input nav-data="$NAV_ITEMS"

    typst compile \
        --root . \
        "content/${fname}.typ" \
        "dist/${fname}.pdf" \
        --input format=pdf

    cat << EOF >> dist/index.html
            <div class="lecture-row">
                <span>${ftitle}</span>
                <div class="lecture-links">
                    <a href="${fname}.html" class="btn btn-web">🌐 View Web</a>
                    <a href="${fname}.pdf" class="btn btn-pdf" target="_blank">📄 PDF Version</a>
                </div>
            </div>

EOF
done

# --------------------------------------------------------------------
# Finish index.html
# --------------------------------------------------------------------
cat << 'EOF' >> dist/index.html
        </main>
    </div>
</body>
</html>
EOF

echo
echo "✅ Compilation pipeline executed successfully!"