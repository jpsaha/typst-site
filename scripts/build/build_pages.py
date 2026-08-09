#!/usr/bin/env python3

"""
Build individual HTML and PDF pages from generated homepage metadata.

Reads:
    generated/homepage.json

Generates:
    dist/index.html
    dist/pages/*.html
    dist/pdf/*.pdf
"""

import json
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

            index.write(
                f"""
<h2 class="category-title">
    {category}
</h2>

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