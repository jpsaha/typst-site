#!/usr/bin/env python3

"""
Analyze Typst import dependencies.

Checks:

1. Scans project Typst source files.
2. Builds an import dependency graph.
3. Detects missing imports.
4. Detects circular imports.
5. Reports top-level files.
6. Reports leaf modules.
7. Writes a Graphviz dependency graph.
8. Reports unreadable Typst files.

Usage:

    python3 scripts/lint/check_imports.py

Exit status:

    0   no problems
    1   missing imports, unreadable files, or circular imports
"""

from collections import defaultdict
from pathlib import Path
import re
import sys


# ============================================================
# Paths
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

DIAGNOSTICS = ROOT / "diagnostics"

DOT = DIAGNOSTICS / "imports.dot"


# ============================================================
# Configuration
# ============================================================

IMPORT_RE = re.compile(
    r'#import\s+"([^"]+)"'
)


def remove_comments(text):
    """
    Remove Typst comments while preserving strings.

    Supports:

        // line comments

        /*
           block comments
        */

    Comment markers appearing inside quoted strings are preserved.
    """

    result = []

    i = 0
    length = len(text)

    in_string = False
    in_line_comment = False
    in_block_comment = False
    escaped = False

    while i < length:

        char = text[i]

        # ----------------------------------------------------
        # Line comment
        # ----------------------------------------------------

        if in_line_comment:

            if char == "\n":

                in_line_comment = False
                result.append(char)

            i += 1
            continue

        # ----------------------------------------------------
        # Block comment
        # ----------------------------------------------------

        if in_block_comment:

            if (
                char == "*"
                and i + 1 < length
                and text[i + 1] == "/"
            ):

                in_block_comment = False
                i += 2
                continue

            # Preserve newlines so that the resulting text
            # retains approximately the original structure.
            if char == "\n":
                result.append("\n")

            i += 1
            continue

        # ----------------------------------------------------
        # Quoted string
        # ----------------------------------------------------

        if in_string:

            result.append(char)

            if escaped:

                escaped = False

            elif char == "\\":

                escaped = True

            elif char == '"':

                in_string = False

            i += 1
            continue

        # ----------------------------------------------------
        # Start quoted string
        # ----------------------------------------------------

        if char == '"':

            in_string = True
            result.append(char)
            i += 1
            continue

        # ----------------------------------------------------
        # Start line comment
        # ----------------------------------------------------

        if (
            char == "/"
            and i + 1 < length
            and text[i + 1] == "/"
        ):

            in_line_comment = True
            i += 2
            continue

        # ----------------------------------------------------
        # Start block comment
        # ----------------------------------------------------

        if (
            char == "/"
            and i + 1 < length
            and text[i + 1] == "*"
        ):

            in_block_comment = True
            i += 2
            continue

        # ----------------------------------------------------
        # Normal character
        # ----------------------------------------------------

        result.append(char)
        i += 1

    return "".join(result)

TYPST_DIRS = (
    ROOT / "content",
    ROOT / "templates",
    ROOT / "generated",
)

TYPST_FILES = (
    ROOT / "book_source.typ",
    ROOT / "pages_source.typ",
    ROOT / "pdflayout.typ",
)


# ============================================================
# Path formatting
# ============================================================

def display_path(path):
    """
    Return a readable path.

    Paths inside the repository are displayed relative to ROOT.
    Paths outside the repository are displayed as absolute paths.
    """

    try:
        return path.relative_to(ROOT).as_posix()

    except ValueError:
        return path.as_posix()


# ============================================================
# Discover Typst files
# ============================================================

def discover_typst_files():
    """Return all Typst files that belong to the project."""

    files = set()

    for directory in TYPST_DIRS:

        if not directory.exists():
            continue

        files.update(
            path.resolve()
            for path in directory.rglob("*.typ")
        )

    for path in TYPST_FILES:

        if path.exists() and path.is_file():
            files.add(path.resolve())

    return files


# ============================================================
# Build dependency graph
# ============================================================

