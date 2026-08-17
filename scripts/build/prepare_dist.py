#!/usr/bin/env python3

import shutil
import tempfile
from pathlib import Path

from scripts.config import (
    DIST_DIR,
    PAGES_DIR,
    PDF_DIR,
    ASSETS_DIR,
    ASSETS_SOURCE_DIR,
    GENERATED_OG_DIR,
    HOMEPAGE_JSON,
    TYPST_OG,
)


# ============================================================
# Helpers
# ============================================================

def preserve_og_images():
    """
    Preserve existing published OG PNGs before dist/ is cleaned.

    These files are committed to Git and are used when:

        TYPST_OG=false

    The preserved files are stored temporarily outside dist/.
    """

    if not TYPST_OG:
        return None

    # When OG generation is enabled, dist/ is a normal fresh build.
    return None


def prepare_dist():
    """
    Prepare the dist directory for a fresh build.

    Behaviour:

        TYPST_OG=true
            ----------------
            Remove dist completely.
            Generated OG images will be rebuilt and copied.

        TYPST_OG=false
            ----------------
            Preserve existing dist/assets/og/*.png files.
            Remove the rest of dist.
            Restore the preserved OG images.

    This allows committed OG images to be used during
    GitHub deployment without requiring LaTeX, Asymptote,
    or ImageMagick.
    """

    print(
        f"🖼️  TYPST_OG = {TYPST_OG}"
    )

    # ========================================================
    # Preserve committed OG images when OG generation is off
    # ========================================================

    preserved_og_dir = None

    if not TYPST_OG:

        existing_og_dir = ASSETS_DIR / "og"

        if existing_og_dir.exists():

            temp_root = Path(
                tempfile.mkdtemp(
                    prefix="typst-og-"
                )
            )

            preserved_og_dir = (
                temp_root / "og"
            )

            shutil.copytree(
                existing_og_dir,
                preserved_og_dir,
            )

            preserved_count = sum(
                1
                for path in preserved_og_dir.rglob("*.png")
            )

            print(
                f"📦 Preserved {preserved_count} "
                f"committed OG image(s)"
            )

        else:

            print(
                "⚠️ No existing dist/assets/og/ "
                "directory found"
            )

    # ========================================================
    # Remove previous generated output
    # ========================================================

    shutil.rmtree(
        DIST_DIR,
        ignore_errors=True,
    )

    # ========================================================
    # Create output directories
    # ========================================================

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

    # ========================================================
    # Restore committed OG images
    #
    # Only done when:
    #
    #     TYPST_OG=false
    #
    # These are the PNGs checked into Git.
    # ========================================================

    if preserved_og_dir is not None:

        shutil.copytree(
            preserved_og_dir,
            ASSETS_DIR / "og",
            dirs_exist_ok=True,
        )

        print(
            "📋 Restored committed OG images"
        )

        # Remove temporary preservation directory.

        shutil.rmtree(
            preserved_og_dir.parent,
            ignore_errors=True,
        )

    # ========================================================
    # Copy CSS
    # ========================================================

    source_css = (
        ASSETS_SOURCE_DIR
        / "css"
        / "style.css"
    )

    target_css = (
        ASSETS_DIR
        / "css"
        / "style.css"
    )

    if source_css.exists():

        shutil.copy2(
            source_css,
            target_css,
        )

        print(
            "📋 Copied style.css"
        )

    else:

        print(
            "⚠️ Warning: assets/css/style.css not found"
        )

    # ========================================================
    # Copy all PNG images from assets
    # ========================================================
    #
    # These are project-supplied static PNGs.
    #
    # For example:
    #
    #     assets/og/default.png
    #     assets/og/fgt1.png
    #
    # They are copied into:
    #
    #     dist/assets/og/
    #
    # ========================================================

    png_count = 0

    for source_png in ASSETS_SOURCE_DIR.rglob("*.png"):

        relative_path = source_png.relative_to(
            ASSETS_SOURCE_DIR
        )

        target_png = (
            ASSETS_DIR / relative_path
        )

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

    # ========================================================
    # Copy generated Open Graph PNG images
    #
    # ONLY when TYPST_OG=true.
    #
    # When TYPST_OG=false, the committed PNGs preserved above
    # are used instead.
    # ========================================================

    generated_og_count = 0

    if TYPST_OG:

        if GENERATED_OG_DIR.exists():

            target_og_dir = (
                ASSETS_DIR / "og"
            )

            target_og_dir.mkdir(
                parents=True,
                exist_ok=True,
            )

            for source_png in (
                GENERATED_OG_DIR.rglob("*.png")
            ):

                relative_path = (
                    source_png.relative_to(
                        GENERATED_OG_DIR
                    )
                )

                target_png = (
                    target_og_dir / relative_path
                )

                target_png.parent.mkdir(
                    parents=True,
                    exist_ok=True,
                )

                shutil.copy2(
                    source_png,
                    target_png,
                )

                print(
                    "📋 Copied generated OG image: "
                    f"{relative_path}"
                )

                generated_og_count += 1

        else:

            print(
                "ℹ️ No generated OG images found"
            )

    else:

        print(
            "ℹ️ TYPST_OG=false — "
            "skipping generated OG images"
        )

    print(
        f"📋 Copied {generated_og_count} "
        f"generated OG image(s)"
    )

    # ========================================================
    # Check generated metadata
    # ========================================================

    if not HOMEPAGE_JSON.exists():

        raise FileNotFoundError(
            f"Missing {HOMEPAGE_JSON}"
        )


def main():
    prepare_dist()


if __name__ == "__main__":
    main()