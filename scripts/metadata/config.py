
from pathlib import Path


# ============================================================
# Project paths
# ============================================================

ROOT = Path(__file__).resolve().parent.parent.parent

CONTENT_DIR = ROOT / "content"
GENERATED_DIR = ROOT / "generated"


# ============================================================
# Generated files
# ============================================================

LECTURES_TYP = GENERATED_DIR / "lectures.typ"

PAGES_TYP = GENERATED_DIR / "pages.typ"

PAGES_META_TYP = GENERATED_DIR / "pages_meta.typ"

BOOK_TYP = GENERATED_DIR / "book.typ"

HOMEPAGE_TYP = GENERATED_DIR / "homepage.typ"

HOMEPAGE_JSON = GENERATED_DIR / "homepage.json"


# ============================================================
# Metadata
# ============================================================

LECTURE_METADATA_PATTERN = (
    r"#let\s+lecture\s*=\s*\((.*?)\)"
)
