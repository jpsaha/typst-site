# 🧮 Typst Mathematics Lecture Portal

A metadata-driven mathematics lecture, course, olympiad, and problem-solving portal built with **Typst**.

The project generates:

* **browser-viewable HTML pages** from Typst
* **print-ready PDF documents**
* **individual lecture/page PDFs**
* **combined books**
* **course and category books**
* **automatically generated homepage**
* **automatically generated navigation**
* **previous/next and category navigation**
* **metadata-driven homepage organization**
* **SEO metadata and canonical URLs**
* **sitemap and `robots.txt`**
* **Open Graph and Twitter Card metadata**
* **generated Open Graph images**
* **metadata and build diagnostics**
* **Typst import/dependency validation**
* **generated-file consistency validation**
* **HTML link validation**
* **Open Graph asset validation**
* **configuration validation**
* **GitHub Pages deployment**

The source is organized so that **content, metadata, templates, generation, diagnostics, and build output remain separate**.

The build system is primarily implemented in **Python + Typst**, with `build.sh` providing the main entry point.

---

# Quick Start

## Prerequisites

Install:

* **Typst CLI** — currently developed against Typst 0.13.x or later
* **Python 3**
* A standard Unix shell such as `bash`

Open Graph image generation may additionally require:

* **Asymptote**
* **TeX Live**
* **ImageMagick**

These additional tools are only required when OG image generation is enabled. Normal builds can reuse existing/static OG assets when generation is disabled.

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

Generated metadata, Typst sources, and intermediate OG assets are written under:

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

# Features

The current system provides:

* 📝 **Typst-first authoring**
* 📚 **Metadata-driven content management**
* 🌐 **Automatic HTML generation**
* 📄 **Individual PDF generation**
* 📖 **Combined book generation**
* 🗂️ **Course and category books**
* 🏠 **Automatically generated homepage**
* 🧭 **Automatic previous/next and category navigation**
* 🔎 **SEO metadata generation**
* 🌍 **Sitemap generation**
* 🤖 **`robots.txt` generation**
* 🖼️ **Open Graph image generation**
* 🐦 **Twitter Card metadata**
* 🔗 **Generated HTML link validation**
* 🧪 **Metadata validation**
* 🧪 **Generated-file consistency validation**
* 🧩 **Typst import/dependency validation**
* ⚙️ **Configuration validation**
* 🖼️ **Open Graph asset validation**
* 📊 **Build and diagnostic reports**
* 🚀 **GitHub Pages deployment**
* ♻️ **Reproducible generated output**

SEO and Open Graph generation are part of the current build pipeline rather than future features.

---

# Project Structure

The repository is organized into distinct source, generation, validation, and publishing layers:

```text
typst-site/
├── README.md
├── assets/                 # Static source website assets
│   ├── README.md
│   ├── css/
│   │   └── style.css
│   └── og/                 # Static/default OG assets
│
├── book_source.typ         # Combined book source
├── pages_source.typ        # Combined pages-book source
├── build.sh                # Main build entry point
│
├── coding/                 # Architecture and development documentation
├── content/                # Source mathematical content and metadata
├── diagnostics/            # Build and validation reports
├── dist/                   # Generated website and PDF output
├── docs/                   # Operational/project documentation
├── figures/                # Figures and graphical assets
├── generated/              # Generated Typst/JSON/OG artifacts
├── install/                # Installation/setup documentation
├── pages_source.typ        # Combined pages source
├── scripts/                # Build, metadata, OG, and linting infrastructure
└── templates/              # Reusable Typst templates and components
```

The most important principle is:

> **Generated artifacts are not the source of truth.**

Source content and metadata are discovered and transformed by the build pipeline:

```text
content/
    │
    │ metadata discovery
    ▼
scripts/
    │
    │ generation
    ▼
generated/
    │
    │ Typst compilation + asset preparation
    ▼
dist/
```

Diagnostics are kept separately:

```text
diagnostics/
```

---

# Content Organization

Source content lives under:

```text
content/
```

The current content tree is organized by subject/program:

