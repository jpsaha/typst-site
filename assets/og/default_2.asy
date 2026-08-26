// ============================================================
// assets/og/default.asy
//
// Mathematics Lectures — Premium Open Graph Banner
// Dimensions: 1200 × 630 (Standard OG Aspect Ratio)
//
// Compile Command: asy -f png -r 1200 default.asy
// ============================================================

import graph;
import fontsize;

// Fix for complex LaTeX rendering & packages
usersetting();
texpreamble("\usepackage{amsmath}");

// ------------------------------------------------------------
// Canvas Dimensions
// ------------------------------------------------------------
size(1200, 630);
real W = 1200;
real H = 630;

// ------------------------------------------------------------
// Color Palette (Premium Editorial Math Journal Slate)
// ------------------------------------------------------------
pen bgCanvas    = rgb("#F7F9FC"); // Cream-tinged modern light gray
pen bgPanel     = rgb("#FFFFFF"); // Crisp white inner card
pen borderDark  = rgb("#0F172A"); // Slate-900 sharp border
pen primary     = rgb("#1E3A8A"); // Deep luxury ink blue
pen accentBlue  = rgb("#3B82F6"); // Vibrant engineering blue
pen textMain    = rgb("#334155"); // Slate-700 neutral dark
pen mathWater   = rgb("#CBD5E1"); // Slate-300 background math
pen gridLine    = rgb("#E2E8F0"); // Slate-200 geometry layout
pen gridFaint   = rgb("#F1F5F9"); // Super faint blueprint grid lines

// ------------------------------------------------------------
// Standalone Native Rounded Box Helper
// ------------------------------------------------------------
path roundedBoxPath(pair A, pair B, real r) {
    real x1 = min(A.x, B.x), x2 = max(A.x, B.x);
    real y1 = min(A.y, B.y), y2 = max(A.y, B.y);
    return (x1+r, y1) -- (x2-r, y1) .. arc((x2-r, y1+r), r, -90, 0) -- 
           (x2, y2-r) .. arc((x2-r, y2-r), r, 0, 90) -- (x1+r, y2) .. 
           arc((x1+r, y2-r), r, 90, 180) -- (x1, y1+r) .. 
           arc((x1+r, y1+r), r, 180, 270) -- cycle;
}

// ------------------------------------------------------------
// Modern Smooth Rounded Canvas Frame
// ------------------------------------------------------------
real boxRadius = 24; 
path canvasFrame = roundedBoxPath((16, 16), (W-16, H-16), boxRadius);

// Render background structures
fill(box((0,0), (W,H)), bgCanvas);
fill(canvasFrame, bgPanel);

// ------------------------------------------------------------
// Subtle Blueprint Background Mesh
// ------------------------------------------------------------
for (real x = 40; x < W - 20; x += 40) {
    draw((x, 20)--(x, H - 20), gridFaint + linewidth(0.5));
}
for (real y = 40; y < H - 20; y += 40) {
    draw((20, y)--(W - 20, y), gridFaint + linewidth(0.5));
}

// Draw the dark outer framing border
draw(canvasFrame, borderDark + linewidth(2.5));

// ============================================================
// REFINED MATHEMATICAL DECORATIONS (Watermarks)
// ============================================================

// Top-Left Matrix Layer (Escaped standard delimiters)
label("$\begin{pmatrix} \cos\theta \\& -\sin\theta \\ \sin\theta \\& \cos\theta \end{pmatrix}$", (170, 535), mathWater + fontsize(14));

// Top-Right Calculus & Identities
label("$\oint_C \mathbf{F} \cdot d\mathbf{r} = \iint_S (\nabla \times \mathbf{F}) \cdot d\mathbf{S}$", (1010, 545), mathWater + fontsize(13));
label("$e^{i\pi} + 1 = 0$", (1010, 505), mathWater + fontsize(16));

// ------------------------------------------------------------
// Left Geometry Structure
// ------------------------------------------------------------
pair C = (150, 340);
real geomR = 60;

draw(circle(C, geomR), gridLine + linewidth(1));
draw((C.x - geomR - 15, C.y)--(C.x + geomR + 15, C.y), gridLine + linewidth(0.6));
draw((C.x, C.y - geomR - 15)--(C.x, C.y + geomR + 15), gridLine + linewidth(0.6));

