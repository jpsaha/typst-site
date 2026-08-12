
from pathlib import Path
import re
import sys


# ============================================================
# Project root
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

# Allow imports such as:
#
#     from scripts.metadata.config import ...
#
# when this file is executed directly with:
#
#     python3 scripts/lint/check_generated.py

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


# ============================================================
# Metadata pipeline
# ============================================================

from scripts.metadata.config import (
    CONTENT_DIR,
    GENERATED_DIR,
)

from scripts.metadata.parser import (
    parse_lecture,
)


# ============================================================
# Paths
# ============================================================

# ============================================================
# Generated files
# ============================================================

LECTURES_TYP = GENERATED_DIR / "lectures.typ"

PAGES_TYP = GENERATED_DIR / "pages.typ"

PAGES_META_TYP = GENERATED_DIR / "pages_meta.typ"

# ============================================================
# Generated-file patterns
# ============================================================

FILE_FIELD_RE = re.compile(
    r'\bfile:\s*"([^"]+)"'
)

CONTENT_INCLUDE_RE = re.compile(
    r'#include\s+"\.\./content/([^"]+)"'
)
