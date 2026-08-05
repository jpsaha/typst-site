#!/bin/bash
set -e

# Initialize output folder
mkdir -p dist
export TYPST_FEATURES=html

echo "🚀 Starting automated build..."

# FIX: Copy the tracked CSS asset into the gitignored output directory dynamically
if [ -f "src/style.css" ]; then
    cp src/style.css dist/style.css
    echo "📋 Synced style.css to dist/"
else
    echo "⚠️ Warning: src/style.css not found"
fi

# Part 1: Gather lecture metadata dynamically
LECTURES_JSON="["

# Find all lecture files sorted numerically (lec1, lec2, lec10, etc.)
FILES=$(ls src/lec*.typ 2>/dev/null | sort -V)

if [ -z "$FILES" ]; then
    echo "❌ No lecture files found matching src/lec*.typ"
    exit 1
fi

FIRST=true
for file in $FILES; do
    filename=$(basename "$file" .typ)
    
    # Extract the main title from the file
    title=$(grep -oP '(?<=\)\[)Lecture.*(?=\])' "$file" | head -n 1)
    if [ -z "$title" ]; then
        title=$(grep -oP '(?<="bold")\[Lecture.*(?=\])' "$file" | head -n 1)
    fi
    if [ -z "$title" ]; then
        title="Lecture ${filename#lec}"
    fi

    echo "Processing module: $title ($filename)"
    
    # Compile Web HTML version
    typst compile "$file" "dist/${filename}.html" --input format=html
    # Compile Print PDF version
    typst compile "$file" "dist/${filename}.pdf" --input format=pdf

    # Append metadata to a temporary JSON block for the index dashboard
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        LECTURES_JSON+=", "
    fi
    LECTURES_JSON+="{\"filename\": \"$filename\", \"title\": \"$title\"}"
done
LECTURES_JSON+="]"

# ==========================================
# NEW: Part 2: Generate the index.html with Pagefind Search Hooks
# ==========================================
cat <<EOF > dist/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mathematics Lecture Series</title>
    <link rel="stylesheet" href="style.css">
    
    <!-- Load Pagefind styling and scripting modules dynamically -->
    <link href="/_pagefind/pagefind-ui.css" rel="stylesheet">
    <script src="/_pagefind/pagefind-ui.js"></script>
</head>
<body>
    <div class="index-container">
        <header class="index-header">
            <h1>🧮 Mathematics Lecture Series</h1>
            <p>Course Materials & Practice Sets</p>
        </header>
        
        <!-- Target location container for Pagefind UI Search Input Box -->
        <div id="search-container" style="margin: 30px 0; min-height: 50px;"></div>
        
        <h2>Course Modules</h2>
        <div class="lecture-list" id="lecture-root"></div>
    </div>

    <script>
        // Injecting generated lecture metadata safely
        const lectures = ${LECTURES_JSON};
        const root = document.getElementById('lecture-root');
        
        lectures.forEach(lec => {
            const row = document.createElement('div');
            row.className = 'lecture-row';
            row.innerHTML = \`
                <span>\${lec.title}</span>
                <div class="lecture-links">
                    <a href="\${lec.filename}.html" class="btn btn-web">🌐 View Web</a>
                    <a href="\${lec.filename}.pdf" class="btn btn-pdf" download>📄 Download PDF</a>
                </div>
            \`;
            root.appendChild(row);
        });

        // Initialize the Interactive Pagefind UI search box component 
        window.addEventListener('DOMContentLoaded', (event) => {
            new PagefindUI({ 
                element: "#search-container", 
                showSubResults: true,
                resetFilters: true
            });
        });
    </script>
</body>
</html>
EOF

# ==========================================
# NEW: Part 3: Execute Pagefind Indexing Engine over the dist output
# ==========================================
echo "🔍 Running Pagefind layout content analyzer..."
npx pagefind --site dist

echo "🎉 Build complete! Site and index created successfully."
