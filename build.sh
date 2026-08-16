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
#     ./build.sh config
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

If TARGET is omitted, "all" is used.


Targets:

    ┌──────────────────────┬─────────────────────────────────────┬──────────────────────────────────────────────┐
    │ Target               │ Example                             │ Description                                  │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ all                  │ ./build.sh                          │ Complete website + all PDFs + link check     │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ config               │ ./build.sh config                   │ Audit centralized configuration              │
    │ metadata             │ ./build.sh metadata                 │ Generate metadata                            │
    │ og-generate          │ ./build.sh og-generate              │ Generate Open Graph .asy sources             │
    │ og-build             │ ./build.sh og-build                 │ Build Open Graph PNG images                  │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ metadata-check       │ ./build.sh metadata-check           │ Validate source metadata                     │
    │ generated            │ ./build.sh generated                │ Validate generated files                     │
    │ imports              │ ./build.sh imports                  │ Validate Typst imports                       │
    │ links                │ ./build.sh links                    │ Check generated website links                │
    │ og-check             │ ./build.sh og-check                 │ Validate Open Graph images in HTML           │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ prepare-dist         │ ./build.sh prepare-dist             │ Prepare dist/ and copy static assets         │
    │ prepare-diagnostics  │ ./build.sh prepare-diagnostics      │ Prepare diagnostics/                         │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ html                 │ ./build.sh html                     │ Build HTML pages                             │
    │ sitemap              │ ./build.sh sitemap                  │ Generate sitemap.xml                         │
    │ robots               │ ./build.sh robots                   │ Generate robots.txt                          │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ pdf                  │ ./build.sh pdf                      │ Build individual page PDFs                   │
    │ categories           │ ./build.sh categories               │ Build category PDFs                          │
    │ book                 │ ./build.sh book                     │ Build complete course/book PDF               │
    │ pages-pdf            │ ./build.sh pages-pdf                │ Build combined pages PDF                     │
    │ allpdf               │ ./build.sh allpdf                   │ Build all PDF outputs                        │
    ├──────────────────────┼─────────────────────────────────────┼──────────────────────────────────────────────┤
    │ report               │ ./build.sh report                   │ Generate diagnostics/build report            │
    └──────────────────────┴─────────────────────────────────────┴──────────────────────────────────────────────┘


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
    # Configuration and generation
    # --------------------------------------------------------

    config|metadata|og-generate|og-build)

        ;;

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    metadata-check|generated|imports|links|og-check)

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
# Configuration and generation
# ------------------------------------------------------------

TIME_CONFIG="0"
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
TIME_OG_CHECK="0"


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
# Common generation and validation
#
# These stages are performed before every build target.
#
# Order:
#
#   1. Generate metadata
#   2. Validate source metadata
#   3. Validate generated files
#   4. Generate Open Graph Asymptote sources
#   5. Build Open Graph PNG images
#   6. Validate Typst imports
#
# Dist preparation is intentionally kept separate because it
# is a build preparation step, not a validation step.
# ============================================================

run_common_checks() {

    # --------------------------------------------------------
    # Generation
    # --------------------------------------------------------

    generate_metadata

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    validate_metadata
    validate_generated

    # --------------------------------------------------------
    # Open Graph generation
    # --------------------------------------------------------

    generate_og
    build_og

    # --------------------------------------------------------
    # Typst dependency validation
    # --------------------------------------------------------

    validate_imports
}


