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
        Run the complete website build.

    --------------------------------------------------------
    Generation
    --------------------------------------------------------

    metadata
        Generate metadata and generated Typst files.

    og-generate
        Generate Open Graph Asymptote sources.

    og-build
        Build PNG Open Graph images from Asymptote sources.

    --------------------------------------------------------
    Validation
    --------------------------------------------------------

    metadata-check
        Validate source metadata.

    generated
        Validate generated files.

    imports
        Validate Typst imports.

    links
        Check links in the generated website.

    --------------------------------------------------------
    Build preparation
    --------------------------------------------------------

    prepare-dist
        Prepare the dist directory and copy assets.

    prepare-diagnostics
        Prepare the diagnostics directory.

    --------------------------------------------------------
    Website output
    --------------------------------------------------------

    html
        Build HTML lecture pages.

    sitemap
        Generate sitemap.xml.

    robots
        Generate robots.txt.

    --------------------------------------------------------
    PDF output
    --------------------------------------------------------

    pdf
        Build individual page PDFs.

    categories
        Build category PDFs.

    book
        Build the complete course book PDF.

    pages-pdf
        Build the complete pages PDF.

    allpdf
        Build all PDF outputs.

    --------------------------------------------------------
    Diagnostics
    --------------------------------------------------------

    report
        Build the diagnostics/build report.

Options:

    -h, --help
        Show this help message.

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
# Validate command-line target
# ============================================================

case "$TARGET" in

    # --------------------------------------------------------
    # Complete build
    # --------------------------------------------------------

    all)

        ;;

    # --------------------------------------------------------
    # Generation
    # --------------------------------------------------------

    metadata|og-generate|og-build)

        ;;

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    metadata-check|generated|imports|links)

        ;;

    # --------------------------------------------------------
    # Build preparation
    # --------------------------------------------------------

    prepare-dist|prepare-diagnostics)

        ;;

    # --------------------------------------------------------
    # Website output
    # --------------------------------------------------------

    html|sitemap|robots)

        ;;

    # --------------------------------------------------------
    # PDF output
    # --------------------------------------------------------

    pdf|categories|book|pages-pdf|allpdf)

        ;;

    # --------------------------------------------------------
    # Diagnostics
    # --------------------------------------------------------

    report)

        ;;

    # --------------------------------------------------------
    # Invalid target
    # --------------------------------------------------------

    *)

        echo "Unknown build target: $TARGET"
        echo
        echo "Run './build.sh --help' for usage information."
        exit 1
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

# ------------------------------------------------------------
# Generation
# ------------------------------------------------------------

TIME_METADATA="0"
TIME_OG_GENERATE="0"
TIME_OG_BUILD="0"

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------

TIME_METADATA_CHECK="0"
TIME_GENERATED_CHECK="0"
TIME_IMPORT_CHECK="0"
TIME_LINKS="0"

# ------------------------------------------------------------
# Build preparation
# ------------------------------------------------------------

TIME_PREPARE_DIST="0"
TIME_PREPARE_DIAGNOSTICS="0"

# ------------------------------------------------------------
# Website output
# ------------------------------------------------------------

TIME_HTML="0"
TIME_SITEMAP="0"
TIME_ROBOTS="0"

# ------------------------------------------------------------
# PDF output
# ------------------------------------------------------------

TIME_PDF="0"
TIME_CATEGORIES="0"
TIME_BOOK="0"
TIME_PAGES="0"

# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------

TIME_REPORT="0"

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
#
# Remove Python bytecode generated during the build.
# Preserve the original exit status of the build.
# ============================================================

cleanup() {

    local status=$?

    if find scripts \
        -type d \
        -name "__pycache__" \
        -print -quit |
        grep -q .
    then
        echo
        echo "🧹 Cleaning Python bytecode..."

        find scripts \
            -type d \
            -name "__pycache__" \
            -prune \
            -exec rm -rf {} +

        echo "✓ Python bytecode removed."
    fi

    return "$status"
}

trap cleanup EXIT

# ============================================================
# 1. Generation
# ============================================================

# ============================================================
# 1a. Generate metadata
# ============================================================

