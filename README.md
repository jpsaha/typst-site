# 🧮 Typst Mathematics Lecture Portal

A **reproducible mathematical publishing engine** whose current frontend happens to be a website.

The project is designed for creating, organizing, validating, and publishing mathematical teaching material using **Typst** for typesetting and **Python** for metadata processing, generation, validation, diagnostics, and build orchestration.

It can be adapted to a wide range of educational publishing scenarios, including:

* university and school courses
* lecture notes
* mathematics courses and course sequences
* olympiad preparation
* problem collections
* seminars and reading courses
* instructor resources
* exercise and solution repositories
* programming-for-mathematics material
* research-oriented notes
* mathematical handouts and books

The same source material can be transformed into multiple synchronized publication formats:

* browser-viewable HTML
* individual lecture/page PDFs
* complete books
* course and category books
* structured navigation
* searchable/indexable web content
* social-media preview assets
* SEO metadata
* machine-generated site metadata
* diagnostic and validation reports

The architecture deliberately separates **content, metadata, presentation, generation, validation, diagnostics, and publication**.

The website is therefore not the fundamental product. It is **one publication frontend produced by the underlying mathematical publishing system**.

The central idea is:

> **Write the mathematics once. Describe it with metadata. Let the publishing engine derive the website, books, PDFs, navigation, SEO, social previews, and diagnostics from the same source.**

The main entry point is:

```bash
./build.sh
```

---

# Quick Start

## Prerequisites

Install:

* **Typst CLI** — currently developed against Typst 0.13.x or later
* **Python 3**
* **Bash** or another standard Unix shell

Open Graph image generation additionally uses:

* **Asymptote**
* **TeX Live**
* **ImageMagick**

These additional tools are only required when OG image generation is enabled.

The normal build can reuse existing/static OG assets when OG generation is disabled.

No Node.js or external search-indexing tool is currently required by the build pipeline.

---

## Build everything

From the repository root:

```bash
chmod +x ./build.sh
./build.sh
```

The build produces the published website and PDFs under:

```text
dist/
```

Generated metadata and intermediate generated files are written under:

```text
generated/
```

Build and validation reports are written under:

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

# Project Overview

The project follows a source-to-publication pipeline:

```text
content/
    │
    │ source content + metadata
    ▼
scripts/
    │
    │ discovery + generation + validation
    ▼
generated/
    │
    │ generated Typst / JSON / OG intermediates
    ▼
Typst + asset build
    │
    ├───────────────┐
    ▼               ▼
 HTML              PDF
    │               │
    └───────┬───────┘
            ▼
          dist/

diagnostics/
    build + validation reports
```

The central principle is:

> **Source content and metadata are authoritative. Everything else is generated or derived from them.**

Generated output should therefore normally be regenerated rather than edited manually.

---

# Repository Structure

The current repository is organized as follows:

```text
typst-site/
├── README.md
├── assets/
│   ├── README.md
│   ├── css/
│   │   └── style.css
│   └── og/
│       ├── default.asy
│       ├── default.pdf
│       ├── default.png
│       └── fgt1.png
│
├── book_source.typ
├── pages_source.typ
├── pdflayout_old.typ
├── build.sh
│
├── coding/
│   ├── Course Website Roadmap.md
│   ├── Course Website Roadmap.pdf
│   ├── Fresh GitHub Repository Setup.md
│   ├── Fresh GitHub Repository Setup.pdf
│   ├── build_architecture_refactoring_roadmap.md
│   ├── build_architecture_refactoring_roadmap.pdf
│   ├── project_architecture_roadmap.md
│   ├── typst-course-roadmap.md
│   ├── typst-course-roadmap.pdf
│   └── typst-course-roadmap-professional.pdf
│
├── content/
├── diagnostics/
├── dist/
├── docs/
├── figures/
├── generated/
├── install/
├── scripts/
└── templates/
```

The major responsibilities are:

| Directory           | Responsibility                                             |
| ------------------- | ---------------------------------------------------------- |
| `content/`          | Mathematical source content and metadata                   |
| `templates/`        | Reusable Typst presentation and mathematical functionality |
| `figures/`          | Source graphical assets                                    |
| `assets/`           | Static website assets and static OG assets                 |
| `scripts/metadata/` | Metadata discovery, parsing, and generation                |
| `scripts/build/`    | Build and publication stages                               |
| `scripts/og/`       | Open Graph source/image generation                         |
| `scripts/lint/`     | Validation and diagnostics                                 |
| `generated/`        | Generated intermediate Typst/JSON artifacts                |
| `dist/`             | Final published website and PDFs                           |
| `diagnostics/`      | Build and validation reports                               |
| `install/`          | Installation and setup documentation                       |
| `docs/`             | Operational documentation                                  |
| `coding/`           | Architecture, roadmap, and development documentation       |

---

# Content Organization

All mathematical source material lives under:

```text
content/
```

The current structure is:

