#!/usr/bin/env python3

import shutil

from scripts.config import (
    DIST_DIR,
    PAGES_DIR,
    PDF_DIR,
    ASSETS_DIR,
    ASSETS_SOURCE_DIR,
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
    # Copy Open Graph image
    # --------------------------------------------------------

    source_og = ASSETS_SOURCE_DIR / "og" / "default.png"
    target_og = ASSETS_DIR / "og" / "default.png"

    if source_og.exists():

        shutil.copy2(
            source_og,
            target_og,
        )

        print("📋 Copied og/default.png")

    else:

        print(
            "⚠️ Warning: assets/og/default.png not found"
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