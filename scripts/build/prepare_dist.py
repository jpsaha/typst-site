
prepare_dist() {

    echo "📁 Preparing dist/..."

    rm -rf "$PAGES_DIR" "$PDF_DIR" "$ASSETS_DIR"

    mkdir -p \
        "$PAGES_DIR" \
        "$PDF_DIR" \
        "$ASSETS_DIR/css" \
        "$ASSETS_DIR/js" \
        "$ASSETS_DIR/images"

    # ========================================================
    # Copy assets
    # ========================================================

    if [ -f "assets/css/style.css" ]; then

        cp \
            assets/css/style.css \
            "$ASSETS_DIR/css/style.css"

        echo "📋 Copied style.css"

    else

        echo "⚠️ Warning: assets/css/style.css not found"

    fi

    # ========================================================
    # Check generated metadata
    # ========================================================

    if [ ! -f "$HOMEPAGE_JSON" ]; then

        die "Missing $HOMEPAGE_JSON"

    fi
}