```text
content/
├── README.md
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

The content directories represent different mathematical programs or collections while sharing the same metadata and build infrastructure.

---

# Courses

Course-level material is stored under:

```text
content/courses/
```

Current sources include:

```text
content/courses/
├── codeeg.typ
├── codeeg_content.typ
├── fun.typ
└── fun_content.typ
```

The general convention is:

```text
<name>.typ
<name>_content.typ
```

The wrapper provides metadata and the corresponding `_content.typ` file contains the actual course material.

---

# Field and Galois Theory

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

The wrapper/content separation allows the metadata system to discover the lecture independently from its mathematical content.

---

# Group Theory

Group Theory material is stored under:

```text
content/gt/
```

The current sources include:

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

Olympiad material is organized by competition:

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

This permits competition-specific pages and generated category collections to coexist within the same publishing system.

---

# MOPSS

MOPSS material is stored under:

```text
content/mopss/
```

The current structure is:

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

The main MOPSS material follows the wrapper/content convention.

The `motypprog/` directory contains supporting mathematical and programming material.

---

# Metadata

Metadata is attached to source content through a Typst metadata wrapper.

A typical wrapper looks like:

```typst
#let lecture = (
  file: "lec1",
  number: 1,
  title: "Linear Transformations & Matrices",
  category: "Linear Algebra",
)
```

The metadata system uses this information to generate:

* homepage entries
* navigation
* previous/next links
* category navigation
* category books
* combined books
* generated Typst sources
* HTML/PDF information
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

Additional metadata may include:

```text
number
category
tags
description
date
```

The exact interpretation of optional fields depends on the content type and metadata rules implemented by the project.

For lectures, `number` identifies the lecture number.

Other pages or content types can omit lecture-specific fields when appropriate.

---

## Semantic metadata and mathematical tagging

The metadata system is intended to describe not only where a piece of content belongs, but also **what mathematical ideas it contains**.

Exercises, problems, solutions, examples, lectures, and other educational units can eventually carry structured semantic metadata such as:

```text
topic
subtopic
concept
technique
method
difficulty
prerequisites
tags
```

For example:

```typst
#let exercise = (
  file: "problem-07",
  title: "A subgroup counting problem",
  type: "exercise",
  category: "Group theory",

  tags: (
    topic: ["group-theory", "subgroups"],
    concept: ["lagrange-theorem"],
    technique: ["counting", "cosets"],
    difficulty: "intermediate",
  ),
)
```

The purpose of this metadata is not merely classification.

It provides the foundation for **semantic relationships between mathematical content**.

The publishing system can eventually use these relationships to automatically generate:

* related exercises
* similar problems
* prerequisite material
* follow-up problems
* problems using the same technique
* problems involving the same theorem or concept
* topic collections
* difficulty-based collections
* recommended next problems
* cross-links between problems and solutions

For example:

```text
                    Problem
                       │
          ┌────────────┼────────────┐
          │            │            │
        Topic       Technique    Concept
          │            │            │
          ▼            ▼            ▼
     Group theory    Cosets    Lagrange theorem
          │            │            │
          └────────────┼────────────┘
                       │
                       ▼
                 Related Problems
```

This makes the metadata layer increasingly valuable as the repository grows.

A key architectural principle is:

> **Relationships between mathematical objects should be derived from structured metadata whenever possible, rather than maintained as manually duplicated links.**

This also creates a path toward a future **mathematical knowledge graph**, where lectures, definitions, theorems, examples, exercises, problems, and solutions can be connected through shared concepts and techniques.

---

# Semantic Mathematical Metadata

The metadata system is intended to evolve beyond simple publication information such as titles, categories, dates, and tags.

A long-term goal is to allow the publishing engine to describe the **mathematical structure and relationships within the content itself**.

A mathematical collection can contain different kinds of objects:

```text
Definition
   ↓
Theorem
   ↓
Example
   ↓
Exercise
   ↓
Problem
   ↓
Solution
```

These objects are not merely pieces of text. They have mathematical relationships with one another.

For example:

```text
Definition: Normal subgroup
          │
          ▼
Theorem: Quotient group theorem
          │
          ├───────────────┐
          ▼               ▼
 Example: S₃          Exercise: 4.3
                          │
                          ▼
                      Problem: P17
                          │
                          ▼
                     Solution: P17
```

The metadata layer can eventually describe these relationships explicitly.

---

## Mathematical object types

Content can eventually be classified using semantic types such as:

```text
definition
theorem
lemma
proposition
corollary
example
remark
exercise
problem
solution
```

These types describe the **role of a piece of content in the mathematical or educational structure**, rather than its location in the repository.

A lecture may therefore contain many different semantic objects:

```text
Lecture 5
├── Definition
├── Example
├── Theorem
├── Proof
├── Exercise
├── Problem
└── Solution
```

The source organization can remain simple while the generated metadata provides a richer model of the material.

---

## Semantic tags

Exercises, problems, examples, and other mathematical objects can carry structured tags describing their mathematical content.

Potential metadata includes:

```text
topic
subtopic
concept
technique
method
difficulty
prerequisites
```

For example:

```typst
#let exercise = (
  file: "problem-07",
  title: "A subgroup counting problem",
  type: "exercise",
  category: "Group theory",

  tags: (
    topic: ["group-theory", "subgroups"],
    concept: ["lagrange-theorem"],
    technique: ["counting", "cosets"],
    difficulty: "intermediate",
  ),
)
```

The purpose of these tags is not merely to organize the website.

They provide the foundation for discovering **mathematically related content**.

---

## Relationships between mathematical objects

The system can eventually represent relationships such as:

```text
requires
uses
illustrates
proves
solves
extends
related-to
follows-from
```

For example:

```text
Problem P17
   │
   ├── uses → Lagrange's theorem
   ├── requires → Normal subgroups
   ├── technique → Coset counting
   └── solution → Solution P17
```

Similarly:

```text
Theorem
   │
   ├── introduced in → Lecture 4
   ├── illustrated by → Example 4.2
   ├── used by → Exercise 4.5
   └── applied in → Problem P17
```

These relationships can eventually be used to generate navigation automatically rather than requiring every cross-reference to be maintained manually.

---

## Related problems

One particularly useful application is automatic discovery of similar problems.

If problems contain structured metadata such as:

```text
topic
concept
technique
difficulty
prerequisites
```

the publishing engine can eventually generate sections such as:

```text
Related Problems

• Problems involving Lagrange's theorem
• Problems involving coset counting
• Problems using the same technique
• Problems with similar difficulty
• Problems requiring the same prerequisites
```

This can be much more useful than ordinary text-based search because the relationships are based on the **mathematical characteristics of the problems**.

---

## Prerequisite navigation

Semantic metadata can also support learning-oriented navigation.

For example:

```text
Current Problem
      │
      ▼