def build_graph(files):
    """
    Build the Typst import graph.

    Returns:

        graph:
            source -> imported files

        reverse:
            imported file -> importing files

        missing:
            (source, target) pairs for missing imports

        unreadable:
            files that could not be read
    """

    graph = defaultdict(list)
    reverse = defaultdict(list)

    missing = []
    unreadable = []

    for path in sorted(files):

        try:

            text = path.read_text(
                encoding="utf-8"
            )

        except (OSError, UnicodeError) as error:

            unreadable.append(
                (path, error)
            )

            continue

        # --------------------------------------------------------
        # Ignore commented-out imports.
        #
        # This prevents lines such as:
        #
        #     // #import "main.typ": *
        #
        # and imports inside:
        #
        #     /*
        #     #import "main.typ": *
        #     */
        #
        # from being treated as real dependencies.
        # --------------------------------------------------------

        text = remove_comments(text)

        for match in IMPORT_RE.finditer(text):

            import_path = match.group(1)

            # ----------------------------------------------------
            # Ignore Typst package imports.
            #
            # Examples:
            #
            #     @preview/cetz:0.3.4
            #     @preview/gentle-clues:1.2.0
            #     @preview/theorion:0.6.0
            #
            # These are handled by Typst's package system and are
            # not local project files.
            # ----------------------------------------------------

            if import_path.startswith("@"):
                continue

            target = (
                path.parent / import_path
            ).resolve()

            graph[path].append(target)
            reverse[target].append(path)

            if not target.is_file():

                missing.append(
                    (path, target)
                )

    return (
        graph,
        reverse,
        missing,
        unreadable,
    )


# ============================================================
# Dependency tree
# ============================================================

def print_tree(
    node,
    graph,
    prefix="",
    seen=None,
):
    """Print the dependency tree rooted at node."""

    if seen is None:
        seen = set()

    print(
        prefix + display_path(node)
    )

    if node in seen:

        print(
            prefix + "  ↺"
        )

        return

    seen = seen | {node}

    for child in graph[node]:

        print_tree(
            child,
            graph,
            prefix + "    ",
            seen,
        )


def print_dependency_tree(
    roots,
    graph,
):
    """Print dependency trees."""

    print(
        "\n=============================="
    )
    print(
        "Dependency Tree"
    )
    print(
        "==============================\n"
    )

    for root in sorted(roots):

        print_tree(
            root,
            graph,
        )

        print()


# ============================================================
# Cycle detection
# ============================================================

def find_cycles(
    nodes,
    graph,
):
    """Return circular import paths."""

    cycles = []

    visited = set()
    stack = []

    def dfs(node):

        if node in stack:

            index = stack.index(node)

            cycles.append(
                stack[index:] + [node]
            )

            return

        if node in visited:
            return

        visited.add(node)
        stack.append(node)

        for child in graph[node]:

            # Missing imports cannot participate
            # in a meaningful cycle.
            if child.is_file():

                dfs(child)

        stack.pop()

    for node in sorted(nodes):
        dfs(node)

    return cycles


def print_cycles(cycles):
    """Print circular imports."""

    print(
        "=============================="
    )
    print(
        "Cycle Detection"
    )
    print(
        "==============================\n"
    )

    if not cycles:

        print(
            "No circular imports.\n"
        )

        return

    for cycle in cycles:

        print(
            "Circular import:"
        )

        for path in cycle:

            print(
                "   ",
                display_path(path),
            )

        print()


# ============================================================
# Missing imports
# ============================================================

def print_missing(missing):
    """Print missing imports."""

    print(
        "=============================="
    )
    print(
        "Missing Imports"
    )
    print(
        "==============================\n"
    )

    if not missing:

        print(
            "No missing imports.\n"
        )

        return

    for source, target in missing:

        print(
            display_path(source)
        )

        print(
            f"   -> {display_path(target)}"
        )

        print(
            "      [NOT FOUND]\n"
        )


# ============================================================
# Unreadable files
# ============================================================

