# 🧮 Typst Mathematics Lecture Portal

A metadata-driven mathematics lecture, course, olympiad, and problem-solving portal built with **Typst**.

The project generates:

* **browser-viewable HTML pages** from Typst
* **print-ready PDF documents**
* **individual lecture/page PDFs**
* **combined books**
* **course and category books**
* **automatically generated navigation**
* **automatically generated homepage data**
* **metadata and build diagnostics**
* **import and link validation**

The source is organized so that **content, metadata, templates, generation, diagnostics, and build output remain separate**.

The build system is primarily implemented in **Python + Typst**, with `build.sh` providing the main entry point.

---

# Quick Start

## Prerequisites

Install:

* **Typst CLI** — currently developed against Typst 0.13.x or later
* **Python 3**
* A standard Unix shell such as `bash`

No Node.js or external search-indexing tool is currently required by the build pipeline.

---

## Build everything

From the repository root:

```bash
chmod +x ./build.sh
./build.sh
```

The build generates the website and PDFs under:

```text
dist/
```

Generated metadata and Typst sources are written under:

```text
generated/
```

Diagnostics are written under:

```text
diagnostics/
```

---

## Preview locally

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

The repository is organized into several distinct layers:

```text
typst-site/
├── assets/             # Static website assets
├── coding/             # Architecture and development documentation
├── content/            # Source mathematical content and metadata
├── diagnostics/        # Build and validation reports
├── dist/               # Generated website and PDF output
├── figures/             # Figures and graphical assets
├── generated/           # Generated Typst/JSON metadata files
├── scripts/             # Build, metadata, and linting infrastructure
├── templates/           # Reusable Typst templates and components
│
├── book_source.typ      # Combined book source
├── pages_source.typ     # Combined pages-book source
├── pdflayout.typ        # PDF layout configuration
├── pdflayout_old.typ    # Previous PDF layout implementation
└── build.sh             # Main build entry point
```

The most important principle is that **generated artifacts are not the source of truth**. Source content and metadata are discovered and transformed by the build pipeline.

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

Source content lives under:

```text
content/
```

The current content tree contains:

```text
content/
├── courses/
├── lectures/
├── mopss/
└── olympiad/
```

Different types of material are therefore kept separate while still using the same metadata and generation infrastructure.

---

# Lectures

Lecture wrappers and their actual content are kept in separate files.

For example:

```text
content/lectures/
├── lec1.typ
├── lec1_content.typ
├── lec2.typ
├── lec2_content.typ
├── lec3.typ
└── lec3_content.typ
```

The wrapper contains metadata and imports or includes the corresponding content file.

For example:

```text
lec1.typ
lec1_content.typ
```

The metadata-bearing wrapper is used by the metadata discovery pipeline, while `_content.typ` contains the actual lecture material.

This separation makes it possible to change metadata, navigation, or generation behavior without mixing those concerns into the mathematical content.

---

# Courses

Course material is organized similarly:

```text
content/courses/
├── codeeg.typ
├── codeeg_content.typ
├── fun.typ
└── fun_content.typ
```

A course wrapper provides metadata and the corresponding `_content.typ` file contains the course material.

---

# Olympiad Material

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

This organization allows competition-specific material to be represented both as individual pages and as generated category collections.

---

# MOPSS

MOPSS material is maintained separately:

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

The MOPSS wrapper/content pattern is the same general separation used elsewhere in the project, while `motypprog/` contains supporting mathematical/programming material.

---

# Metadata

Each metadata-bearing wrapper defines a `lecture` dictionary.

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
* metadata reports

---

## Required metadata

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

For lectures, `number` identifies the lecture number.

Pages or other content without a lecture number can be represented separately by the generation pipeline.

---

# Adding New Content

To add a new lecture, the usual workflow is:

## 1. Create the wrapper

For example:

```text
content/lectures/lec4.typ
```

## 2. Create the content file

```text
content/lectures/lec4_content.typ
```

## 3. Add metadata

The wrapper should define the required metadata:

```typst
#let lecture = (
  file: "lec4",
  number: 4,
  title: "Your Lecture Title",
  category: "Your Category",
)
```

## 4. Put the lecture material in `_content.typ`

For example:

```text
lec4_content.typ
```

contains the actual definitions, theorems, examples, exercises, proofs, and other material.

## 5. Run the build

```bash
./build.sh
```

