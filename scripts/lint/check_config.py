#!/usr/bin/env python3

"""
Audit project configuration usage.

This script checks Python files under scripts/ for configuration-like
values that may have been defined locally instead of being centralized
in scripts/config.py.

The script does NOT modify any files.

Report:
    diagnostics/config_report.txt

Checks:
    1. Constants defined in scripts/config.py.
    2. Uppercase constants defined outside config.py.
    3. Path(...) constructions outside config.py.
    4. ROOT / ... path constructions.
    5. Hard-coded project directory names.
    6. Hard-coded project/site-specific strings.
    7. Configuration-like numeric constants.
    8. Imports from scripts.config.
    9. Local redefinitions of names imported from config.py.

This is an audit tool, not a strict linter. Some findings are
legitimate local implementation details and should simply be reviewed.
"""

from pathlib import Path
import ast
import re


# ============================================================
# Project paths
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

SCRIPTS_DIR = ROOT / "scripts"
CONFIG_FILE = SCRIPTS_DIR / "config.py"

DIAGNOSTICS_DIR = ROOT / "diagnostics"
REPORT_FILE = DIAGNOSTICS_DIR / "config_report.txt"


# ============================================================
# Configuration-like patterns
# ============================================================

PROJECT_DIRECTORIES = {
    "content",
    "templates",
    "generated",
    "diagnostics",
    "dist",
    "assets",
    "pages",
    "pdf",
    "scripts",
}

PROJECT_STRINGS = {
    "jpsaha",
    "typst-site",
    "github.io",
}

CONFIG_LIKE_NUMBERS = {
    1200,
    630,
    300,
}


# ============================================================
# Utilities
# ============================================================

def relative(path):
    """Return a project-relative path."""

    try:
        return path.relative_to(ROOT)
    except ValueError:
        return path


def source_line(source, lineno):
    """Return a source line, if available."""

    lines = source.splitlines()

    if 1 <= lineno <= len(lines):
        return lines[lineno - 1].strip()

    return ""


def add_finding(findings, category, path, lineno, text):
    """Add one finding to the report."""

    findings[category].append(
        (
            str(relative(path)),
            lineno,
            text,
        )
    )


# ============================================================
# AST helpers
# ============================================================

def imported_config_names(tree):
    """
    Return names imported from scripts.config.

    Handles:

        from scripts.config import ROOT
        from scripts.config import ROOT, DIST_DIR
        from scripts.config import ROOT as PROJECT_ROOT
    """

    names = {}

    for node in ast.walk(tree):

        if not isinstance(node, ast.ImportFrom):
            continue

        if node.module != "scripts.config":
            continue

        for alias in node.names:

            if alias.name == "*":
                continue

            local_name = alias.asname or alias.name

            names[local_name] = alias.name

    return names


def assigned_names(tree):
    """
    Return names assigned anywhere in the module.
    """

    names = set()

    for node in ast.walk(tree):

        if isinstance(node, ast.Name):
            if isinstance(node.ctx, ast.Store):
                names.add(node.id)

        elif isinstance(node, ast.arg):
            names.add(node.arg)

    return names


def uppercase_assignments(tree):
    """
    Return uppercase module-level configuration-like assignments.
    """

    results = []

    for node in tree.body:

        targets = []

        if isinstance(node, ast.Assign):
            targets = node.targets

        elif isinstance(node, ast.AnnAssign):
            targets = [node.target]

        for target in targets:

            if not isinstance(target, ast.Name):
                continue

            name = target.id

            if re.fullmatch(
                r"[A-Z][A-Z0-9_]*",
                name,
            ):
                results.append(
                    (
                        name,
                        target.lineno,
                    )
                )

    return results


# ============================================================
# Main audit
# ============================================================