```text
content/
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

Different types of material are therefore kept separate while still using the same metadata and generation infrastructure.

---

# Courses

Course-level material is stored under:

```text
content/courses/
```

Current course sources include:

```text
content/courses/
├── codeeg.typ
├── codeeg_content.typ
├── fun.typ
└── fun_content.typ
```

A course wrapper provides metadata, while the corresponding `_content.typ` file contains the actual course material.

---

# FGT

Field and Galois Theory material is stored under:

```text
content/fgt/
```

For example:

```text
content/fgt/
├── lec1.typ
├── lec1_content.typ
├── lec2.typ
└── lec2_content.typ
```

The wrapper/content separation follows the same pattern used throughout the project.

---

# Group Theory

Group Theory material is stored under:

```text
content/gt/
```

For example:

```text
content/gt/
├── lec1.typ
├── lec1_content.typ
├── lec2.typ
├── lec2_content.typ
├── lec3.typ
└── lec3_content.typ
```

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
* SEO metadata
* canonical URLs
* Open Graph information
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
tags
description
date
```

are handled according to the project's metadata rules.

For lectures, `number` identifies the lecture number.

Pages or other content without a lecture number can be represented separately by the generation pipeline.

---

# Adding New Content

To add new content, the usual workflow is:

## 1. Create the metadata wrapper

For example:

```text
content/fgt/lec3.typ
```

## 2. Create the content file

```text
content/fgt/lec3_content.typ
```

## 3. Add metadata

The wrapper should define the required metadata:

```typst
#let lecture = (
  file: "lec3",
  number: 3,
  title: "Your Lecture Title",
  category: "Your Category",
)
```

## 4. Put the mathematical material in `_content.typ`

The content file contains the actual definitions, theorems, examples, exercises, proofs, and other material.

## 5. Run the build

```bash
./build.sh
```

The metadata discovery and generation pipeline automatically discovers the new content and regenerates the relevant files.

---

# Installation and Setup

Installation and repository setup documentation is kept under:

```text
install/
```

The current installation documentation includes:

```text
install/
├── INSTALL.md
└── sync-typst-template.sh
```

The main installation guide is:

```text
install/INSTALL.md
```

The synchronization helper is:

