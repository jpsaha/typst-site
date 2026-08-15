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
from pathlib import Path


# ============================================================
# Paths
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

OG_DIR = (
    ROOT / "generated" / "og"
)


# ============================================================
# Settings
# ============================================================

WIDTH = 1200
HEIGHT = 630

DENSITY = 300


# ============================================================
# Build one OG image
# ============================================================

def build_og_image(source):
    """
    Convert one Asymptote source into a 1200×630 PNG.
    """

    relative = source.relative_to(OG_DIR)

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
            # "magick",
            "convert",
            "-density",
            str(DENSITY),
            str(pdf),
            "-resize",
            f"{WIDTH}x{HEIGHT}!",
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

    if not OG_DIR.exists():
        print(
            f"⚠️  OG directory does not exist: "
            f"{OG_DIR}"
        )
        return

    # --------------------------------------------------------
    # Find all Asymptote sources recursively
    # --------------------------------------------------------

    sources = sorted(
        OG_DIR.rglob("*.asy")
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