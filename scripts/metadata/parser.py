#!/usr/bin/env python3

"""
Parse lecture metadata from Typst source files.

Expected format:

    #let lecture = (
      file: "lec1",
      type: "lecture",
      number: 1,
      title: "Polynomial rings",
      category: "Fields and Galois theory",
      tags: ("linear-map", "matrices"),
    )

The parser supports:

    strings
    integers
    none
    booleans
    tuples
    nested tuples

The outer `#let lecture = (...)` record is extracted by matching
balanced parentheses rather than by using a regular expression.
"""

import re


# ============================================================
# Lecture declaration
# ============================================================

LECTURE_START_RE = re.compile(
    r"#let\s+lecture\s*=\s*\("
)


# ============================================================
# Value parsing
# ============================================================

def parse_value(value):
    """
    Convert a simple Typst metadata value to Python.

    Supported values include:

        "text"
        123
        none
        true
        false
        ("one", "two")

    Nested tuples are supported recursively.
    """

    value = value.strip()

    # --------------------------------------------------------
    # none
    # --------------------------------------------------------

    if value == "none":
        return None

    # --------------------------------------------------------
    # boolean
    # --------------------------------------------------------

    if value == "true":
        return True

    if value == "false":
        return False

    # --------------------------------------------------------
    # string
    # --------------------------------------------------------

    if (
        len(value) >= 2
        and value.startswith('"')
        and value.endswith('"')
    ):
        return value[1:-1]

    # --------------------------------------------------------
    # tuple
    # --------------------------------------------------------

    if (
        len(value) >= 2
        and value.startswith("(")
        and value.endswith(")")
    ):
        return parse_tuple(value)

    # --------------------------------------------------------
    # integer
    # --------------------------------------------------------

    try:
        return int(value)
    except ValueError:
        pass

    # --------------------------------------------------------
    # Fallback
    # --------------------------------------------------------

    return value


# ============================================================
# Tuple parsing
# ============================================================

def split_top_level(value):
    """
    Split a comma-separated Typst value at top level.

    For example:

        ("linear-map", "matrices")

    becomes:

        [
            '"linear-map"',
            '"matrices"',
        ]

    Nested parentheses and quoted strings are respected.
    """

    parts = []

    current = []

    depth = 0
    in_string = False
    escaped = False

    for char in value:

        # ----------------------------------------------------
        # Inside a string
        # ----------------------------------------------------

        if in_string:

            current.append(char)

            if escaped:
                escaped = False

            elif char == "\\":
                escaped = True

            elif char == '"':
                in_string = False

            continue

        # ----------------------------------------------------
        # Start string
        # ----------------------------------------------------

        if char == '"':
            in_string = True
            current.append(char)
            continue

        # ----------------------------------------------------
        # Nested parentheses
        # ----------------------------------------------------

        if char == "(":
            depth += 1
            current.append(char)
            continue

        if char == ")":
            depth -= 1
            current.append(char)
            continue

        # ----------------------------------------------------
        # Top-level comma
        # ----------------------------------------------------

        if char == "," and depth == 0:

            item = "".join(current).strip()

            if item:
                parts.append(item)

            current = []

            continue

        # ----------------------------------------------------
        # Normal character
        # ----------------------------------------------------

        current.append(char)

    # --------------------------------------------------------
    # Final item
    # --------------------------------------------------------

    item = "".join(current).strip()

    if item:
        parts.append(item)

    return parts


def parse_tuple(value):
    """
    Parse a Typst tuple recursively.

    Example:

        ("linear-map", "matrices")

    becomes:

        [
            "linear-map",
            "matrices",
        ]
    """

    inner = value.strip()[1:-1].strip()

    if not inner:
        return []

    parts = split_top_level(inner)

    return [
        parse_value(part)
        for part in parts
    ]


# ============================================================
# Lecture block extraction
# ============================================================

def extract_lecture_body(text):
    """
    Extract the contents of:

        #let lecture = (
            ...
        )

    while correctly handling nested parentheses.

    Returns:
        str | None
    """

    match = LECTURE_START_RE.search(text)

    if match is None:
        return None

    # --------------------------------------------------------
    # The regex already consumed the opening '('.
    # --------------------------------------------------------

    start = match.end()

    depth = 1

    in_string = False
    escaped = False

    for index in range(start, len(text)):

        char = text[index]

        # ----------------------------------------------------
        # Inside quoted string
        # ----------------------------------------------------

        if in_string:

            if escaped:
                escaped = False

            elif char == "\\":
                escaped = True

            elif char == '"':
                in_string = False

            continue

        # ----------------------------------------------------
        # Start quoted string
        # ----------------------------------------------------

        if char == '"':
            in_string = True
            continue

        # ----------------------------------------------------
        # Parentheses
        # ----------------------------------------------------

        if char == "(":
            depth += 1

        elif char == ")":

            depth -= 1

            # ------------------------------------------------
            # This is the closing parenthesis of the outer
            # lecture record.
            # ------------------------------------------------

            if depth == 0:
                return text[start:index]

    # --------------------------------------------------------
    # Unbalanced metadata block
    # --------------------------------------------------------

    return None


# ============================================================
# Lecture parser
# ============================================================

def parse_lecture(text):
    """
    Extract and parse the:

        #let lecture = (...)

    metadata block.

    Returns:

        dict
            Parsed lecture metadata.

        None
            If no lecture metadata block is found.
    """

    body = extract_lecture_body(text)

    if body is None:
        return None

    lecture = {}

    # --------------------------------------------------------
    # Parse fields.
    #
    # We split on lines because the project's metadata format
    # uses one field per line.
    # --------------------------------------------------------

    for line in body.splitlines():

        line = line.strip()

        # ----------------------------------------------------
        # Empty line
        # ----------------------------------------------------

        if not line:
            continue

        # ----------------------------------------------------
        # Remove trailing comma
        # ----------------------------------------------------

        if line.endswith(","):
            line = line[:-1].rstrip()

        # ----------------------------------------------------
        # Ignore malformed lines
        # ----------------------------------------------------

        if ":" not in line:
            continue

        # ----------------------------------------------------
        # Split only at the first colon.
        # ----------------------------------------------------

        key, value = line.split(":", 1)

        key = key.strip()
        value = value.strip()

        if not key:
            continue

        # ----------------------------------------------------
        # Parse value
        # ----------------------------------------------------

        lecture[key] = parse_value(value)

    return lecture