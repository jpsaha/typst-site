#!/usr/bin/env bash
set -euo pipefail


# ------------------------------------------------------------
# Generate metadata
# ------------------------------------------------------------

python3 scripts/generate_metadata.py


# ------------------------------------------------------------
# Initialize dist
# ------------------------------------------------------------

mkdir -p dist

export TYPST_FEATURES=html

echo "🚀 Launching modular artifact compile pipeline..."


# ------------------------------------------------------------
# Copy CSS
# ------------------------------------------------------------

if [ -f "assets/css/style.css" ]; then
    cp assets/css/style.css dist/style.css
    echo "📋 Copied style.css"
else
    echo "⚠️ Warning: assets/css/style.css not found"
fi



# ------------------------------------------------------------
# Check homepage metadata
# ------------------------------------------------------------

if [ ! -f "generated/homepage.json" ]; then
    echo "❌ Missing generated/homepage.json"
    exit 1
fi



# ------------------------------------------------------------
# Read lecture list from homepage.json
# ------------------------------------------------------------

LECTURES_JSON="generated/homepage.json"



# ------------------------------------------------------------
# Write landing page header
# ------------------------------------------------------------

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



# ------------------------------------------------------------
# Compile lectures
# ------------------------------------------------------------

python3 - <<'PY'

import json
import subprocess


with open("generated/homepage.json",
          encoding="utf-8") as f:
    categories = json.load(f)


with open("dist/index.html",
          "a",
          encoding="utf-8") as index:

    for category, lectures in categories.items():

        index.write(
f"""
<h2 class="category-title">
    {category}
</h2>

"""
        )

        for lec in lectures:

            title = lec["title"]
            html = lec["html"]
            pdf = lec["pdf"]

            fname = html.removesuffix(".html")


            print(f"📖 Compiling {title}")


            subprocess.run(
                [
                    "typst",
                    "compile",
                    "--root",
                    ".",
                    f"content/{fname}.typ",
                    f"dist/{html}",
                    "--input",
                    "format=html",
                ],
                check=True,
            )


            subprocess.run(
                [
                    "typst",
                    "compile",
                    "--root",
                    ".",
                    f"content/{fname}.typ",
                    f"dist/{pdf}",
                    "--input",
                    "format=pdf",
                ],
                check=True,
            )


            index.write(
f"""
<div class="lecture-row">

    <span>{title}</span>

    <div class="lecture-links">

        <a href="{html}" class="btn btn-web">
            🌐 View Web
        </a>

        <a href="{pdf}"
           class="btn btn-pdf"
           target="_blank">
            📄 PDF Version
        </a>

    </div>

</div>

"""
            )

PY



# ------------------------------------------------------------
# Finish index.html
# ------------------------------------------------------------

cat << 'EOF' >> dist/index.html

</main>

</div>

</body>
</html>

EOF

# ------------------------------------------------------------
# Build complete course PDF
# ------------------------------------------------------------

echo
echo "📚 Building complete course book..."

typst compile \
    --root . \
    book.typ \
    dist/book.pdf \
    --input format=pdf


# ------------------------------------------------------------
# Build complete course PDF (pages part)
# ------------------------------------------------------------

echo
echo "📚 Building complete course book..."

typst compile \
    --root . \
    pages.typ \
    dist/pages.pdf \
    --input format=pdf

echo
echo "✅ Compilation pipeline executed successfully!"