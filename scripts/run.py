#!/usr/bin/env python3

import subprocess
import sys


# ============================================================
# Command registry
#
# Each command maps to a Python module that can be executed
# with:
#
#     python3 -m <module>
#
# This file provides a single entry point for build.sh and
# keeps the shell script independent of the individual Python
# module names.
#
# ------------------------------------------------------------
# Generation
# ------------------------------------------------------------
#
# python3 scripts/run.py metadata
#
# ------------------------------------------------------------
# Open Graph images
# ------------------------------------------------------------
#
# python3 scripts/run.py og-generate
# python3 scripts/run.py og-build
#
# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
#
# python3 scripts/run.py metadata-check
# python3 scripts/run.py generated
# python3 scripts/run.py imports
# python3 scripts/run.py links
#
# ------------------------------------------------------------
# Build infrastructure
# ------------------------------------------------------------
#
# python3 scripts/run.py prepare-dist
# python3 scripts/run.py prepare-diagnostics
#
# ------------------------------------------------------------
# Output
# ------------------------------------------------------------
#
# python3 scripts/run.py html
# python3 scripts/run.py pdf
# python3 scripts/run.py categories
# python3 scripts/run.py book
# python3 scripts/run.py pages-pdf
#
# ------------------------------------------------------------
# Site files
# ------------------------------------------------------------
#
# python3 scripts/run.py sitemap
# python3 scripts/run.py robots
#
# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------
#
# python3 scripts/run.py report
# ============================================================

COMMANDS = {

    # --------------------------------------------------------
    # Generation
    # --------------------------------------------------------

    "metadata": "scripts.build.generate_metadata",

    # --------------------------------------------------------
    # Open Graph images
    # --------------------------------------------------------

    "og-generate": "scripts.og.generate_og",
    "og-build": "scripts.og.build_og",

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    "metadata-check": "scripts.lint.check_metadata",
    "generated": "scripts.lint.check_generated",
    "imports": "scripts.lint.check_imports",
    "links": "scripts.lint.check_links",

    # --------------------------------------------------------
    # Build infrastructure preparation
    # --------------------------------------------------------

    "prepare-dist": "scripts.build.prepare_dist",

    # --------------------------------------------------------
    # Prepare diagnostics
    # --------------------------------------------------------

    "prepare-diagnostics": "scripts.build.prepare_diagnostics",

    # --------------------------------------------------------
    # Website Output
    # --------------------------------------------------------

    "html": "scripts.build.build_html",
    "sitemap": "scripts.build.build_sitemap",
    "robots": "scripts.build.build_robots",

    # --------------------------------------------------------
    # PDF Output
    # --------------------------------------------------------

    "pdf": "scripts.build.build_pdfs",
    "categories": "scripts.build.build_categories",
    "book": "scripts.build.build_book",
    "pages-pdf": "scripts.build.build_pages_pdf",

    # --------------------------------------------------------
    # Diagnostics
    # --------------------------------------------------------

    "report": "scripts.build.build_report",
}


# ============================================================
# Main
# ============================================================

def main():

    # --------------------------------------------------------
    # Validate command
    # --------------------------------------------------------

    if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:

        print("Usage: python3 scripts/run.py <command>")
        print()
        print("Commands:")

        for command in COMMANDS:
            print(f"  {command}")

        return 1

    # --------------------------------------------------------
    # Resolve module
    # --------------------------------------------------------

    module = COMMANDS[sys.argv[1]]

    # --------------------------------------------------------
    # Execute module
    #
    # Use the same Python interpreter that invoked run.py.
    # This avoids accidentally using a different Python
    # installation or virtual environment.
    # --------------------------------------------------------

    result = subprocess.run(
        [sys.executable, "-m", module]
    )

    return result.returncode


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    sys.exit(main())