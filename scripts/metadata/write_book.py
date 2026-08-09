from pathlib import Path
import re

from .config import BOOK_TYP
from .typst import write_header


# ============================================================
# Paths
# ============================================================

def content_source(lecture):
    """Return the path to the lecture's content file."""

    source = lecture["source"]

    if source.endswith(".typ"):
        source = source[:-4]

    return f"{source}_content.typ"


def safe_filename(name):
    """Convert a category name into a safe filename."""

    name = name.lower().strip()
    name = re.sub(r"[^a-z0-9]+", "_", name)

    return name.strip("_")


# ============================================================
# Typst writers
# ============================================================

def write_imports(file):
    """Write imports required by generated book files."""

    file.write(
        '#import "../templates/render.typ": include-lecture\n'
    )

    file.write(
        '#import "../generated/lectures.typ": lectures\n\n'
    )


def write_header_and_imports(file):
    """Write the standard header and imports."""

    write_header(file)
    write_imports(file)


def write_lecture(file, lecture):
    """Write one lecture or page as an include-lecture call."""

    content = content_source(lecture)

    number = lecture.get("number")

    number_value = (
        str(number)
        if number is not None
        else "none"
    )

    file.write(
        f"""#include-lecture(
  (
    file: "{lecture["file"]}",
    number: {number_value},
    title: "{lecture["title"]}",
  ),
  [
    #include "../content/{content}"
  ],
)

"""
    )


# ============================================================
# Complete course book
# ============================================================

def write_book(lectures):
    """Generate generated/book.typ."""

    with BOOK_TYP.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header_and_imports(file)

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
# Category grouping
# ============================================================

def group_by_category(lectures):
    """Group lectures and pages by category."""

    categories = {}

    for lecture in lectures:

        category = lecture.get(
            "category",
            "Uncategorized",
        )

        categories.setdefault(
            category,
            [],
        ).append(
            lecture
        )

    return categories


# ============================================================
# Category books
# ============================================================

def write_category_book(
    category,
    lectures,
    generated_dir,
):
    """Generate one combined Typst source for a category."""

    generated_dir = Path(generated_dir)

    output = (
        generated_dir
        / f"category_{safe_filename(category)}.typ"
    )

    with output.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header_and_imports(file)

        for lecture in lectures:

            write_lecture(
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

    for path in generated_dir.glob(
        "category_*.typ"
    ):
        path.unlink()

        print(
            f"Removed stale category book: {path}"
        )


def write_category_books(
    lectures,
    generated_dir,
):
    """Generate combined Typst sources for every category."""

    generated_dir = Path(generated_dir)

    remove_stale_category_books(
        generated_dir
    )

    categories = group_by_category(
        lectures
    )

    outputs = []

    for category in sorted(categories):

        category_lectures = categories[
            category
        ]

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
