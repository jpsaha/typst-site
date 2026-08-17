from pathlib import Path

# ============================================================
# Project root
# ============================================================
#
# This file is:
#
#     scripts/config.py
#
# Therefore:
#
#     parents[0] = scripts/
#     parents[1] = project root
#
# Keeping the project root here provides a single source of
# truth for all project paths used throughout the build system.
# ============================================================

ROOT = Path(__file__).resolve().parents[1]


# ============================================================
# Project directories
# ============================================================

CONTENT_DIR = ROOT / "content"
TEMPLATES_DIR = ROOT / "templates"
GENERATED_DIR = ROOT / "generated"
DIAGNOSTICS_DIR = ROOT / "diagnostics"

# Generated Open Graph sources and images.
#
# Example:
#
#     generated/og/gt/lec1.asy
#     generated/og/gt/lec1.png
#
GENERATED_OG_DIR = GENERATED_DIR / "og"


# ============================================================
# Source directories
# ============================================================

# Static assets supplied directly by the project.
#
# These are copied into:
#
#     dist/assets/
#
# during dist preparation.
# ============================================================

ASSETS_SOURCE_DIR = ROOT / "assets"


# ============================================================
# Project source files
# ============================================================

BOOK_SOURCE = ROOT / "book_source.typ"
PAGES_SOURCE = ROOT / "pages_source.typ"
PDFLAYOUT = ROOT / "templates" / "pdflayout.typ"


# ============================================================
# Generated files
# ============================================================
#
# These files are produced by the metadata/build pipeline.
# They should not normally be edited by hand.
# ============================================================

LECTURES_TYP = GENERATED_DIR / "lectures.typ"
BOOK_TYP = GENERATED_DIR / "book.typ"
PAGES_TYP = GENERATED_DIR / "pages.typ"
PAGES_META_TYP = GENERATED_DIR / "pages_meta.typ"
HOMEPAGE_TYP = GENERATED_DIR / "homepage.typ"
HOMEPAGE_JSON = GENERATED_DIR / "homepage.json"


# ============================================================
# Distribution directories
# ============================================================
#
# Everything under dist/ is generated and is suitable for
# publishing to GitHub Pages.
#
# Typical structure:
#
#     dist/
#     ├── index.html
#     ├── pages/
#     ├── pdf/
#     └── assets/
#         ├── css/
#         └── og/
# ============================================================

DIST_DIR = ROOT / "dist"

PAGES_DIR = DIST_DIR / "pages"
PDF_DIR = DIST_DIR / "pdf"
ASSETS_DIR = DIST_DIR / "assets"

INDEX_HTML = DIST_DIR / "index.html"


# ============================================================
# Diagnostic files
# ============================================================

IMPORTS_DOT = DIAGNOSTICS_DIR / "imports.dot"

METADATA_REPORT = DIAGNOSTICS_DIR / "metadata_report.txt"
GENERATED_REPORT = DIAGNOSTICS_DIR / "generated_report.txt"
LINK_REPORT = DIAGNOSTICS_DIR / "link_report.txt"

BUILD_REPORT = DIAGNOSTICS_DIR / "build_report.txt"

# Historical/commented reference:
#
# DOT = DIAGNOSTICS_DIR / "imports.dot"


# ============================================================
# Site information
# ============================================================

# ------------------------------------------------------------
# Previous site configuration
# ------------------------------------------------------------
#
# Kept here for reference in case the site identity is changed
# back to the simpler portal-style presentation.
# ------------------------------------------------------------

# SITE_TITLE = "Mathematics Lecture Portal"
# SITE_ICON = "🧮"
# SITE_TAGLINE = (
#     "Interactive web modules & downloadable "
#     "print-ready course material"
# )


# ------------------------------------------------------------
# Current site identity
# ------------------------------------------------------------

SITE_TITLE = "Mathematics: Lectures & Notes"
SITE_SUBTITLE = "Typeset with Typst"

SITE_ICON = "🧮"

SITE_TAGLINE = (
    "These notes may contain typos, "
    "and need not be a faithful representation of any lecture or a course. "
    "Please report any errors you find to the author."
)


# ============================================================
# SEO / Website
# ============================================================

# ------------------------------------------------------------
# GitHub repository
# ------------------------------------------------------------
#
# GitHub username and repository name are kept separately so
# that SITE_URL can be constructed automatically.
#
# Example:
#
#     https://jpsaha.github.io/typst-site
# ------------------------------------------------------------

# GITHUB_USERNAME = "username"
# REPO_NAME = "reponame"

GITHUB_USERNAME = "jpsaha"
REPO_NAME = "typst-site"


# ------------------------------------------------------------
# Website URL
# ------------------------------------------------------------
#
# Do not put a trailing "/" on SITE_URL.
#
# This value is used when constructing canonical URLs and
# absolute Open Graph / Twitter image URLs.
# ------------------------------------------------------------

SITE_URL = f"https://{GITHUB_USERNAME}.github.io/{REPO_NAME}"


