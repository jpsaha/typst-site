#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Typst Template Synchronization
#
# Synchronize template/infrastructure changes from:
#
#     typst-site/
#
# into:
#
#     26fgt/
#
# Expected layout:
#
#     common-parent/
#     ├── typst-site/
#     ├── 26fgt/
#     └── sync-typst-template.sh
#
# Usage:
#
#     ./sync-typst-template.sh
#     ./sync-typst-template.sh --dry-run
#     ./sync-typst-template.sh --help
#
# ============================================================


# ============================================================
# Configuration
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEMPLATE_DIR="$SCRIPT_DIR/typst-site"
TARGET_DIR="$SCRIPT_DIR/26fgt"

DRY_RUN=false


# ============================================================
# Files/directories copied from typst-site → 26fgt
#
# These are TEMPLATE / INFRASTRUCTURE files.
#
# Project-specific content is deliberately NOT included.
# ============================================================

SYNC_ITEMS=(
    "templates"
    "assets"
    # "install"
    "scripts"
    "build.sh"
    "book_source.typ"
    "pages_source.typ"
    ".github/workflows/deploy.yml"
)


# ============================================================
# Protected target assets
#
# These files belong to the individual 26fgt project rather
# than the template.
#
# They must never be overwritten or deleted by synchronization.
#
# Paths are relative to:
#
#     assets/
#
# The entire assets/ directory is otherwise synchronized, so
# newly added template assets will automatically be copied.
# ============================================================

PROTECTED_ASSETS=(
    "og/default.pdf"
    "og/default.asy"
    "og/default.png"
    "og/fgt1.png"
    "og/default_1.asy"
    "og/default_2.asy"
    "og/default_3.asy"
    "og/default_4.asy"
    "og/default_5.asy"
    "og/default_6.asy"
    "og/default_7.asy"
    "og/default_8.asy"
)


PROTECTED_SCRIPTS=(
    "site_config.py"
)


# ============================================================
# Usage
# ============================================================

usage() {

    cat <<EOF

Typst Template Synchronization

Synchronizes template/infrastructure files from:

    typst-site/

into:

    26fgt/

Usage:

    ./sync-typst-template.sh
    ./sync-typst-template.sh --dry-run
    ./sync-typst-template.sh --help

Options:

    --dry-run
        Show what would be synchronized without changing 26fgt.

    -h, --help
        Show this help message.

Expected directory structure:

    common-parent/
    ├── typst-site/
    ├── 26fgt/
    └── sync-typst-template.sh

Protected assets:

    assets/og/default.pdf
    assets/og/default.asy
    assets/og/fgt1.png

EOF
}


# ============================================================
# Parse arguments
# ============================================================

case "${1:-}" in

    "")
        ;;

    --dry-run)
        DRY_RUN=true
        ;;

    -h|--help)
        usage
        exit 0
        ;;

    *)
        echo "❌ Unknown option: $1"
        echo
        usage
        exit 1
        ;;

esac


# ============================================================
# Helpers
# ============================================================

die() {

    echo
    echo "❌ Error: $1"
    exit 1
}


# ============================================================
# Build rsync exclusion arguments for assets
#
# Converts:
#
#     PROTECTED_ASSETS=(
#         "og/default.pdf"
#         "og/default.asy"
#         "og/fgt1.png"
#     )
#
# into:
#
#     --exclude=og/default.pdf
#     --exclude=og/default.asy
#     --exclude=og/fgt1.png
#
# This keeps the protected-file list separate from the rsync
# implementation.
# ============================================================

rsync_assets() {

    local source="$1"
    local target="$2"
    local dry_run="${3:-false}"

    local exclude_args=()

    for file in "${PROTECTED_ASSETS[@]}"; do
        exclude_args+=(--exclude="$file")
    done


    # --------------------------------------------------------
    # Normal synchronization
    # --------------------------------------------------------

    if [[ "$dry_run" == "false" ]]; then

        rsync \
            -a \
            --delete \
            "${exclude_args[@]}" \
            "$source/" \
            "$target/"

        return

    fi


    # --------------------------------------------------------
    # Dry run
    # --------------------------------------------------------

    rsync \
        -a \
        --delete \
        --dry-run \
        --itemize-changes \
        "${exclude_args[@]}" \
        "$source/" \
        "$target/"
}

# ============================================================
# Synchronize scripts while protecting project-specific files
# ============================================================

rsync_scripts() {

    local source="$1"
    local target="$2"
    local dry_run="${3:-false}"

    local exclude_args=()

    for file in "${PROTECTED_SCRIPTS[@]}"; do
        exclude_args+=(--exclude="$file")
    done

    if [[ "$dry_run" == "false" ]]; then

        rsync \
            -a \
            --delete \
            "${exclude_args[@]}" \
            "$source/" \
            "$target/"

        return
    fi

    rsync \
        -a \
        --delete \
        --dry-run \
        --itemize-changes \
        "${exclude_args[@]}" \
        "$source/" \
        "$target/"
}

# ============================================================
# Header
# ============================================================

echo
echo "=============================================="
echo " Typst Template Synchronization"
echo "=============================================="
echo

echo "Template:"
echo "    $TEMPLATE_DIR"

echo
echo "Target:"
echo "    $TARGET_DIR"

echo
echo "Mode:"

if $DRY_RUN; then
    echo "    DRY RUN — no files will be changed"
else
    echo "    LIVE — files may be changed"
fi


# ============================================================
# Check directories
# ============================================================

[[ -d "$TEMPLATE_DIR" ]] ||
    die "Template directory does not exist."

[[ -d "$TARGET_DIR" ]] ||
    die "Target directory does not exist."


# ============================================================
# Check Git repositories
# ============================================================

