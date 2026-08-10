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
# Project root
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

# Allow imports such as:
#
#     from scripts.metadata.config import ...
#
# when this file is executed directly with:
#
#     python3 scripts/lint/check_generated.py

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


# ============================================================
# Metadata pipeline
# ============================================================

from scripts.metadata.config import (
    CONTENT_DIR,
    GENERATED_DIR,
)

from scripts.metadata.parser import (
    parse_lecture,
)


# ============================================================
# Paths
# ============================================================

LECTURES_TYP = GENERATED_DIR / "lectures.typ"

PAGES_TYP = GENERATED_DIR / "pages.typ"

PAGES_META_TYP = GENERATED_DIR / "pages_meta.typ"


# ============================================================
# Generated-file patterns
# ============================================================

FILE_FIELD_RE = re.compile(
    r'\bfile:\s*"([^"]+)"'
)

CONTENT_INCLUDE_RE = re.compile(
    r'#include\s+"\.\./content/([^"]+)"'
)


# ============================================================
# Path helpers
# ============================================================

def display_path(path):
    """Return a path relative to the project root."""

    try:

        return path.relative_to(
            ROOT
        ).as_posix()

    except ValueError:

        return path.as_posix()


def safe_filename(name):
    """
    Convert a category name to the same filename form used
    by write_book.py.
    """

    name = name.lower().strip()

    name = re.sub(
        r"[^a-z0-9]+",
        "_",
        name,
    )

    return name.strip("_")


# ============================================================
# Source metadata
# ============================================================

def discover_source_metadata():
    """
    Discover source wrapper metadata.

    Returns:

        wrappers
        lectures
        pages
        errors
    """

    wrappers = []

    lectures = []

    pages = []

    errors = []

    if not CONTENT_DIR.exists():

        errors.append(
            (
                CONTENT_DIR,
                "content directory does not exist",
            )
        )

        return (
            wrappers,
            lectures,
            pages,
            errors,
        )

    for path in sorted(
        path
        for path in CONTENT_DIR.rglob("*.typ")
        if "motypprog" not in path.parts
    ):

        # ----------------------------------------------------
        # Ignore generated content files
        # ----------------------------------------------------

        if path.stem.endswith("_content"):
            continue

        # ----------------------------------------------------
        # Read source
        # ----------------------------------------------------

        try:

            text = path.read_text(
                encoding="utf-8"
            )

        except (OSError, UnicodeError) as error:

            errors.append(
                (
                    path,
                    f"could not read file: {error}",
                )
            )

            continue

        # ----------------------------------------------------
        # Parse metadata
        # ----------------------------------------------------

        data = parse_lecture(text)

        if data is None:

            errors.append(
                (
                    path,
                    "no metadata block found",
                )
            )

            continue

        wrappers.append(
            (path, data)
        )

        # ----------------------------------------------------
        # Classify
        #
        # number == None  -> page
        # number != None  -> lecture
        # ----------------------------------------------------

        if data.get("number") is None:

            pages.append(
                (path, data)
            )

        else:

            lectures.append(
                (path, data)
            )

    return (
        wrappers,
        lectures,
        pages,
        errors,
    )


# ============================================================
# Generated identifiers
# ============================================================

def generated_file_ids(path):
    """
    Extract file identifiers from a generated metadata file.

    Returns a set of identifiers.
    """

    if not path.exists():

        return set()

    text = path.read_text(
        encoding="utf-8"
    )

    return set(
        FILE_FIELD_RE.findall(text)
    )


def generated_content_sources(path):
    """
    Extract content source filenames from a generated page file.
    """

    if not path.exists():

        return set()

    text = path.read_text(
        encoding="utf-8"
    )

    return set(
        CONTENT_INCLUDE_RE.findall(text)
    )


# ============================================================
# Generated file checks
# ============================================================

def check_required_file(
    path,
    errors,
):
    """Check that a generated file exists."""

    if not path.is_file():

        errors.append(
            (
                path,
                "generated file is missing",
            )
        )

        return False

    return True