def print_unreadable(unreadable):
    """Print Typst files that could not be read."""

    print(
        "=============================="
    )
    print(
        "Unreadable Files"
    )
    print(
        "==============================\n"
    )

    if not unreadable:

        print(
            "No unreadable files.\n"
        )

        return

    for path, error in unreadable:

        print(
            display_path(path)
        )

        print(
            f"   -> {error}\n"
        )


# ============================================================
# Top-level files
# ============================================================

def print_roots(
    roots,
):
    """Print files that are not imported by another file."""

    print(
        "=============================="
    )
    print(
        "Top-level files"
    )
    print(
        "==============================\n"
    )

    for path in sorted(roots):

        print(
            display_path(path)
        )

    print()


# ============================================================
# Leaves
# ============================================================

def print_leaves(
    files,
    graph,
):
    """Print files that import nothing."""

    print(
        "=============================="
    )
    print(
        "Leaf modules"
    )
    print(
        "==============================\n"
    )

    for path in sorted(files):

        if not graph[path]:

            print(
                display_path(path)
            )

    print()


# ============================================================
# Graphviz
# ============================================================

def write_graphviz(
    files,
    graph,
):
    """Write the import graph as Graphviz DOT."""

    DIAGNOSTICS.mkdir(
        parents=True,
        exist_ok=True,
    )

    with DOT.open(
        "w",
        encoding="utf-8",
    ) as file:

        file.write(
            "digraph Imports {\n"
        )

        file.write(
            "rankdir=LR;\n\n"
        )

        for source in sorted(files):

            source_name = display_path(source)

            if not graph[source]:

                file.write(
                    f'"{source_name}";\n'
                )

            for target in graph[source]:

                target_name = display_path(target)

                file.write(
                    f'"{source_name}" '
                    f'-> '
                    f'"{target_name}";\n'
                )

        file.write(
            "}\n"
        )

    print(
        "=============================="
    )

    print(
        "Graphviz"
    )

    print(
        "==============================\n"
    )

    print(
        f"Wrote {DOT.relative_to(ROOT)}"
    )


# ============================================================
# Main
# ============================================================

def main():

    files = discover_typst_files()

    if not files:

        print(
            "ERROR: no Typst files found."
        )

        return 1

    (
        graph,
        reverse,
        missing,
        unreadable,
    ) = build_graph(
        files
    )

    # --------------------------------------------------------
    # Top-level files
    # --------------------------------------------------------

    roots = [
        path
        for path in files
        if not reverse[path]
    ]

    # --------------------------------------------------------
    # Dependency tree
    # --------------------------------------------------------

    print_dependency_tree(
        roots,
        graph,
    )

    # --------------------------------------------------------
    # Missing imports
    # --------------------------------------------------------

    print_missing(
        missing
    )

    # --------------------------------------------------------
    # Unreadable files
    # --------------------------------------------------------

    print_unreadable(
        unreadable
    )

    # --------------------------------------------------------
    # Cycles
    # --------------------------------------------------------

    cycles = find_cycles(
        files,
        graph,
    )

    print_cycles(
        cycles
    )

    # --------------------------------------------------------
    # Roots
    # --------------------------------------------------------

    print_roots(
        roots
    )

    # --------------------------------------------------------
    # Leaves
    # --------------------------------------------------------

    print_leaves(
        files,
        graph,
    )

    # --------------------------------------------------------
    # Graphviz
    # --------------------------------------------------------

    write_graphviz(
        files,
        graph,
    )

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    print()
    print(
        "=============================="
    )
    print(
        "Import Check"
    )
    print(
        "==============================\n"
    )

    import_count = sum(
        len(targets)
        for targets in graph.values()
    )

    print(
        f"Typst files : {len(files)}"
    )

    print(
        f"Imports     : {import_count}"
    )

    print(
        f"Missing     : {len(missing)}"
    )

    print(
        f"Unreadable  : {len(unreadable)}"
    )

    print(
        f"Cycles      : {len(cycles)}"
    )

    if missing or unreadable or cycles:

        print()
        print(
            "❌ Import check failed."
        )

        return 1

    print()
    print(
        "✅ Import check passed."
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())