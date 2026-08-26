// ============================================================
// assets/promo/hero_banner.asy
//
// Promotional / Hero Feature Banner Layout
// Dimensions: 1200 × 600
//
// Compile Command: asy -f png -r 1200 hero_banner.asy
// ============================================================

import graph;
import fontsize;

// Fix for complex LaTeX rendering
usersetting();
texpreamble("\usepackage{amsmath}");

size(1200, 600);
real W = 1200;
real H = 600;

// ------------------------------------------------------------
// Color Palette
// ------------------------------------------------------------
pen bgMain       = rgb("#FFFFFF");
pen topBarBlue   = rgb("#0284C7"); // Top accent header line

// Left Column Colors
pen badgeBgGreen = rgb("#E6F7F0"); 
pen badgeTxtGreen= rgb("#0D9488");
pen textTitle    = rgb("#0F172A");
pen textSub      = rgb("#64748B");
pen btnBgBlue    = rgb("#3B82F6");

// Right Card Mockup Colors
pen cardBg       = rgb("#FDFCF7");
pen cardCream    = rgb("#F8F6EE");
pen cardDarkGreen= rgb("#174D35");
pen cardGreen    = rgb("#2E7D32");
pen cardFaint    = rgb("#E2E8F0");

// Background Decorative Circles
pen circleTeal   = rgb("#E6F4EA");
pen circleBlue   = rgb("#DBEAFE");

// ------------------------------------------------------------
// Helper: Rounded Box Path
// ------------------------------------------------------------
path roundedBox(pair A, pair B, real r) {
    real x1 = min(A.x, B.x), x2 = max(A.x, B.x);
    real y1 = min(A.y, B.y), y2 = max(A.y, B.y);
    return (x1+r, y1) -- (x2-r, y1) .. arc((x2-r, y1+r), r, -90, 0) -- 
           (x2, y2-r) .. arc((x2-r, y2-r), r, 0, 90) -- (x1+r, y2) .. 
           arc((x1+r, y2-r), r, 90, 180) -- (x1, y1+r) .. 
           arc((x1+r, y1+r), r, 180, 270) -- cycle;
}

// ------------------------------------------------------------
// Base Canvas Backdrop
// ------------------------------------------------------------
fill(box((0,0), (W,H)), bgMain);

// Top colored accent strip
fill(box((0, H-12), (W, H)), topBarBlue);

// ------------------------------------------------------------
// Decorative Background Graphic Blobs (Right Side)
// ------------------------------------------------------------
fill(circle((700, 380), 120), circleTeal);
fill(circle((920, 120), 110), circleBlue);

// ============================================================
// LEFT SIDE CONTENT COLUMN
// ============================================================

// 1. Top Category Badge
path greenBadge = roundedBox((70, 420), (390, 462), 14);
fill(greenBadge, badgeBgGreen);
label("Mathematics Olympiad", (230, 441), badgeTxtGreen + Helvetica("b") + fontsize(20));

// 2. Main Title Text 
label("Lectures Notes", (70, 340), E, textTitle + Helvetica("b") + fontsize(54));

// 3. Informative Subtitle Description 
label("Mathematics lectures, notes, and", (70, 255), E, textSub + Helvetica() + fontsize(24));
label("problem-solving resources.", (70, 215), E, textSub + Helvetica() + fontsize(24));

// 4. Bottom Target Exam Tags Badge
path blueBadge = roundedBox((70, 115), (350, 165), 8);
fill(blueBadge, btnBgBlue);
label("IOQM $\bullet$ RMO $\bullet$ INMO", (210, 140), white + Helvetica("b") + fontsize(18));


// ============================================================
// RIGHT SIDE: MATH CARD GRAPHIC MOCKUP
// ============================================================
// Base frame positioning anchors for the inner card canvas
pair cMin = (560, 140);
pair cMax = (1130, 490);
real cW = cMax.x - cMin.x;
real cH = cMax.y - cMin.y;

// Drop shadow mockup layer
fill(shift(4, -6) * roundedBox(cMin, cMax, 16), rgb("#E2E8F0"));

// Main mockup card body
fill(roundedBox(cMin, cMax, 16), cardBg);
draw(roundedBox(cMin, cMax, 16), cardDarkGreen + linewidth(1.5));

// Inner colored frame/container layout
fill(roundedBox(cMin + (8,8), (cMax.x - 8, cMax.y - 45), 12), cardCream);

// Miniature inner graphics & layouts
pair innerCenter = (cMin.x + cW/2, cMin.y + cH/2);

// Center Badge Icon
fill(circle((innerCenter.x, cMax.y - 95), 18), cardDarkGreen);
label("$\pi$", (innerCenter.x, cMax.y - 95), white + fontsize(14));

// Mock Title text lines inside card mockup
label("MATHEMATICS", (innerCenter.x, cMax.y - 145), cardDarkGreen + Palatino("b") + fontsize(26));
label("LECTURES", (innerCenter.x, cMax.y - 180), cardDarkGreen + Palatino("b") + fontsize(26));

// Text separator rule
draw((innerCenter.x - 70, cMax.y - 202)--(innerCenter.x + 70, cMax.y - 202), cardGreen + linewidth(0.6));
label("Notes $\bullet$ Problems $\bullet$ Resources", (innerCenter.x, cMax.y - 218), textTitle + fontsize(10));

// Tiny low-profile sub-badge inside card
path miniBadge = box((innerCenter.x - 90, cMax.y - 262), (innerCenter.x + 90, cMax.y - 242));
fill(miniBadge, rgb("#E8EBDD"));
draw(miniBadge, rgb("#C5CBB7") + linewidth(0.5));
label("ALGEBRA $\bullet$ NUMBER THEORY", (innerCenter.x, cMax.y - 253), cardDarkGreen + Palatino("b") + fontsize(8));

// Subtle geometric wireframe outlines on background card corners
draw(circle((cMin.x + 60, cMin.y + 110), 30), cardFaint + linewidth(0.8));
draw((cMin.x + 30, cMin.y + 110)--(cMin.x + 90, cMin.y + 110), cardFaint + linewidth(0.6));
draw((cMin.x + 60, cMin.y + 80)--(cMin.x + 60, cMin.y + 140), cardFaint + linewidth(0.6));

draw(circle((cMax.x - 50, cMin.y + 90), 22), cardFaint + linewidth(0.8));
path innerLat = ellipse((cMax.x - 50, cMin.y + 90), 22, 7); // FIXED: Data type declared as path
draw(innerLat, cardFaint + linewidth(0.6));
