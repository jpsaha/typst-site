#!/usr/bin/env python3

"""
Build individual HTML and PDF pages from generated homepage metadata.

Reads:
generated/homepage.json

Generates:
dist/index.html
dist/pages/*.html
dist/pdf/*.pdf

Also adds a complete PDF download button for each category.
"""

import json
import re
import subprocess
from pathlib import Path


# ============================================================
# Paths
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

GENERATED = ROOT / "generated"
DIST = ROOT / "dist"

HOMEPAGE_JSON = GENERATED / "homepage.json"
INDEX_HTML = DIST / "index.html"

PAGES_DIR = DIST / "pages"
PDF_DIR = DIST / "pdf"


# ============================================================
# Compile one page
# ============================================================

def compile_page(lecture):
    """Compile one content page to HTML and PDF."""

    title = lecture["title"]
    html = lecture["html"]
    pdf = lecture["pdf"]
    source = lecture["source"]

    source_path = ROOT / "content" / source

    html_path = PAGES_DIR / html
    pdf_path = PDF_DIR / pdf

    print(f"📖 Compiling {title}")

    # --------------------------------------------------------
    # HTML
    # --------------------------------------------------------

    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            str(ROOT),
            str(source_path),
            str(html_path),
            "--input",
            "format=html",
        ],
        check=True,
    )

    # --------------------------------------------------------
    # PDF
    # --------------------------------------------------------

    subprocess.run(
        [
            "typst",
            "compile",
            "--root",
            str(ROOT),
            str(source_path),
            str(pdf_path),
            "--input",
            "format=pdf",
        ],
        check=True,
    )


# ============================================================
# Write one homepage entry
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
    Convert a category name into the same safe filename
    convention used by write_book.py.

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
# Write category PDF button
# ============================================================

def write_category_pdf_entry(file, category):
    """
    Write the complete category PDF button.

    This deliberately uses the existing button classes.
    No new CSS classes are introduced.
    """

    pdf = category_pdf_filename(category)

    file.write(
        f"""
<div class="lecture-links">

    <a
        href="pdf/{pdf}"
        class="btn btn-pdf"
        target="_blank"
    >
        📚 Download Complete PDF
    </a>

</div>
"""
    )


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
            '    <title>Mathematics Lecture Portal</title>\n'
            '    <link rel="stylesheet" '
            'href="assets/css/style.css">\n'
            "</head>\n"
            "\n"
            "<body>\n"
            "\n"
            '<div class="index-container">\n'
            "\n"
            '<header class="index-header">\n'
            "    <h1>🧮 Mathematics Lecture Portal</h1>\n"
            "    <p>Interactive web modules & "
            "downloadable print-ready course material</p>\n"
            "</header>\n"
            "\n"
            '<main class="lecture-list">\n'
        )

        # ----------------------------------------------------
        # Categories
        # ----------------------------------------------------

        for category, lectures in categories.items():

            # ------------------------------------------------
            # Category heading + complete PDF button
            # ------------------------------------------------

            index.write(
                f"""
        <div class="lecture-row">

            <span>{category}</span>

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


# ============================================================
# Main
# ============================================================

def main():

    # --------------------------------------------------------
    # Check metadata
    # --------------------------------------------------------

    if not HOMEPAGE_JSON.exists():

        raise FileNotFoundError(
            f"Missing {HOMEPAGE_JSON}"
        )

    # --------------------------------------------------------
    # Prepare output directories
    # --------------------------------------------------------

    PAGES_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    PDF_DIR.mkdir(
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