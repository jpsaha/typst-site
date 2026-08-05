# 🧮 Typst Mathematics Lecture Portal

An automated, dual-target academic portal built entirely with **Typst**. This repository hosts interactive, browser-viewable lecture notes alongside downloadable, print-ready A4 PDFs. It features automated indexing, a built-in search engine, local rendering fallbacks, and multi-theme (Dark/Light) UI environments.

---

## 🚀 Quick Start & Local Development

### 📋 Prerequisites
Ensure you have the following installed on your local machine:
- **Typst CLI** (v0.12.x or later)
- **Node.js** (v20+ to run the local Pagefind search indexer)

# 🧮 Typst Mathematics Lecture Portal

[![CI](https://github.com/jpsaha/typst-site/actions/workflows/deploy.yml/badge.svg)](https://github.com/jpsaha/typst-site/actions) [![Pages](https://github.com/jpsaha/typst-site/workflows/Pages/badge.svg)](https://OWNER.github.io/REPO) [![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Concise, browser-viewable lecture notes and print-ready A4 PDFs generated with Typst. Includes automatic indexing, Pagefind search, local-render fallbacks, and Light/Dark themes.

## Table of Contents
- Quick Start
- Project layout
- Adding lectures
- CI/CD
- Customization

## Quick Start

Prerequisites
- Typst CLI (v0.12+)
- Node.js (v20+) — used for Pagefind indexing

Build the site (from repo root):
```bash
chmod +x ./build.sh
./build.sh
```
This creates a `dist/` directory with the static site and generated PDFs.

Preview locally (in macOS):
```bash
cd dist
python3 -m http.server 8000
open http://localhost:8000
```

Tip: If you only want to compile a single lecture for testing, run the Typst compiler on that file (example):
```bash
typst compile src/lec1.typ -o dist/lec1.pdf
```

## Project layout

```
typst-site/
├── .github/workflows/deploy.yml  # CI deploy to GitHub Pages
├── src/
│   ├── template.typ              # Layout (theorems, exercises, nav)
│   ├── style.css                 # Theme variables & styles
│   ├── lec1.typ
│   └── lec2.typ
├── .gitignore
└── build.sh                       # Build + index + publish pipeline
```

## Adding a lecture
1. Add `src/lecN.typ` (exact filename expected by the indexer).
2. Include a title metadata line at the top. Example (comment or YAML frontmatter):
```typst
// Title: Vector Spaces & Inner Products
#import "template.typ": theorem, definition, exercise, html-nav-header
```
Recommendation: consider using a YAML frontmatter block or a documented metadata header to make parsing more robust across editors and tools.

Run `./build.sh` to update the site and search index, or push to `main` and let CI deploy.

## CI / Deployment
Pipeline: [.github/workflows/deploy.yml](.github/workflows/deploy.yml) — the action builds the site and deploys to GitHub Pages, and runs Pagefind for search indexing.

## Customization
- Edit `src/style.css` for colors, fonts, and theme variables.
- Edit `src/template.typ` to change layout, theorem styling, or navigation.