Required concepts
      │
      ▼
Prerequisite definitions
      │
      ▼
Relevant examples
      │
      ▼
Earlier exercises
      │
      ▼
Current Problem
```

This provides a foundation for features such as:

* prerequisite material
* recommended exercises
* suggested next problems
* related theorems
* related examples
* concept-based navigation
* difficulty-based progression
* topic collections

The same mechanism can therefore support both **publishing** and **teaching**.

---

## From metadata to a mathematical knowledge graph

As the semantic metadata becomes richer, the repository can be viewed as a network of mathematical objects:

```text
                     Definition
                         │
                         ▼
                      Theorem
                     /       \
                    ▼         ▼
                Example     Exercise
                              │
                     ┌────────┴────────┐
                     ▼                 ▼
                  Problem          Related Problem
                     │
                     ▼
                  Solution
```

Each object can have both:

```text
semantic attributes
```

and

```text
relationships to other objects
```

This creates the possibility of a future **mathematical knowledge graph** derived directly from the source material.

The important architectural principle is:

> **The publishing engine should eventually understand not only where mathematical content belongs, but how mathematical ideas, results, examples, problems, and solutions relate to one another.**

---

## Author once, connect once, publish everywhere

The semantic model is intended to remain independent of any particular frontend.

The same relationships could eventually drive:

```text
Website
   ├── Related problems
   ├── Prerequisites
   ├── Recommended material
   └── Concept navigation

PDF
   ├── Related exercises
   └── References

Course
   ├── Learning sequence
   ├── Prerequisites
   └── Problem sets

Problem collection
   ├── Topic index
   ├── Technique index
   └── Difficulty index
```

The underlying mathematical content remains the authoritative source.

The website, PDFs, books, indexes, and future educational interfaces are simply different views generated from that source.

This reinforces the central architectural principle of the project:

> **Author the mathematics once. Structure it carefully. Connect it meaningfully. Validate it automatically. Publish it in whatever educational formats are needed.**

---

# Adding New Content

The normal workflow for adding a lecture, course, olympiad page, or similar content is:

## 1. Create the metadata wrapper

For example:

```text
content/fgt/lec3.typ
```

## 2. Create the content file

```text
content/fgt/lec3_content.typ
```

## 3. Define the metadata

For example:

```typst
#let lecture = (
  file: "lec3",
  number: 3,
  title: "Your Lecture Title",
  category: "Your Category",
)
```

## 4. Add the mathematical content

Put definitions, theorems, examples, exercises, proofs, and other material in:

```text
lec3_content.typ
```

## 5. Build

```bash
./build.sh
```

The metadata discovery system automatically discovers the new source and regenerates the appropriate intermediate files and published output.

---

# Installation and Setup

Installation and repository setup documentation lives under:

```text
install/
```

The current files are:

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

# Build System

The primary build entry point is:

```text
build.sh
```

The Python infrastructure is organized under:

```text
scripts/
```

The current structure is:

```text
scripts/
├── README.md
├── __init__.py
├── build/
├── completion/
├── config.py
├── lint/
├── metadata/
├── og/
├── run.py
├── site_config.py
└── utils/
```

The design intentionally separates:

```text
metadata/
    discovery + parsing + generation

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

# Central Configuration

Project-wide configuration is centralized primarily in:

```text
scripts/config.py
```

Site-specific configuration is also represented by:

```text
scripts/site_config.py
```

The configuration layer controls project paths and build behavior rather than requiring individual scripts to reconstruct paths independently.

Configuration covers areas such as:

* project directories
* generated directories
* distribution directories
* diagnostics
* site identity
* SEO
* Open Graph generation
* build modes
* repository/deployment information

---

# Build Pipeline

The complete build is orchestrated through:

```text
build.sh
```

with Python components under:

```text
scripts/
```

The major stages are described below.

---

## 1. Metadata discovery and generation

The main entry point is:

```text
scripts/build/generate_metadata.py
```

Metadata processing is implemented through:

```text
scripts/metadata/
```

The current modules include:

```text
scripts/metadata/
├── __init__.py
├── config.py
├── discover.py
├── navigation.py
├── parser.py
├── seo.py
├── typst.py
├── write_book.py
├── write_homepage.py
├── write_lectures.py
├── write_pages.py
└── write_report.py
```

The metadata pipeline discovers source files, parses their metadata, constructs navigation information, and writes the generated Typst and JSON artifacts required by later build stages.

---

## 2. Configuration validation

Configuration validation is handled by:

```text
scripts/lint/check_config.py
```

The report is written to:

```text
diagnostics/config_report.txt
```

This stage catches invalid or inconsistent configuration before dependent build stages run.

---

## 3. Metadata validation

Source metadata is validated by:

```text
scripts/lint/check_metadata.py
```

The validator checks project metadata rules such as:

* required fields
* field types
* duplicate identifiers
* source/content relationships
* lecture numbering
* metadata consistency

---

## 4. Generated-file validation

Generated-file consistency is checked by:

```text
scripts/lint/check_generated.py
```

Supporting code is organized under:

```text
scripts/lint/generated/
├── checks.py
├── config.py
├── report.py
└── source.py
```

This detects problems such as:

* missing generated entries
* stale generated entries
* source/generated mismatches
* inconsistent generated metadata

---

## 5. Prepare diagnostics and distribution output

The build prepares:

```text
diagnostics/
dist/
```

and removes/recreates generated output where appropriate.

This helps prevent obsolete files from silently surviving from previous builds.

---

# Open Graph Generation

Open Graph generation is integrated into the build system.

The implementation is under:

```text
scripts/og/
├── __init__.py
├── build_og.py
├── generate_og.py
└── og_template.asy
```

There is also a publication step under:

```text
scripts/build/publish_og.py
```

