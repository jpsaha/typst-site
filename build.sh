# Refactored `build.sh`

#!/usr/bin/env bash

set -euo pipefail

export TYPST_FEATURES=html

# ============================================================
# Build target
#
# Usage:
#
#     ./build.sh
#     ./build.sh all
#     ./build.sh html
#     ./build.sh pdf
#     ./build.sh allpdf
#     ./build.sh categories
#     ./build.sh book
#     ./build.sh pages-pdf
#
# The default target is "all".
# ============================================================

TARGET="${1:-all}"

# ============================================================
# Help
# ============================================================

print_help() {

    cat <<'EOF'

Build the Typst mathematics lecture website and PDFs.

Usage:
    ./build.sh [TARGET]

Targets:
    all
        Build everything:
        HTML pages, individual PDFs, category PDFs,
        complete course PDF, complete pages PDF,
        and validate links.

    html
        Build HTML pages only.

    pdf
        Build individual page PDFs only.

    allpdf
        Build all PDF outputs:
        individual PDFs, category PDFs, course PDF,
        and pages PDF.

    categories
        Build category PDFs only.

    book
        Build the complete course PDF only.

    pages-pdf
        Build the complete pages PDF only.

Options:
    -h, --help
        Show this help message.

Examples:
    ./build.sh
    ./build.sh all
    ./build.sh html
    ./build.sh pdf
    ./build.sh allpdf
    ./build.sh categories
    ./build.sh book
    ./build.sh pages-pdf
    ./build.sh --help

The default target is:
    all

EOF
}

# ============================================================
# Handle command-line help
# ============================================================

case "$TARGET" in

    -h|--help)
        print_help
        exit 0
        ;;

esac

# ============================================================
# Build timing
#
# Record the time at which the build starts.
# The final summary will report the total build time.
# ============================================================

BUILD_START=$(date +%s)

# ============================================================
# Stage timings
#
# Each major build stage stores its elapsed time so that the
# final summary can show where the build time was spent.
# ============================================================

TIME_METADATA="0"
TIME_METADATA_CHECK="0"
TIME_GENERATED_CHECK="0"
TIME_IMPORT_CHECK="0"
TIME_HTML="0"
TIME_PDF="0"
TIME_CATEGORIES="0"
TIME_BOOK="0"
TIME_PAGES="0"
TIME_LINKS="0"

# ============================================================
# Helpers
# ============================================================

die() {
    echo "Build failed: $1"
    exit 1
}

# ============================================================
# Timing helpers
#
# macOS does not support date +%s.%N reliably.
# Use whole-second timestamps for portable shell timing.
# ============================================================

stage_start() {
    STAGE_START=$(date +%s)
}

stage_end() {
    local variable="$1"
    local elapsed

    elapsed=$(( $(date +%s) - STAGE_START ))

    printf -v "$variable" '%s' "$elapsed"
}

# ============================================================
# Cleanup
# ============================================================

cleanup() {

    local status=$?

    echo
    echo "🧹 Cleaning Python bytecode..."

    find scripts \
        -type d \
        -name "__pycache__" \
        -prune \
        -exec rm -rf {} +

    echo "✓ Python bytecode removed."

    return "$status"
}

trap cleanup EXIT

# ============================================================
# 1. Generate metadata
# ============================================================

generate_metadata() {

    echo "📋 Generating metadata..."

    stage_start

    python3 scripts/run.py metadata

    stage_end TIME_METADATA
}

# ============================================================
# 2. Check source metadata
# ============================================================

validate_metadata() {

    echo
    echo "🔗 Checking source metadata..."

    stage_start

    if ! python3 scripts/run.py metadata-check; then
        die "metadata validation failed."
    fi

    stage_end TIME_METADATA_CHECK
}

# ============================================================
# 3. Check generated files
# ============================================================

validate_generated() {

    echo
    echo "🔗 Checking generated files..."

    stage_start

    if ! python3 scripts/run.py generated; then
        die "generated consistency check failed."
    fi

    stage_end TIME_GENERATED_CHECK
}

# ============================================================
# 4. Check Typst imports
#
# Verify that all imported Typst files exist and that there
# are no circular import dependencies.
#
# The detailed dependency graph is written to:
#
#     diagnostics/imports.dot
#
# ============================================================