```text
install/sync-typst-template.sh
```

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
├── og/
├── utils/
├── config.py
└── run.py
```

This separation keeps build orchestration, metadata processing, Open Graph generation, validation, and reusable utilities independent.

---

# Central Configuration

Project-wide configuration is centralized in:

```text
scripts/config.py
```

This module contains configuration for:

* project paths
* generated-file paths
* distribution paths
* diagnostic paths
* site identity
* SEO
* Open Graph generation
* build modes
* GitHub repository information

Build scripts should import project-specific paths and configuration from this module rather than constructing them independently.

Important Open Graph configuration values include:

```text
TYPST_OG_BUILD
TYPST_OG_GITBUILD
TYPST_OG
```

The first two specify the default OG generation policy for local and GitHub Actions builds respectively.

`TYPST_OG` is the effective setting used by the build.

For example, a local build can temporarily enable OG generation with:

```bash
TYPST_OG_BUILD=true ./build.sh
```

The normal configuration can keep OG generation disabled and reuse existing/static OG assets.

---

# Build Pipeline

The build orchestration is implemented through:

```text
build.sh
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
config.py
discover.py
navigation.py
parser.py
seo.py
typst.py
write_book.py
write_homepage.py
write_lectures.py
write_pages.py
write_report.py
```

The metadata system discovers source content and generates the Typst and JSON artifacts required by the rest of the build.

The metadata system is also responsible for generating information used by:

* navigation
* homepage generation
* category books
* SEO
* Open Graph generation
* reports

---

## 2. Validate configuration

Configuration validation is performed by:

```text
scripts/lint/check_config.py
```

The resulting report is written to:

```text
diagnostics/config_report.txt
```

This catches invalid or inconsistent project configuration before later build stages depend on it.

---

## 3. Validate metadata

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

## 4. Validate generated files

Generated-file consistency is checked by:

```text
scripts/lint/check_generated.py
```

The generated-file checker is organized into supporting modules:

```text
scripts/lint/generated/
├── checks.py
├── config.py
├── report.py
└── source.py
```

This makes it possible to detect stale or missing generated artifacts and discrepancies between source metadata and generated files.

---

## 5. Prepare diagnostics and output directories

The build infrastructure prepares:

```text
diagnostics/
dist/
```

and removes or recreates generated output as appropriate.

The goal is that stale output should not silently survive from an earlier build.

---

## 6. Build Open Graph assets

Open Graph generation is handled by:

```text
scripts/og/
├── __init__.py
├── build_og.py
├── generate_og.py
└── og_template.asy
```

The OG pipeline uses metadata to generate page-specific social preview images.

Generated OG sources and intermediate images are kept under:

```text
generated/og/
```

Published OG images are placed under:

```text
dist/assets/og/
```

OG validation is performed by:

```text
scripts/lint/check_og.py
```

The build can be configured either to generate OG images or to reuse existing/static assets.

---

## 7. Build HTML pages

HTML generation is handled by:

```text
scripts/build/build_html.py
```

The generated Typst page sources and metadata are used to produce browser-viewable pages under:

```text
dist/pages/
```

The generated homepage is placed at:

```text
dist/index.html
```

Static website assets such as CSS are copied into:

```text
dist/assets/
```

---

## 8. Build SEO-related files

SEO generation is part of the normal build pipeline.

The metadata system provides page-level SEO information, while:

```text
scripts/build/build_sitemap.py
scripts/build/build_robots.py
```

generate crawler-related files.

The published files are normally:

```text
dist/sitemap.xml
dist/robots.txt
```

---

## 9. Build individual PDFs

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

## 10. Build category books

Category sources are generated under:

```text
generated/category_*.typ
```

and compiled into category PDFs.

Examples include:

```text
generated/category_developer.typ
generated/category_extras.typ
generated/category_fields_and_galois_theory.typ
generated/category_group_theory.typ
generated/category_ioqm.typ
generated/category_mopss.typ
generated/category_r_m_o.typ
```

Category generation is handled by:

```text
scripts/build/build_categories.py
```

---

## 11. Build combined books

The project also produces combined collections.

The primary sources are:

```text
book_source.typ
pages_source.typ
```

The book build logic is implemented under:

```text
scripts/build/build_book.py
```

Generated book metadata/source information is written to:

```text
generated/book.typ
```

---

## 12. Validate generated links

Generated HTML is checked by:

```text
scripts/lint/check_links.py
```

The checker scans generated HTML for broken local links and records the results in:

```text
diagnostics/link_report.txt
```

---

## 13. Generate build diagnostics

Build reporting is handled by:

```text
scripts/build/build_report.py
```

The consolidated report is written to:

```text
diagnostics/build_report.txt
```

---

# SEO

SEO generation is part of the normal metadata/build pipeline.

SEO-related logic lives under:

```text
scripts/metadata/seo.py
```

The generated HTML pages receive metadata derived from the source content and project configuration.

The SEO pipeline is designed to keep page metadata synchronized with the same metadata used for:

* titles
* descriptions
* categories
* navigation
* homepage information
* canonical URLs
* Open Graph metadata

This avoids maintaining SEO information separately for every generated HTML page.

---

# Sitemap and robots.txt

The build automatically generates the site's crawler-related files.

The relevant build components are:

```text
scripts/build/build_sitemap.py
scripts/build/build_robots.py
```

The generated files are placed in the published site under:

```text
dist/
```

typically as:

```text
dist/sitemap.xml
dist/robots.txt
```

These are generated artifacts and should not normally be edited manually.

---

# Open Graph Images

Open Graph image generation is integrated into the build pipeline.

The implementation lives under:

```text
scripts/og/
├── __init__.py
├── build_og.py
├── generate_og.py
└── og_template.asy
```

The OG pipeline uses metadata to generate page-specific social preview images.

Generated OG sources and intermediate images are kept under:

```text
generated/og/
```

and published images are copied into:

```text
dist/assets/og/
```

The structure is organized by content:

```text
generated/og/
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

The published structure mirrors the content organization:

```text
dist/assets/og/
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

A default OG asset is available for pages that do not have a specific generated image.

---

## Open Graph asset layers

The project deliberately separates OG assets into three layers.

### 1. Static/source assets

```text
assets/og/
```

These contain static/default assets supplied directly by the project.

The current tree includes:

```text
assets/og/
├── default.asy
├── default.pdf
├── default.png
└── fgt1.png
```

These files are source/static assets and are not generated into `generated/og/` merely because they exist under `assets/og/`.

### 2. Generated/intermediate assets

```text
generated/og/
```

This directory contains generated Asymptote source files and intermediate images.

For example:

```text
generated/og/
├── courses/
│   ├── codeeg.asy
│   ├── codeeg.png
│   ├── fun.asy
│   └── fun.png
├── fgt/
│   ├── lec2.asy
│   └── lec2.png
├── gt/
│   ├── lec1.asy
│   ├── lec1.png
│   ├── lec2.asy
│   ├── lec2.png
│   ├── lec3.asy
│   └── lec3.png
├── mopss/
│   ├── mopss_aug08.asy
│   ├── mopss_aug08.png
│   ├── mopss_aug29.asy
│   └── mopss_aug29.png
└── olympiad/
    ├── ioqm/
    │   ├── ioqm2024.asy
    │   ├── ioqm2024.png
    │   ├── ioqm2025.asy
    │   └── ioqm2025.png
    └── rmo/
        ├── rmo2025.asy
        └── rmo2025.png