git -C "$TEMPLATE_DIR" rev-parse --is-inside-work-tree \
    >/dev/null 2>&1 ||
    die "typst-site is not a Git repository."

git -C "$TARGET_DIR" rev-parse --is-inside-work-tree \
    >/dev/null 2>&1 ||
    die "26fgt is not a Git repository."


# ============================================================
# Protect uncommitted work in 26fgt
#
# IMPORTANT:
#
# This check is performed even for --dry-run.
#
# The purpose is to ensure that the synchronization script
# never previews against a dirty target and then encourages
# accidental overwriting of local work.
# ============================================================

if [[ -n "$(git -C "$TARGET_DIR" status --porcelain)" ]]; then

    echo
    echo "❌ 26fgt has uncommitted changes:"
    echo

    git -C "$TARGET_DIR" status --short

    echo
    echo "Please commit or stash these changes first."
    echo

    exit 1

fi


# ============================================================
# Show Git information
# ============================================================

echo
echo "Template branch:"
git -C "$TEMPLATE_DIR" rev-parse --abbrev-ref HEAD

echo
echo "Template commit:"
git -C "$TEMPLATE_DIR" log -1 --oneline

echo
echo "Target branch:"
git -C "$TARGET_DIR" rev-parse --abbrev-ref HEAD


# ============================================================
# List synchronization items
# ============================================================

echo
echo "=============================================="
echo " Template files to synchronize"
echo "=============================================="
echo

for item in "${SYNC_ITEMS[@]}"; do

    if [[ -e "$TEMPLATE_DIR/$item" ]]; then

        echo "  ✓ $item"

    else

        echo "  ⚠ $item"
        echo "      Source does not exist — will be skipped."

    fi

done


# ============================================================
# Show protected assets
# ============================================================

echo
echo "=============================================="
echo " Protected target assets"
echo "=============================================="
echo

for file in "${PROTECTED_ASSETS[@]}"; do
    echo "  🔒 assets/$file"
done


# ============================================================
# Show protected target scripts
# ============================================================

echo
echo "=============================================="
echo " Protected target scripts"
echo "=============================================="
echo

for file in "${PROTECTED_SCRIPTS[@]}"; do
    echo "  🔒 scripts/$file"
done


# ============================================================
# Dry run
# ============================================================

if $DRY_RUN; then

    echo
    echo "=============================================="
    echo " DRY RUN"
    echo "=============================================="
    echo
    echo "No files will be changed."
    echo

    echo
    echo "=============================================="
    echo " Synchronization Preview"
    echo "=============================================="
    echo


    for item in "${SYNC_ITEMS[@]}"; do

        source="$TEMPLATE_DIR/$item"
        target="$TARGET_DIR/$item"


        # ----------------------------------------------------
        # Missing source
        # ----------------------------------------------------

        if [[ ! -e "$source" ]]; then

            echo "⚠ Skipping missing source: $item"
            continue

        fi


        # ----------------------------------------------------
        # Directory
        # ----------------------------------------------------

        if [[ -d "$source" ]]; then

            echo "→ Synchronizing $item/"

            mkdir -p "$target"

            if [[ "$item" == "assets" ]]; then

                rsync_assets "$source" "$target" true

            elif [[ "$item" == "scripts" ]]; then

                rsync_scripts "$source" "$target" true

            else

                rsync \
                    -a \
                    --delete \
                    --dry-run \
                    --itemize-changes \
                    "$source/" \
                    "$target/"

            fi


        # ----------------------------------------------------
        # File
        # ----------------------------------------------------

        else

            echo "→ Synchronizing $item"

            rsync \
                -a \
                --dry-run \
                --itemize-changes \
                "$source" \
                "$target"

        fi

    done


    echo
    echo "=============================================="
    echo " Dry run complete"
    echo "=============================================="
    echo
    echo "No files were changed."

    exit 0

fi


# ============================================================
# Confirm
# ============================================================

echo
read -r -p "Synchronize these template files into 26fgt? [y/N] " answer

case "$answer" in

    y|Y|yes|YES)
        ;;

    *)
        echo
        echo "Cancelled."
        exit 0
        ;;

esac


# ============================================================
# Synchronize
# ============================================================

echo
echo "=============================================="
echo " Synchronizing"
echo "=============================================="
echo


for item in "${SYNC_ITEMS[@]}"; do

    source="$TEMPLATE_DIR/$item"
    target="$TARGET_DIR/$item"


    # --------------------------------------------------------
    # Missing source
    # --------------------------------------------------------

    if [[ ! -e "$source" ]]; then

        echo "⚠ Skipping missing source: $item"
        continue

    fi


    # --------------------------------------------------------
    # Directory
    # --------------------------------------------------------

    if [[ -d "$source" ]]; then

        mkdir -p "$target"


        if [[ "$item" == "assets" ]]; then

            rsync_assets "$source" "$target"

        elif [[ "$item" == "scripts" ]]; then

            rsync_scripts "$source" "$target"

        else

            rsync \
                -a \
                --delete \
                "$source/" \
                "$target/"

        fi

        echo "✓ $item/"


    # --------------------------------------------------------
    # File
    # --------------------------------------------------------

    else

        mkdir -p "$(dirname "$target")"

        rsync \
            -a \
            "$source" \
            "$target"

        echo "✓ $item"

    fi

done


# ============================================================
# Show changes
# ============================================================

echo
echo "=============================================="
echo " Changes in 26fgt"
echo "=============================================="
echo

git -C "$TARGET_DIR" status --short


# ============================================================
# Finish
# ============================================================

echo
echo "=============================================="
echo " Synchronization complete"
echo "=============================================="
echo

echo "Review the changes with:"
echo
echo "    cd \"$TARGET_DIR\""
echo "    git diff"
echo

echo "If everything is correct, commit the update."
echo