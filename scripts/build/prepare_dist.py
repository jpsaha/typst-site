#!/usr/bin/env python3

import shutil

from scripts.config import (
    DIST_DIR,
    PAGES_DIR,
    PDF_DIR,
    ASSETS_DIR,
    ASSETS_SOURCE_DIR,
    GENERATED_OG_DIR,
    HOMEPAGE_JSON,
)


def prepare_dist():
    """Prepare the dist directory for a fresh build."""

    # --------------------------------------------------------
    # Remove previous generated output
    # --------------------------------------------------------

    shutil.rmtree(
        DIST_DIR,
        ignore_errors=True,
    )

    # --------------------------------------------------------
    # Create output directories
    # --------------------------------------------------------

    for directory in (
        PAGES_DIR,
        PDF_DIR,
        ASSETS_DIR / "css",
        ASSETS_DIR / "js",
        ASSETS_DIR / "images",
        ASSETS_DIR / "og",
    ):
        directory.mkdir(
            parents=True,
            exist_ok=True,
        )

    # --------------------------------------------------------
    # Copy CSS
    # --------------------------------------------------------

    source_css = ASSETS_SOURCE_DIR / "css" / "style.css"
    target_css = ASSETS_DIR / "css" / "style.css"

    if source_css.exists():

        shutil.copy2(
            source_css,
            target_css,
        )

        print("📋 Copied style.css")

    else:

        print(
            "⚠️ Warning: assets/css/style.css not found"
        )


    # --------------------------------------------------------
    # Copy all PNG images from assets
    # --------------------------------------------------------

    png_count = 0

    for source_png in ASSETS_SOURCE_DIR.rglob("*.png"):

        relative_path = source_png.relative_to(
            ASSETS_SOURCE_DIR
        )

        target_png = ASSETS_DIR / relative_path

        target_png.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        shutil.copy2(
            source_png,
            target_png,
        )

        print(
            f"📋 Copied {relative_path}"
        )

        png_count += 1

    print(
        f"📋 Copied {png_count} PNG image(s)"
    )

    # --------------------------------------------------------
    # Copy generated Open Graph PNG images
    #
    # Generated OG files preserve their directory structure:
    #
    #     generated/og/lectures/lec1.png
    #     generated/og/lectures_dummy/lec2.png
    #
    # Published OG images preserve the same structure:
    #
    #     dist/assets/og/lectures/lec1.png
    #     dist/assets/og/lectures_dummy/lec2.png
    #
    # This keeps the generated and published OG directory
    # structures consistent.
    # --------------------------------------------------------

    generated_og_count = 0

    if GENERATED_OG_DIR.exists():

        target_og_dir = ASSETS_DIR / "og"

        target_og_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        for source_png in GENERATED_OG_DIR.rglob("*.png"):

            relative_path = source_png.relative_to(
                GENERATED_OG_DIR
            )

            target_png = target_og_dir / relative_path

            target_png.parent.mkdir(
                parents=True,
                exist_ok=True,
            )

            shutil.copy2(
                source_png,
                target_png,
            )

            print(
                f"📋 Copied generated OG image: "
                f"{relative_path}"
            )

            generated_og_count += 1

    else:

        print(
            "ℹ️ No generated OG images found"
        )

    print(
        f"📋 Copied {generated_og_count} generated OG image(s)"
    )

    # --------------------------------------------------------
    # Check generated metadata
    # --------------------------------------------------------

    if not HOMEPAGE_JSON.exists():

        raise FileNotFoundError(
            f"Missing {HOMEPAGE_JSON}"
        )


def main():
    prepare_dist()


if __name__ == "__main__":
    main()