# ------------------------------------------------------------
# Site-wide description
# ------------------------------------------------------------
#
# Used as the fallback description when an individual page
# does not provide its own description.
# ------------------------------------------------------------

SITE_DESCRIPTION = (
    "Mathematics lectures, notes, and problem-solving resources."
)


# ------------------------------------------------------------
# Site author
# ------------------------------------------------------------

SITE_AUTHOR = ""

# ============================================================
# Open Graph build mode
# ============================================================
#
# Controls whether Open Graph images are generated during
# the build.
#
# True:
#     Generate OG .asy files and build PNGs.
#
# False:
#     Reuse the committed OG PNGs already present in
#     dist/assets/og/.
#
# Normal local/deployment build:
#
#     False
#
# To generate/update OG images locally, temporarily change
# this to True.
# ============================================================

# ======================================================================

# ============================================================
# Open Graph build mode
# ============================================================

# ------------------------------------------------------------
# Local OG generation
# ------------------------------------------------------------
#
# Normally False.
#
# Set to True only when new OG images need to be generated,
# for example when:
#
#   - a new lecture is added
#   - OG-related metadata changes
#   - the OG template changes
#
# After generating the images and committing them, set this
# back to False.
# ------------------------------------------------------------

TYPST_OG_BUILD = False


# ------------------------------------------------------------
# GitHub deployment OG generation
# ------------------------------------------------------------
#
# Normally False and expected to remain False.
#
# GitHub deployment reuses the committed PNG files in:
#
#     dist/assets/og/
#
# Therefore GitHub does not need LaTeX, Asymptote, or
# ImageMagick installed just to generate OG images.
# ------------------------------------------------------------

# GitHub deployment should normally NEVER generate OG images.
# Keep this False unless the GitHub workflow is deliberately
# changed to install Asymptote, TeX Live, and ImageMagick.

TYPST_OG_GITBUILD = False

# ============================================================
# Effective OG setting
# ============================================================
#
# Priority:
#
#   1. Explicit TYPST_OG_BUILD environment variable
#      (local one-off override)
#
#   2. TYPST_OG_GITBUILD when running on GitHub Actions
#
#   3. TYPST_OG_BUILD for normal local builds
# ============================================================

import os

IS_GITHUB_ACTIONS = (
    os.environ.get("GITHUB_ACTIONS", "").lower() == "true"
)

if not IS_GITHUB_ACTIONS and "TYPST_OG_BUILD" in os.environ:

    TYPST_OG = (
        os.environ["TYPST_OG_BUILD"].lower() == "true"
    )

else:

    TYPST_OG = (
        TYPST_OG_GITBUILD
        if IS_GITHUB_ACTIONS
        else TYPST_OG_BUILD
    )

# ------------------------------------------------------------
# Default Open Graph image
# ------------------------------------------------------------
#
# Used when a page does not have a page-specific OG image.
#
# The source image is:
#
#     assets/og/default.png
#
# and it is copied during dist preparation to:
#
#     dist/assets/og/default.png
#
# Its public URL is therefore:
#
#     /assets/og/default.png
#
# This is a PUBLIC URL, not a filesystem path.
# ------------------------------------------------------------

SITE_OG_IMAGE = "/assets/og/default.png"


# ------------------------------------------------------------
# Website language
# ------------------------------------------------------------

SITE_LANGUAGE = "en"


# ------------------------------------------------------------
# Robots policy
# ------------------------------------------------------------

SITE_ROBOTS = "index, follow"


# ============================================================
# Open Graph generation
# ============================================================
#
# The following settings are shared by the OG generation
# scripts. They belong here rather than being duplicated in:
#
#     scripts/og/generate_og.py
#     scripts/og/build_og.py
#
# This keeps OG-related configuration in one place.
# ============================================================


# ------------------------------------------------------------
# Asymptote template
# ------------------------------------------------------------
#
# Template used to generate Asymptote source files.
#
#     scripts/og/og_template.asy
#
# This is a project-level configuration path because changing
# the template location should not require modifying the OG
# generation code.
# ------------------------------------------------------------

OG_TEMPLATE_FILE = (
    ROOT
    / "scripts"
    / "og"
    / "og_template.asy"
)


# ------------------------------------------------------------
# Final Open Graph image dimensions
# ------------------------------------------------------------
#
# Standard Open Graph landscape dimensions:
#
#     1200 × 630 pixels
#
# These values are used by build_og.py when converting the
# intermediate PDF into the final PNG.
# ------------------------------------------------------------

OG_WIDTH = 1200
OG_HEIGHT = 630


# ------------------------------------------------------------
# Open Graph rasterization density
# ------------------------------------------------------------
#
# Asymptote first produces an intermediate PDF.
#
# ImageMagick then rasterizes that PDF at this density before
# resizing the result to OG_WIDTH × OG_HEIGHT.
# ------------------------------------------------------------

OG_DENSITY = 300