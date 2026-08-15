// ============================================================
// scripts/og/og_template.asy
//
// Open Graph image template
//
// Generated lecture-specific values:
//     __LECTURE_NUMBER__
//     __TITLE__
//     __CATEGORY__
//     __FILE__
//
// Output:
//     1200 × 630
// ============================================================

import graph;
import fontsize;


// ============================================================
// Canvas
// ============================================================

size(1200, 630);

real W = 1200;
real H = 630;


// ============================================================
// Colours
// ============================================================

pen darkgreen  = rgb("#174D35");
pen green      = rgb("#2E7D32");
pen lightgreen = rgb("#6F9160");

pen cream      = rgb("#F8F6EE");
pen paper      = rgb("#FDFCF7");

pen gray       = rgb("#AEB3AA");
pen faint      = rgb("#D9DDD5");
pen textcolor  = rgb("#26383A");


// ============================================================
// Background
// ============================================================

fill(
  box((0,0),(W,H)),
  paper
);

draw(
  box((6,6),(W-6,H-6)),
  darkgreen + linewidth(2)
);

fill(
  box((12,12),(W-12,H-72)),
  cream
);


// ============================================================
// Background mathematical decorations
// ============================================================

// ------------------------------------------------------------
// Summation
// ------------------------------------------------------------

label(
  "$\sum_{k=1}^{n} k$",
  (105,535),
  gray + fontsize(20)
);

label(
  "$=\frac{n(n+1)}{2}$",
  (105,505),
  gray + fontsize(14)
);


// ------------------------------------------------------------
// Quadratic formula
// ------------------------------------------------------------

label(
  "$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$",
  (1080,525),
  gray + fontsize(15)
);


// ============================================================
// Left geometric circle
// ============================================================

pair C = (125,365);
real R = 72;

draw(
  circle(C,R),
  faint + linewidth(1)
);

// Horizontal axis

draw(
  (C.x-R-20,C.y)--(C.x+R+25,C.y),
  faint + linewidth(0.8)
);

// Vertical axis

draw(
  (C.x,C.y-R-20)--(C.x,C.y+R+20),
  faint + linewidth(0.8)
);

// Radius

pair P = C + R*dir(35);

draw(
  C--P,
  gray + linewidth(1)
);

dot(
  C,
  gray
);

label(
  "$r$",
  C + (35,28),
  gray + fontsize(13)
);

label(
  "$\theta$",
  C + (23,8),
  gray + fontsize(12)
);


// ============================================================
// Right polynomial graph
// ============================================================

real gx1 = 930;
real gx2 = 1135;

real gy = 365;

draw(
  (gx1,gy)--(gx2,gy),
  faint + linewidth(0.8)
);

draw(
  (1032,285)--(1032,455),
  faint + linewidth(0.8)
);

real poly(real x) {

  real t = (x-1032)/75;

  return gy - 48*t + 30*t^3;
}

draw(
  graph(
    poly,
    gx1,
    gx2,
    n=160
  ),
  gray + linewidth(1.2)
);

label(
  "$x$",
  (gx2+5,gy-8),
  gray + fontsize(11)
);

label(
  "$y$",
  (1038,455),
  gray + fontsize(11)
);


// ============================================================
// Main title decoration
// ============================================================

draw(
  (390,445)--(810,445),
  lightgreen + linewidth(1)
);

dot(
  (390,445),
  lightgreen
);

dot(
  (810,445),
  lightgreen
);


// ============================================================
// Pi circle
// ============================================================

pair PI = (600,475);
real PIR = 28;

fill(
  circle(PI,PIR),
  darkgreen
);

label(
  "$\pi$",
  PI + (0,-2),
  white + fontsize(25)
);


// Lines beside pi

draw(
  (450,475)--(572,475),
  lightgreen + linewidth(1)
);

draw(
  (628,475)--(750,475),
  lightgreen + linewidth(1)
);

dot(
  (572,475),
  lightgreen
);

dot(
  (628,475),
  lightgreen
);


// ============================================================
// Site title
// ============================================================

label(
  "MATHEMATICS",
  (600,390),
  darkgreen + fontsize(30)
);

label(
  "LECTURES",
  (600,345),
  darkgreen + fontsize(30)
);


// ============================================================
// Lecture number
// ============================================================

label(
  "LECTURE __LECTURE_NUMBER__",
  (600,302),
  green + fontsize(12)
);


// ============================================================
// Lecture title
// ============================================================

