
print_summary() {

    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))

    PAGE_COUNT=$(
        find "$PAGES_DIR" \
            -type f \
            -name "*.html" |
        wc -l |
        tr -d ' '
    )

    PDF_COUNT=$(
        find "$PDF_DIR" \
            -type f \
            -name "*.pdf" |
        wc -l |
        tr -d ' '
    )

    CATEGORY_COUNT=$(
        find "$PDF_DIR" \
            -type f \
            -name "category_*.pdf" |
        wc -l |
        tr -d ' '
    )

    echo
    echo "=============================================="
    echo "📊 Build diagnostics summary"
    echo "=============================================="

    # ------------------------------------------------------------
    # Metadata report
    # ------------------------------------------------------------

    if [ -f "$METADATA_REPORT" ]; then

        echo
        echo "## 📋 Metadata"
        echo

        grep -E \
            '^(Total items|Lectures[[:space:]]*:|Pages[[:space:]]*:|Categories[[:space:]]*:)' \
            "$METADATA_REPORT" \
            || true

        echo "Report      : $METADATA_REPORT"

    else

        echo
        echo "## 📋 Metadata"
        echo
        echo "Metadata report not found"
    fi

    # ------------------------------------------------------------
    # Link report
    # ------------------------------------------------------------

    if [ -f "$LINK_REPORT" ]; then

        echo
        echo "## 🔗 Links"
        echo

        grep -E \
            '^(Links checked|Broken links|Working links)' \
            "$LINK_REPORT" \
            || true

        echo "Report      : $LINK_REPORT"

    else

        echo
        echo "## 🔗 Links"
        echo
        echo "Link report not found"
    fi

    # ------------------------------------------------------------
    # Build statistics
    # ------------------------------------------------------------

    echo
    echo "## 📦 Build"
    echo
    echo "🌐 HTML pages:      $PAGE_COUNT"
    echo "📚 Category books:  $CATEGORY_COUNT"
    echo "📄 PDF files:       $PDF_COUNT"
    echo "⏱ Build time:       ${BUILD_TIME}s"

    # ------------------------------------------------------------
    # Build timing
    #
    # Shows how much time was spent in each major stage.
    # ------------------------------------------------------------

    echo
    echo "## ⏱ Build timing"
    echo
    printf "Metadata generation       %6ss\n" "$TIME_METADATA"
    printf "Metadata validation       %6ss\n" "$TIME_METADATA_CHECK"
    printf "Generated validation      %6ss\n" "$TIME_GENERATED_CHECK"
    printf "Typst import validation   %6ss\n" "$TIME_IMPORT_CHECK"
    printf "HTML pages                %6ss\n" "$TIME_HTML"
    printf "Individual PDFs           %6ss\n" "$TIME_PDF"
    printf "Category PDFs             %6ss\n" "$TIME_CATEGORIES"
    printf "Book PDF                  %6ss\n" "$TIME_BOOK"
    printf "Pages PDF                 %6ss\n" "$TIME_PAGES"
    printf "Link checking             %6ss\n" "$TIME_LINKS"
    printf "Total                     %6ss\n" "$BUILD_TIME"

    # ------------------------------------------------------------
    # Compact one-line summary
    #
    # Extract the link count from the link report so that the
    # final line gives the most useful overall build statistics.
    # ------------------------------------------------------------

    LINK_COUNT=0
    BROKEN_COUNT=0

    if [ -f "$LINK_REPORT" ]; then

        LINK_COUNT=$(
            grep '^Links checked' "$LINK_REPORT" |
            awk -F: '{gsub(/[[:space:]]/, "", $2); print $2}'
        )

        BROKEN_COUNT=$(
            grep '^Broken links' "$LINK_REPORT" |
            awk -F: '{gsub(/[[:space:]]/, "", $2); print $2}'
        )

        LINK_COUNT=${LINK_COUNT:-0}
        BROKEN_COUNT=${BROKEN_COUNT:-0}
    fi

    echo
    echo "$PAGE_COUNT HTML · $PDF_COUNT PDFs · $CATEGORY_COUNT categories · $LINK_COUNT links · $BROKEN_COUNT broken"

    # ------------------------------------------------------------
    # Final status
    # ------------------------------------------------------------

    echo
    echo "=============================================="
    echo "✅ Build completed successfully in ${BUILD_TIME}s"
    echo "=============================================="
}
