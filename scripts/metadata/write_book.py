from .config import BOOK_TYP
from .typst import write_header


def write_lecture(file, lecture):
    """Write one lecture to the generated book."""

    file.write(
        f"""#include-lecture(
  (
    file: "{lecture["file"]}",
    number: {lecture["number"]},
    title: "{lecture["title"]}",
  ),
  [
    #include "../content/{lecture["file"]}_content.typ"
  ],
)

"""
    )


def write_book(lectures):
    """Generate generated/book.typ."""

    with BOOK_TYP.open(
        "w",
        encoding="utf-8",
    ) as file:

        write_header(file)

        file.write(
            '#import "../templates/render.typ": include-lecture\n'
        )

        file.write(
            '#import "../generated/lectures.typ": lectures\n\n'
        )

        for lecture in lectures:

            if lecture.get("number") is None:

                print(
                    f"Skipping {lecture['file']}: "
                    "no lecture number."
                )

                continue

            write_lecture(
                file,
                lecture,
            )

    print(
        f"Wrote {BOOK_TYP}"
    )