# ============================================================
# Build dispatcher
#
# The build dispatcher determines which build operation should
# be executed for the selected TARGET.
#
# Usage:
#
#     ./build.sh
#     ./build.sh all
#     ./build.sh <target>
#
# If no target is supplied, TARGET defaults to "all".
#
# The dispatcher has two kinds of targets:
#
#   1. Composite targets
#
#      These combine several build stages and are implemented
#      directly in this build.sh file.
#
#          all
#          allpdf
#
#   2. Individual targets
#
#      These correspond directly to commands registered in
#      scripts/run.py and are delegated to:
#
#          python3 scripts/run.py <target>
#
#      For example:
#
#          ./build.sh og-generate
#
#      is equivalent to:
#
#          python3 scripts/run.py og-generate
#
#
# ------------------------------------------------------------
# Complete build
# ------------------------------------------------------------
#
# The "all" target performs the complete build pipeline.
#
#     ./build.sh
#     ./build.sh all
#
# The complete build proceeds in the following order:
#
#   1.  Prepare diagnostics
#
#       Remove previous diagnostic output and recreate the
#       diagnostics directory.
#
#   2.  Generate metadata
#
#       Discover source files, parse their metadata, generate
#       the metadata JSON/Typst files, navigation data, and
#       other generated metadata required by later stages.
#
#   3.  Validate source metadata
#
#       Check that the metadata supplied by the source Typst
#       files satisfies the project's metadata requirements.
#
#   4.  Validate generated files
#
#       Check that generated files are consistent with the
#       current source metadata.
#
#   5.  Generate Open Graph sources
#
#       Generate .asy files under:
#
#           generated/og/
#
#       for lectures that do not already provide a custom
#       Open Graph image.
#
#       If a lecture already specifies an "og_image" in its
#       metadata, no generated .asy source is created for it.
#
#   6.  Build Open Graph images
#
#       Recursively process:
#
#           generated/og/**/*.asy
#
#       and generate corresponding PNG files while preserving
#       the directory structure.
#
#   7.  Validate Typst imports
#
#       Verify that imported Typst files exist and that there
#       are no circular import dependencies.
#
#       The detailed dependency graph is written to:
#
#           diagnostics/imports.dot
#
#   8.  Prepare dist
#
#       Remove the previous distribution directory, recreate
#       the required output directories, and copy the required
#       static assets.
#
#   9.  Build HTML
#
#       Compile the lecture and resource pages and place the
#       resulting website files under:
#
#           dist/pages/
#
#   10. Generate sitemap
#
#       Generate sitemap.xml for the deployed website.
#
#   11. Generate robots.txt
#
#       Generate the robots.txt file for the deployed website.
#
#   12. Build individual PDFs
#
#       Generate the PDF corresponding to each page.
#
#   13. Build category PDFs
#
#       Generate the combined PDF for each category.
#
#   14. Build complete course book
#
#       Generate the complete course/book PDF.
#
#   15. Build complete pages PDF
#
#       Generate the combined pages PDF.
#
#   16. Check links
#
#       Check links in the final generated HTML files.
#
#       This check is performed only after the HTML output and
#       all referenced files have been generated.
#
#   17. Print diagnostics summary
#
#       After run_build() completes, print_summary() generates
#       the final build diagnostics summary, including stage
#       timings.
#
#
# ------------------------------------------------------------
# Individual generation targets
# ------------------------------------------------------------
#
#   metadata
#       Generate metadata and generated Typst/JSON files.
#
#       Usage:
#
#           ./build.sh metadata
#
#       Delegates to:
#
#           python3 scripts/run.py metadata
#
#
#   og-generate
#       Generate Open Graph Asymptote source files.
#
#       Generated files are placed under:
#
#           generated/og/
#
#       The directory structure follows the source structure.
#
#       Lectures with an explicitly supplied "og_image" are
#       skipped because their custom image should be used
#       instead of generating a default image.
#
#       Usage:
#
#           ./build.sh og-generate
#
#
#   og-build
#       Convert generated Open Graph Asymptote sources into PNG
#       images.
#
#       The build searches recursively for:
#
#           generated/og/**/*.asy
#
#       and creates corresponding:
#
#           generated/og/**/*.png
#
#       while preserving the directory structure.
#
#       Usage:
#
#           ./build.sh og-build
#
#
# ------------------------------------------------------------
# Validation targets
# ------------------------------------------------------------
#
#   metadata-check
#       Validate metadata supplied by source Typst files.
#
#       Usage:
#
#           ./build.sh metadata-check
#
#
#   generated
#       Validate consistency between source metadata and the
#       generated files.
#
#       Usage:
#
#           ./build.sh generated
#
#
#   imports
#       Check Typst imports and detect missing imports or
#       circular dependencies.
#
#       Usage:
#
#           ./build.sh imports
#
#
#   links
#       Check links in the generated website.
#
#       This is normally run near the end of the complete
#       build, after all HTML and referenced output files have
#       been generated.
#
#       Usage:
#
#           ./build.sh links
#
#
# ------------------------------------------------------------
# Build preparation targets
# ------------------------------------------------------------
#
#   prepare-dist
#       Prepare the dist directory for a fresh build.
#
#       This removes previous distribution output, recreates
#       the required directory structure, and copies static
#       assets needed by the deployed website.
#
#       Usage:
#
#           ./build.sh prepare-dist
#
#
#   prepare-diagnostics
#       Prepare a clean diagnostics directory before a build.
#
#       Usage:
#
#           ./build.sh prepare-diagnostics
#
#
# ------------------------------------------------------------
# Website output targets
# ------------------------------------------------------------
#
#   html
#       Build the HTML pages.
#
#       This target performs only the HTML build operation.
#       It does not automatically generate sitemap.xml or
#       robots.txt.
#
#       Usage:
#
#           ./build.sh html
#
#
#   sitemap
#       Generate sitemap.xml for the website.
#
#       Usage:
#
#           ./build.sh sitemap
#
#
#   robots
#       Generate robots.txt for the website.
#
#       Usage:
#
#           ./build.sh robots
#
#
# ------------------------------------------------------------
# PDF output targets
# ------------------------------------------------------------
#
#   pdf
#       Build individual page PDFs.
#
#       Usage:
#
#           ./build.sh pdf
#
#
#   categories
#       Build the PDF corresponding to each category.
#
#       Usage:
#
#           ./build.sh categories
#
#
#   book
#       Build the complete course/book PDF.
#
#       Usage:
#
#           ./build.sh book
#
#
#   pages-pdf
#       Build the combined pages PDF.
#
#       Usage:
#
#           ./build.sh pages-pdf
#
#
#   allpdf
#       Build every PDF output.
#
#       This is a composite target consisting of:
#
#           1. Individual page PDFs
#           2. Category PDFs
#           3. Complete course/book PDF
#           4. Complete pages PDF
#
#       Usage:
#
#           ./build.sh allpdf
#
#
# ------------------------------------------------------------
# Diagnostics target
# ------------------------------------------------------------
#
#   report
#       Generate the diagnostics/build report.
#
#       This target delegates directly to:
#
#           python3 scripts/run.py report
#
#       Usage:
#
#           ./build.sh report
#
#
# ------------------------------------------------------------
# Target independence
# ------------------------------------------------------------
#
# Individual targets are intentionally independent.
#
# For example:
#
#     ./build.sh og-generate
#
# performs only Open Graph source generation.
#
#     ./build.sh og-build
#
# performs only Open Graph PNG generation.
#
#     ./build.sh html
#
# performs only the HTML build.
#
#     ./build.sh sitemap
#
# performs only sitemap generation.
#
#     ./build.sh report
#
# performs only diagnostics report generation.
#
# These individual commands do not automatically execute the
# complete build pipeline.
#
# This makes it possible to inspect, debug, or rerun a single
# stage without unnecessarily rebuilding the entire project.
#
#
# ------------------------------------------------------------
# Relationship with scripts/run.py
# ------------------------------------------------------------
#
# scripts/run.py is the central Python command registry.
#
# build.sh provides the user-facing build interface, while
# scripts/run.py maps each individual command to its Python
# implementation.
#
# Therefore:
#
#     ./build.sh og-generate
#
# eventually executes:
#
#     python3 scripts/run.py og-generate
#
# and scripts/run.py dispatches that command to the
# corresponding Python module.
#
# Composite targets such as "all" and "allpdf" remain in
# build.sh because they represent orchestration of multiple
# independent build stages.
#
# ============================================================

