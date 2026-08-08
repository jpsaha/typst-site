#!/usr/bin/env bash

set -euo pipefail

export TYPST_FEATURES=html


# ============================================================
# Configuration
# ============================================================

DIST="dist"
PAGES_DIR="$DIST/pages"
PDF_DIR="$DIST/pdf"
ASSETS_DIR="$DIST/assets"

HOMEPAGE_JSON="generated/homepage.json"


# ============================================================
# Helpers
# ============================================================

die() {
    echo "❌ $1"
    exit 1
}


# ============================================================
# 1. Generate metadata
# ============================================================

echo "📋 Generating metadata..."

python3 scripts/build/generate_metadata.py


# ============================================================
# 2. Initialize dist
# ============================================================

echo "📁 Preparing dist/..."

mkdir -p \
    "$PAGES_DIR" \
    "$PDF_DIR" \
    "$ASSETS_DIR/css" \
    "$ASSETS_DIR/js" \
    "$ASSETS_DIR/images"


# ============================================================
# 3. Copy assets
# ============================================================

if [ -f "assets/css/style.css" ]; then

    cp \
        assets/css/style.css \
        "$ASSETS_DIR/css/style.css"

    echo "📋 Copied style.css"

else

    echo "⚠️ Warning: assets/css/style.css not found"

fi


# ============================================================
# 4. Check generated metadata
# ============================================================

if [ ! -f "$HOMEPAGE_JSON" ]; then
    die "Missing $HOMEPAGE_JSON"
fi


# ============================================================
# 5. Generate homepage and compile pages
# ============================================================

echo "🌐 Building course pages..."

python3 - <<'PY'

import json
import subprocess


HOMEPAGE_JSON = "generated/homepage.json"
INDEX_HTML = "dist/index.html"


# ------------------------------------------------------------
# Read metadata
# ------------------------------------------------------------

with open(
    HOMEPAGE_JSON,
    encoding="utf-8",
) as file:

    categories = json.load(file)


# ------------------------------------------------------------
# Start homepage
# ------------------------------------------------------------

with open(
    INDEX_HTML,
    "w",
    encoding="utf-8",
) as index:

    index.write(
        "<!DOCTYPE html>\n"
        "<html>\n"
        "<head>\n"
        '  <meta charset="utf-8">\n'
        '  <link rel="stylesheet" href="assets/css/style.css">\n'
        "</head>\n"
        "<body>\n"
    )


    # --------------------------------------------------------
    # Categories
    # --------------------------------------------------------

    for category, lectures in categories.items():

        index.write(
            f"\n<h2>{category}</h2>\n"
        )


        # ----------------------------------------------------
        # Lectures/pages
        # ----------------------------------------------------

        for lecture in lectures:

            title = lecture["title"]
            html = lecture["html"]
            pdf = lecture["pdf"]
            source = lecture["source"]

            print(
                f"📖 Compiling {title}"
            )


            # ------------------------------------------------
            # HTML
            # ------------------------------------------------

            subprocess.run(
                [
                    "typst",
                    "compile",
                    "--root",
                    ".",
                    f"content/{source}",
                    f"dist/pages/{html}",
                    "--input",
                    "format=html",
                ],
                check=True,
            )


            # ------------------------------------------------
            # PDF
            # ------------------------------------------------

            subprocess.run(
                [
                    "typst",
                    "compile",
                    "--root",
                    ".",
                    f"content/{source}",
                    f"dist/pdf/{pdf}",
                    "--input",
                    "format=pdf",
                ],
                check=True,
            )


            # ------------------------------------------------
            # Homepage entry
            # ------------------------------------------------

            index.write(
                f"""
<div class="lecture">

    <span>{title}</span>

    <div class="lecture-links">

        <a
            href="pages/{html}"
            class="btn btn-web"
        >
            🌐 View Web
        </a>

        <a
            href="pdf/{pdf}"
            class="btn btn-pdf"
            target="_blank"
        >
            📄 PDF Version
        </a>

    </div>

</div>
"""
            )


    # --------------------------------------------------------
    # Finish homepage
    # --------------------------------------------------------

    index.write(
        """
</body>
</html>
"""
    )

PY


# ============================================================
# 6. Check links
# ============================================================

echo
echo "🔗 Checking links..."

if ! python3 scripts/lint/check_links.py; then

    die "Build failed: broken links detected."

fi


# ============================================================
# 7. Build complete course PDF
# ============================================================

echo
echo "📚 Building complete course book..."

typst compile \
    --root . \
    book_source.typ \
    "$PDF_DIR/book.pdf" \
    --input format=pdf


# ============================================================
# 8. Build complete pages PDF
# ============================================================

echo
echo "📚 Building complete pages.pdf..."

typst compile \
    --root . \
    pages_source.typ \
    "$PDF_DIR/pages.pdf" \
    --input format=pdf


# ============================================================
# Done
# ============================================================

echo
echo "=============================================="
echo "✅ Compilation pipeline completed successfully"
echo "=============================================="
