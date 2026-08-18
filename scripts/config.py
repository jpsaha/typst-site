#!/usr/bin/env python3

"""
Central configuration for the Typst mathematics lecture website.

This module contains:

    - Project paths
    - Generated-file paths
    - Distribution paths
    - Diagnostic paths
    - Site identity
    - SEO configuration
    - Open Graph configuration
    - Build-mode configuration

All build scripts should import paths and configuration values
from this module rather than constructing project-specific paths
independently.
"""

import os
from pathlib import Path

from scripts.site_config import (
    GITHUB_USERNAME,
    REPO_NAME,
    SITE_DESCRIPTION,
    SITE_TITLE,
    SITE_SUBTITLE,
    SITE_ICON,
    SITE_TAGLINE,
)

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
# ============================================================

ROOT = Path(__file__).resolve().parents[1]


# ============================================================
# Project directories
# ============================================================

CONTENT_DIR = ROOT / "content"
TEMPLATES_DIR = ROOT / "templates"
GENERATED_DIR = ROOT / "generated"
DIAGNOSTICS_DIR = ROOT / "diagnostics"


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
#
ASSETS_SOURCE_DIR = ROOT / "assets"


# ============================================================
# Generated Open Graph files
# ============================================================
#
# Generated OG sources and intermediate PNG files are kept
# outside dist/.
#
# Example:
#
#     generated/og/gt/lec2.asy
#     generated/og/gt/lec2.png
#
# These files are temporary build products.
#
# They are later copied into:
#
#     dist/assets/og/
#
# by the OG/dist preparation pipeline.
#
GENERATED_OG_DIR = GENERATED_DIR / "og"


# ============================================================
# Project source files
# ============================================================

BOOK_SOURCE = ROOT / "book_source.typ"
PAGES_SOURCE = ROOT / "pages_source.typ"
PDFLAYOUT = TEMPLATES_DIR / "pdflayout.typ"


# ============================================================
# Generated metadata files
# ============================================================
#
# These files are produced by the metadata/build pipeline.
# They should not normally be edited by hand.
#
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
#
# ============================================================

DIST_DIR = ROOT / "dist"

PAGES_DIR = DIST_DIR / "pages"
PDF_DIR = DIST_DIR / "pdf"
ASSETS_DIR = DIST_DIR / "assets"
OG_DIR = ASSETS_DIR / "og"

INDEX_HTML = DIST_DIR / "index.html"


# ============================================================
# Diagnostic files
# ============================================================

IMPORTS_DOT = DIAGNOSTICS_DIR / "imports.dot"

METADATA_REPORT = DIAGNOSTICS_DIR / "metadata_report.txt"
GENERATED_REPORT = DIAGNOSTICS_DIR / "generated_report.txt"
LINK_REPORT = DIAGNOSTICS_DIR / "link_report.txt"
BUILD_REPORT = DIAGNOSTICS_DIR / "build_report.txt"



# ============================================================
# SEO / Website
# ============================================================

# ------------------------------------------------------------
# Website URL
# ------------------------------------------------------------
#
# No trailing "/" is used.
#
# ============================================================

SITE_URL = (
    f"https://{GITHUB_USERNAME}.github.io/{REPO_NAME}"
)


# ------------------------------------------------------------
# Site author
# ------------------------------------------------------------

SITE_AUTHOR = ""


# ------------------------------------------------------------
# Website language
# ------------------------------------------------------------

SITE_LANGUAGE = "en"


# ------------------------------------------------------------
# Robots policy
# ------------------------------------------------------------

SITE_ROBOTS = "index, follow"


# ============================================================
# Open Graph build mode
# ============================================================
#
# These values define the default Open Graph generation policy.
#
#     TYPST_OG_BUILD
#         Default for local builds.
#
#     TYPST_OG_GITBUILD
#         Default for GitHub Actions builds.
#
# The effective setting used by the build is:
#
#     TYPST_OG
#
# See the "Effective Open Graph setting" section below for
# the complete precedence and environment-variable behavior.
#
# ------------------------------------------------------------
# Local builds
# ------------------------------------------------------------
#
# False:
#     Reuse existing/committed OG PNG images.
#
# True:
#     Generate OG .asy sources and PNG images.
#
# ------------------------------------------------------------
# GitHub Actions
# ------------------------------------------------------------
#
# False:
#     Reuse committed OG PNG images.
#
# True:
#     Generate OG images during the GitHub build.
#
# When enabled on GitHub, the workflow must provide:
#
#     Asymptote
#     TeX Live
#     ImageMagick
#
# ============================================================

TYPST_OG_BUILD = False

TYPST_OG_GITBUILD = False

# ============================================================
# Effective Open Graph setting
# ============================================================
#
# Priority:
#
#     1. GitHub Actions
#        → TYPST_OG_GITBUILD
#
#     2. Local build with TYPST_OG_BUILD environment variable
#        → environment variable value
#
#     3. Normal local build
#        → TYPST_OG_BUILD from this configuration file
#
# Important:
#
# A TYPST_OG_BUILD environment variable does NOT override
# TYPST_OG_GITBUILD on GitHub Actions.
#
# ============================================================

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


# ============================================================
# Default Open Graph image
# ============================================================
#
# Used when a page has neither:
#
#     1. an explicit og_image, nor
#     2. an available generated/published page-specific image.
#
# Source:
#
#     assets/og/default.png
#
# Published:
#
#     dist/assets/og/default.png
#
# Public URL:
#
#     /assets/og/default.png
#
# This is a PUBLIC URL, not a filesystem path.
#
# ============================================================

SITE_OG_IMAGE = "/assets/og/default.png"


# ============================================================
# Open Graph generation
# ============================================================
#
# Configuration shared by:
#
#     scripts/og/generate_og.py
#     scripts/og/build_og.py
#
# ============================================================


# ------------------------------------------------------------
# Asymptote template
# ------------------------------------------------------------
#
# Template used to generate Asymptote source files.
#
#     scripts/og/og_template.asy
#
# ============================================================

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
# ============================================================

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
#
# ============================================================

OG_DENSITY = 300