The OG system uses metadata to generate page-specific social preview images.

Generated/intermediate OG material is kept separate from source/static assets and published assets.

---

# Open Graph Asset Lifecycle

The project deliberately separates OG assets into three layers.

## 1. Static/source OG assets

```text
assets/og/
```

Current static assets include:

```text
assets/og/
├── default.asy
├── default.pdf
├── default.png
└── fgt1.png
```

These are source/static assets.

They are not automatically treated as generated files simply because they are located under `assets/og/`.

---

## 2. Generated OG assets

Generated OG sources and intermediate files are written under:

```text
generated/og/
```

when OG generation is enabled.

The generated structure follows the content hierarchy, for example:

```text
generated/og/
├── courses/
├── fgt/
├── gt/
├── mopss/
└── olympiad/
```

Generated files may include:

```text
*.asy
*.png
```

depending on the stage of the OG pipeline.

---

## 3. Published OG assets

Final OG images used by the website are published under:

```text
dist/assets/og/
```

The current published structure is:

```text
dist/assets/og/
├── courses/
│   ├── codeeg.png
│   └── fun.png
├── default.png
├── fgt/
│   └── lec2.png
├── fgt1.png
├── gt/
│   ├── lec1.png
│   ├── lec2.png
│   └── lec3.png
├── mopss/
│   ├── mopss_aug08.png
│   └── mopss_aug29.png
└── olympiad/
    ├── ioqm/
    │   ├── ioqm2024.png
    │   └── ioqm2025.png
    └── rmo/
        └── rmo2025.png
```

The lifecycle is therefore:

```text
assets/og/
    │
    │ static/source assets
    ▼
generated/og/
    │
    │ generated/intermediate assets
    ▼
dist/assets/og/
    │
    │ published assets
    ▼
generated HTML pages
```

---

# Open Graph Build Modes

OG generation can be controlled separately for local and GitHub Actions builds.

The configuration is defined in:

```text
scripts/config.py
```

The project uses configuration values corresponding to:

```python
TYPST_OG_BUILD
TYPST_OG_GITBUILD
TYPST_OG
```

The first two represent the default OG generation policy for local and GitHub Actions builds.

`TYPST_OG` represents the effective OG setting used by the build.

For example, to temporarily enable OG generation during a local build:

```bash
TYPST_OG_BUILD=true ./build.sh
```

When OG generation is disabled, the build can reuse existing/static OG assets.

If OG generation is enabled, the required external tools must be available:

```text
Asymptote
TeX Live
ImageMagick
```

---

# Open Graph Validation

Generated OG assets are validated by:

```text
scripts/lint/check_og.py
```

This verifies the expected relationship between:

* source metadata
* generated OG assets
* published OG assets

OG validation is kept separate from the actual OG generation process.

---

# HTML Generation

HTML generation is handled by:

```text
scripts/build/build_html.py
```

Generated pages are written to:

```text
dist/pages/
```

The generated homepage is:

```text
dist/index.html
```

The website also receives the static assets required by the HTML pages, including CSS and generated OG images.

The published website is therefore self-contained under:

```text
dist/
```

---

# SEO

SEO metadata is part of the normal build pipeline.

The main SEO logic is:

```text
scripts/metadata/seo.py
```

The same source metadata used for page titles, descriptions, categories, and navigation is used to generate SEO information.

This keeps the following synchronized:

* page title
* description
* canonical URL
* category information
* Open Graph metadata
* Twitter Card metadata
* homepage information

SEO data is generated rather than manually maintained separately for every HTML page.

---

# Sitemap and robots.txt

The build automatically generates crawler-related files.

The relevant scripts are:

```text
scripts/build/build_sitemap.py
scripts/build/build_robots.py
```

The published files are:

```text
dist/sitemap.xml
dist/robots.txt
```

These are generated artifacts and should normally not be edited manually.

---

# PDF Generation

Individual PDFs are generated by the PDF build components under:

```text
scripts/build/
```

including:

```text
build_pdfs.py
build_pages_pdf.py
```

The resulting PDFs are published under:

```text
dist/pdf/
```

The current output includes individual PDFs such as:

```text
dist/pdf/
├── codeeg.pdf
├── fgt1.pdf
├── fgt2.pdf
├── fun.pdf
├── gt1.pdf
├── gt2.pdf
├── gt3.pdf
├── ioqm2024.pdf
├── ioqm2025.pdf
├── mopss_26aug08.pdf
├── mopss_26aug29.pdf
└── rmo2025.pdf
```

---

# Category Books

Category books are generated from metadata.

The build component is:

```text
scripts/build/build_categories.py
```

Generated category sources include:

```text
generated/
├── category_developer.typ
├── category_extras.typ
├── category_fields_and_galois_theory.typ
├── category_group_theory.typ
├── category_ioqm.typ
├── category_mopss.typ
└── category_r_m_o.typ
```

The corresponding PDFs are published under:

```text
dist/pdf/
```

For example:

```text
dist/pdf/
├── category_developer.pdf
├── category_extras.pdf
├── category_fields_and_galois_theory.pdf
├── category_group_theory.pdf
├── category_ioqm.pdf
├── category_mopss.pdf
└── category_r_m_o.pdf
```

The category books are derived from the same metadata that drives the website.

---

# Combined Books

The project generates combined collections using:

```text
book_source.typ
pages_source.typ
```

The main book build logic is:

```text
scripts/build/build_book.py
```

Generated book information is written under:

```text
generated/
```

The published combined PDFs currently include:

```text
dist/pdf/
├── book.pdf
└── pages.pdf
```

---

# Generated Files

The directory:

```text
generated/
```