```

### 3. Published assets

```text
dist/assets/og/
```

These are the final OG images used by the generated website.

The published tree follows the content hierarchy:

```text
dist/assets/og/
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

The general OG flow is therefore:

```text
source/static assets
        │
        ▼
assets/og/

generated OG source/images
        │
        ▼
generated/og/

published OG images
        │
        ▼
dist/assets/og/
```

---

# Open Graph Build Modes

The Open Graph system supports separate defaults for local development and GitHub Actions.

The configuration is defined in:

```text
scripts/config.py
```

The two default settings are:

```python
TYPST_OG_BUILD = False
TYPST_OG_GITBUILD = False
```

The effective setting is:

```python
TYPST_OG
```

### Local builds

By default:

```text
TYPST_OG_BUILD = False
```

The normal build can therefore reuse existing/static OG assets.

To temporarily enable local OG generation:

```bash
TYPST_OG_BUILD=true ./build.sh
```

### GitHub Actions

By default:

```text
TYPST_OG_GITBUILD = False
```

This means GitHub Actions can reuse the committed/static OG assets rather than generating them during every deployment.

If GitHub OG generation is enabled, the workflow must provide the required external tools, including:

```text
Asymptote
TeX Live
ImageMagick
```

The effective setting follows the configuration rules implemented in `scripts/config.py`.

---

# Generated Files

The directory:

```text
generated/
```

contains files produced automatically by the metadata and asset-generation pipelines.

The current generated tree includes:

```text
generated/
├── book.typ
├── category_developer.typ
├── category_extras.typ
├── category_fields_and_galois_theory.typ
├── category_group_theory.typ
├── category_ioqm.typ
├── category_mopss.typ
├── category_r_m_o.typ
├── homepage.json
├── homepage.typ
├── lectures.typ
├── og/
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

The output is organized approximately as:

```text
dist/
├── assets/
│   ├── css/
│   │   └── style.css
│   ├── images/
│   ├── js/
│   └── og/
│       ├── courses/
│       ├── fgt/
│       ├── gt/
│       ├── mopss/
│       └── olympiad/
│
├── index.html
├── robots.txt
├── sitemap.xml
│
├── pages/
│
└── pdf/
```

The exact files under `pages/` and `pdf/` depend on the current source content and the result of the build.

`dist/` is build output and can be regenerated from the repository source.

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
├── config_report.txt
├── generated_report.txt
├── imports.dot
├── link_report.txt
└── metadata_report.txt
```

---

## Configuration report

```text
config_report.txt
```

contains the results of configuration validation.

It is generated by:

```text
scripts/lint/check_config.py
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

The current structure includes:

```text
templates/
├── README.md
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

It is used together with generated metadata to provide:

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

The rendering layer keeps presentation logic separate from individual content files and supports the different output targets.

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

Figures are stored separately from lecture source:

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

As the content hierarchy evolves, figure organization can also be aligned more closely with the corresponding course/program structure.

---

# Website Assets

Static website assets live under:

```text
assets/
```

The current source asset tree includes:

```text
assets/
├── README.md
├── css/
│   └── style.css
└── og/
    ├── default.asy
    ├── default.pdf
    ├── default.png
    └── fgt1.png
```

The build copies or generates the required assets into:

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

The published copy is:

```text
dist/assets/css/style.css
```

The generated copy should not be edited manually.

---

# PDF Layout

The main PDF-related files are:

```text
book_source.typ
pages_source.typ
templates/pdflayout.typ
```

The source files define the entry points and layout configuration used for the generated combined PDFs and page collections.

PDF-specific layout should generally be changed in the PDF/template layer rather than in individual content files.

There is also an older:

```text
pdflayout_old.typ
```

file in the repository. This is retained as historical/reference material and should not normally be modified or used by new build code unless explicitly required.

---

