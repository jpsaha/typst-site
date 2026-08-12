#!/usr/bin/env python3

"""
Check consistency between source metadata and generated Typst files.

Checks:

1. Scans content/**/*.typ wrapper files.
2. Ignores *_content.typ files.
3. Parses source metadata using the normal metadata parser.
4. Verifies generated/lectures.typ contains every lecture.
5. Verifies generated/pages.typ contains every page.
6. Verifies generated/pages_meta.typ contains every page.
7. Verifies generated category books match current categories.
8. Detects stale generated category books.
9. Detects missing generated files.
10. Returns non-zero when generated output is inconsistent.

This checker does NOT regenerate anything.

Use:

    python3 scripts/lint/check_generated.py

Exit status:

    0   generated files are consistent
    1   inconsistencies were found
"""

from pathlib import Path
import re
import sys


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