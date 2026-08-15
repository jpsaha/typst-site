#!/usr/bin/env python3

"""
Build individual HTML pages and the homepage.

Reads:
    generated/homepage.json

Generates:
    dist/index.html
    dist/pages/*.html

PDF files are built separately by build_pdfs.py,
build_categories.py, build_book.py, and build_pages_pdf.py.
"""

from pathlib import Path
import json
import re
import subprocess

from scripts.config import (
    ROOT,
    PAGES_DIR,
    CONTENT_DIR,
    HOMEPAGE_JSON,
    INDEX_HTML,
    SITE_TITLE,
    SITE_ICON,
    SITE_TAGLINE,
    SITE_DESCRIPTION,
)

# from scripts.metadata.seo import seo_head
from scripts.metadata.seo import inject_seo


# ============================================================
# Compile one page
# ============================================================

def compile_page(lecture):
    """Compile one content page to HTML and inject SEO metadata."""

    # ========================================================
    # Basic lecture metadata
    # ========================================================

    title = lecture["title"]
    html = lecture["html"]
    source = lecture["source"]

    # --------------------------------------------------------
    # Resolve source and output paths
    # --------------------------------------------------------

    source_path = CONTENT_DIR / source
    html_path = PAGES_DIR / html

    print(f"📖 Compiling {title}")

    # ========================================================
    # Compile Typst source to HTML
    # ========================================================

    subprocess.run(
        [
            "typst",
            "compile",
            "--features",
            "html",
            "--root",
            str(ROOT),
            str(source_path),
            str(html_path),
            "--input",
            "format=html",
        ],
        check=True,
    )

    # ========================================================
    # Read generated HTML
    # ========================================================

    html_content = html_path.read_text(
        encoding="utf-8",
    )

    # ========================================================
    # SEO description
    # ========================================================

    # Use the lecture-specific description when supplied.
    # Otherwise fall back to the site-wide description.
    description = lecture.get(
        "description",
        SITE_DESCRIPTION,
    )

    # ========================================================
    # Determine Open Graph image
    # ========================================================
    #
    # Priority:
    #
    #   1. Explicit "og_image" in lecture metadata.
    #   2. Generated OG image corresponding to the source file.
    #
    # Example with:
    #
    #     source: "lectures/lec1.typ"
    #
    # the generated OG image is:
    #
    #     generated/og/lectures/lec1.png
    #
    # and the published URL is:
    #
    #     /assets/og/lectures/lec1.png
    #
    # --------------------------------------------------------

    if lecture.get("og_image"):

        # ----------------------------------------------------
        # An explicit image was supplied in the metadata.
        # Do not generate or derive another OG image path.
        # ----------------------------------------------------

        image = lecture["og_image"]

    else:

        # ----------------------------------------------------
        # No explicit OG image was supplied.
        #
        # Derive the generated image path from the source
        # content path while preserving its directory structure.
        #
        #     lectures/lec1.typ
        #             ↓
        #     lectures/lec1.png
        #
        #     lectures_dummy/lec2.typ
        #             ↓
        #     lectures_dummy/lec2.png
        # ----------------------------------------------------

        source_path_relative = Path(source)

        image = (
            "/assets/og/"
            + str(
                source_path_relative.with_suffix(".png")
            )
        )

    # ========================================================
    # Inject SEO / Open Graph / Twitter metadata
    # ========================================================

    html_content = inject_seo(
        html_content,
        title=title,
        description=description,
        path=f"pages/{html}",
        og_type="article",
        image=image,
    )

    # ========================================================
    # Write HTML back to disk
    # ========================================================

    html_path.write_text(
        html_content,
        encoding="utf-8",
    )

# ============================================================
# Homepage entry
# ============================================================