contains automatically generated intermediate source and metadata files.

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
├── pages.typ
└── pages_meta.typ
```

OG intermediates may additionally appear under:

```text
generated/og/
```

when OG generation is enabled.

Generated files should normally **not be edited manually**.

They are regenerated from:

```text
content/
scripts/
templates/
assets/
```

as appropriate.

---

# Published Website

The final website is written to:

```text
dist/
```

The current structure is:

```text
dist/
├── assets/
│   ├── css/
│   │   └── style.css
│   ├── images/
│   ├── js/
│   └── og/
│       ├── courses/
│       ├── default.png
│       ├── fgt/
│       ├── fgt1.png
│       ├── gt/
│       ├── mopss/
│       └── olympiad/
│
├── index.html
├── pages/
│   ├── codeeg.html
│   ├── fgt1.html
│   ├── fgt2.html
│   ├── fun.html
│   ├── gt1.html
│   ├── gt2.html
│   ├── gt3.html
│   ├── ioqm2024.html
│   ├── ioqm2025.html
│   ├── mopss_26aug08.html
│   ├── mopss_26aug29.html
│   └── rmo2025.html
│
├── pdf/
│   ├── book.pdf
│   ├── pages.pdf
│   ├── category_*.pdf
│   └── individual page/lecture PDFs
│
├── robots.txt
└── sitemap.xml
```

The exact page and PDF list changes as content is added or removed.

`dist/` is generated output, not source.

---

# Diagnostics

Build and validation reports are kept under:

```text
diagnostics/
```

The current directory contains:

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
diagnostics/config_report.txt
```

is generated by:

```text
scripts/lint/check_config.py
```

It records the results of configuration validation.

---

## Metadata report

```text
diagnostics/metadata_report.txt
```

summarizes metadata discovered from the source content.

It is generated by the metadata pipeline.

---

## Generated-file report

```text
diagnostics/generated_report.txt
```

contains the results of generated-file consistency validation.

It helps identify:

* missing generated entries
* stale generated entries
* source/generated mismatches
* inconsistent generated metadata

---

## Link report

```text
diagnostics/link_report.txt
```

contains the results of generated HTML link validation.

The checker scans generated HTML for broken local links.

---

## Build report

```text
diagnostics/build_report.txt
```

contains the consolidated build summary and diagnostic information.

This is intended to provide a final overview of the build rather than requiring individual build stages to be inspected separately.

---

## Typst import graph

```text
diagnostics/imports.dot
```

contains the Typst import dependency graph.

If Graphviz is installed, it can be rendered with:

```bash
dot -Tpdf diagnostics/imports.dot -o diagnostics/imports.pdf
```

---

# Validation and Linting

Validation scripts are located under:

```text
scripts/lint/
```

The current top-level checks are:

```text
scripts/lint/
├── check_config.py
├── check_generated.py
├── check_imports.py
├── check_links.py
├── check_metadata.py
└── check_og.py
```

---

## Configuration validation

```bash
python3 scripts/lint/check_config.py
```

Checks project configuration.

---

## Metadata validation

```bash
python3 scripts/lint/check_metadata.py
```

Checks source metadata against the project's metadata rules.

---

## Generated-file validation

```bash
python3 scripts/lint/check_generated.py
```

Checks source/generated consistency.

---

## Typst import validation

```bash
python3 scripts/lint/check_imports.py
```

Checks Typst imports and reports missing dependencies and circular imports.

Supporting code is located under:

```text
scripts/lint/imports/
├── __init__.py
├── graph.py
├── parser.py
└── report.py
```

The resulting dependency graph is:

```text
diagnostics/imports.dot
```

---

## HTML link validation

```bash
python3 scripts/lint/check_links.py
```

Checks local links in generated HTML.

The report is:

```text
diagnostics/link_report.txt
```

---

## Open Graph validation

```bash
python3 scripts/lint/check_og.py
```

Checks Open Graph assets and their relationship to metadata and published output.

---

# Normal Development Workflow

For normal development, the preferred workflow is simply:

```bash
./build.sh
```

The main build runs the required generation and validation stages.

Standalone checks are useful when debugging a particular subsystem.

A typical editing cycle is:

```text
Edit source
    ↓
Update metadata if necessary
    ↓
./build.sh
    ↓
Metadata discovery
    ↓
Configuration validation
    ↓
Metadata validation
    ↓
Generated-file validation
    ↓
Generate intermediate files
    ↓
Generate/reuse OG assets
    ↓
Build HTML
    ↓
Build SEO files
    ↓
Build PDFs
    ↓
Build category books
    ↓
Build combined books
    ↓
Publish assets
    ↓
Check HTML links
    ↓
Generate diagnostics
```

After the build:

```text
dist/
```

contains the published site and PDFs.

```text
diagnostics/
```

contains the validation and build reports.

---

# Templates

Reusable Typst functionality lives under:

```text
templates/
```

