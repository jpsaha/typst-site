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

    number_text, title = m.groups()

    number = None if number_text == "none" else int(number_text)

    lectures.append({
        "file": path.stem,
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

with OUT.open("w", encoding="utf-8") as f:
    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")
    f.write("#let lectures = (\n")

    for lec in lectures:
        num = "none" if lec["number"] is None else str(lec["number"])

        f.write("  (\n")
        f.write(f'    file: "{lec["file"]}",\n')
        f.write(f'    html: "{lec["file"]}.html",\n')
        f.write(f'    pdf: "{lec["file"]}.pdf",\n')
        f.write(f"    number: {num},\n")
        f.write(f'    title: "{lec["title"]}",\n')
        f.write("  ),\n")

    f.write(")\n")

print(f"Wrote {OUT}")