from .config import PAGES_TYP, PAGES_META_TYP
from .typst import write_field, write_header


def content_source(page):
    """Return the path to the page's content file."""

    source = page["source"]

    if source.endswith(".typ"):
        return source[:-4] + "_content.typ"

    return source + "_content.typ"


def write_pages(pages):
    """Generate generated/pages.typ."""

    with PAGES_TYP.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header(file)

        for page in pages:

            content = content_source(page)

            file.write(
                f"""
= {page["title"]}

#include "../content/{content}"

"""
            )

    print(
        f"Wrote {PAGES_TYP}"
    )


def write_pages_meta(pages):
    """Generate generated/pages_meta.typ."""

    with PAGES_META_TYP.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header(file)

        file.write(
            "#let pages = (\n"
        )

        for page in pages:

            file.write(
                "  (\n"
            )

            write_field(
                file,
                "html",
                f'{page["file"]}.html',
                indent=4,
            )

            write_field(
                file,
                "pdf",
                f'{page["file"]}.pdf',
                indent=4,
            )

            write_field(
                file,
                "title",
                page["title"],
                indent=4,
            )

            file.write(
                "  ),\n"
            )

        file.write(
            ")\n"
        )

    print(
        f"Wrote {PAGES_META_TYP}"
    )