The metadata discovery and generation pipeline automatically discovers the new content and regenerates the relevant files.

---

# Build Architecture

The main entry point is:

```text
build.sh
```

The build system is divided into several Python components under:

```text
scripts/
```

The major areas are:

```text
scripts/
├── build/
├── lint/
├── metadata/
└── utils/
```

This separation keeps the build orchestration, metadata processing, validation, and reusable utilities independent.

---

# Build Pipeline

The exact build orchestration is implemented by:

```text
scripts/run.py
scripts/config.py
scripts/build/
```

The major stages are as follows.

---

## 1. Generate metadata

The main metadata entry point is:

```text
scripts/build/generate_metadata.py
```

The actual metadata work is divided into modules under:

```text
scripts/metadata/
```

These modules handle tasks including:

```text
discover.py
parser.py
navigation.py
typst.py
write_book.py
write_homepage.py
write_lectures.py
write_pages.py
write_report.py
```

The metadata system discovers source content and generates the Typst and JSON artifacts required by the rest of the build.

---

## 2. Validate metadata

Metadata validation is performed by:

```text
scripts/lint/check_metadata.py
```

It checks the metadata structure and the project's metadata rules, including such things as:

* required fields
* field types
* duplicate identifiers
* source/content relationships
* lecture numbering
* metadata consistency

---

## 3. Validate generated files

Generated-file consistency is checked by:

```text
scripts/lint/check_generated.py
```

The generated-file checker is itself organized into supporting modules:

```text
scripts/lint/generated/
├── checks.py
├── config.py
├── report.py
└── source.py
```

This makes it possible to detect stale or missing generated artifacts and discrepancies between source metadata and generated files.

---

## 4. Prepare diagnostics and output directories

The build infrastructure prepares:

```text
diagnostics/
dist/
```

and removes or recreates generated output as appropriate.

The goal is that stale output should not silently survive from an earlier build.

---

## 5. Build HTML pages

HTML generation is handled by:

```text
scripts/build/build_html.py
```

The generated Typst page sources and metadata are used to produce the browser-viewable pages under:

```text
dist/pages/
```

The generated homepage is placed at:

```text
dist/index.html
```

---

## 6. Build individual PDFs

Individual page/lecture PDFs are built by the PDF build components under:

```text
scripts/build/
```

including:

```text
build_pdfs.py
build_pages_pdf.py
```

The resulting PDFs are placed under:

```text
dist/pdf/
```

---

## 7. Build category books

Category sources are generated under:

```text
generated/category_*.typ
```

and compiled into category PDFs.

For example:

```text
generated/category_ioqm.typ
generated/category_mopss.typ
generated/category_olympiad.typ
generated/category_r_m_o.typ
```

produce corresponding category books under:

```text
dist/pdf/
```

The current build also generates category books for categories such as:

```text
Developer
Extras
Fields and Galois Theory
IOQM
MOPSS
Olympiad
RMO
```

---

## 8. Build combined books

The project also produces combined collections.

The primary sources are:

```text
book_source.typ
pages_source.typ
```

and the resulting PDFs include:

```text
dist/pdf/book.pdf
dist/pdf/pages.pdf
```

The generated book metadata is written to:

```text
generated/book.typ
```

The book build logic is implemented under:

```text
scripts/build/build_book.py
```

---

## 9. Build report

Build reporting is handled by:

```text
scripts/build/build_report.py
```

The resulting diagnostic information is written under:

```text
diagnostics/
```

including:

```text
diagnostics/build_report.txt
```

This provides a consolidated view of the build result in addition to the individual validation reports.

---

## 10. Check generated links

Generated HTML is checked by:

```text
scripts/lint/check_links.py
```

The checker scans the generated HTML for broken local links and records the results in:

```text
diagnostics/link_report.txt
```

---

# Generated Files

The directory:

```text
generated/
```

contains files produced automatically by the metadata pipeline.

The current generated tree includes:

```text
generated/
├── book.typ
├── category_developer.typ
├── category_extras.typ
├── category_fields_and_galois_theory.typ
├── category_ioqm.typ
├── category_mopss.typ
├── category_olympiad.typ
├── category_r_m_o.typ
├── homepage.json
├── homepage.typ
├── lectures.typ
├── pages.typ
└── pages_meta.typ
```

These files should generally **not be edited manually**.

They are regenerated by:

```bash
./build.sh
```

The source of truth is the content and metadata under:

