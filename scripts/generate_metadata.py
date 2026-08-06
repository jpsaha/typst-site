#!/usr/bin/env python3

"""
Generate templates/generated.typ from lecture metadata.

Each lecture file should contain something like

#let lecture = (
  number: 1,
  title: "Linear Transformations & Matrices",
)

The script scans content/*.typ and writes

templates/generated.typ
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "content"
OUT = ROOT / "templates" / "generated.typ"

# Match the lecture metadata block.
LECTURE_RE = re.compile(
    r"#let\s+lecture\s*=\s*\(\s*"
    r"file\s*:\s*\"([^\"]+)\"\s*,\s*"
    r"number\s*:\s*(none|\d+)\s*,\s*"
    r"title\s*:\s*\"([^\"]+)\"\s*,?\s*"
    r"\)",
    re.DOTALL,
)

lectures = []

for path in sorted(SRC.glob("*.typ")):
    text = path.read_text(encoding="utf-8")

    m = LECTURE_RE.search(text)
    if not m:
        print(f"Skipping {path.name}: no lecture metadata.")
        continue

    file_name, number_text, title = m.groups()

    number = None if number_text == "none" else int(number_text)

    lectures.append({
        "file": file_name,
        "number": number,
        "title": title,
    })

# Sort:
#   numbered lectures first
#   by lecture number
#   then unnumbered pages alphabetically
lectures.sort(
    key=lambda x: (
        x["number"] is None,
        x["number"] if x["number"] is not None else 10**9,
        x["file"],
    )
)

# Add previous / next information
for i, lec in enumerate(lectures):

    if i > 0:
        prev = lectures[i - 1]
        lec["previous"] = {
            "file": prev["file"],
            "title": prev["title"],
            "html": prev["file"] + ".html",
        }
    else:
        lec["previous"] = None

    if i < len(lectures) - 1:
        nxt = lectures[i + 1]
        lec["next"] = {
            "file": nxt["file"],
            "title": nxt["title"],
            "html": nxt["file"] + ".html",
        }
    else:
        lec["next"] = None


# Write generated.typ

with OUT.open("w", encoding="utf-8") as f:

    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")
    f.write("#let lectures = (\n")

    for lec in lectures:

        f.write("  (\n")
        f.write(f'    file: "{lec["file"]}",\n')
        f.write(f'    html: "{lec["file"]}.html",\n')
        f.write(f'    pdf: "{lec["file"]}.pdf",\n')

        if lec["number"] is None:
            f.write("    number: none,\n")
        else:
            f.write(f'    number: {lec["number"]},\n')

        f.write(f'    title: "{lec["title"]}",\n')


        # previous
        if lec["previous"]:
            p = lec["previous"]
            f.write(
                "    previous: (\n"
                f'      title: "{p["title"]}",\n'
                f'      html: "{p["html"]}",\n'
                "    ),\n"
            )
        else:
            f.write("    previous: none,\n")


        # next
        if lec["next"]:
            n = lec["next"]
            f.write(
                "    next: (\n"
                f'      title: "{n["title"]}",\n'
                f'      html: "{n["html"]}",\n'
                "    ),\n"
            )
        else:
            f.write("    next: none,\n")


        f.write("  ),\n")

    f.write(")\n")


print(f"Wrote {OUT}")