The current structure is:

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
├── euler/
│   ├── components/
│   │   └── theorems.typ
│   └── styles/
│       ├── colors.typ
│       ├── headings.typ
│       ├── page.typ
│       └── typography.typ
├── math/
│   ├── analysis.typ
│   ├── combinatorics.typ
│   ├── geometry.typ
│   ├── graph.typ
│   ├── linear.typ
│   ├── logic.typ
│   ├── matrix.typ
│   ├── misc.typ
│   ├── notation.typ
│   ├── number.typ
│   ├── operators.typ
│   ├── probability.typ
│   ├── sets.typ
│   └── vectors.typ
├── math.typ
├── nav.typ
├── pdflayout.typ
├── render.typ
├── theorems.typ
└── utils.typ
```

Templates contain reusable presentation, navigation, mathematical, and layout functionality.

Individual content files should therefore focus primarily on mathematical content rather than reimplementing common presentation logic.

---

# Block and Theorem System

The main block infrastructure is implemented in:

```text
templates/block-engine.typ
templates/blocks.typ
templates/theorems.typ
```

These provide reusable structures for mathematical material, including:

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

The block engine provides the common implementation while higher-level template files provide the interfaces used by content.

---

# Navigation

Navigation functionality is primarily located in:

```text
templates/nav.typ
```

It works together with generated metadata to provide:

* previous/next links
* lecture navigation
* page navigation
* category navigation
* related generated links

Navigation is therefore generated from metadata rather than manually maintained in each page.

---

# Rendering

Shared rendering functionality lives in:

```text
templates/render.typ
```

The rendering layer separates presentation logic from individual mathematical content files and supports the different generated output targets.

---

# Configuration and Styling

Common Typst configuration and utilities are provided by:

```text
templates/config.typ
templates/colors.typ
templates/counters.typ
templates/utils.typ
```

These modules provide reusable configuration, styling, counters, and utility functions.

---

# Mathematics Templates

Reusable mathematical notation is organized under:

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

The common interface is:

```text
templates/math.typ
```

This keeps frequently used mathematical notation and constructions out of individual lecture files.

---

# Euler Styling

Euler-specific components and styles are organized under:

```text
templates/euler/
```

The current structure is:

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

This separates Euler-specific styling from the main project-wide template infrastructure.

---

# Figures

Figures are kept separate from mathematical source content:

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

The organization allows:

* common figures to be shared
* lecture-specific figures to remain localized
* olympiad figures to remain separate

Figures are source assets and are therefore distinct from generated website output.

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
├── css/
│   └── style.css
└── og/
    ├── default.asy
    ├── default.pdf
    ├── default.png
    └── fgt1.png
```

The build copies or generates the assets required by the published website into:

```text
dist/assets/
```

---

# Website Styling

The generated HTML styling is controlled by:

```text
assets/css/style.css
```

During the build it is copied to:

```text
dist/assets/css/style.css
```

To change the website appearance, edit the source CSS:

```text
assets/css/style.css
```

Do not normally edit:

```text
dist/assets/css/style.css
```

because it is generated output.

---

# PDF Layout

The main PDF-related sources are:

```text
book_source.typ
pages_source.typ
templates/pdflayout.typ
```

These define the entry points and layout configuration used by combined PDFs and page collections.

PDF presentation should generally be changed in the PDF/template layer rather than in individual content files.

The repository also contains:

```text
pdflayout_old.typ
```

This is retained as historical/reference material and should not normally be used by new build code.

---

# Scripts

The current script architecture is:

```text
scripts/
├── README.md
├── __init__.py
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
│   ├── prepare_dist.py
│   └── publish_og.py
│
├── completion/
│   └── build.sh
│
├── config.py
├── site_config.py
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
├── run.py
└── utils/
```

The `__pycache__/` directories that may appear in a working checkout are ordinary Python runtime artifacts and are not part of the conceptual architecture.

---

# Command Entry Point

The Python command dispatcher is:

```text
scripts/run.py
```

It provides a centralized entry point for project-specific Python operations.

The shell build entry point remains:

```text
build.sh
```

The preferred user-facing command for a complete build is:

```bash
./build.sh
```

Individual Python commands should generally be used when developing or debugging a specific subsystem.

---

# Development Documentation

Architecture and development history are kept under:

```text
coding/
```

The current documentation includes:

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
├── typst-course-roadmap.pdf
└── typst-course-roadmap-professional.pdf
```

These documents contain architectural decisions, setup procedures, roadmaps, refactoring plans, and development history.

They are intentionally separate from the operational README.

---

# Operational Documentation

Additional subsystem documentation is kept under:

```text
docs/
```

The current files are:

```text
docs/
├── README_diagnostic.md
├── README_dist.md
├── README_figure.md
├── README_generated.md
└── README_og.md
```

These documents provide more detailed information about individual project subsystems.

---

# Source vs Generated Files

One of the most important rules of the project is the distinction between source and generated output.

## Source

The main source areas are:

```text
content/
figures/
templates/
assets/
scripts/
```

## Generated/intermediate

Generated intermediate material lives under:

```text
generated/
```

## Published output

Published website and PDFs live under:

```text
dist/
```

## Diagnostics

Validation and build reports live under:

```text
diagnostics/
```

The relationship is:

```text
SOURCE
────────────────────────────────────────
content/
figures/
templates/
assets/
scripts/
        │
        ▼
GENERATED
────────────────────────────────────────
generated/
        │
        ▼
PUBLISHED
────────────────────────────────────────
dist/

