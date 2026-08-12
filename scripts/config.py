from pathlib import Path

# ============================================================
# Project root
# ============================================================

ROOT = Path(__file__).resolve().parents[1]


# ============================================================
# Project directories
# ============================================================

CONTENT_DIR = ROOT / "content"
TEMPLATES_DIR = ROOT / "templates"
GENERATED_DIR = ROOT / "generated"
DIAGNOSTICS_DIR = ROOT / "diagnostics"


# ============================================================
# Project files
# ============================================================

BOOK_SOURCE = ROOT / "book_source.typ"
PAGES_SOURCE = ROOT / "pages_source.typ"
PDFLAYOUT = ROOT / "pdflayout.typ"

DOT = DIAGNOSTICS_DIR / "imports.dot"

# ============================================================
# Generated files
# ============================================================

LECTURES_TYP = GENERATED_DIR / "lectures.typ"

PAGES_TYP = GENERATED_DIR / "pages.typ"

PAGES_META_TYP = GENERATED_DIR / "pages_meta.typ"
