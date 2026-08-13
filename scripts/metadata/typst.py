def typst_value(value):
    if value is None:
        return "none"

    if isinstance(value, bool):
        return "true" if value else "false"

    if isinstance(value, list):
        return "[" + ", ".join(typst_value(x) for x in value) + "]"

    if isinstance(value, str):
        return '"' + value.replace('"', '\\"') + '"'

    return str(value)


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
