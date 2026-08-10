# 🧮 Typst Mathematics Lecture Portal

A metadata-driven mathematics lecture and problem-solving portal built with **Typst**.

The project generates both:

* **browser-viewable HTML pages** from Typst
* **print-ready PDF documents**
* **individual lecture/page PDFs**
* **combined course and category books**
* **automatically generated navigation and homepage data**
* **metadata and build diagnostics**

The source is organized so that **content, metadata, templates, generation, and build output remain separate**.

---

## Quick Start

### Prerequisites

Install:

* **Typst CLI** — currently developed against Typst 0.13.x or later
* **Python 3**
* A standard Unix shell such as `bash`

No Node.js or external search-indexing tool is currently required by the build pipeline.

### Build everything

From the repository root:

```bash
chmod +x ./build.sh
./build.sh
```

The build generates the website and PDFs under:

```text
dist/
```

### Preview locally

After building:

```bash
cd dist
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

On macOS:

```bash
open http://localhost:8000
```

---

# Project Structure

The important parts of the repository are:

```text
typst-site/
├── assets/
│   └── css/
│       └── style.css
│
├── content/
│   ├── courses/
│   ├── lectures/
│   ├── mopss/
│   └── olympiad/
│
├── diagnostics/
│   ├── imports.dot
│   ├── link_report.txt
│   └── metadata_report.txt
│
├── figures/
│
├── generated/
│   ├── book.typ
│   ├── category_*.typ
│   ├── homepage.json
│   ├── homepage.typ
│   ├── lectures.typ
│   ├── pages.typ
│   └── pages_meta.typ
│
├── scripts/
│   ├── build/
│   ├── lint/
│   ├── metadata/
│   └── utils/
│
├── templates/
│   ├── block-engine.typ
│   ├── blocks.typ
│   ├── code.typ
│   ├── colors.typ
│   ├── config.typ
│   ├── counters.typ
│   ├── course.typ
│   ├── math.typ
│   ├── nav.typ
│   ├── render.typ
│   ├── theorems.typ
│   └── utils.typ
│
├── book_source.typ
├── pages_source.typ
├── pdflayout.typ
└── build.sh
```

---

# Content Organization

Content is divided into several areas.

## Lectures

Lecture wrappers and their actual content are kept in separate files:

```text
content/lectures/
├── lec1.typ
├── lec1_content.typ
├── lec2.typ
├── lec2_content.typ
├── lec3.typ
└── lec3_content.typ
```

The wrapper contains metadata and the `_content.typ` file contains the actual lecture material.

For example:

```text
lec1.typ
lec1_content.typ
```

The generated system uses the metadata from `lec1.typ` and includes the content from `lec1_content.typ`.

---

## Courses

Course material is organized similarly:

```text
content/courses/
├── codeeg.typ
├── codeeg_content.typ
├── fun.typ
└── fun_content.typ
```

---

## Olympiad Material

Olympiad material is grouped by competition:

```text
content/olympiad/
├── ioqm/
│   ├── ioqm2024.typ
│   ├── ioqm2024_content.typ
│   ├── ioqm2025.typ
│   └── ioqm2025_content.typ
│
└── rmo/
    ├── rmo2025.typ
    └── rmo2025_content.typ
```

---

## MOPSS

MOPSS material is organized separately:

```text
content/mopss/
├── mopss_aug08.typ
├── mopss_aug08_content.typ
├── mopss_aug29.typ
├── mopss_aug29_content.typ
└── motypprog/
    ├── fermatlittle.typ
    ├── ioqm2025ap18full.typ
    ├── ioqm2025ap18partial.typ
    ├── ioqm2025ap2.typ
    ├── ioqm2025ap2_venn.typ
    ├── ioqm2025ap8.typ
    └── php.typ
