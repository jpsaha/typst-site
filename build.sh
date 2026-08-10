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
# Build timing
#
# Record the time at which the build starts.
# The final summary will report the total build time.
# ============================================================

BUILD_START=$(date +%s)

# ============================================================
# Build statistics
#
# These counters are updated during the build and displayed
# in the final build summary.
# ============================================================

CATEGORY_COUNT=0

# ============================================================
# Helpers
# ============================================================

die() {
    echo "Build failed: $1"
    exit 1
}

# ============================================================
# 1. Generate metadata
# ============================================================

echo "📋 Generating metadata..."

python3 scripts/build/generate_metadata.py

# ============================================================
# 2. Check source metadata
# ============================================================

echo
echo "🔗 Checking source metadata..."

if ! python3 scripts/lint/check_metadata.py; then
    die "metadata validation failed."
fi

# ============================================================
# 3. Check generated files
# ============================================================

echo
echo "🔗 Checking generated files..."

if ! python3 scripts/lint/check_generated.py; then
    die "generated consistency check failed."
fi

# ============================================================
# 4. Initialize dist
# ============================================================

echo "📁 Preparing dist/..."

rm -rf "$PAGES_DIR" "$PDF_DIR" "$ASSETS_DIR"

mkdir -p \
    "$PAGES_DIR" \
    "$PDF_DIR" \
    "$ASSETS_DIR/css" \
    "$ASSETS_DIR/js" \
    "$ASSETS_DIR/images"

# ============================================================
# 5. Copy assets
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
# 6. Check generated metadata
# ============================================================

if [ ! -f "$HOMEPAGE_JSON" ]; then

    die "Missing $HOMEPAGE_JSON"

fi

# ============================================================
# 7. Generate homepage and compile pages
# ============================================================

echo
echo "🌐 Building course pages..."

python3 scripts/build/build_pages.py

# ============================================================
# 8. Build category books
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

    # Count successfully compiled category books.
    CATEGORY_COUNT=$((CATEGORY_COUNT + 1))

done

# ============================================================
# 9. Build complete course PDF
# ============================================================

echo
echo "📚 Building complete course book..."

typst compile \
    --root . \
    book_source.typ \
    "$PDF_DIR/book.pdf" \
    --input format=pdf

# ============================================================
# 10. Build complete pages PDF
# ============================================================

echo
echo "📚 Building complete pages.pdf..."

typst compile \
    --root . \
    pages_source.typ \
    "$PDF_DIR/pages.pdf" \
    --input format=pdf

# ============================================================
# 11. Check links
# ============================================================

echo
echo "🔗 Checking links..."

if ! python3 scripts/lint/check_links.py; then

    die "broken links detected."

fi

# ============================================================
# 12. Build summary
#
# Because dist/ was cleaned before compilation, these counts
# represent files produced by the current build.
# ============================================================

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

PAGE_COUNT=$(find "$PAGES_DIR" -type f -name "*.html" | wc -l | tr -d ' ')

PDF_COUNT=$(find "$PDF_DIR" -type f -name "*.pdf" | wc -l | tr -d ' ')

echo
echo "=============================================="
echo "📊 Build summary"
echo "=============================================="
echo "  🌐 HTML pages:     $PAGE_COUNT"
echo "  📚 Category books: $CATEGORY_COUNT"
echo "  📄 PDF files:      $PDF_COUNT"
echo "  ⏱ Build time:      ${BUILD_TIME}s"
echo "=============================================="
echo "✅ Compilation pipeline completed successfully"
echo "=============================================="