DIAGNOSTICS
────────────────────────────────────────
diagnostics/
```

Generated directories should not become an alternative source of truth.

---

# What to Edit

When modifying the repository, use the following rules.

## Mathematical content

Edit:

```text
content/
```

## Figures

Edit:

```text
figures/
```

## Reusable Typst functionality

Edit:

```text
templates/
```

## Metadata generation

Edit:

```text
scripts/metadata/
```

## Build behavior

Edit:

```text
scripts/build/
```

## Open Graph generation

Edit:

```text
scripts/og/
```

## Validation

Edit:

```text
scripts/lint/
```

## Website appearance

Edit:

```text
assets/css/style.css
```

## Static/default OG assets

Edit:

```text
assets/og/
```

## Installation/setup documentation

Edit:

```text
install/
```

## Operational documentation

Edit:

```text
docs/
```

## Architecture and development documentation

Edit:

```text
coding/
```

---

# What Not to Edit Manually

The following are normally generated:

```text
generated/
dist/
diagnostics/
```

Do not manually modify generated pages, generated metadata, generated PDFs, generated OG output, or generated reports as part of normal development.

Instead, modify the source or generation logic and run:

```bash
./build.sh
```

---

# Design Philosophy

The project follows several core principles.

## 1. Content is separate from metadata

Mathematical content and metadata have distinct responsibilities.

The content contains the actual mathematical material.

The metadata wrapper provides information needed by the publishing system.

---

## 2. Generated files are separate from source files

Everything under:

```text
generated/
```

is derived from source material.

Generated files are not the authoritative representation of the project.

---

## 3. Diagnostics are separate from published output

Reports belong under:

```text
diagnostics/
```

rather than:

```text
dist/
```

The published website should contain only the assets required by the website itself.

---

## 4. One metadata system drives many outputs

The same metadata drives:

```text
homepage
navigation
previous/next links
category navigation
HTML
PDF
category books
combined books
SEO
Open Graph
reports
```

This avoids maintaining the same information independently in multiple places.

---

## 5. Generated output should be reproducible

A clean build should be capable of regenerating:

```text
generated/
dist/
diagnostics/
```

from repository source and configuration.

---

## 6. Stale output should not silently survive

The build prepares its generated and published directories so obsolete output does not remain unnoticed after source content changes.

---

## 7. Reusable functionality belongs in templates

Individual content files should focus on mathematics.

Common functionality such as:

* theorem blocks
* navigation
* notation
* layout
* rendering
* counters
* styling

belongs in reusable templates.

---

## 8. Build responsibilities remain modular

The system separates:

```text
discovery
metadata parsing
metadata generation
HTML generation
PDF generation
book generation
OG generation
asset publishing
validation
diagnostics
```

This makes individual parts easier to understand and maintain.

---

## 9. Source organization reflects content organization

Courses, FGT, Group Theory, Olympiad, and MOPSS material have distinct source directories while sharing the same publishing infrastructure.

---

## 10. Published assets are derived assets

CSS, HTML, PDFs, OG images, `sitemap.xml`, and `robots.txt` are produced or assembled by the build system.

The `dist/` directory is therefore a publication target rather than a development workspace.

---

## 11. OG assets have an explicit lifecycle

Open Graph assets are separated into:

```text
assets/og/
```

for static/source assets,

```text
generated/og/
```

for generated/intermediate assets, and

```text
dist/assets/og/
```

for published assets.

---

## 12. Configuration is centralized

Project-wide configuration should be obtained from the configuration modules, principally:

```text
scripts/config.py
scripts/site_config.py
```

rather than duplicated across individual build scripts.

---

# Beyond a Website

Although the current implementation publishes a static website, the architecture is intentionally broader than a website generator.

The project can be viewed as a **mathematical publishing engine**.

```text
                    MATHEMATICAL SOURCE
                           │
                           ▼
                    ┌───────────────┐
                    │   Metadata    │
                    │   + Content   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Publishing  │
                    │     Engine    │
                    └───────┬───────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
        Website            PDFs            Books
          │                 │                 │
          ▼                 ▼                 ▼
       Teaching         Printing         Distribution
```

The important abstraction is therefore not:

```text
Typst → website
```

but:

```text
Mathematical source
        ↓
Structured metadata
        ↓
Reproducible publication pipeline
        ↓
Multiple educational and publishing outputs
```

This makes the system suitable for different teaching environments without changing the underlying content architecture.

For example, the same course material could eventually produce:

```text
Course
├── Website
├── Lecture pages
├── Lecture PDFs
├── Complete course book
├── Instructor version
├── Student version
├── Exercise collection
├── Problem/solution collection
├── Course index
├── Search index
└── Archive
```

Likewise, olympiad material could produce:

```text
Olympiad Program
├── Topic pages
├── Problem sheets
├── Solution sheets
├── Year collections
├── Category books
├── Website pages
└── Searchable archive
```

The underlying mathematical source remains the same.

This is a deliberate architectural goal:

> **The publication format should be replaceable without rewriting the mathematical content.**

The current website is therefore one consumer of the publishing engine rather than the boundary of the architecture.

---

# GitHub Pages

The generated site is designed to be published as a static website, including through GitHub Pages.

The publication target is:

```text
dist/
```

A successful build produces a self-contained static site containing:

```text
HTML
CSS
images
JavaScript assets
Open Graph images
PDFs
sitemap.xml
robots.txt
```

The repository's deployment configuration should publish the generated `dist/` output.

---

# Current Output

With the current source tree, the generated website contains pages corresponding to the discovered source content, including:

```text
dist/pages/
├── codeeg.html
├── fgt1.html
├── fgt2.html
├── fun.html
├── gt1.html
├── gt2.html
├── gt3.html
├── ioqm2024.html
├── ioqm2025.html
├── mopss_26aug08.html
├── mopss_26aug29.html
└── rmo2025.html
```

The PDF output contains:

```text
dist/pdf/
├── book.pdf
├── pages.pdf
├── category_developer.pdf
├── category_extras.pdf
├── category_fields_and_galois_theory.pdf
├── category_group_theory.pdf
├── category_ioqm.pdf
├── category_mopss.pdf
├── category_r_m_o.pdf
├── codeeg.pdf
├── fgt1.pdf
├── fgt2.pdf
├── fun.pdf
├── gt1.pdf
├── gt2.pdf
├── gt3.pdf
├── ioqm2024.pdf
├── ioqm2025.pdf
├── mopss_26aug08.pdf
├── mopss_26aug29.pdf
└── rmo2025.pdf
```

This list is generated dynamically from source metadata and will change as the repository grows.

---

# Future Improvements

The project is designed to evolve incrementally. Future work falls into several layers.

## Publishing and presentation

* **Website search** across lectures, courses, topics, and problem collections.
* **Homepage filtering** by course, category, topic, content type, date, or tags.
* **Course landing pages** with structured lecture sequences and course information.
* **Improved navigation** with breadcrumbs, related material, topic navigation, and richer cross-references.
* **Responsive and mobile presentation**.
* **Accessibility improvements**, including semantic HTML, keyboard navigation, focus states, and contrast.
* **Favicon and site identity assets**.
* **Improved PDF typography**, title pages, headers, footers, and book design.

## Teaching-oriented features

The metadata model can eventually support richer educational structures such as:

* courses and course sequences
* lecture numbering and prerequisites
* topics and subtopics
* exercises and solutions
* problem sets
* assignments
* quizzes
* examples
* reading lists
* references
* instructor notes
* student notes
* difficulty levels
* learning objectives
* prerequisite knowledge
* estimated study time
* **Semantic mathematical metadata**, including structured topics,
  concepts, techniques, difficulty, prerequisites, and relationships
  between definitions, theorems, examples, exercises, problems,
  and solutions.
* **Automatic related-problem discovery** based on mathematical
  concepts and techniques rather than only text similarity.
* **Mathematical knowledge graph generation** from semantic metadata.

This would allow the same publishing engine to support not only lecture notes but complete **teaching collections**.

## Reproducible builds

* **Incremental builds**, avoiding unnecessary regeneration of unchanged content.
* Content/metadata dependency tracking.
* Build caching.
* Per-stage build timing.
* Explicit build manifests.
* Source-to-output dependency reports.
* Stronger stale-output detection.
* Deterministic generated artifacts where practical.
* Reproducibility checks between builds.

The goal is that a large repository remains fast and predictable even as the number of mathematical documents grows substantially.

## Validation and quality assurance

* Automated tests for generated HTML.
* PDF sanity checks.
* Metadata schema validation.
* Cross-reference validation.
* Asset validation.
* Accessibility checks.
* SEO validation.
* Open Graph validation.
* Link checking.
* Import/dependency checking.
* Build regression tests.
* CI validation before publication.

The build should increasingly behave like a **compiler with a test suite**, rather than a collection of scripts.

## Publishing targets

The architecture can eventually support additional publication targets without changing the source content:

```text
                 Source Mathematics
                        │
                 Metadata + Structure
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
        HTML           PDF          Books
          │             │             │
          ▼             ▼             ▼
       Website       Printing      Archives