run_build() {

    case "$TARGET" in

        # ====================================================
        # Complete build
        # ====================================================

        all)

            # ------------------------------------------------
            # Prepare diagnostics
            # ------------------------------------------------

            prepare_diagnostics

            # ------------------------------------------------
            # Common generation and validation
            # ------------------------------------------------

            generate_metadata
            validate_metadata
            validate_generated

            # ------------------------------------------------
            # Open Graph generation
            # ------------------------------------------------

            generate_og
            build_og

            # ------------------------------------------------
            # Typst dependency validation
            # ------------------------------------------------

            validate_imports

            # ------------------------------------------------
            # Prepare dist
            # ------------------------------------------------

            prepare_dist

            # ------------------------------------------------
            # Website output
            # ------------------------------------------------

            build_html
            build_sitemap
            build_robots

            # ------------------------------------------------
            # PDF output
            # ------------------------------------------------

            build_allpdf

            # ------------------------------------------------
            # Final validation
            # ------------------------------------------------

            validate_links

            ;;

        # ====================================================
        # All PDFs
        # ====================================================

        allpdf)

            build_allpdf

            ;;

        # ====================================================
        # Individual targets
        #
        # Delegate directly to scripts/run.py.
        # ====================================================

        metadata)

            python3 scripts/run.py metadata

            ;;

        og-generate)

            python3 scripts/run.py og-generate

            ;;

        og-build)

            python3 scripts/run.py og-build

            ;;

        metadata-check)

            python3 scripts/run.py metadata-check

            ;;

        generated)

            python3 scripts/run.py generated

            ;;

        imports)

            python3 scripts/run.py imports

            ;;

        links)

            python3 scripts/run.py links

            ;;

        prepare-dist)

            python3 scripts/run.py prepare-dist

            ;;

        prepare-diagnostics)

            python3 scripts/run.py prepare-diagnostics

            ;;

        html)

            python3 scripts/run.py html

            ;;

        sitemap)

            python3 scripts/run.py sitemap

            ;;

        robots)

            python3 scripts/run.py robots

            ;;

        pdf)

            python3 scripts/run.py pdf

            ;;

        categories)

            python3 scripts/run.py categories

            ;;

        book)

            python3 scripts/run.py book

            ;;

        pages-pdf)

            python3 scripts/run.py pages-pdf

            ;;

        report)

            python3 scripts/run.py report

            ;;

    esac
}

# ============================================================
# Run selected build target
# ============================================================

run_build


# ============================================================
# Print summary
#
# The report is generated after the selected build target has
# completed so that all stage timings and diagnostics are
# available.
# ============================================================

print_summary