```text
content/
```

together with the generation logic under:

```text
scripts/
```

---

# Generated Website and PDF Output

The final website and PDFs are placed under:

```text
dist/
```

The current output is organized as:

```text
dist/
├── assets/
│   ├── css/
│   │   └── style.css
│   ├── images/
│   └── js/
│
├── index.html
│
├── pages/
│   ├── codeeg.html
│   ├── fun.html
│   ├── ioqm2024.html
│   ├── ioqm2025.html
│   ├── lec1.html
│   ├── lec2.html
│   ├── lec3.html
│   ├── mopss_26aug08.html
│   ├── mopss_26aug29.html
│   └── rmo2025.html
│
└── pdf/
    ├── book.pdf
    ├── pages.pdf
    ├── codeeg.pdf
    ├── fun.pdf
    ├── ioqm2024.pdf
    ├── ioqm2025.pdf
    ├── lec1.pdf
    ├── lec2.pdf
    ├── lec3.pdf
    ├── mopss_26aug08.pdf
    ├── mopss_26aug29.pdf
    ├── rmo2025.pdf
    ├── category_developer.pdf
    ├── category_extras.pdf
    ├── category_fields_and_galois_theory.pdf
    ├── category_ioqm.pdf
    ├── category_mopss.pdf
    ├── category_olympiad.pdf
    └── category_r_m_o.pdf
```

`dist/` is build output and can be safely regenerated.

---

# Diagnostics

Build diagnostics are kept separately from generated site files:

```text
diagnostics/
```

The current diagnostic files include:

```text
diagnostics/
├── build_report.txt
├── generated_report.txt
├── imports.dot
├── link_report.txt
└── metadata_report.txt
```

---

## Build report

```text
build_report.txt
```

contains the overall build summary and diagnostic information produced by the build system.

---

## Metadata report

```text
metadata_report.txt
```

summarizes the metadata discovered from the source content, including information about lectures, pages, and categories.

The report is generated by the metadata pipeline.

---

## Generated-file report

```text
generated_report.txt
```

contains the results of the generated-file consistency checks.

It is useful for detecting:

* missing generated entries
* stale generated entries
* source/generated mismatches
* other inconsistencies in generated metadata

---

## Link report

```text
link_report.txt
```

contains the results of the generated HTML link checker.

---

## Import graph

```text
imports.dot
```

contains the Typst import dependency graph.

It can be inspected or rendered with Graphviz tools.

For example:

```bash
dot -Tpdf diagnostics/imports.dot -o diagnostics/imports.pdf
```

if Graphviz is installed.

---

# Templates

Reusable Typst functionality lives under:

```text
templates/
```

The template system is now divided into several layers.

The current structure includes:

```text
templates/
├── block-engine.typ
├── blocks.typ
├── code.typ
├── colors.typ
├── config.typ
├── counters.typ
├── course.typ
├── math.typ
├── nav.typ
├── pdflayout.typ
├── render.typ
├── theorems.typ
├── utils.typ
│
├── euler/
│   ├── components/
│   │   └── theorems.typ
│   └── styles/
│       ├── colors.typ
│       ├── headings.typ
│       ├── page.typ
│       └── typography.typ
│
└── math/
    ├── analysis.typ
    ├── combinatorics.typ
    ├── geometry.typ
    ├── graph.typ
    ├── linear.typ
    ├── logic.typ
    ├── matrix.typ
    ├── misc.typ
    ├── notation.typ
    ├── number.typ
    ├── operators.typ
    ├── probability.typ
    ├── sets.typ
    └── vectors.typ
```

---

## Blocks and theorem system

The main reusable block infrastructure is:

```text
templates/block-engine.typ
templates/blocks.typ
templates/theorems.typ
```

These provide reusable mathematical environments such as:

* theorems
* definitions
* lemmas
* propositions
* corollaries
* claims
* examples
* remarks
* notes
* exercises
* warnings
* other structured blocks

The block engine provides the common implementation while higher-level files define the mathematical interfaces used by content files.

---

## Navigation

Navigation-related functionality lives in:

```text
templates/nav.typ
```

It is used together with generated metadata to provide navigation such as:

* previous/next links
* lecture navigation
* page navigation
* category navigation
* related generated links

---

## Rendering

Shared rendering logic lives in:

```text
templates/render.typ
```

The rendering layer is intended to keep presentation logic separate from individual content files and to support the different output targets.