def main():

    if not CONFIG_FILE.exists():
        raise FileNotFoundError(
            f"Configuration file not found: {CONFIG_FILE}"
        )

    DIAGNOSTICS_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    python_files = sorted(
        SCRIPTS_DIR.rglob("*.py")
    )

    # --------------------------------------------------------
    # Report sections
    # --------------------------------------------------------

    findings = {
        "local_constants": [],
        "local_paths": [],
        "root_paths": [],
        "project_directories": [],
        "project_strings": [],
        "config_numbers": [],
        "config_imports": [],
        "redefinitions": [],
    }

    config_constants = set()

    # --------------------------------------------------------
    # Parse config.py
    # --------------------------------------------------------

    config_source = CONFIG_FILE.read_text(
        encoding="utf-8"
    )

    config_tree = ast.parse(
        config_source,
        filename=str(CONFIG_FILE),
    )

    for name, lineno in uppercase_assignments(
        config_tree
    ):
        config_constants.add(name)

    # --------------------------------------------------------
    # Audit every Python script
    # --------------------------------------------------------

    for path in python_files:

        source = path.read_text(
            encoding="utf-8"
        )

        try:
            tree = ast.parse(
                source,
                filename=str(path),
            )

        except SyntaxError as exc:

            print(
                f"⚠️  Could not parse {relative(path)}: "
                f"{exc}"
            )

            continue

        # ====================================================
        # Skip config.py for duplicate-definition checks
        # ====================================================

        if path != CONFIG_FILE:

            # ------------------------------------------------
            # 1. Uppercase constants
            # ------------------------------------------------

            for name, lineno in uppercase_assignments(
                tree
            ):

                add_finding(
                    findings,
                    "local_constants",
                    path,
                    lineno,
                    name,
                )

            # ------------------------------------------------
            # 2. Imported config names
            # ------------------------------------------------

            imported = imported_config_names(tree)

            for local_name, config_name in imported.items():

                findings["config_imports"].append(
                    (
                        str(relative(path)),
                        0,
                        f"{local_name} ← config.{config_name}",
                    )
                )

            # ------------------------------------------------
            # 3. Local redefinitions
            # ------------------------------------------------

            assignments = assigned_names(tree)

            for local_name, config_name in imported.items():

                if local_name in assignments:

                    # Ignore the import itself. We only want
                    # actual subsequent/local assignments.
                    for node in ast.walk(tree):

                        if isinstance(node, ast.Name):

                            if (
                                node.id == local_name
                                and isinstance(
                                    node.ctx,
                                    ast.Store,
                                )
                            ):

                                findings["redefinitions"].append(
                                    (
                                        str(relative(path)),
                                        node.lineno,
                                        (
                                            f"{local_name} "
                                            f"(imported from config "
                                            f"as {config_name})"
                                        ),
                                    )
                                )

        # ====================================================
        # AST/path checks
        # ====================================================

        for node in ast.walk(tree):

            # ------------------------------------------------
            # 4. Path(...)
            # ------------------------------------------------

            if (
                isinstance(node, ast.Call)
                and isinstance(node.func, ast.Name)
                and node.func.id == "Path"
            ):

                add_finding(
                    findings,
                    "local_paths",
                    path,
                    node.lineno,
                    source_line(source, node.lineno),
                )

            # ------------------------------------------------
            # 5. ROOT / ...
            # ------------------------------------------------

            if (
                isinstance(node, ast.BinOp)
                and isinstance(node.op, ast.Div)
            ):

                text = source_line(
                    source,
                    node.lineno,
                )

                if "ROOT" in text:

                    add_finding(
                        findings,
                        "root_paths",
                        path,
                        node.lineno,
                        text,
                    )

            # ------------------------------------------------
            # 6. Numeric constants
            # ------------------------------------------------

            if isinstance(node, ast.Constant):

                if (
                    isinstance(node.value, int)
                    and node.value in CONFIG_LIKE_NUMBERS
                ):

                    add_finding(
                        findings,
                        "config_numbers",
                        path,
                        node.lineno,
                        str(node.value),
                    )

    # ========================================================
    # Text-based checks
    # ========================================================

    for path in python_files:

        if path == CONFIG_FILE:
            continue

        source = path.read_text(
            encoding="utf-8"
        )

        lines = source.splitlines()

        for lineno, line in enumerate(
            lines,
            start=1,
        ):

            # ------------------------------------------------
            # 7. Project directory names
            # ------------------------------------------------

            for directory in PROJECT_DIRECTORIES:

                pattern = (
                    rf'["\']{re.escape(directory)}'
                    rf'(?:/|["\'])'
                )

                if re.search(
                    pattern,
                    line,
                ):

                    add_finding(
                        findings,
                        "project_directories",
                        path,
                        lineno,
                        line.strip(),
                    )

                    break

            # ------------------------------------------------
            # 8. Project-specific strings
            # ------------------------------------------------

            for value in PROJECT_STRINGS:

                if value in line:

                    add_finding(
                        findings,
                        "project_strings",
                        path,
                        lineno,
                        line.strip(),
                    )

                    break

    # ========================================================
    # Remove obvious false positives
    # ========================================================

    for category in findings:

        findings[category] = sorted(
            set(findings[category]),
            key=lambda item: (
                item[0],
                item[1],
                item[2],
            ),
        )

    # ========================================================
    # Build report
    # ========================================================

    lines = []

    lines.append(
        "=" * 70
    )
    lines.append(
        "Configuration Audit Report"
    )
    lines.append(
        "=" * 70
    )
    lines.append("")
    lines.append(
        f"Project root : {ROOT}"
    )
    lines.append(
        f"Config file  : {relative(CONFIG_FILE)}"
    )
    lines.append(
        f"Python files : {len(python_files)}"
    )
    lines.append("")

    # --------------------------------------------------------
    # Central configuration
    # --------------------------------------------------------

    lines.append(
        "CENTRAL CONFIGURATION"
    )
    lines.append(
        "-" * 70
    )

    for name in sorted(config_constants):
        lines.append(
            f"  {name}"
        )

    lines.append(
        f"\nTotal: {len(config_constants)}"
    )
    lines.append("")

    # --------------------------------------------------------
    # Local constants
    # --------------------------------------------------------

    lines.append(
        "1. UPPERCASE CONSTANTS DEFINED OUTSIDE config.py"
    )
    lines.append(
        "-" * 70
    )

    if findings["local_constants"]:

        for path, lineno, text in findings[
            "local_constants"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Local paths
    # --------------------------------------------------------

    lines.append(
        "2. Path(...) CONSTRUCTIONS OUTSIDE config.py"
    )
    lines.append(
        "-" * 70
    )

    if findings["local_paths"]:

        for path, lineno, text in findings[
            "local_paths"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # ROOT path constructions
    # --------------------------------------------------------

    lines.append(
        "3. ROOT / ... PATH CONSTRUCTIONS"
    )
    lines.append(
        "-" * 70
    )

    if findings["root_paths"]:

        for path, lineno, text in findings[
            "root_paths"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Project directories
    # --------------------------------------------------------

    lines.append(
        "4. HARDCODED PROJECT DIRECTORY NAMES"
    )
    lines.append(
        "-" * 70
    )

    if findings["project_directories"]:

        for path, lineno, text in findings[
            "project_directories"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Project strings
    # --------------------------------------------------------

    lines.append(
        "5. HARDCODED PROJECT / WEBSITE STRINGS"
    )
    lines.append(
        "-" * 70
    )

    if findings["project_strings"]:

        for path, lineno, text in findings[
            "project_strings"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Numeric configuration
    # --------------------------------------------------------

    lines.append(
        "6. CONFIGURATION-LIKE NUMERIC VALUES"
    )
    lines.append(
        "-" * 70
    )

    if findings["config_numbers"]:

        for path, lineno, text in findings[
            "config_numbers"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Config imports
    # --------------------------------------------------------

    lines.append(
        "7. IMPORTS FROM scripts.config"
    )
    lines.append(
        "-" * 70
    )

    if findings["config_imports"]:

        for path, lineno, text in findings[
            "config_imports"
        ]:

            lines.append(
                f"  {path}: {text}"
            )

    else:
        lines.append(
            "  ⚠️  No config imports found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Redefinitions
    # --------------------------------------------------------

    lines.append(
        "8. NAMES IMPORTED FROM config.py AND REDEFINED"
    )
    lines.append(
        "-" * 70
    )

    if findings["redefinitions"]:

        for path, lineno, text in findings[
            "redefinitions"
        ]:

            lines.append(
                f"  {path}:{lineno}: {text}"
            )

    else:
        lines.append(
            "  ✓ None found."
        )

    lines.append("")

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    lines.append(
        "SUMMARY"
    )
    lines.append(
        "-" * 70
    )

    lines.append(
        f"Config constants              : "
        f"{len(config_constants)}"
    )

    lines.append(
        f"Local uppercase constants     : "
        f"{len(findings['local_constants'])}"
    )

    lines.append(
        f"Local Path(...) constructions  : "
        f"{len(findings['local_paths'])}"
    )

    lines.append(
        f"ROOT / ... constructions       : "
        f"{len(findings['root_paths'])}"
    )

    lines.append(
        f"Hardcoded directories          : "
        f"{len(findings['project_directories'])}"
    )

    lines.append(
        f"Hardcoded project strings      : "
        f"{len(findings['project_strings'])}"
    )

    lines.append(
        f"Configuration-like numbers     : "
        f"{len(findings['config_numbers'])}"
    )

    lines.append(
        f"Config imports                 : "
        f"{len(findings['config_imports'])}"
    )

    lines.append(
        f"Config-name redefinitions      : "
        f"{len(findings['redefinitions'])}"
    )

    lines.append("")
    lines.append(
        "NOTE: Findings are candidates for review, not "
        "automatic errors."
    )
    lines.append(
        "Local implementation details may legitimately "
        "remain outside config.py."
    )

    report = "\n".join(lines) + "\n"

    # ========================================================
    # Write report
    # ========================================================

    REPORT_FILE.write_text(
        report,
        encoding="utf-8",
    )

    # ========================================================
    # Print report
    # ========================================================

    print(report)

    print(
        f"📄 Report written to "
        f"{relative(REPORT_FILE)}"
    )


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":
    main()