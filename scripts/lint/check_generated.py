#!/usr/bin/env python3

"""
Check consistency between source metadata and generated Typst files.

The actual checking logic is implemented in:

    scripts/generated/

This script is the command-line entry point.

Usage:

    python3 scripts/lint/check_generated.py

Exit status:

    0   generated files are consistent
    1   inconsistencies were found
"""

import sys

# ============================================================
# Project root
# ============================================================

from pathlib import Path
import sys

# ============================================================
# Project root
# ============================================================

# Allow imports such as:
#
#     from scripts.generated.source import ...
#
# when this file is executed directly.

PROJECT_ROOT = Path(__file__).resolve().parents[2]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))



from scripts.config import ROOT

# ============================================================
# Generated consistency checks
# ============================================================

from scripts.lint.generated.source import (
    discover_source_metadata,
)

from scripts.lint.generated.checks import (
    check_lectures,
    check_pages,
    check_category_books,
)

from scripts.lint.generated.report import (
    display_path,
)


# ============================================================
# Main
# ============================================================

def main():

    (
        wrappers,
        lectures,
        pages,
        errors,
    ) = discover_source_metadata()

    # --------------------------------------------------------
    # All metadata-bearing content
    #
    # Category books are generated from both lectures and
    # pages, so the consistency check must use the same set.
    # --------------------------------------------------------

    all_content = lectures + pages

    # --------------------------------------------------------
    # Generated consistency
    # --------------------------------------------------------

    check_lectures(
        lectures,
        errors,
    )

    check_pages(
        pages,
        errors,
    )

    check_category_books(
        all_content,
        errors,
    )

    # ========================================================
    # Report
    # ========================================================

    print()
    print(
        "=============================="
    )
    print(
        "Generated Consistency Check"
    )
    print(
        "=============================="
    )
    print()

    print(
        f"Source wrappers : {len(wrappers)}"
    )

    print(
        f"Source metadata : {len(wrappers)}"
    )

    print(
        f"Lectures        : {len(lectures)}"
    )

    print(
        f"Pages           : {len(pages)}"
    )

    print(
        f"Errors          : {len(errors)}"
    )

    # --------------------------------------------------------
    # Errors
    # --------------------------------------------------------

    if errors:

        print()
        print(
            "=============================="
        )
        print(
            "Generated Consistency Errors"
        )
        print(
            "=============================="
        )
        print()

        for path, message in errors:

            print(
                display_path(path)
            )

            print(
                f"   -> {message}"
            )

            print()

        print(
            "Generated consistency check failed."
        )

        return 1

    # --------------------------------------------------------
    # Success
    # --------------------------------------------------------

    print()
    print(
        "No generated consistency errors found."
    )

    print()
    print(
        "Generated consistency check passed."
    )

    return 0


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    sys.exit(main())