generate_metadata() {

    echo
    echo "📋 Generating metadata..."

    stage_start

    python3 scripts/run.py metadata

    stage_end TIME_METADATA
}

# ============================================================
# 1b. Generate Open Graph Asymptote sources
# ============================================================

generate_og() {

    echo
    echo "🖼️  Generating Open Graph sources..."

    stage_start

    if ! python3 scripts/run.py og-generate; then
        die "Open Graph source generation failed."
    fi

    stage_end TIME_OG_GENERATE
}

# ============================================================
# 1c. Build Open Graph PNG images
# ============================================================

build_og() {

    echo
    echo "🖼️  Building Open Graph images..."

    stage_start

    if ! python3 scripts/run.py og-build; then
        die "Open Graph image generation failed."
    fi

    stage_end TIME_OG_BUILD
}


# ============================================================
# 2. Validation
# ============================================================

# ============================================================
# 2a. Check source metadata
# ============================================================

validate_metadata() {

    echo
    echo "📋 Validating source metadata..."

    stage_start

    if ! python3 scripts/run.py metadata-check; then
        die "metadata validation failed."
    fi

    stage_end TIME_METADATA_CHECK
}

# ============================================================
# 2b. Check generated files
# ============================================================

validate_generated() {

    echo
    echo "🔍 Validating generated files..."

    stage_start

    if ! python3 scripts/run.py generated; then
        die "generated consistency check failed."
    fi

    stage_end TIME_GENERATED_CHECK
}

# ============================================================
# 2c. Check Typst imports
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
    echo "🔍 Validating Typst imports..."

    stage_start

    if ! python3 scripts/run.py imports; then
        die "Typst import validation failed."
    fi

    stage_end TIME_IMPORT_CHECK
}

# ============================================================
# 2d. Check links
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
# 3. Build preparation
# ============================================================

# ============================================================
# 3a. Prepare dist
#
# Delegate dist preparation to the Python build layer.
# ============================================================

prepare_dist() {

    echo
    echo "📁 Preparing dist..."

    stage_start

    python3 scripts/run.py prepare-dist

    stage_end TIME_PREPARE_DIST
}

# ============================================================
# 3b. Prepare diagnostics
# ============================================================

prepare_diagnostics() {

    echo
    echo "🧹 Preparing diagnostics..."

    stage_start

    python3 scripts/run.py prepare-diagnostics

    stage_end TIME_PREPARE_DIAGNOSTICS

    echo "✓ Diagnostics directory prepared."
}


# ============================================================
# 4. Website output
# ============================================================

# ============================================================
# 4a. Build HTML pages
# ============================================================

build_html() {

    echo
    echo "🌐 Building course pages..."

    stage_start

    python3 scripts/run.py html

    stage_end TIME_HTML
}

# ============================================================
# 4b. Generate sitemap
# ============================================================

build_sitemap() {

    echo
    echo "🗺️  Generating sitemap..."

    stage_start

    python3 scripts/run.py sitemap

    stage_end TIME_SITEMAP
}

# ============================================================
# 4c. Generate robots.txt
# ============================================================

build_robots() {

    echo
    echo "🤖 Generating robots.txt..."

    stage_start

    python3 scripts/run.py robots

    stage_end TIME_ROBOTS
}


# ============================================================
# 5. PDF output
# ============================================================

# ============================================================
# 5a. Build individual page PDFs
# ============================================================

build_pdf() {

    echo
    echo "📄 Building individual page PDFs..."

    stage_start

    python3 scripts/run.py pdf

    stage_end TIME_PDF
}

# ============================================================
# 5b. Build category books
# ============================================================

build_categories() {

    echo
    echo "📚 Building category books..."

    stage_start

    python3 scripts/run.py categories

    stage_end TIME_CATEGORIES
}

# ============================================================
# 5c. Build complete course PDF
# ============================================================

build_book() {

    echo
    echo "📚 Building complete course book..."

    stage_start

    python3 scripts/run.py book

    stage_end TIME_BOOK
}

# ============================================================
# 5d. Build complete pages PDF
# ============================================================

