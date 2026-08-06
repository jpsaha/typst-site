#!/usr/bin/env bash
set -euo pipefail

# Initialize isolated web assets folder
mkdir -p dist
export TYPST_FEATURES=html

echo "🚀 Launching modular artifact compile pipeline..."

if [ -f "src/style.css" ]; then
    cp src/style.css dist/style.css
    echo "📋 Synced external stylesheet assets to dist/ workspace"
else
    echo "⚠️ Warning: src/style.css asset target missing"
fi

# Locate tracking paths chronologically
FILES=$(ls src/lec*.typ 2>/dev/null | sort -V || true)

if [ -z "$FILES" ]; then
    echo "❌ Missing source lecture targets matching: src/lec*.typ"
    exit 1
fi

# Core array initialization for building the portal index
LECTURES_ARR=()

for file in $FILES; do
    filename=$(basename "$file" .typ)
    
    # Brittle extraction alternative: Read metadata safely with robust parsing fallback
    title=$(grep -m 1 "^// Title:" "$file" | sed 's/\/\/ Title://g' | xargs || true)
    if [ -z "$title" ]; then
        title="Lecture ${filename#lec}"
    fi

    echo "Compiling academic segment: $title ($filename)"

    # Build web pages and high-fidelity print layouts independently
    typst compile "$file" "dist/${filename}.html" --input format=html
    typst compile "$file" "dist/${filename}.pdf" --input format=pdf

    # Push to array mapping stack variables safely
    LECTURES_ARR+=("$filename|$title")
done

# Dynamically write out the dashboard file
echo "🌐 Writing landing index layout workspace: dist/index.html"
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

for item in "${LECTURES_ARR[@]}"; do
    IFS='|' read -r fname ftitle <<< "$item"
    cat << EOF >> dist/index.html
            <div class="lecture-row">
                <span>${ftitle}</span>
                <div class="lecture-links">
                    <a href="${fname}.html" class="btn btn-web">🌐 View Web</a>
                    <a href="${fname}.pdf" class="btn btn-pdf" download>📄 PDF Version</a>
                </div>
            </div>
EOF
done

cat << 'EOF' >> dist/index.html
        </main>
    </div>
</body>
</html>
EOF

echo "✅ Compilation pipeline executed successfully!"