label(
  "__TITLE__",
  (600,265),
  darkgreen + fontsize(22)
);


// ============================================================
// Category
// ============================================================

label(
  "__CATEGORY__",
  (600,225),
  textcolor + fontsize(11)
);


// ============================================================
// Decorative matrix
// ============================================================

pair M = (160,145);

real cw = 45;
real ch = 32;

real mw = 4*cw;
real mh = 4*ch;


// ------------------------------------------------------------
// Left bracket
// ------------------------------------------------------------

draw(
  (M.x+10,M.y)
  --(M.x,M.y)
  --(M.x,M.y+mh)
  --(M.x+10,M.y+mh),
  gray + linewidth(1.2)
);


// ------------------------------------------------------------
// Right bracket
// ------------------------------------------------------------

draw(
  (M.x+mw+10,M.y)
  --(M.x+mw+20,M.y)
  --(M.x+mw+20,M.y+mh)
  --(M.x+mw+10,M.y+mh),
  gray + linewidth(1.2)
);


// ------------------------------------------------------------
// Matrix entries
// ------------------------------------------------------------

label(
  "$a_{11}$",
  (M.x+35,M.y+mh-15),
  gray + fontsize(10)
);

label(
  "$a_{12}$",
  (M.x+80,M.y+mh-15),
  gray + fontsize(10)
);

label(
  "$\cdots$",
  (M.x+125,M.y+mh-15),
  gray + fontsize(10)
);

label(
  "$a_{1n}$",
  (M.x+170,M.y+mh-15),
  gray + fontsize(10)
);


label(
  "$a_{21}$",
  (M.x+35,M.y+mh-47),
  gray + fontsize(10)
);

label(
  "$a_{22}$",
  (M.x+80,M.y+mh-47),
  gray + fontsize(10)
);

label(
  "$\cdots$",
  (M.x+125,M.y+mh-47),
  gray + fontsize(10)
);

label(
  "$a_{2n}$",
  (M.x+170,M.y+mh-47),
  gray + fontsize(10)
);


label(
  "$\vdots$",
  (M.x+35,M.y+mh-79),
  gray + fontsize(10)
);

label(
  "$\vdots$",
  (M.x+80,M.y+mh-79),
  gray + fontsize(10)
);

label(
  "$\ddots$",
  (M.x+125,M.y+mh-79),
  gray + fontsize(10)
);

label(
  "$\vdots$",
  (M.x+170,M.y+mh-79),
  gray + fontsize(10)
);


label(
  "$a_{n1}$",
  (M.x+35,M.y+mh-111),
  gray + fontsize(10)
);

label(
  "$a_{n2}$",
  (M.x+80,M.y+mh-111),
  gray + fontsize(10)
);

label(
  "$\cdots$",
  (M.x+125,M.y+mh-111),
  gray + fontsize(10)
);

label(
  "$a_{nn}$",
  (M.x+170,M.y+mh-111),
  gray + fontsize(10)
);


// ============================================================
// Decorative sphere
// ============================================================

pair S = (920,130);
real SR = 48;

draw(
  circle(S,SR),
  faint + linewidth(1)
);

// Horizontal latitude

draw(
  ellipse(
    S,
    SR,
    SR/3
  ),
  faint + linewidth(1)
);

// Vertical longitude

draw(
  ellipse(
    S,
    SR/2,
    SR
  ),
  faint + linewidth(1)
);

// Vertical axis

draw(
  (S.x,S.y-SR)
  --(S.x,S.y+SR),
  faint + linewidth(0.8)
);


// ============================================================
// Subtle wave pattern
// ============================================================

real wave(
  real x,
  real phase,
  real amplitude
) {
  return 80
    + amplitude
    * sin(0.012*x + phase);
}

for (int i=0; i<4; ++i) {

  real f(real x) {
    return wave(
      x,
      i*0.55,
      5+i*1.5
    );
  }

  draw(
    graph(
      f,
      20,
      1180,
      n=250
    ),
    faint + linewidth(0.6)
  );
}


// ============================================================
// Footer
// ============================================================

fill(
  box((12,12),(1188,62)),
  darkgreen
);


// Decorative footer lines

draw(
  (420,37)--(550,37),
  white + linewidth(0.8)
);

draw(
  (650,37)--(780,37),
  white + linewidth(0.8)
);

label(
  "$\diamond$",
  (600,37),
  white + fontsize(12)
);


// ============================================================
// End
// ============================================================