validate_imports() {

    echo
    echo "🔗 Checking Typst imports..."

    stage_start

    if ! python3 scripts/run.py imports; then
        die "Typst import validation failed."
    fi

    stage_end TIME_IMPORT_CHECK
}

# ============================================================
# 5. Initialize dist
#
# Initialize the output directories, copy assets, and verify
# that the generated homepage metadata is available.
# ============================================================

prepare_dist() {

    echo
    echo "📁 Preparing dist..."

    python3 scripts/run.py prepare-dist
}

# ============================================================
# 6. Generate homepage and compile pages
# ============================================================

build_html() {

    echo
    echo "🌐 Building course pages..."

    stage_start

    python3 scripts/run.py html

    stage_end TIME_HTML
}

# ============================================================
# 7. Build individual page PDFs
# ============================================================

build_pdf() {

    echo
    echo "📄 Building individual page PDFs..."

    stage_start

    python3 scripts/run.py pdf

    stage_end TIME_PDF
}

# ============================================================
# 8. Build all PDFs
# ============================================================

build_allpdf() {

    build_pdf
    build_categories
    build_book
    build_pages_pdf
}

# ============================================================
# 9. Build category books
# ============================================================

build_categories() {

    echo
    echo "📚 Building category books..."

    stage_start

    python3 scripts/run.py categories

    stage_end TIME_CATEGORIES
}

# ============================================================
# 10. Build complete course PDF
# ============================================================

build_book() {

    echo
    echo "📚 Building together complete course book..."

    stage_start

    python3 scripts/run.py book

    stage_end TIME_BOOK
}

# ============================================================
# 11. Build complete pages PDF
# ============================================================

build_pages_pdf() {

    echo
    echo "📚 Building together complete pages.pdf..."

    stage_start

    python3 scripts/run.py pages-pdf

    stage_end TIME_PAGES
}

# ============================================================
# 12. Check links
# ============================================================

validate_links() {

    echo
    echo "🔗 Checking links..."

    stage_start

    if ! python3 scripts/run.py links; then

        die "broken links detected."

    fi

    stage_end TIME_LINKS
}

# ============================================================
# 13. Build diagnostics summary
#
# The individual reports are still produced at their normal
# stages above. This final section gives a compact overview
# so the build result can be checked without scrolling back.
#
# The existing diagnostic files are read here; the checks are
# NOT executed again.
# ============================================================

print_summary() {

    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))

    BUILD_TIME="$BUILD_TIME" \
    TIME_METADATA="$TIME_METADATA" \
    TIME_METADATA_CHECK="$TIME_METADATA_CHECK" \
    TIME_GENERATED_CHECK="$TIME_GENERATED_CHECK" \
    TIME_IMPORT_CHECK="$TIME_IMPORT_CHECK" \
    TIME_HTML="$TIME_HTML" \
    TIME_PDF="$TIME_PDF" \
    TIME_CATEGORIES="$TIME_CATEGORIES" \
    TIME_BOOK="$TIME_BOOK" \
    TIME_PAGES="$TIME_PAGES" \
    TIME_LINKS="$TIME_LINKS" \
        python3 scripts/run.py report
}

# ============================================================
# 14. Build targets
#
# All targets perform the common metadata and validation
# stages first.
#
# Target-specific stages are then executed.
# ============================================================

run_common_checks() {

    generate_metadata
    validate_metadata
    validate_generated
    validate_imports
    prepare_dist
}

run_all() {

    run_common_checks

    build_html
    build_allpdf
    validate_links
}

run_html() {

    run_common_checks

    build_html
}

run_pdf() {

    run_common_checks

    build_pdf
}

run_allpdf() {

    run_common_checks

    build_allpdf
}

run_categories() {

    run_common_checks

    build_categories
}

run_book() {

    run_common_checks

    build_book
}

run_pages_pdf() {

    run_common_checks

    build_pages_pdf
}

# ============================================================
# 15. Select build target
# ============================================================

case "$TARGET" in

    all)
        run_all
        ;;

    html)
        run_html
        ;;

    pdf)
        run_pdf
        ;;

    allpdf)
        run_allpdf
        ;;

    categories)
        run_categories
        ;;

    book)
        run_book
        ;;

    pages-pdf)
        run_pages_pdf
        ;;

    *)
        echo "Unknown build target: $TARGET"
        echo
        echo "Run './build.sh --help' for usage information."
        exit 1
        ;;

esac

# ============================================================
# 16. Print summary
# ============================================================

print_summary