#!/usr/bin/env python3

import sys
import subprocess


COMMANDS = {
    "metadata": "scripts.build.generate_metadata",
    "metadata-check": "scripts.lint.check_metadata",
    "generated": "scripts.lint.check_generated",
    "imports": "scripts.lint.check_imports",
    "pages": "scripts.build.build_pages",
    "links": "scripts.lint.check_links",
}


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
        print("Usage: python3 scripts/run.py <command>")
        print()
        print("Commands:")
        for name in COMMANDS:
            print(f"  {name}")
        return 1

    module = COMMANDS[sys.argv[1]]

    return subprocess.run(
        [sys.executable, "-m", module]
    ).returncode


if __name__ == "__main__":
    sys.exit(main())