build_pages_pdf() {

    echo
    echo "📚 Building complete pages.pdf..."

    stage_start

    python3 scripts/run.py pages-pdf

    stage_end TIME_PAGES
}

# ============================================================
# 5e. Composite PDF build
#
# Build all PDF outputs:
#
#   1. Individual page PDFs
#   2. Category PDFs
#   3. Complete course book
#   4. Complete pages PDF
#
# This is a composite operation, so its constituent stages
# provide the individual timings.
# ============================================================

build_allpdf() {

    build_pdf
    build_categories
    build_book
    build_pages_pdf
}


# ============================================================
# 6. Diagnostics
# ============================================================

# ============================================================
# 6a. Build diagnostics summary
#
# Delegate report generation to the Python build layer.
# ============================================================

print_summary() {

    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))

    BUILD_TIME="$BUILD_TIME" \
    TIME_METADATA="$TIME_METADATA" \
    TIME_OG_GENERATE="$TIME_OG_GENERATE" \
    TIME_OG_BUILD="$TIME_OG_BUILD" \
    TIME_METADATA_CHECK="$TIME_METADATA_CHECK" \
    TIME_GENERATED_CHECK="$TIME_GENERATED_CHECK" \
    TIME_IMPORT_CHECK="$TIME_IMPORT_CHECK" \
    TIME_LINKS="$TIME_LINKS" \
    TIME_PREPARE_DIST="$TIME_PREPARE_DIST" \
    TIME_PREPARE_DIAGNOSTICS="$TIME_PREPARE_DIAGNOSTICS" \
    TIME_HTML="$TIME_HTML" \
    TIME_SITEMAP="$TIME_SITEMAP" \
    TIME_ROBOTS="$TIME_ROBOTS" \
    TIME_PDF="$TIME_PDF" \
    TIME_CATEGORIES="$TIME_CATEGORIES" \
    TIME_BOOK="$TIME_BOOK" \
    TIME_PAGES="$TIME_PAGES" \
    TIME_REPORT="$TIME_REPORT" \
        python3 scripts/run.py report
}

# ============================================================
# Build pipeline
# ============================================================

# ============================================================
# Common validation
#
# These checks and generation stages are performed before
# every build target.
#
# They:
#
#   1. Generate metadata.
#   2. Validate source metadata.
#   3. Validate generated files.
#   4. Generate Open Graph sources and PNGs.
#   5. Validate Typst imports.
#
# Dist preparation is intentionally kept separate because it
# is a build preparation step, not a validation step.
# ============================================================

run_common_checks() {

    generate_metadata
    validate_metadata
    validate_generated
    generate_og
    validate_imports
}

# ============================================================
# Build dispatcher
#
# Every build target performs:
#
#   1. Common metadata, OG generation and validation checks.
#   2. Dist preparation.
#   3. The build stages required by the selected target.
#
# Supported targets:
#
#   all
#       HTML + all PDFs + link validation
#
#   html
#       HTML pages only
#
#   pdf
#       Individual PDFs only
#
#   allpdf
#       All PDF outputs
#
#   categories
#       Category PDFs only
#
#   book
#       Complete course PDF only
#
#   pages-pdf
#       Complete pages PDF only
# ============================================================

run_build() {

    prepare_diagnostics

    # --------------------------------------------------------
    # Common validation and generation
    # --------------------------------------------------------

    run_common_checks

    # --------------------------------------------------------
    # Prepare output directories and assets
    # --------------------------------------------------------

    prepare_dist

    # --------------------------------------------------------
    # Target-specific build
    # --------------------------------------------------------

    case "$TARGET" in

        all)
            build_html
            build_allpdf
            validate_links
            ;;

        html)
            build_html
            ;;

        pdf)
            build_pdf
            ;;

        allpdf)
            build_allpdf
            ;;

        categories)
            build_categories
            ;;

        book)
            build_book
            ;;

        pages-pdf)
            build_pages_pdf
            ;;

    esac
}

# ============================================================
# Run selected build target
# ============================================================

run_build

# ============================================================
# Print summary
# ============================================================

print_summary