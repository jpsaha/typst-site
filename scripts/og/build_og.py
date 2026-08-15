import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

SOURCE_DIR = ROOT / "assets" / "og" / "src"
OUTPUT_DIR = ROOT / "assets" / "og"


def build():

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    sources = sorted(
        SOURCE_DIR.glob("*.asy")
    )

    for source in sources:

        name = source.stem

        pdf = OUTPUT_DIR / f"{name}.pdf"
        png = OUTPUT_DIR / f"{name}.png"

        # ----------------------------------------------------
        # Asymptote → PDF
        # ----------------------------------------------------

        subprocess.run(
            [
                "asy",
                "-f",
                "pdf",
                "-o",
                str(OUTPUT_DIR / name),
                str(source),
            ],
            check=True,
        )

        # ----------------------------------------------------
        # PDF → PNG
        # ----------------------------------------------------

        subprocess.run(
            [
                "magick",
                "-density",
                "300",
                str(pdf),
                "-resize",
                "1200x630!",
                "-filter",
                "Lanczos",
                str(png),
            ],
            check=True,
        )

        # ----------------------------------------------------
        # Remove intermediate PDF
        # ----------------------------------------------------

        if pdf.exists():
            pdf.unlink()

        print(
            f"🖼️ Generated "
            f"{png.relative_to(ROOT)}"
        )


if __name__ == "__main__":
    build()