pair P = C + geomR*dir(38);
draw(C--P, accentBlue + linewidth(1.5));
dot(C, primary);
label("$r$", C + (22, 24), mathWater + fontsize(12));
label("$\theta$", C + (16, 6), mathWater + fontsize(11));

// ------------------------------------------------------------
// Right Waveform Graph
// ------------------------------------------------------------
real gx1 = 930, gx2 = 1110;
real gy  = 340;

draw((gx1, gy)--(gx2, gy), gridLine + linewidth(0.8));
draw((1020, 270)--(1020, 410), gridLine + linewidth(0.8));

real poly(real x) {
  real t = (x - 1020)/50;
  return gy - 25*t + 12*t^3; 
}
draw(graph(poly, gx1, gx2, n=150), accentBlue + linewidth(1.2));

// ============================================================
// CENTERPIECE TYPOGRAPHY & BRANDING
// ============================================================

// Math Icon Emblem Base
pair emblemCenter = (600, 485);
fill(circle(emblemCenter, 36), primary);
label("$\sum$", emblemCenter + (0, 0), white + fontsize(36));

// Decorative alignment anchors running left/right
draw((420, 485)--(535, 485), accentBlue + linewidth(1));
draw((665, 485)--(780, 485), accentBlue + linewidth(1));
dot((535, 485), accentBlue);
dot((665, 485), accentBlue);

// ------------------------------------------------------------
// Core Title Headers
// ------------------------------------------------------------
pen titleFont = Palatino(series="b", shape="n") + fontsize(56);

label("MATHEMATICS", (600, 395), primary + titleFont);
label("LECTURES", (600, 325), primary + titleFont);

// Minimal Separator
draw((480, 292)--(720, 292), gridLine + linewidth(1.2));

// Subtext Meta Row
label("Rigorous Notes  $\cdot$  Curated Problem Sets  $\cdot$  Visual Proofs", (600, 262), textMain + fontsize(16));

// ============================================================
// TOPIC BADGE
// ============================================================
pair badgeB1 = (380, 192);
pair badgeB2 = (820, 230);
path badgeBox = roundedBoxPath(badgeB1, badgeB2, 6);

fill(badgeBox, rgb("#EFF6FF")); 
draw(badgeBox, accentBlue + linewidth(1));

pen badgeFont = Palatino(series="b", shape="n") + fontsize(12);
label("ALGEBRA  $\cdot$  CALCULUS  $\cdot$  PROBABILITY  $\cdot$  GEOMETRY", (600, 209), primary + badgeFont);

// ============================================================
// NEW: DECORATIVE MATHEMATICAL FOOTER WAVES
// ============================================================
real baseFooterY = 60;

real waveA(real x) { return baseFooterY + 12 * sin(0.025 * x); }
real waveB(real x) { return baseFooterY + 8 * cos(0.035 * x + 0.5); }

// Draw overlapping elegant wave ripples behind the footer card
draw(graph(waveA, 30, W - 30, n=300), gridLine + linewidth(1));
draw(graph(waveB, 30, W - 30, n=300), mathWater + linewidth(0.8));

// Small geometric data points across the footer track
for (int i = 1; i <= 10; ++i) {
    real dotX = 40 + i * 105;
    if (dotX < 430 || dotX > 770) { // Do not draw dots directly through text area
        dot((dotX, waveA(dotX)), primary + linewidth(4));
        dot((dotX + 25, waveB(dotX + 25)), accentBlue + linewidth(3));
    }
}

// ============================================================
// PREMIUM FOOTER & WEBSITE URL
// ============================================================
pair footerMin = (440, 40);
pair footerMax = (760, 80);
path footerBox = roundedBoxPath(footerMin, footerMax, 10);

// Crisp layered background depth drop shadow effect
fill(shift(0, -3) * footerBox, mathWater);
fill(footerBox, borderDark);

pen urlFont = Palatino(series="b", shape="n") + fontsize(15);
label("math-lectures.com", (600, 60), white + urlFont);
