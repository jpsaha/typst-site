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
    "scripts"
    "build.sh"
    "book_source.typ"
    "pages_source.typ"
    "pdflayout.typ"
    ".github/workflows/deploy.yml"
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
# Do not overwrite a working tree that contains changes.
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
        echo "      Source does not exist -- will be skipped."

    fi

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

    for item in "${SYNC_ITEMS[@]}"; do

        source="$TEMPLATE_DIR/$item"
        target="$TARGET_DIR/$item"

        [[ -e "$source" ]] || continue

        if [[ -d "$source" ]]; then

            echo "Would synchronize:"
            echo "    $item/"

            rsync \
                -a \
                --delete \
                --dry-run \
                "$source/" \
                "$target/"

        else

            echo "Would copy:"
            echo "    $item"

        fi

        echo

    done

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

        rsync \
            -a \
            --delete \
            "$source/" \
            "$target/"

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