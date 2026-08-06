#!/usr/bin/env python3

"""
Analyze Typst import dependencies.

Usage:
    python3 scripts/check_imports.py
"""

from pathlib import Path
import re
from collections import defaultdict

ROOT = Path(__file__).resolve().parent.parent

IMPORT_RE = re.compile(r'#import\s+"([^"]+)"')

graph = defaultdict(list)
reverse = defaultdict(list)
all_files = set()


# ------------------------------------------------------------
# Read all Typst files
# ------------------------------------------------------------

for path in sorted(ROOT.rglob("*.typ")):

    path = path.resolve()
    all_files.add(path)

    text = path.read_text(encoding="utf-8")

    for m in IMPORT_RE.finditer(text):

        target = (path.parent / m.group(1)).resolve()

        graph[path].append(target)
        reverse[target].append(path)


# ------------------------------------------------------------
# Print dependency tree
# ------------------------------------------------------------

print("\n==============================")
print("Dependency Tree")
print("==============================\n")


def tree(node, prefix="", seen=None):

    if seen is None:
        seen = set()

    print(prefix + node.relative_to(ROOT).as_posix())

    if node in seen:
        print(prefix + "  ↺")
        return

    seen = seen | {node}

    for child in graph[node]:
        tree(child, prefix + "    ", seen)


roots = [
    f for f in all_files
    if len(reverse[f]) == 0
]

for r in sorted(roots):
    tree(r)
    print()


# ------------------------------------------------------------
# Detect cycles
# ------------------------------------------------------------

print("==============================")
print("Cycle Detection")
print("==============================\n")

visited = set()
stack = []
found = False


def dfs(node):

    global found

    if node in stack:
        found = True

        i = stack.index(node)

        cycle = stack[i:] + [node]

        print("Circular import:")

        for p in cycle:
            print("   ", p.relative_to(ROOT))

        print()
        return

    if node in visited:
        return

    visited.add(node)
    stack.append(node)

    for child in graph[node]:
        dfs(child)

    stack.pop()


for node in all_files:
    dfs(node)

if not found:
    print("No circular imports.\n")


# ------------------------------------------------------------
# Files never imported
# ------------------------------------------------------------

print("==============================")
print("Top-level files")
print("==============================\n")

for f in sorted(roots):
    print(f.relative_to(ROOT))

print()


# ------------------------------------------------------------
# Leaves
# ------------------------------------------------------------

print("==============================")
print("Leaf modules")
print("==============================\n")

for f in sorted(all_files):

    if len(graph[f]) == 0:
        print(f.relative_to(ROOT))

print()


# ------------------------------------------------------------
# Generate Graphviz
# ------------------------------------------------------------

dot = ROOT / "imports.dot"

with dot.open("w") as f:

    f.write("digraph Imports {\n")
    f.write("rankdir=LR;\n\n")

    for src in sorted(all_files):

        if len(graph[src]) == 0:
            f.write(f'"{src.relative_to(ROOT)}";\n')

        for dst in graph[src]:
            f.write(
                f'"{src.relative_to(ROOT)}" -> "{dst.relative_to(ROOT)}";\n'
            )

    f.write("}\n")


print("==============================")
print("Graphviz")
print("==============================\n")

print(f"Wrote {dot.relative_to(ROOT)}")