def check_lectures(
    lectures,
    errors,
):
    """Check generated/lectures.typ against source lectures."""

    if not check_required_file(
        LECTURES_TYP,
        errors,
    ):

        return

    generated = generated_file_ids(
        LECTURES_TYP
    )

    expected = {
        data.get("file")
        for _, data in lectures
        if isinstance(
            data.get("file"),
            str,
        )
    }

    # --------------------------------------------------------
    # Missing lectures
    # --------------------------------------------------------

    for file_name in sorted(
        expected - generated
    ):

        errors.append(
            (
                LECTURES_TYP,
                (
                    f"source lecture '{file_name}' "
                    "is missing from generated lectures"
                ),
            )
        )

    # --------------------------------------------------------
    # Stale lectures
    # --------------------------------------------------------

    for file_name in sorted(
        generated - expected
    ):

        errors.append(
            (
                LECTURES_TYP,
                (
                    f"generated lecture '{file_name}' "
                    "has no source metadata"
                ),
            )
        )


# ============================================================
# Page checks
# ============================================================

def expected_page_sources(pages):
    """
    Return expected generated page content filenames.

    The source path is relative to content/.

    Example:

        content/courses/fun.typ

    becomes:

        courses/fun_content.typ
    """

    sources = set()

    for path, _ in pages:

        source = path.relative_to(
            CONTENT_DIR
        ).as_posix()

        if source.endswith(".typ"):

            source = source[:-4]

        sources.add(
            f"{source}_content.typ"
        )

    return sources


def check_pages(
    pages,
    errors,
):
    """Check generated page files against source pages."""

    expected_files = {
        data.get("file")
        for _, data in pages
        if isinstance(
            data.get("file"),
            str,
        )
    }

    # ========================================================
    # pages.typ
    # ========================================================

    if check_required_file(
        PAGES_TYP,
        errors,
    ):

        generated_sources = (
            generated_content_sources(
                PAGES_TYP
            )
        )

        expected_sources = (
            expected_page_sources(
                pages
            )
        )

        # ----------------------------------------------------
        # Missing pages
        # ----------------------------------------------------

        for source in sorted(
            expected_sources - generated_sources
        ):

            errors.append(
                (
                    PAGES_TYP,
                    (
                        f"source page content '{source}' "
                        "is missing from generated pages"
                    ),
                )
            )

        # ----------------------------------------------------
        # Stale pages
        # ----------------------------------------------------

        for source in sorted(
            generated_sources - expected_sources
        ):

            errors.append(
                (
                    PAGES_TYP,
                    (
                        f"generated page content '{source}' "
                        "has no source page metadata"
                    ),
                )
            )

    # ========================================================
    # pages_meta.typ
    # ========================================================

    if check_required_file(
        PAGES_META_TYP,
        errors,
    ):

        generated = generated_file_ids(
            PAGES_META_TYP
        )

        # ----------------------------------------------------
        # Missing page metadata
        # ----------------------------------------------------

        for file_name in sorted(
            expected_files - generated
        ):

            errors.append(
                (
                    PAGES_META_TYP,
                    (
                        f"source page '{file_name}' "
                        "is missing from generated page metadata"
                    ),
                )
            )

        # ----------------------------------------------------
        # Stale page metadata
        # ----------------------------------------------------

        for file_name in sorted(
            generated - expected_files
        ):

            errors.append(
                (
                    PAGES_META_TYP,
                    (
                        f"generated page '{file_name}' "
                        "has no source page metadata"
                    ),
                )
            )


# ============================================================
# Category books
# ============================================================

def expected_categories(content):
    """
    Return the set of category-generated filenames required
    by the current metadata-bearing content.
    """

    categories = set()

    for _, data in content:

        category = data.get(
            "category",
            "Uncategorized",
        )

        if not isinstance(category, str):
            continue

        filename = safe_filename(
            category
        )

        categories.add(
            f"category_{filename}.typ"
        )

    return categories


def check_category_books(
    content,
    errors,
):
    """Check generated category books."""

    if not GENERATED_DIR.exists():

        errors.append(
            (
                GENERATED_DIR,
                "generated directory does not exist",
            )
        )

        return

    expected = expected_categories(
        content
    )

    actual = {
        path.name
        for path in GENERATED_DIR.glob(
            "category_*.typ"
        )
    }

    # --------------------------------------------------------
    # Missing category books
    # --------------------------------------------------------

    for filename in sorted(
        expected - actual
    ):

        errors.append(
            (
                GENERATED_DIR / filename,
                "generated category book is missing",
            )
        )

    # --------------------------------------------------------
    # Stale category books
    # --------------------------------------------------------

    for filename in sorted(
        actual - expected
    ):

        errors.append(
            (
                GENERATED_DIR / filename,
                "stale category book exists",
            )
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