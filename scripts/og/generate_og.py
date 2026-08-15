#!/usr/bin/env python3

"""
Generate Asymptote sources for lecture Open Graph images.

Input:
    generated/homepage.json

Template:
    scripts/og/og_template.asy

Output:
    generated/og/<lecture>.asy

Rule:
    If a lecture already has an `og_image` field, no OG source
    is generated for that lecture.

    If `og_image` is absent, an Asymptote source is generated
    from the lecture metadata.
"""

import json
from pathlib import Path


# ============================================================
# Paths
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

METADATA_FILE = (
    ROOT / "generated" / "homepage.json"
)

TEMPLATE_FILE = (
    ROOT / "scripts" / "og" / "og_template.asy"
)

OUTPUT_DIR = (
    ROOT / "generated" / "og"
)


# ============================================================
# Utilities
# ============================================================

def escape_asy_string(value):
    """
    Escape a Python string for use inside an Asymptote string.
    """

    return (
        str(value)
        .replace("\\", "\\\\")
        .replace('"', '\\"')
    )


# ============================================================
# Generate one OG source
# ============================================================

def generate_asy(
    template,
    *,
    number,
    title,
    category,
):
    """
    Generate one Asymptote source from lecture metadata.
    """

    source = template

    source = source.replace(
        "__LECTURE_NUMBER__",
        escape_asy_string(number),
    )

    source = source.replace(
        "__TITLE__",
        escape_asy_string(title),
    )

    source = source.replace(
        "__CATEGORY__",
        escape_asy_string(category),
    )

    return source


# ============================================================
# Main
# ============================================================

def main():

    # --------------------------------------------------------
    # Check input files
    # --------------------------------------------------------

    if not METADATA_FILE.exists():
        raise FileNotFoundError(
            f"Metadata file not found: {METADATA_FILE}"
        )

    if not TEMPLATE_FILE.exists():
        raise FileNotFoundError(
            f"OG template not found: {TEMPLATE_FILE}"
        )

    # --------------------------------------------------------
    # Read metadata
    # --------------------------------------------------------

    data = json.loads(
        METADATA_FILE.read_text(
            encoding="utf-8"
        )
    )

    template = TEMPLATE_FILE.read_text(
        encoding="utf-8"
    )

    # --------------------------------------------------------
    # Prepare output directory
    # --------------------------------------------------------

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    # --------------------------------------------------------
    # Generate OG sources
    # --------------------------------------------------------

    generated = 0
    skipped = 0

    for category, pages in data.items():

        for lecture in pages:

            # ------------------------------------------------
            # Only lectures
            # ------------------------------------------------

            if lecture.get("type") != "lecture":
                continue

            # ------------------------------------------------
            # Existing OG image
            # ------------------------------------------------

            if lecture.get("og_image"):

                print(
                    f"⏭️  Skipping "
                    f"{lecture.get('html', '<unknown>')}"
                    f" — og_image supplied"
                )

                skipped += 1
                continue


            # --------------------------------------------------------
            # Source path
            # --------------------------------------------------------

            source = lecture.get("source")

            if not source:
                print(
                    "⚠️  Skipping lecture without source"
                )
                continue

            source_path = Path(source)

            if source_path.suffix != ".typ":
                print(
                    f"⚠️  Skipping {source} "
                    f"— expected .typ source"
                )
                continue

            # Preserve source directory structure
            # and replace .typ with .asy

            output_relative = source_path.with_suffix(".asy")

            output = (
                OUTPUT_DIR
                / output_relative
            )

            output.parent.mkdir(
                parents=True,
                exist_ok=True,
            )


            # --------------------------------------------------------
            # Lecture metadata
            # --------------------------------------------------------

            number = lecture.get(
                "number",
                "",
            )

            title = lecture.get(
                "title",
                "",
            )

            category_name = category


            # --------------------------------------------------------
            # Generate Asymptote source
            # --------------------------------------------------------

            source_text = generate_asy(
                template,
                number=number,
                title=title,
                category=category_name,
            )


            # --------------------------------------------------------
            # Write output
            # --------------------------------------------------------

            output.write_text(
                source_text,
                encoding="utf-8",
            )

            print(
                f"📐 Generated "
                f"{output.relative_to(ROOT)}"
            )

            generated += 1

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    print()
    print("OG image source generation")
    print("--------------------------")
    print(f"Generated : {generated}")
    print(f"Skipped   : {skipped}")


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    main()