# Development Documentation

Architecture and development notes are kept under:

```text
coding/
```

The current documentation includes material such as:

```text
coding/
├── Course Website Roadmap.md
├── Course Website Roadmap.pdf
├── Fresh GitHub Repository Setup.md
├── Fresh GitHub Repository Setup.pdf
├── build_architecture_refactoring_roadmap.md
├── build_architecture_refactoring_roadmap.pdf
├── project_architecture_roadmap.md
├── typst-course-roadmap.md
└── typst-course-roadmap.pdf
```

These documents record architectural decisions, setup procedures, planned refactoring, and development history.

They are intentionally kept separate from the operational README.

Additional operational documentation is kept under:

```text
docs/
```

including:

```text
docs/
├── README_diagnostic.md
├── README_dist.md
├── README_figure.md
├── README_generated.md
└── README_og.md
```

---

# Development and Validation

Several standalone checks are available under:

```text
scripts/lint/
```

---

## Configuration

Run:

```bash
python3 scripts/lint/check_config.py
```

This validates project configuration.

The result is written to:

```text
diagnostics/config_report.txt
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

## Open Graph assets

Run:

```bash
python3 scripts/lint/check_og.py
```

This validates generated Open Graph assets and their relationship to source metadata and published output.

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
├── __init__.py
├── graph.py
├── parser.py
└── report.py
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

# Scripts

The build infrastructure is organized as follows:

```text
scripts/
├── README.md
├── __init__.py
│
├── build/
│   ├── build_book.py
│   ├── build_categories.py
│   ├── build_html.py
│   ├── build_pages_pdf.py
│   ├── build_pdfs.py
│   ├── build_report.py
│   ├── build_robots.py
│   ├── build_sitemap.py
│   ├── generate_metadata.py
│   ├── prepare_diagnostics.py
│   └── prepare_dist.py
│
├── completion/
│   └── build.sh
│
├── lint/
│   ├── check_config.py
│   ├── check_generated.py
│   ├── check_imports.py
│   ├── check_links.py
│   ├── check_metadata.py
│   ├── check_og.py
│   ├── generated/
│   │   ├── checks.py
│   │   ├── config.py
│   │   ├── report.py
│   │   └── source.py
│   └── imports/
│       ├── __init__.py
│       ├── graph.py
│       ├── parser.py
│       └── report.py
│
├── metadata/
│   ├── __init__.py
│   ├── config.py
│   ├── discover.py
│   ├── navigation.py
│   ├── parser.py
│   ├── seo.py
│   ├── typst.py
│   ├── write_book.py
│   ├── write_homepage.py
│   ├── write_lectures.py
│   ├── write_pages.py
│   └── write_report.py
│
├── og/
│   ├── __init__.py
│   ├── build_og.py
│   ├── generate_og.py
│   └── og_template.asy
│
├── config.py
├── run.py
└── utils/
```

The `__pycache__/` directory shown in a working checkout is a Python runtime artifact and is not part of the conceptual project architecture.

The modular structure is intentional:

```text
metadata/
    discovery + parsing + metadata generation

build/
    compilation + packaging + reports

og/
    Open Graph generation

lint/
    validation

utils/
    reusable implementation helpers
```

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

   Metadata is used to generate HTML, PDFs, navigation, homepage information, category collections, SEO metadata, and Open Graph assets.

5. **Generated artifacts should be reproducible.**

   A clean build should be able to regenerate the generated metadata and `dist/` output from repository source.

6. **Stale output should not silently survive.**

   The build system prepares its output directories so obsolete generated files do not remain unnoticed.

7. **Reusable Typst functionality belongs in templates.**

   Individual lectures should contain mathematical content rather than repeatedly implementing layout, navigation, theorem blocks, or common notation.

8. **Build responsibilities should remain modular.**

   Discovery, metadata parsing, generation, compilation, validation, OG generation, and reporting are implemented as separate components under `scripts/`.

9. **Source organization should reflect content organization.**

   Courses, FGT, Group Theory, Olympiad, and MOPSS material have their own source areas while sharing the same underlying generation infrastructure.

10. **Published assets are derived from source assets.**

    CSS, images, OG assets, sitemap, robots.txt, HTML, and PDFs are produced as part of the build rather than being maintained independently in the published output.

11. **Social-preview assets have explicit lifecycle layers.**

    Static source OG assets, generated OG intermediates, and published OG images are kept separate under `assets/og/`, `generated/og/`, and `dist/assets/og/`.

12. **Configuration is centralized.**

    Build scripts should obtain project paths, site identity, SEO settings, and OG/build-mode configuration from `scripts/config.py`.

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
Validate configuration
    ↓
Validate metadata
    ↓
Generate Typst/JSON metadata
    ↓
Generate/reuse OG assets
    ↓
Validate generated files
    ↓
Build HTML pages
    ↓
Build SEO-related files
    ↓
Build individual PDFs
    ↓
Build category books
    ↓
Build combined books
    ↓
Copy website assets
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

for metadata, generated-file, configuration, OG, import, link, and build reports.

---

# Typical Repository Workflow

When modifying the project, the general rule is:

### Edit source content

Modify files under:

```text
content/
```

### Modify figures

Modify files under:

```text
figures/
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
scripts/og/
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

