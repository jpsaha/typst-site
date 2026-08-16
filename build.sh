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

    if ! python3 scripts/run.py metadata; then
        die "metadata generation failed."
    fi

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
# 2a. Check central configuration
#
# Audit configuration usage throughout the Python build
# system. The detailed report is written to:
#
#     diagnostics/config_report.txt
#
# ============================================================

validate_config() {

    echo
    echo "⚙️  Checking configuration..."

    stage_start

    if ! python3 scripts/run.py config; then
        die "configuration audit failed."
    fi

    stage_end TIME_CONFIG_CHECK
}

# ============================================================
# 2b. Check source metadata
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
# 2c. Check generated files
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
# 2d. Check Typst imports
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
# 2e. Check Open Graph images
#
# Verify that generated HTML pages contain valid Open Graph
# image references and that the referenced image files exist.
# ============================================================

validate_og() {

    echo
    echo "🖼️  Checking Open Graph images..."

    stage_start

    if ! python3 scripts/run.py og-check; then
        die "Open Graph image check failed."
    fi

    stage_end TIME_OG_CHECK
}

# ============================================================
# 2f. Check links
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

    if ! python3 scripts/run.py prepare-dist; then
        die "dist preparation failed."
    fi

    stage_end TIME_PREPARE_DIST
}

# ============================================================
# 3b. Prepare diagnostics
# ============================================================

prepare_diagnostics() {

    echo
    echo "🧹 Preparing diagnostics..."

    stage_start

    if ! python3 scripts/run.py prepare-diagnostics; then
        die "diagnostics preparation failed."
    fi

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

    if ! python3 scripts/run.py html; then
        die "HTML build failed."
    fi

    stage_end TIME_HTML
}

# ============================================================
# 4b. Generate sitemap
# ============================================================

build_sitemap() {

    echo
    echo "🗺️  Generating sitemap..."

    stage_start

    if ! python3 scripts/run.py sitemap; then
        die "sitemap generation failed."
    fi

    stage_end TIME_SITEMAP
}

# ============================================================
# 4c. Generate robots.txt
# ============================================================

build_robots() {

    echo
    echo "🤖 Generating robots.txt..."

    stage_start

    if ! python3 scripts/run.py robots; then
        die "robots.txt generation failed."
    fi

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

    if ! python3 scripts/run.py pdf; then
        die "individual PDF build failed."
    fi

    stage_end TIME_PDF
}

# ============================================================
# 5b. Build category books
# ============================================================

build_categories() {

    echo
    echo "📚 Building category books..."

    stage_start

    if ! python3 scripts/run.py categories; then
        die "category PDF build failed."
    fi

    stage_end TIME_CATEGORIES
}

# ============================================================
# 5c. Build complete course PDF
# ============================================================

build_book() {

    echo
    echo "📚 Building complete course book..."

    stage_start

    if ! python3 scripts/run.py book; then
        die "complete course book build failed."
    fi

    stage_end TIME_BOOK
}

# ============================================================
# 5d. Build complete pages PDF
# ============================================================

