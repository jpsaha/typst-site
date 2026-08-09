from pathlib import Path
import re

from .config import BOOK_TYP
from .typst import write_header


# ============================================================
# Content source
# ============================================================

def content_source(lecture):
    """Return the path to the lecture's content file."""

    source = lecture["source"]

    if source.endswith(".typ"):
        return source[:-4] + "_content.typ"

    return source + "_content.typ"


# ============================================================
# Safe filenames
# ============================================================

def safe_filename(name):
    """Convert a category name into a safe filename."""

    name = name.lower().strip()
    name = re.sub(r"[^a-z0-9]+", "_", name)

    return name.strip("_")


# ============================================================
# Complete course book
# ============================================================

def write_lecture(file, lecture):
    """Write one lecture to the generated book."""

    content = content_source(lecture)

    file.write(
        f"""#include-lecture(
(
file: "{lecture["file"]}",
number: {lecture["number"]},
title: "{lecture["title"]}",
),
[
#include "../content/{content}"
],
)

"""
    )


def write_book(lectures):
    """Generate generated/book.typ."""

    with BOOK_TYP.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header(file)

        file.write(
            '#import "../templates/render.typ": include-lecture\n'
        )

        file.write(
            '#import "../generated/lectures.typ": lectures\n\n'
        )

        for lecture in lectures:

            if lecture.get("number") is None:

                print(
                    f"Skipping {lecture['file']}: "
                    "no lecture number."
                )

                continue

            write_lecture(
                file,
                lecture,
            )

    print(
        f"Wrote {BOOK_TYP}"
    )


# ============================================================
# Category books
# ============================================================

def write_category_lecture(file, lecture):
    """Write one content item into a category book."""

    content = content_source(lecture)

    # --------------------------------------------------------
    # Category books can contain both:
    #
    #   1. numbered lectures
    #   2. non-numbered pages/courses
    #
    # Therefore, do not require a lecture number here.
    # --------------------------------------------------------

    number = lecture.get("number")

    if number is None:

        # Non-numbered page.
        #
        # include-lecture expects a number, so use none.
        # The actual page/content is still included.
        file.write(
            f"""#include-lecture(
(
file: "{lecture["file"]}",
number: none,
title: "{lecture["title"]}",
),
[
#include "../content/{content}"
],
)

"""
        )

    else:

        # Normal numbered lecture.
        file.write(
            f"""#include-lecture(
(
file: "{lecture["file"]}",
number: {number},
title: "{lecture["title"]}",
),
[
#include "../content/{content}"
],
)

"""
        )


def write_category_book(
    category,
    lectures,
    generated_dir,
):
    """Generate one combined Typst source for a category."""

    generated_dir = Path(generated_dir)

    filename = (
        f"category_{safe_filename(category)}.typ"
    )

    output = generated_dir / filename

    with output.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header(file)

        file.write(
            '#import "../templates/render.typ": include-lecture\n'
        )

        file.write(
            '#import "../generated/lectures.typ": lectures\n\n'
        )

        # ----------------------------------------------------
        # Include every item in this category.
        #
        # Unlike the complete course book, category books
        # include both numbered lectures and non-numbered
        # pages/courses.
        # ----------------------------------------------------

        for lecture in lectures:

            write_category_lecture(
                file,
                lecture,
            )

    print(
        f"Wrote {output}"
    )

    return output


def remove_stale_category_books(generated_dir):
    """Remove previously generated category book files."""

    generated_dir = Path(generated_dir)

    for path in generated_dir.glob("category_*.typ"):
        path.unlink()

        print(f"Removed stale category book: {path}")


def write_category_books(
    lectures,
    generated_dir,
):
    """Generate combined Typst sources for every category."""

    generated_dir = Path(generated_dir)

    categories = {}

    # --------------------------------------------------------
    # Group all content by category.
    #
    # The argument may contain both lectures and pages.
    # --------------------------------------------------------

    for lecture in lectures:

        category = lecture.get(
            "category",
            "Uncategorized",
        )

        categories.setdefault(
            category,
            [],
        )

        categories[category].append(
            lecture
        )

    outputs = []

    # --------------------------------------------------------
    # Generate one Typst source per category.
    # --------------------------------------------------------

    for category, category_lectures in categories.items():

        output = write_category_book(
            category,
            category_lectures,
            generated_dir,
        )

        outputs.append(
            {
                "category": category,
                "source": output,
                "lectures": category_lectures,
            }
        )

    return outputs