def write_homepage_entry(file, lecture):
    """Write one lecture/page entry to index.html."""

    title = lecture["title"]
    html = lecture["html"]
    pdf = lecture["pdf"]

    file.write(
        f"""
<div class="lecture-row">

    <span>{title}</span>

    <div class="lecture-links">

        <a
            href="pages/{html}"
            class="btn btn-web"
        >
            🌐 View Web
        </a>

        <a
            href="pdf/{pdf}"
            class="btn btn-pdf"
            target="_blank"
        >
            📄 PDF Version
        </a>

    </div>

</div>
"""
    )


# ============================================================
# Category PDF filename
# ============================================================

def category_pdf_filename(category):
    """
    Convert a category name into the category PDF filename.

    Examples:

        Linear Algebra -> category_linear_algebra.pdf
        IOQM           -> category_ioqm.pdf
        R-M-O          -> category_r_m_o.pdf
    """

    name = category.lower().strip()

    name = re.sub(
        r"[^a-z0-9]+",
        "_",
        name,
    )

    name = name.strip("_")

    return f"category_{name}.pdf"


# ============================================================
# Build homepage
# ============================================================

def build_homepage(categories):
    """Write the generated index.html."""

    with INDEX_HTML.open(
        "w",
        encoding="utf-8",
    ) as index:

        # ----------------------------------------------------
        # Header
        # ----------------------------------------------------

        index.write(
            "<!DOCTYPE html>\n"
            "<html lang=\"en\">\n"
            "<head>\n"
            '    <meta charset="UTF-8">\n'
            '    <meta name="viewport" '
            'content="width=device-width, initial-scale=1.0">\n'
            f'    <title>{SITE_TITLE}</title>\n'
            '    <link rel="stylesheet" '
            'href="assets/css/style.css">\n'
            "</head>\n"
            "\n"
            "<body>\n"
            "\n"
            '<div class="index-container">\n'
            "\n"
            '<header class="index-header">\n'
            f"    <h1>{SITE_ICON} {SITE_TITLE}</h1>\n"
            f"    <p>{SITE_TAGLINE}</p>\n"
            "</header>\n"
            "\n"
            '<main class="lecture-list">\n'
        )

        # ----------------------------------------------------
        # Categories
        # ----------------------------------------------------

        for category, lectures in categories.items():

            index.write(
                f"""
        <div style="
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
        ">

            <h2 style="
                margin: 0;
            ">
                {category}
            </h2>

            <div class="lecture-links">

                <a
                    href="pdf/{category_pdf_filename(category)}"
                    class="btn btn-pdf"
                    target="_blank"
                >
                    📚 Download Complete PDF
                </a>

            </div>

        </div>
        """
            )

            # ------------------------------------------------
            # Lectures / pages
            # ------------------------------------------------

            for lecture in lectures:

                compile_page(lecture)

                write_homepage_entry(
                    index,
                    lecture,
                )

        # ----------------------------------------------------
        # Footer
        # ----------------------------------------------------

        index.write(
            """
</main>

</div>

</body>
</html>
"""
        )


    # --------------------------------------------------------
    # Inject homepage SEO
    # --------------------------------------------------------

    html_content = INDEX_HTML.read_text(
        encoding="utf-8",
    )

    html_content = inject_seo(
        html_content,
        title=SITE_TITLE,
        description=SITE_DESCRIPTION,
        path="",
        og_type="website",
    )

    INDEX_HTML.write_text(
        html_content,
        encoding="utf-8",
    )
# ============================================================
# Main
# ============================================================

def main():

    if not HOMEPAGE_JSON.exists():

        raise FileNotFoundError(
            f"Missing {HOMEPAGE_JSON}"
        )

    # --------------------------------------------------------
    # Prepare output directory
    # --------------------------------------------------------

    PAGES_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    # --------------------------------------------------------
    # Read homepage metadata
    # --------------------------------------------------------

    with HOMEPAGE_JSON.open(
        encoding="utf-8",
    ) as file:

        categories = json.load(file)

    # --------------------------------------------------------
    # Build
    # --------------------------------------------------------

    build_homepage(categories)

    print(
        f"🌐 Wrote {INDEX_HTML}"
    )


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    main()