```

Potential future outputs include:

* course websites
* printable handouts
* instructor editions
* student editions
* problem books
* solution books
* lecture collections
* topic collections
* downloadable archives
* machine-readable indexes

## Community and discussion

A future teaching-oriented deployment could optionally integrate discussion systems such as **Giscus** for page-level comments.

This should remain an optional frontend integration rather than becoming part of the mathematical source or build core.

The architectural principle would be:

```text
Mathematical source
        │
        ▼
Publishing engine
        │
        ├── Website
        ├── PDFs
        ├── Books
        └── Optional services
                ├── Search
                ├── Comments
                └── Analytics
```

This keeps external services replaceable.

## Long-term direction

The long-term goal is not to accumulate website features indefinitely.

It is to build a system in which:

> **Mathematical content is authored once, structured once, validated once, and reproducibly published into whatever educational formats are needed.**

The website is simply the current and most visible publication format.

---

# Repository Summary

The architecture can be summarized as:

```text
                         ┌──────────────────────┐
                         │      content/        │
                         │                      │
                         │ Mathematics +        │
                         │ metadata             │
                         └──────────┬───────────┘
                                    │
                                    │ discovery
                                    ▼
                         ┌──────────────────────┐
                         │      scripts/        │
                         │                      │
                         │ Metadata             │
                         │ Build                │
                         │ OG generation        │
                         │ Validation           │
                         │ Configuration        │
                         └──────────┬───────────┘
                                    │
                                    │ generation
                                    ▼
                         ┌──────────────────────┐
                         │     generated/       │
                         │                      │
                         │ Typst                │
                         │ JSON                 │
                         │ OG intermediates     │
                         └──────────┬───────────┘
                                    │
                         ┌──────────┴───────────┐
                         │                      │
                         ▼                      ▼
              ┌──────────────────┐   ┌──────────────────┐
              │   templates/     │   │    figures/      │
              │                  │   │                  │
              │ Layout           │   │ Graphical assets │
              │ Blocks           │   │                  │
              │ Navigation       │   │                  │
              │ Mathematics      │   │                  │
              └────────┬─────────┘   └────────┬─────────┘
                       │                      │
                       └──────────┬───────────┘
                                  │
                                  ▼
                         ┌──────────────────────┐
                         │       dist/          │
                         │                      │
                         │ HTML                 │
                         │ PDFs                 │
                         │ CSS                  │
                         │ Images               │
                         │ OG images            │
                         │ sitemap.xml          │
                         │ robots.txt            │
                         └──────────────────────┘

                         ┌──────────────────────┐
                         │    diagnostics/      │
                         │                      │
                         │ Build reports        │
                         │ Metadata reports     │
                         │ Link reports         │
                         │ Import graph         │
                         │ Validation reports   │
                         └──────────────────────┘
```

The central idea is:

> **`content/` and its metadata are the authoritative inputs. `scripts/` transforms them, `generated/` holds intermediate artifacts, `dist/` is the published result, and `diagnostics/` records the health of the build.**

The project is therefore best understood not as a website with a build script, but as a **reproducible mathematical publishing engine**.

Its fundamental unit is not the HTML page. It is the **structured mathematical source**.

From that source, the system can derive:

```text
                    Mathematical Source
                           │
                    Metadata + Structure
                           │
                           ▼
                 Reproducible Build Engine
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
      Website             PDFs              Books
        │                  │                  │
        ├── SEO            ├── lectures       ├── courses
        ├── Search         ├── handouts       ├── categories
        ├── Navigation     └── archives       └── collections
        │
        └── Optional integrations
             ├── Comments
             ├── Search
             └── Analytics

                           │
                           ▼
                    Diagnostics + QA
```

This architecture makes it possible to adapt the same system to **courses, lecture series, olympiad programs, problem collections, seminars, instructor resources, and other forms of mathematical teaching and publication**.

The guiding principle is:

> **Author the mathematics once. Structure it carefully. Validate it automatically. Publish it everywhere.**
