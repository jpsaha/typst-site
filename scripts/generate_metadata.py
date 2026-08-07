#!/usr/bin/env python3

"""
Generate metadata files from lecture metadata.

Each lecture file should contain:

#let lecture = (
  file: "lec1",
  number: 1,
  title: "Linear Transformations & Matrices",
  category: "Linear Algebra",
  date: "2026-08-10",
  reading: "Chapter 2",
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
GENERATED_BOOK = TEMPLATES / "generated_book.typ"
GENERATED_PAGES = TEMPLATES / "generated_pages.typ"


# ------------------------------------------------------------
# Find lecture metadata block
# ------------------------------------------------------------

LECTURE_BLOCK_RE = re.compile(
    r"#let\s+lecture\s*=\s*\((.*?)\)",
    re.DOTALL,
)


# ------------------------------------------------------------
# Parse lecture metadata
# ------------------------------------------------------------

def parse_lecture(text):

    m = LECTURE_BLOCK_RE.search(text)

    if m is None:
        return None

    body = m.group(1)

    lecture = {}

    for line in body.splitlines():

        line = line.strip()

        if not line:
            continue

        if line.endswith(","):
            line = line[:-1]

        if ":" not in line:
            continue

        key, value = line.split(":", 1)

        key = key.strip()
        value = value.strip()


        # string
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]

        # none
        elif value == "none":
            value = None

        # integer
        else:
            try:
                value = int(value)
            except ValueError:
                pass


        lecture[key] = value


    return lecture



# # ------------------------------------------------------------
# # Read all lectures
# # ------------------------------------------------------------

# lectures = []


# for path in sorted(SRC.glob("*.typ")):

#     text = path.read_text(encoding="utf-8")

#     lecture = parse_lecture(text)


#     if lecture is None:
#         print(f"Skipping {path.name}: no lecture metadata.")
#         continue


#     lectures.append(lecture)


# ------------------------------------------------------------
# Read all lecture wrappers
# ------------------------------------------------------------

lectures = []
pages = []

for path in sorted(SRC.glob("*.typ")):

    if path.stem.endswith("_content"):
        continue

    text = path.read_text(encoding="utf-8")

    data = parse_lecture(text)

    if data is None:
        print(f"Skipping {path.name}: no metadata.")
        continue

    if data.get("number") is None:
        pages.append(data)
        print(f"Page: {data['file']}")
    else:
        lectures.append(data)
        print(f"Lecture: {data['file']}")


# lectures = []
# pages = []

# for path in sorted(SRC.glob("*.typ")):

#     if path.stem.endswith("_content"):
#         continue

#     text = path.read_text(encoding="utf-8")

#     lecture = parse_lecture(text)

#     if lecture is None:
#         print(f"Adding content page: {path.name}")

#     if lecture.get("number") is None:
#         print(f"Adding page: {lecture['file']}")
#         pages.append(lecture)
#         continue

#     lectures.append(lecture)

print("LECTURES:")
for lec in lectures:
    print(lec)

print("\nPAGES:")
for page in pages:
    print(page)


# ------------------------------------------------------------
# Sort lectures
# ------------------------------------------------------------

lectures.sort(
    key=lambda x: (
        x.get("number") is None,
        x.get("number")
        if x.get("number") is not None
        else 10**9,
        x.get("file"),
    )
)



# ------------------------------------------------------------
# Add previous / next links
# Only numbered lectures
# ------------------------------------------------------------

numbered = [
    lec
    for lec in lectures
    if lec.get("number") is not None
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



# Non-numbered pages (fun, extras)
for lec in lectures:

    if lec.get("number") is None:

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


        # generated fields
        f.write(
            f'    html: "{lec["file"]}.html",\n'
        )

        f.write(
            f'    pdf: "{lec["file"]}.pdf",\n'
        )


        # all metadata
        for key, value in lec.items():

            if key in ("previous", "next"):
                continue


            if value is None:

                f.write(
                    f"    {key}: none,\n"
                )

            elif isinstance(value, int):

                f.write(
                    f"    {key}: {value},\n"
                )

            else:

                f.write(
                    f'    {key}: "{value}",\n'
                )



        # previous

        if lec["previous"] is None:

            f.write(
                "    previous: none,\n"
            )

        else:

            p = lec["previous"]

            f.write(
                "    previous: (\n"
                f'      title: "{p["title"]}",\n'
                f'      html: "{p["html"]}",\n'
                "    ),\n"
            )



        # next

        if lec["next"] is None:

            f.write(
                "    next: none,\n"
            )

        else:

            n = lec["next"]

            f.write(
                "    next: (\n"
                f'      title: "{n["title"]}",\n'
                f'      html: "{n["html"]}",\n'
                "    ),\n"
            )



        f.write("  ),\n")



    f.write(")\n")


print(f"Wrote {GENERATED}")


with GENERATED_PAGES.open("w", encoding="utf-8") as f:

    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")

    for page in pages:
        f.write(
f'''
= {page["title"]}

#include "../content/{page["file"]}_content.typ"

'''
        )



# ------------------------------------------------------------
# Write homepage.typ
# ------------------------------------------------------------

with HOMEPAGE_TYP.open("w", encoding="utf-8") as f:


    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")

    f.write("#let homepage = (\n")


    for lec in lectures:


        if lec.get("number") is None:
            continue


        f.write("  (\n")


        for key in (
            "number",
            "title",
            "category",
            "date",
            "reading",
            "duration",
        ):

            if key in lec:

                value = lec[key]

                if isinstance(value, int):

                    f.write(
                        f"    {key}: {value},\n"
                    )

                else:

                    f.write(
                        f'    {key}: "{value}",\n'
                    )



        f.write(
            f'    html: "{lec["file"]}.html",\n'
        )

        f.write(
            f'    pdf: "{lec["file"]}.pdf",\n'
        )


        f.write("  ),\n")



    f.write(")\n")


print(f"Wrote {HOMEPAGE_TYP}")


# ------------------------------------------------------------
# Write generated_book.typ
# ------------------------------------------------------------

with GENERATED_BOOK.open("w", encoding="utf-8") as f:
    f.write("// AUTO-GENERATED. DO NOT EDIT.\n\n")

    f.write('#import "render.typ": include-lecture\n')
    f.write('#import "generated.typ": lectures\n\n')
    
    for lec in lectures:

        if lec.get("number") is None:
            print(f"Skipping {lec['file']}: no lecture number.")
            continue

        f.write(
f"""#include-lecture(
  (
    file: "{lec["file"]}",
    number: {lec["number"]},
    title: "{lec["title"]}",
  ),
  [
    #include "../content/{lec["file"]}_content.typ"
  ],
)

"""
        )

print(f"Wrote {GENERATED_BOOK}")


# ------------------------------------------------------------
# Write homepage.json
# ------------------------------------------------------------

homepage = {}


for lec in lectures + pages:


    category = lec.get(
        "category",
        "Uncategorized"
    )


    homepage.setdefault(
        category,
        []
    )


    homepage[category].append(

        {
            "title": lec["title"],
            "html": lec["file"] + ".html",
            "pdf": lec["file"] + ".pdf",

            **{
                k: v
                for k, v in lec.items()
                if k not in (
                    "file",
                    "title",
                    "category",
                    "previous",
                    "next",
                )
            },
        }

    )



with HOMEPAGE_JSON.open(
    "w",
    encoding="utf-8"
) as f:

    json.dump(
        homepage,
        f,
        indent=2,
        ensure_ascii=False,
    )


print(f"Wrote {HOMEPAGE_JSON}")