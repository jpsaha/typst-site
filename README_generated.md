# Generated

Machine-generated intermediate files.

This directory contains files produced automatically by the build and metadata
generation system. These files should normally **not be edited by hand**.

## Contents

Typical generated files include:

- `homepage.typ` — generated homepage Typst source
- `homepage.json` — homepage metadata used by the website build
- `lectures.typ` — generated lecture metadata
- `pages.typ` — generated page metadata
- `pages_meta.typ` — generated navigation/page information
- `book.typ` — generated complete-course book source
- `category_*.typ` — generated category book sources

The exact set of files may change as the project grows.

## Source of truth

The files in this directory are **not the source of truth**.

Their contents are derived from:

- files under `content/`
- files under `templates/`
- metadata-generation code under `scripts/metadata/`
- build configuration under `scripts/config.py`

If a generated file contains something that needs to be changed, modify the
appropriate source file or generator instead of editing the generated file
directly.

## Regeneration

Generated files are recreated by the build system.

The normal workflow is:

```bash
./build.sh
```
