#!/usr/bin/env python3

from scripts.config import (
    PAGES_DIR,
    PDF_DIR,
    METADATA_REPORT,
    LINK_REPORT,
)


def count_files(directory, pattern):
    """Count files matching a glob pattern."""

    if not directory.exists():
        return 0

    return sum(
        1
        for path in directory.rglob(pattern)
        if path.is_file()
    )


def read_report_value(report, label):
    """Read a numeric value from a diagnostic report."""

    if not report.exists():
        return 0

    prefix = f"{label}:"

    with report.open(encoding="utf-8") as file:

        for line in file:

            if line.startswith(prefix):

                value = line.split(":", 1)[1].strip()

                try:
                    return int(value)

                except ValueError:
                    return 0

    return 0


def print_summary(
    build_time,
    time_metadata,
    time_metadata_check,
    time_generated_check,
    time_import_check,
    time_html,
    time_pdf,
    time_categories,
    time_book,
    time_pages,
    time_links,
):
    """Print the final build diagnostics summary."""

    page_count = count_files(
        PAGES_DIR,
        "*.html",
    )

    pdf_count = count_files(
        PDF_DIR,
        "*.pdf",
    )

    category_count = count_files(
        PDF_DIR,
        "category_*.pdf",
    )

    print()
    print("==============================================")
    print("📊 Build diagnostics summary")
    print("==============================================")

    # --------------------------------------------------------
    # Metadata report
    # --------------------------------------------------------

    if METADATA_REPORT.exists():

        print()
        print("## 📋 Metadata")
        print()

        with METADATA_REPORT.open(
            encoding="utf-8"
        ) as file:

            for line in file:

                if line.startswith(
                    (
                        "Total items",
                        "Lectures",
                        "Pages",
                        "Categories",
                    )
                ):
                    print(line, end="")

        print(
            f"Report      : {METADATA_REPORT}"
        )

    else:

        print()
        print("## 📋 Metadata")
        print()
        print("Metadata report not found")

    # --------------------------------------------------------
    # Link report
    # --------------------------------------------------------

    if LINK_REPORT.exists():

        print()
        print("## 🔗 Links")
        print()

        with LINK_REPORT.open(
            encoding="utf-8"
        ) as file:

            for line in file:

                if line.startswith(
                    (
                        "Links checked",
                        "Broken links",
                        "Working links",
                    )
                ):
                    print(line, end="")

        print(
            f"Report      : {LINK_REPORT}"
        )

    else:

        print()
        print("## 🔗 Links")
        print()
        print("Link report not found")

    # --------------------------------------------------------
    # Build statistics
    # --------------------------------------------------------

    print()
    print("## 📦 Build")
    print()

    print(
        f"🌐 HTML pages:      {page_count}"
    )

    print(
        f"📚 Category books:  {category_count}"
    )

    print(
        f"📄 PDF files:       {pdf_count}"
    )

    print(
        f"⏱ Build time:       {build_time}s"
    )

    # --------------------------------------------------------
    # Build timing
    # --------------------------------------------------------

    print()
    print("## ⏱ Build timing")
    print()

    print(
        f"Metadata generation       {time_metadata:>6}s"
    )

    print(
        f"Metadata validation       {time_metadata_check:>6}s"
    )

    print(
        f"Generated validation      {time_generated_check:>6}s"
    )

    print(
        f"Typst import validation   {time_import_check:>6}s"
    )

    print(
        f"HTML pages                {time_html:>6}s"
    )

    print(
        f"Individual PDFs           {time_pdf:>6}s"
    )

    print(
        f"Category PDFs             {time_categories:>6}s"
    )

    print(
        f"Book PDF                  {time_book:>6}s"
    )

    print(
        f"Pages PDF                 {time_pages:>6}s"
    )

    print(
        f"Link checking             {time_links:>6}s"
    )

    print(
        f"Total                     {build_time:>6}s"
    )

    # --------------------------------------------------------
    # Compact summary
    # --------------------------------------------------------

    link_count = read_report_value(
        LINK_REPORT,
        "Links checked",
    )

    broken_count = read_report_value(
        LINK_REPORT,
        "Broken links",
    )

    print()

    print(
        f"{page_count} HTML · "
        f"{pdf_count} PDFs · "
        f"{category_count} categories · "
        f"{link_count} links · "
        f"{broken_count} broken"
    )

    # --------------------------------------------------------
    # Final status
    # --------------------------------------------------------

    print()
    print("==============================================")
    print(
        f"✅ Build completed successfully "
        f"in {build_time}s"
    )
    print("==============================================")


def main():
    # This command is normally called by build.sh,
    # which supplies the timing information.
    raise SystemExit(
        "report.py is intended to be called through scripts/run.py"
    )


if __name__ == "__main__":
    main()