---

## Configuration and styling

Project-wide configuration and styling are distributed among:

```text
templates/config.typ
templates/colors.typ
templates/counters.typ
templates/utils.typ
```

These provide common configuration, colors, counters, and utility functions used throughout the templates.

---

# Mathematics Templates

Reusable mathematical notation and helpers are organized under:

```text
templates/math/
```

The current modules include:

```text
analysis.typ
combinatorics.typ
geometry.typ
graph.typ
linear.typ
logic.typ
matrix.typ
misc.typ
notation.typ
number.typ
operators.typ
probability.typ
sets.typ
vectors.typ
```

This keeps frequently used notation and mathematical constructions out of individual lecture files.

The top-level:

```text
templates/math.typ
```

provides the common mathematics interface.

---

# Euler Styling

An additional template/style organization is available under:

```text
templates/euler/
```

It currently contains:

```text
templates/euler/
├── components/
│   └── theorems.typ
└── styles/
    ├── colors.typ
    ├── headings.typ
    ├── page.typ
    └── typography.typ
```

This separates Euler-specific components and visual styling from the main project-wide template infrastructure.

---

# Figures

Figures are stored separately from the lecture source:

```text
figures/
├── common/
├── lectures/
│   ├── lec1/
│   ├── lec2/
│   ├── lec3/
│   ├── lec4/
│   └── lec5/
└── olympiad/
```

This keeps mathematical source content and graphical assets organized independently.

Common figures can be shared across multiple pieces of content, while lecture-specific and olympiad-specific figures remain localized.

---

# Website Assets

Static website assets live under:

```text
assets/
```

The current source asset tree is:

```text
assets/
├── README.md
└── css/
    └── style.css
```

The build copies the required assets into:

```text
dist/assets/
```

The generated website therefore remains self-contained under `dist/`.

---

# Website Styling

To change the appearance of the generated HTML pages, edit:

```text
assets/css/style.css
```

The CSS is copied into the generated website during the build.

---

# PDF Layout

The main PDF-related files are:

```text
book_source.typ
pages_source.typ
pdflayout.typ
```

There is also an older implementation retained as:

```text
pdflayout_old.typ
```

The source files define the entry points and layout configuration used for the generated combined PDFs and page collections.

PDF-specific layout should generally be changed in the PDF/template layer rather than in individual content files.

---

# Development Documentation

Architecture and development notes are kept under:

```text
coding/
```

The current documentation includes:

```text
coding/
├── Course Website Roadmap.md
├── Course Website Roadmap.pdf
├── build_architecture_refactoring_roadmap.md
├── build_architecture_refactoring_roadmap.pdf
└── project_architecture_roadmap.md
```

These documents record architectural decisions, planned refactoring, and future development directions.

They are intentionally kept separate from the operational README.

---

# Development and Validation

Several standalone checks are available under:

```text
scripts/lint/
```

---

## Metadata

Run:

```bash
python3 scripts/lint/check_metadata.py
```

This validates source metadata.

---

## Generated files

Run:

```bash
python3 scripts/lint/check_generated.py
```

This checks consistency between source metadata and generated files.

---

## Typst imports

Run:

```bash
python3 scripts/lint/check_imports.py
```

This analyzes Typst imports and reports missing dependencies and circular imports.

The import checker is organized into:

```text
scripts/lint/imports/
├── graph.py
├── parser.py
├── report.py
└── __init__.py
```

It also produces the Graphviz dependency graph:

```text
diagnostics/imports.dot
```

---

## Links

Run:

```bash
python3 scripts/lint/check_links.py
```

This checks local links in generated HTML.

The result is written to:

```text
diagnostics/link_report.txt
```

---

## Normal development workflow

For normal development, running:

```bash
./build.sh
```

is usually sufficient because the main build pipeline runs the important generation and validation stages automatically.

The standalone checks are useful when debugging a particular part of the system.

---

# Design Philosophy

The project follows several basic principles.

1. **Content is separate from metadata.**

   Mathematical content lives in source files while metadata is kept in metadata-bearing wrappers.

2. **Generated files are separate from source files.**

   Everything under `generated/` is derived from the source and should normally not be edited manually.

3. **Diagnostics are separate from published output.**

   Build reports and validation artifacts live under `diagnostics/`, not `dist/`.

4. **The same metadata drives multiple outputs.**

   Metadata is used to generate HTML, PDFs, navigation, homepage information, and category collections.

