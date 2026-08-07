import re

from .config import LECTURE_METADATA_PATTERN


LECTURE_BLOCK_RE = re.compile(
    LECTURE_METADATA_PATTERN,
    re.DOTALL,
)


def parse_value(value):
    """Convert a simple Typst metadata value to Python."""

    value = value.strip()

    # string
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]

    # none
    if value == "none":
        return None

    # integer
    try:
        return int(value)
    except ValueError:
        return value


def parse_lecture(text):
    """
    Extract the #let lecture = (...) metadata block.

    Returns:
        dict | None
    """

    match = LECTURE_BLOCK_RE.search(text)

    if match is None:
        return None

    body = match.group(1)

    lecture = {}

    for line in body.splitlines():

        line = line.strip()

        if not line:
            continue

        if line.endswith(","):
            line = line[:-1]

        if ":" not in line:
            continue

        key, value = line.split(":", 1)

        key = key.strip()
        value = value.strip()

        lecture[key] = parse_value(value)

    return lecture