build_pages_pdf() {

    echo
    echo "📚 Building complete pages.pdf..."

    stage_start

    if ! python3 scripts/run.py pages-pdf; then
        die "complete pages PDF build failed."
    fi

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
    TIME_CONFIG_CHECK="$TIME_CONFIG_CHECK" \
    TIME_METADATA="$TIME_METADATA" \
    TIME_OG_GENERATE="$TIME_OG_GENERATE" \
    TIME_OG_BUILD="$TIME_OG_BUILD" \
    TIME_METADATA_CHECK="$TIME_METADATA_CHECK" \
    TIME_GENERATED_CHECK="$TIME_GENERATED_CHECK" \
    TIME_IMPORT_CHECK="$TIME_IMPORT_CHECK" \
    TIME_OG_CHECK="$TIME_OG_CHECK" \
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
# These stages are performed before every build target that
# produces or validates site output.
#
# Order:
#
#   1. Generate metadata
#   2. Validate source metadata
#   3. Validate generated files
#   4. Generate Open Graph Asymptote sources
#   5. Build Open Graph PNG images
#   6. Validate central configuration
#   7. Validate Typst imports
#
# The configuration audit is included here because the build
# depends on scripts/config.py being used consistently.
#
# Dist preparation is intentionally kept separate because it
# is a build preparation step, not a validation step.
#
# Open Graph validation is also kept separate. It requires the
# generated HTML files in dist/ and therefore must run after
# the HTML output has been built.
# ============================================================

run_common_checks() {

    # --------------------------------------------------------
    # Generation
    # --------------------------------------------------------

    generate_metadata

    # --------------------------------------------------------
    # Source and generated-file validation
    # --------------------------------------------------------

    validate_metadata
    validate_generated

    # --------------------------------------------------------
    # Open Graph generation
    #
    # Generate the OG source files first, then rasterize them
    # into PNG images.
    # --------------------------------------------------------

    generate_og
    build_og

    # --------------------------------------------------------
    # Central configuration audit
    #
    # Check that configuration-like values are centralized
    # appropriately in scripts/config.py.
    # --------------------------------------------------------

    validate_config

    # --------------------------------------------------------
    # Typst dependency validation
    #
    # Verify that imported Typst files exist and that there
    # are no circular import dependencies.
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
#      directly in this build.sh file:
#
#          all
#          allpdf
#
#   2. Individual targets
#
#      These correspond to commands registered in scripts/run.py
#      and are delegated to the Python command registry.
#
#      For example:
#
#          ./build.sh og-generate
#
#      executes:
#
#          python3 scripts/run.py og-generate
#
#
# ------------------------------------------------------------
# Complete build
# ------------------------------------------------------------
#
# The "all" target performs the complete production build.
#
#     ./build.sh
#     ./build.sh all
#
# The complete build proceeds in this order:
#
#   1.  Prepare diagnostics
#   2.  Run common generation and validation
#   3.  Prepare dist
#   4.  Build HTML
#   5.  Generate sitemap
#   6.  Generate robots.txt
#   7.  Validate Open Graph references
#   8.  Build all PDF outputs
#   9.  Check links
#   10. Print the final diagnostics summary
#
# Common generation and validation includes:
#
#   - Configuration audit
#   - Metadata generation
#   - Source metadata validation
#   - Generated-file validation
#   - Open Graph source generation
#   - Open Graph image generation
#   - Typst import validation
#
# Open Graph validation is deliberately performed after HTML
# generation because it checks the generated HTML files in
# dist/ and verifies their referenced OG images.
#
# Link validation is performed near the end because all HTML,
# PDF, and other referenced output files should exist before
# links are checked.
#
#
# ------------------------------------------------------------
# Configuration target
# ------------------------------------------------------------
#
#   config
#
#       Audit Python configuration usage throughout the project.
#
#       The audit identifies configuration-like values outside
#       scripts/config.py, including:
#
#       - uppercase constants
#       - Path(...) constructions
#       - ROOT / ... path constructions
#       - hardcoded project directory names
#       - hardcoded project/website strings
#       - configuration-like numeric values
#       - imports from scripts.config
#       - redefinitions of imported configuration names
#
#       This is a diagnostic/audit tool rather than a strict
#       failure for every finding. Local implementation
#       constants may legitimately remain outside config.py.
#
#       Usage:
#
#           ./build.sh config
#
#
# ------------------------------------------------------------
# Generation targets
# ------------------------------------------------------------
#
#   metadata
#
#       Generate metadata and generated Typst/JSON files.
#
#       This discovers source files, parses their metadata,
#       generates navigation information, and writes the
#       generated metadata files used by later build stages.
#
#       Usage:
#
#           ./build.sh metadata
#
#
#   og-generate
#
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
#
#       Convert generated Open Graph Asymptote sources into PNG
#       images.
#
#       The build searches recursively for:
#
#           generated/og/**/*.asy
#
#       and creates corresponding PNG files while preserving
#       the directory structure.
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
#
#       Validate metadata supplied by source Typst files.
#
#       Usage:
#
#           ./build.sh metadata-check
#
#
#   generated
#
#       Validate consistency between source metadata and the
#       generated files.
#
#       Usage:
#
#           ./build.sh generated
#
#
#   imports
#
#       Check Typst imports and detect missing imports or
#       circular dependencies.
#
#       The detailed dependency graph is written to:
#
#           diagnostics/imports.dot
#
#       Usage:
#
#           ./build.sh imports
#
#
#   og-check
#
#       Validate Open Graph references in generated HTML.
#
#       The check verifies that:
#
#       - expected HTML pages exist
#       - og:image references are present where required
#       - OG URLs are valid
#       - OG images are located under dist/assets/og/
#       - referenced OG image files exist
#
#       This check must normally be run after the HTML build.
#
#       Usage:
#
#           ./build.sh og-check
#
#
#   links
#
#       Check links in the generated website.
#
#       This is normally run near the end of the complete
#       build, after HTML and all referenced output files have
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
#
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
#
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
#
#       Build the HTML pages.
#
#       This target performs only the HTML build operation.
#       It does not automatically generate sitemap.xml,
#       robots.txt, or run OG validation.
#
#       Usage:
#
#           ./build.sh html
#
#
#   sitemap
#
#       Generate sitemap.xml for the website.
#
#       Usage:
#
#           ./build.sh sitemap
#
#
#   robots
#
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
#
#       Build individual page PDFs.
#
#       Usage:
#
#           ./build.sh pdf
#
#
#   categories
#
#       Build the PDF corresponding to each category.
#
#       Usage:
#
#           ./build.sh categories
#
#
#   book
#
#       Build the complete course/book PDF.
#
#       Usage:
#
#           ./build.sh book
#
#
#   pages-pdf
#
#       Build the combined pages PDF.
#
#       Usage:
#
#           ./build.sh pages-pdf
#
#
#   allpdf
#
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
#
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
#     ./build.sh config
#
# performs only the configuration audit.
#
#     ./build.sh og-generate
#
# performs only Open Graph source generation.
#
#     ./build.sh og-build
#
# performs only Open Graph PNG generation.
#
#     ./build.sh og-check
#
# checks the existing generated HTML/OG output.
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
            #
            # This performs:
            #
            #   1. Configuration audit
            #   2. Metadata generation
            #   3. Metadata validation
            #   4. Generated-file validation
            #   5. Open Graph generation
            #   6. Open Graph image build
            #   7. Typst import validation
            # ------------------------------------------------

            run_common_checks

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
            # Open Graph validation
            #
            # This must run after HTML generation because
            # check_og.py examines the generated HTML files
            # and their OG image references in dist/.
            # ------------------------------------------------

            validate_og

            # ------------------------------------------------
            # PDF output
            # ------------------------------------------------

            build_allpdf

            # ------------------------------------------------
            # Final link validation
            #
            # All generated HTML and referenced output files
            # should now exist.
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
        # Configuration audit
        # ====================================================

        config)

            python3 scripts/run.py config

            ;;

        # ====================================================
        # Generation
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

        # ====================================================
        # Validation
        # ====================================================

        metadata-check)

            python3 scripts/run.py metadata-check

            ;;

        generated)

            python3 scripts/run.py generated

            ;;

        imports)

            python3 scripts/run.py imports

            ;;

        og-check)

            python3 scripts/run.py og-check

            ;;

        links)

            python3 scripts/run.py links

            ;;

        # ====================================================
        # Build preparation
        # ====================================================

        prepare-dist)

            python3 scripts/run.py prepare-dist

            ;;

        prepare-diagnostics)

            python3 scripts/run.py prepare-diagnostics

            ;;

        # ====================================================
        # Website output
        # ====================================================

        html)

            python3 scripts/run.py html

            ;;

        sitemap)

            python3 scripts/run.py sitemap

            ;;

        robots)

            python3 scripts/run.py robots

            ;;

        # ====================================================
        # PDF output
        # ====================================================

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

        # ====================================================
        # Diagnostics
        # ====================================================

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
# completed so that all available stage timings and diagnostic
# information can be included.
#
# For the complete build, this produces the final build
# summary.
# ============================================================

print_summary