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
# Write homepage entry
# ============================================================

def write_homepage_entry(file, lecture):
    """Write one lecture/page entry to index.html."""

    title = lecture["title"]
    html = lecture["html"]
    pdf = lecture["pdf"]

    file.write(
        f"""
<div class="lecture">

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

        index.write(
            "<!DOCTYPE html>\n"
            "<html>\n"
            "<head>\n"
            '  <meta charset="utf-8">\n'
            '  <link rel="stylesheet" '
            'href="assets/css/style.css">\n'
            "</head>\n"
            "<body>\n"
        )

        for category, lectures in categories.items():

            index.write(
                f"\n<h2>{category}</h2>\n"
            )

            for lecture in lectures:

                compile_page(lecture)

                write_homepage_entry(
                    index,
                    lecture,
                )

        index.write(
            "\n</body>\n"
            "</html>\n"
        )


# ============================================================
# Main
# ============================================================

def main():

    if not HOMEPAGE_JSON.exists():
        raise FileNotFoundError(
            f"Missing {HOMEPAGE_JSON}"
        )

    PAGES_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    PDF_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    with HOMEPAGE_JSON.open(
        encoding="utf-8",
    ) as file:

        categories = json.load(file)

    build_homepage(categories)

    print(
        f"🌐 Wrote {INDEX_HTML}"
    )


if __name__ == "__main__":
    main()