### Modify static/default OG assets

Modify:

```text
assets/og/
```

### Modify installation/setup documentation

Modify:

```text
install/
```

### Modify operational documentation

Modify:

```text
docs/
```

### Do not manually edit generated output

Avoid manually editing:

```text
generated/
dist/
diagnostics/
```

unless debugging or inspecting generated artifacts.

Regenerate them with:

```bash
./build.sh
```

---

# Future Improvements

The project is already functional as a complete metadata-driven publishing pipeline.

The following are possible future extensions rather than requirements of the current system:

* **Website search** — add client-side search across lectures, courses, olympiad material, and problem collections.
* **Homepage filtering** — optionally add lightweight client-side filtering or views by category, content type, date, or tags while retaining the current automatically generated category layout.
* **Homepage presentation** — further refine the visual presentation of categories, lecture cards, metadata, and navigation as the amount of content grows.
* **Build diagnostics** — expand the final build summary with more detailed timing, file counts, validation statistics, and clearer warnings.
* **Metadata tooling** — strengthen metadata validation, duplicate detection, cross-field validation, and error reporting.
* **Navigation** — further improve breadcrumbs, previous/next navigation, category navigation, and cross-references.
* **PDF presentation** — continue refining typography, page layout, title pages, headers, footers, and category-book design.
* **HTML presentation** — continue polishing responsive layouts, mathematical typography, theorem blocks, code blocks, and mobile presentation.
* **Accessibility** — improve semantic HTML, keyboard navigation, contrast, focus states, and screen-reader support.
* **Testing** — introduce more automated checks for generated HTML, PDFs, metadata, links, OG assets, and Typst imports.
* **CI/CD** — further improve automated builds, deployment checks, artifact validation, and build failure diagnostics.
* **Performance** — reduce unnecessary compilation and improve incremental development workflows.
* **Documentation** — expand documentation as the project architecture and authoring workflow evolve.

These are intentionally ongoing areas of development. New functionality can be added incrementally without changing the underlying separation between source content, metadata, templates, generation, diagnostics, and published output.

---

# Repository Summary

The repository can be viewed conceptually as the following pipeline:

```text
                 ┌──────────────────────┐
                 │      content/        │
                 │ Mathematics +        │
                 │ metadata             │
                 └──────────┬───────────┘
                            │
                            │ discovery
                            ▼
                 ┌──────────────────────┐
                 │      scripts/        │
                 │ Metadata + build +   │
                 │ validation + OG      │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │     generated/       │
                 │ Typst + JSON + OG    │
                 │ intermediate files   │
                 └──────────┬───────────┘
                            │
                 ┌──────────┴───────────┐
                 │                      │
                 ▼                      ▼
       ┌──────────────────┐   ┌──────────────────┐
       │   templates/     │   │    figures/      │
       │ Layout + blocks  │   │ Graphical assets │
       │ navigation +     │   │                  │
       │ mathematics      │   │                  │
       └────────┬─────────┘   └────────┬─────────┘
                │                      │
                └──────────┬───────────┘
                           │
                           ▼
                 ┌──────────────────────┐
                 │       dist/          │
                 │ HTML + PDFs + assets │
                 │ SEO + OG + sitemap   │
                 │ + robots.txt         │
                 └──────────────────────┘

                 diagnostics/
                 Build + validation
                 reports
```

The central idea is:

> **Source content and metadata are the authoritative inputs; everything else is generated or derived from them.**

This keeps the project maintainable as the number of lectures, courses, problem collections, figures, and generated outputs grows.
