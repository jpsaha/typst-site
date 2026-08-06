#!/usr/bin/env python3

"""
Generate metadata files from lecture metadata.

Each lecture file should contain:

#let lecture = (
  file: "lec1",
  number: 1,
  title: "Linear Transformations & Matrices",
  category: "Linear Algebra",
)

Generates:

templates/generated.typ
templates/homepage.typ
templates/homepage.json
"""

from pathlib import Path
import re
import json


ROOT = Path(__file__).resolve().parent.parent

SRC = ROOT / "content"

TEMPLATES = ROOT / "templates"

GENERATED = TEMPLATES / "generated.typ"
HOMEPAGE_TYP = TEMPLATES / "homepage.typ"
HOMEPAGE_JSON = TEMPLATES / "homepage.json"


# ------------------------------------------------------------
# Match lecture metadata
# ------------------------------------------------------------

LECTURE_RE = re.compile(
    r"#let\s+lecture\s*=\s*\(\s*"
    r"file\s*:\s*\"([^\"]+)\"\s*,\s*"
    r"number\s*:\s*(none|\d+)\s*,\s*"
    r"title\s*:\s*\"([^\"]+)\"\s*,?\s*"
    r"category\s*:\s*\"([^\"]+)\"\s*,?\s*"
    r"\)",
    re.DOTALL,
)


lectures = []


# ------------------------------------------------------------
# Read lecture files
# ------------------------------------------------------------

for path in sorted(SRC.glob("*.typ")):

    text = path.read_text(encoding="utf-8")

    m = LECTURE_RE.search(text)

    if not m:
        print(f"Skipping {path.name}: no lecture metadata.")
        continue

    file_name, number_text, title, category = m.groups()

    number = None if number_text == "none" else int(number_text)

    lectures.append(
        {
            "file": file_name,
            "number": number,
            "title": title,
            "category": category,
        }
    )


# ------------------------------------------------------------
# Sort lectures
# ------------------------------------------------------------

lectures.sort(
    key=lambda x: (
        x["number"] is None,
        x["number"] if x["number"] is not None else 10**9,
        x["file"],
    )
)


# ------------------------------------------------------------
# Add previous / next
# Only numbered lectures participate
# ------------------------------------------------------------

numbered = [
    lec for lec in lectures
    if lec["number"] is not None
]


for i, lec in enumerate(numbered):

    if i > 0:
        prev = numbered[i - 1]
        lec["previous"] = {
            "title": prev["title"],
            "html": prev["file"] + ".html",
        }
    else:
        lec["previous"] = None


    if i < len(numbered) - 1:
        nxt = numbered[i + 1]
        lec["next"] = {
            "title": nxt["title"],
            "html": nxt["file"] + ".html",
        }
    else:
        lec["next"] = None


# Non lectures (fun etc.)
for lec in lectures:
    if lec["number"] is None:
        lec["previous"] = None
        lec["next"] = None



# ------------------------------------------------------------
# Write generated.typ
# ------------------------------------------------------------

with GENERATED.open("w", encoding="utf-8") as f:

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
        f.write(f'    category: "{lec["category"]}",\n')


        if lec["previous"]:

            f.write(
                "    previous: (\n"
                f'      title: "{lec["previous"]["title"]}",\n'
                f'      html: "{lec["previous"]["html"]}",\n'
                "    ),\n"
            )

        else:
            f.write("    previous: none,\n")


        if lec["next"]:

            f.write(
                "    next: (\n"
                f'      title: "{lec["next"]["title"]}",\n'
                f'      html: "{lec["next"]["html"]}",\n'
                "    ),\n"
            )

        else:
            f.write("    next: none,\n")


        f.write("  ),\n")


    f.write(")\n")


print(f"Wrote {GENERATED}")



# ------------------------------------------------------------
# Write homepage.typ
# ------------------------------------------------------------

with HOMEPAGE_TYP.open("w", encoding="utf-8") as f:

    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")

    f.write("#let homepage = (\n")

    for lec in lectures:

        if lec["number"] is None:
            continue

        f.write(
            "  (\n"
            f'    title: "{lec["title"]}",\n'
            f'    category: "{lec["category"]}",\n'
            f'    html: "{lec["file"]}.html",\n'
            f'    pdf: "{lec["file"]}.pdf",\n'
            "  ),\n"
        )

    f.write(")\n")


print(f"Wrote {HOMEPAGE_TYP}")



# ------------------------------------------------------------
# Write homepage.json
# ------------------------------------------------------------

homepage = {}

for lec in lectures:

    cat = lec["category"]

    if cat not in homepage:
        homepage[cat] = []

    homepage[cat].append(
        {
            "title": lec["title"],
            "html": lec["file"] + ".html",
            "pdf": lec["file"] + ".pdf",
        }
    )


with HOMEPAGE_JSON.open("w", encoding="utf-8") as f:
    json.dump(
        homepage,
        f,
        indent=2,
        ensure_ascii=False,
    )


print(f"Wrote {HOMEPAGE_JSON}")