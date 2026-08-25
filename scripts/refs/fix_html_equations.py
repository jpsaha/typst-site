#!/usr/bin/env python3

"""
Fix equation-number rendering in generated HTML.

Typst's HTML output currently produces labelled equations like:

    <math id="eqn-ab" display="block">...</math>

but does not render the equation number visually.

This script:

1. Reads generated/refmap.json when available.
2. Processes dist/pages/*.html.
3. Finds block equations with an id.
4. Inserts a visible equation number.
5. Preserves the equation id so internal references continue to work.

Example:

    Before:

        <math id="eqn-ab" display="block">...</math>

    After:

        <div class="html-equation">
          <math id="eqn-ab" display="block">...</math>
          <span class="html-equation-number">(1)</span>
        </div>

The numbering is determined from the order of labelled block
equations in each lecture page.

This is deliberately an HTML post-processing step. PDF equation
numbering remains entirely under Typst's control.
"""

from pathlib import Path
import re
import sys


# ============================================================
# Project root
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


from scripts.config import PAGES_DIR


# ============================================================
# Equation pattern
# ============================================================

EQUATION_RE = re.compile(
    r'(?P<equation>'
    r'<math\b'
    r'(?P<attrs>[^>]*\bid="(?P<id>[^"]+)"[^>]*)'
    r'\bdisplay="block"'
    r'[^>]*>'
    r'.*?'
    r'</math>'
    r')',
    re.IGNORECASE | re.DOTALL,
)


# ============================================================
# Already wrapped equation
# ============================================================

WRAPPED_RE = re.compile(
    r'<div\s+class="html-equation"[^>]*>'
    r'\s*<math\b',
    re.IGNORECASE,
)


# ============================================================
# Equation number
# ============================================================

def equation_number(index):
    """
    Return the visible HTML equation number.

    Example:

        1 -> (1)
        2 -> (2)
    """

    return f"({index})"


# ============================================================
# Build replacement
# ============================================================

def make_equation_html(
    equation,
    number,
):
    """
    Wrap one block equation in the HTML equation container.
    """

    return (
        '<div class="html-equation">'
        + equation
        + '<span class="html-equation-number">'
        + number
        + '</span>'
        + '</div>'
    )


# ============================================================
# Fix one HTML file
# ============================================================

def fix_file(html_path):
    """
    Fix labelled block equations in one HTML file.

    Returns:

        (number_of_equations, number_of_changes)
    """

    html = html_path.read_text(
        encoding="utf-8"
    )

    equation_count = 0
    changes = 0

    def replace(match):

        nonlocal equation_count
        nonlocal changes

        equation = match.group("equation")
        anchor = match.group("id")

        # ----------------------------------------------------
        # Ignore equations that have already been processed.
        #
        # This also makes the script idempotent.
        # ----------------------------------------------------

        start = match.start()

        preceding = html[
            max(0, start - 100):
            start
        ]

        if (
            preceding.endswith(
                '<div class="html-equation">'
            )
        ):
            return equation

        equation_count += 1

        number = equation_number(
            equation_count
        )

        changes += 1

        print(
            f"  ✓ #{equation_count:<4}"
            f"{anchor:<30}"
            f" → {number}"
        )

        return make_equation_html(
            equation,
            number,
        )

    updated = EQUATION_RE.sub(
        replace,
        html,
    )

    # --------------------------------------------------------
    # Write only if changed.
    # --------------------------------------------------------

    if updated != html:

        html_path.write_text(
            updated,
            encoding="utf-8",
        )

    return equation_count, changes


# ============================================================
# Main
# ============================================================

def main():

    print()
    print("🔢 Fixing HTML equation numbers")
    print("================================")

    html_files = sorted(
        PAGES_DIR.glob("*.html")
    )

    if not html_files:

        print(
            f"ERROR: no HTML files found in {PAGES_DIR}"
        )

        return 1

    total_equations = 0
    total_changes = 0

    for html_path in html_files:

        print()
        print(
            f"📖 {html_path.name}"
        )

        equations, changes = fix_file(
            html_path
        )

        total_equations += equations
        total_changes += changes

    print()
    print(
        f"✓ HTML pages        : {len(html_files)}"
    )

    print(
        f"✓ Equations found   : {total_equations}"
    )

    print(
        f"✓ Equations changed : {total_changes}"
    )

    print()

    return 0


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":

    raise SystemExit(
        main()
    )