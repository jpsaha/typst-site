#!/usr/bin/env python3

"""
Build Open Graph PNG images from generated Asymptote sources.

Input:
    generated/og/**/*.asy

Output:
    generated/og/**/*.png

The directory structure is preserved.

Example:

    generated/og/lectures_dummy/lec1.asy
        ↓
    generated/og/lectures_dummy/lec1.png

Requirements:
    - Asymptote (`asy`)
    - ImageMagick (`magick`)
"""

import subprocess

from scripts.config import (
    ROOT,
    GENERATED_OG_DIR,
    OG_WIDTH,
    OG_HEIGHT,
    OG_DENSITY,
)


# ============================================================
# Open Graph source directory
# ============================================================
#
# Generated Asymptote sources are stored under:
#
#     generated/og/
#
# The directory structure of the corresponding content source
# is preserved.
#
# Example:
#
#     content/gt/lec1.typ
#             ↓
#     generated/og/gt/lec1.asy
#
#     content/mopss/mopss_aug29.typ
#             ↓
#     generated/og/mopss/mopss_aug29.asy
# ============================================================


# ============================================================
# Open Graph image settings
# ============================================================
#
# These values are defined centrally in scripts/config.py.
#
# OG_WIDTH
#     Final PNG width in pixels.
#
# OG_HEIGHT
#     Final PNG height in pixels.
#
# OG_DENSITY
#     Resolution used when rasterizing the intermediate
#     Asymptote-generated PDF.
# ============================================================


# ============================================================
# Rasterization density
# ============================================================
#
# Asymptote first produces the OG artwork as a PDF.
# ImageMagick then rasterizes that PDF to PNG.
#
# A higher density gives ImageMagick more source resolution
# before the final 1200 × 630 resize.
# ============================================================

# ============================================================
# Build one OG image
# ============================================================

def build_og_image(source):
    """
    Convert one Asymptote source into a 1200×630 PNG.
    """

    relative = source.relative_to(GENERATED_OG_DIR)

    output_base = source.with_suffix("")

    pdf = output_base.with_suffix(".pdf")
    png = output_base.with_suffix(".png")

    # --------------------------------------------------------
    # Ensure output directory exists
    # --------------------------------------------------------

    output_base.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    # --------------------------------------------------------
    # Asymptote → PDF
    # --------------------------------------------------------

    print(
        f"📐 Building {relative}"
    )

    subprocess.run(
        [
            "asy",
            "-f",
            "pdf",
            "-o",
            str(output_base),
            str(source),
        ],
        check=True,
    )

    # --------------------------------------------------------
    # PDF → PNG
    # --------------------------------------------------------

    print(
        f"🖼️  Converting "
        f"{relative.with_suffix('.pdf')}"
        f" → "
        f"{relative.with_suffix('.png')}"
    )

    subprocess.run(
        [
            "magick",
            "-density",
            str(OG_DENSITY),
            str(pdf),
            "-resize",
            f"{OG_WIDTH}x{OG_HEIGHT}!",
            "-filter",
            "Lanczos",
            str(png),
        ],
        check=True,
    )

    # --------------------------------------------------------
    # Remove intermediate PDF
    # --------------------------------------------------------

    if pdf.exists():
        pdf.unlink()

    # --------------------------------------------------------
    # Verify output
    # --------------------------------------------------------

    if not png.exists():
        raise RuntimeError(
            f"PNG was not created: {png}"
        )

    print(
        f"✅ Created "
        f"{png.relative_to(ROOT)}"
    )


# ============================================================
# Main
# ============================================================

def main():

    if not GENERATED_OG_DIR.exists():
        print(
            f"⚠️  OG directory does not exist: "
            f"{GENERATED_OG_DIR}"
        )
        return

    # --------------------------------------------------------
    # Find all Asymptote sources recursively
    # --------------------------------------------------------

    sources = sorted(
        GENERATED_OG_DIR.rglob("*.asy")
    )

    if not sources:
        print(
            "ℹ️  No .asy files found."
        )
        return

    print(
        f"📐 Found {len(sources)} OG source(s)"
    )

    print()

    # --------------------------------------------------------
    # Build images
    # --------------------------------------------------------

    built = 0

    for source in sources:

        build_og_image(source)

        built += 1

        print()

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    print(
        "OG image generation complete."
    )

    print(
        f"Generated : {built}"
    )


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    main()