```

---

# Metadata

Each metadata-bearing wrapper contains a `lecture` dictionary.

A typical wrapper looks conceptually like:

```typst
#let lecture = (
  file: "lec1",
  number: 1,
  title: "Linear Transformations & Matrices",
  category: "Linear Algebra",
)
```

The metadata is used to generate:

* lecture/page navigation
* homepage information
* previous/next links
* category books
* combined books
* generated Typst files
* HTML/PDF output information

### Required metadata

The metadata validator currently requires:

```text
file
title
```

Other fields, such as:

```text
number
category
```

are handled according to the project's metadata rules.

For lectures, `number` identifies the lecture number. Pages without a lecture number are treated separately by the generation pipeline.

---

# Adding New Content

To add a new lecture:

### 1. Create the wrapper

For example:

```text
content/lectures/lec4.typ
```

### 2. Create the content file

```text
content/lectures/lec4_content.typ
```

### 3. Add metadata

The wrapper should define the required metadata:

```typst
#let lecture = (
  file: "lec4",
  number: 4,
  title: "Your Lecture Title",
  category: "Your Category",
)
```

### 4. Put the lecture material in `_content.typ`

For example:

```text
lec4_content.typ
```

contains the actual definitions, theorems, examples, exercises, proofs, and other material.

### 5. Run the build

```bash
./build.sh
```

The metadata generation pipeline discovers the new content and updates the generated files automatically.

---

# Build Pipeline

The main entry point is:

```text
build.sh
```

The pipeline performs the following major steps.

### 1. Generate metadata

```text
scripts/build/generate_metadata.py
```

This discovers the content and generates the required Typst/JSON files.

The metadata generation is divided into modules under:

```text
scripts/metadata/
```

These modules handle discovery, navigation, homepage generation, page generation, book generation, and metadata reporting.

### 2. Validate metadata

```text
scripts/lint/check_metadata.py
```

This checks metadata structure, required fields, field types, duplicate file identifiers, corresponding content files, and lecture numbers.

### 3. Validate generated files

```text
scripts/lint/check_generated.py
```

This checks that generated files are consistent with the source metadata.

### 4. Rebuild `dist/`

The generated page, PDF, and asset directories are cleaned before compilation so that stale output files are not retained.

### 5. Build HTML pages

```text
scripts/build/build_pages.py
```

This generates the individual browser-viewable pages and corresponding PDFs.

### 6. Build category books

Generated category sources such as:

```text
generated/category_ioqm.typ
generated/category_mopss.typ
generated/category_olympiad.typ
```

are compiled into category PDFs.

### 7. Build combined books

The pipeline also produces:

```text
dist/pdf/book.pdf
dist/pdf/pages.pdf
```

### 8. Check links

```text
scripts/lint/check_links.py
```

The generated HTML files are scanned for broken local links.

---

# Generated Files

The directory:

```text
generated/
```

contains files produced automatically by the metadata pipeline.

Examples include:

```text
generated/book.typ
generated/lectures.typ
generated/pages.typ
generated/pages_meta.typ
generated/homepage.typ
generated/homepage.json
generated/category_*.typ
```

These files should generally **not be edited manually**.

They will be regenerated by:

```bash
./build.sh
```

---

# Build Output

The final website and PDFs are placed in:

```text
dist/
```

A typical output looks like:

```text
dist/
├── assets/
│   └── css/
│       └── style.css
│
├── index.html
│
├── pages/
│   ├── lec1.html
│   ├── lec2.html
│   ├── lec3.html
│   ├── ioqm2024.html
│   └── ...
│
└── pdf/
    ├── book.pdf
    ├── pages.pdf
    ├── lec1.pdf
    ├── lec2.pdf
    ├── category_ioqm.pdf
    └── ...
```

`dist/` is build output and can be safely regenerated.

---

# Diagnostics

Build diagnostics are kept separately from generated site files:

```text
diagnostics/
```

Current reports include:

```text
diagnostics/
├── imports.dot
├── link_report.txt
└── metadata_report.txt
```

### Metadata report

```text
metadata_report.txt
```

summarizes the discovered metadata, including lectures, pages, and categories.

### Link report

```text
link_report.txt
```

contains the results of the generated HTML link check.

### Import graph

```text
imports.dot
```

contains the Typst import dependency graph and can be inspected with Graphviz tools.

The reports are diagnostic artifacts and are not part of the published website.

---

# Templates

Reusable Typst functionality lives under:

```text
templates/
```

Important areas include:

### Blocks and theorems

```text
templates/blocks.typ
templates/theorems.typ
templates/block-engine.typ
```

These define reusable mathematical environments such as theorems, definitions, lemmas, propositions, examples, remarks, notes, and exercises.

### Navigation

```text
templates/nav.typ
```

contains navigation-related components.

### Rendering

```text
templates/render.typ
```

contains rendering logic shared by the HTML and PDF targets.

### Styling

```text
templates/colors.typ
templates/config.typ
```

contain project-wide configuration and visual settings.

### Mathematics

Reusable mathematical notation and helpers are organized under:

```text
templates/math/
```

---

# Figures

Figures are stored separately from the lecture source:

```text
figures/
├── common/
├── lectures/
│   ├── lec1/
│   ├── lec2/
│   └── ...
└── olympiad/
```

This keeps source content and graphical assets organized independently.

---

# Customization

### Website styling

Edit:

```text
assets/css/style.css
```

to change the appearance of the generated HTML pages.

### Typst templates

Edit the appropriate file under:

```text
templates/
```

to change layouts, blocks, navigation, typography, colors, or mathematical components.

### PDF layout

The main PDF-related layout files include:

```text
book_source.typ
pages_source.typ
pdflayout.typ
```

---

# Development and Validation

Several standalone checks are available under:

```text
scripts/lint/
```

### Metadata

```bash
python3 scripts/lint/check_metadata.py
```

### Generated files

```bash
python3 scripts/lint/check_generated.py
```

### Imports

```bash
python3 scripts/lint/check_imports.py
```

### Links

```bash
python3 scripts/lint/check_links.py
```

For normal development, however, running:

```bash
./build.sh
```

is usually sufficient because the main build pipeline runs the important validation steps automatically.

---

# Design Philosophy

The project follows a few basic principles:

1. **Content is separate from metadata.**
2. **Generated files are separate from source files.**
3. **Diagnostics are separate from published output.**
4. **The same metadata drives HTML, PDF, navigation, and indexing.**
5. **Generated artifacts should be reproducible from the source.**
6. **The build should remove stale output rather than silently preserve obsolete files.**
7. **Reusable Typst functionality belongs in templates rather than individual lectures.**

This structure makes it possible to add lectures, courses, olympiad material, and problem-solving pages without manually maintaining the website navigation or PDF collections.

---

# Typical Workflow

A normal editing cycle is:

```text
Edit content
    ↓
Update metadata if necessary
    ↓
./build.sh
    ↓
Metadata validation
    ↓
Generated files
    ↓
HTML + PDF compilation
    ↓
Link validation
    ↓
Build diagnostics summary
```

After a successful build, inspect:

```text
dist/
```

for the generated website and PDFs, and:

```text
diagnostics/
```

for validation reports.