5. **Generated artifacts should be reproducible.**

   A clean build should be able to regenerate the generated metadata and `dist/` output from the repository source.

6. **Stale output should not silently survive.**

   The build system prepares its output directories so obsolete generated files do not remain unnoticed.

7. **Reusable Typst functionality belongs in templates.**

   Individual lectures should contain mathematical content rather than repeatedly implementing layout, navigation, theorem blocks, or common notation.

8. **Build responsibilities should remain modular.**

   Discovery, metadata parsing, generation, compilation, validation, and reporting are implemented as separate components under `scripts/`.

9. **Source organization should reflect content organization.**

   Lectures, courses, olympiad material, and MOPSS material have their own source areas while sharing the same underlying generation infrastructure.

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
Discover and parse metadata
    ↓
Validate metadata
    ↓
Generate Typst/JSON files
    ↓
Validate generated files
    ↓
Build HTML pages
    ↓
Build individual PDFs
    ↓
Build category books
    ↓
Build combined books
    ↓
Check generated links
    ↓
Generate build diagnostics
```

After a successful build, inspect:

```text
dist/
```

for the generated website and PDFs.

Inspect:

```text
diagnostics/
```

for metadata, generated-file, import, link, and build reports.

---

# Typical Repository Workflow

When modifying the project, the general rule is:

### Edit source content

Modify files under:

```text
content/
```

### Modify reusable presentation or functionality

Modify files under:

```text
templates/
```

### Modify generation behavior

Modify the appropriate modules under:

```text
scripts/metadata/
scripts/build/
```

### Modify validation

Modify the appropriate modules under:

```text
scripts/lint/
```

### Modify website appearance

Modify:

```text
assets/css/style.css
```

### Do not manually edit generated output

Avoid manually editing:

```text
generated/
dist/
```

unless debugging or inspecting generated artifacts.

Regenerate them with:

```bash
./build.sh
```

---

# Future Improvements

The project is functional, but there are several areas that can be improved or extended over time.

Possible directions include:

* **Website search** — add client-side search across lectures, courses, and problem collections.
* **Richer homepage** — improve categorization, filtering, and presentation of available material.
* **Build diagnostics** — expand the final build summary with more detailed timing, file counts, and validation statistics.
* **Metadata tooling** — add stronger validation, duplicate detection, and clearer metadata error messages.
* **Navigation** — further improve breadcrumbs, previous/next navigation, category navigation, and cross-references.
* **PDF presentation** — continue refining typography, page layout, title pages, headers, footers, and category-book design.
* **HTML presentation** — polish responsive layouts, mathematical typography, theorem blocks, code blocks, and mobile presentation.
* **Accessibility** — improve semantic HTML, keyboard navigation, contrast, and screen-reader support.
* **Testing** — introduce more automated checks for generated HTML, PDFs, metadata, links, and Typst imports.
* **CI/CD** — further improve automated builds, deployment checks, and build failure diagnostics.
* **Performance** — reduce unnecessary compilation and improve incremental development workflows.
* **Documentation** — expand documentation as the project architecture and authoring workflow evolve.

These are intentionally ongoing areas of development rather than fixed requirements. The project can evolve incrementally as new content and requirements emerge.

---

# Repository Summary

The current repository can be viewed conceptually as five layers:

```text
                 ┌──────────────────────┐
                 │      content/        │
                 │ Mathematics +        │
                 │ metadata             │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │      scripts/        │
                 │ Discovery + metadata │
                 │ generation + build   │
                 │ validation           │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │     generated/       │
                 │ Generated Typst +    │
                 │ JSON metadata        │
                 └──────────┬───────────┘
                            │
                 ┌──────────┴───────────┐
                 ▼                      ▼
       ┌──────────────────┐   ┌──────────────────┐
       │   templates/     │   │    figures/      │
       │ Layout + blocks  │   │ Graphical assets │
       │ navigation +     │   │                  │
       │ mathematics      │   │                  │
       └────────┬─────────┘   └────────┬─────────┘
                │                      │
                └──────────┬───────────┘
                           ▼
                 ┌──────────────────────┐
                 │       dist/          │
                 │ HTML + PDFs + assets │
                 └──────────────────────┘

                 diagnostics/
                 Build + validation
                 reports
```

The central idea is that **source content and metadata are the authoritative inputs; everything else is generated or derived from them**.
