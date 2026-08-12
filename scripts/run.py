#!/usr/bin/env python3

import subprocess
import sys

COMMANDS = {
    # Generation
    "metadata": "scripts.build.generate_metadata",

    # Output
    "html": "scripts.build.build_html",
    "book": "scripts.build.build_book",
    "pages-pdf": "scripts.build.build_pages_pdf",
    "categories": "scripts.build.build_categories",

    # Validation
    "metadata-check": "scripts.lint.check_metadata",
    "generated": "scripts.lint.check_generated",
    "imports": "scripts.lint.check_imports",
    "links": "scripts.lint.check_links",
}


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
        print("Usage: python3 scripts/run.py <command>")
        print()
        print("Commands:")

        for command in COMMANDS:
            print(f"  {command}")

        return 1

    module = COMMANDS[sys.argv[1]]

    return subprocess.run(
        [sys.executable, "-m", module]
    ).returncode


if __name__ == "__main__":
    sys.exit(main())