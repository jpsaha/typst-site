def typst_value(value):
    """Convert a Python value to a Typst value."""

    if value is None:
        return "none"

    if isinstance(value, bool):
        return "true" if value else "false"

    if isinstance(value, int):
        return str(value)

    # --------------------------------------------------------
    # Lists / tuples
    #
    # Python:
    #
    #     ("linear-map", "matrices")
    #
    # becomes:
    #
    #     ("linear-map", "matrices")
    # --------------------------------------------------------

    if isinstance(value, (list, tuple)):
        items = ", ".join(
            typst_value(item)
            for item in value
        )

        return f"({items})"

    # --------------------------------------------------------
    # Strings
    # --------------------------------------------------------

    if isinstance(value, str):
        # Escape backslashes and quotation marks.
        escaped = (
            value
            .replace("\\", "\\\\")
            .replace('"', '\\"')
        )

        return f'"{escaped}"'

    # --------------------------------------------------------
    # Fallback
    # --------------------------------------------------------

    return f'"{value}"'


def write_field(file, key, value, indent=4):
    """Write one field of a Typst record."""

    spaces = " " * indent

    file.write(
        f"{spaces}{key}: "
        f"{typst_value(value)},\n"
    )


def write_header(file):
    """Write the standard generated-file header."""

    file.write(
        "// AUTO-GENERATED. DO NOT EDIT.\n\n"
    )