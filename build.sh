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

python3 scripts/build/build_pages.py


# ============================================================
# 6. Build category books
# ============================================================

echo
echo "📚 Building category books..."

for CATEGORY_SOURCE in generated/category_*.typ; do

    # If no category files exist, skip the loop.
    [ -e "$CATEGORY_SOURCE" ] || continue

    CATEGORY_NAME="$(basename "$CATEGORY_SOURCE" .typ)"

    echo "  📖 Building $CATEGORY_NAME..."

    typst compile \
        --root . \
        "$CATEGORY_SOURCE" \
        "$PDF_DIR/${CATEGORY_NAME}.pdf" \
        --input format=pdf

done


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
# 9. Check links
# ============================================================

echo
echo "🔗 Checking links..."

if ! python3 scripts/lint/check_links.py; then

    die "Build failed: broken links detected."

fi


# ============================================================
# Done
# ============================================================

echo
echo "=============================================="
echo "✅ Compilation pipeline completed successfully"
echo "=============================================="
