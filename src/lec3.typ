// src/lec3.typ
#import "template.typ": theorem, definition, exercise, html-nav-header

#let is-html = sys.inputs.at("format", default: "pdf") == "html"

#show: doc => {
  if is-html {
    return doc
  }
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), height: 29.7cm)
  set text(size: 11pt, font: "Liberation Serif")
  doc
}

// NEW: Render navigation bar for browser view
#if is-html {
  html-nav-header()
  html.elem("h1", attrs: (style: "font-family: system-ui, sans-serif; color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;"))[Lecture 2: Eigenvalues & Spectral Mapping]
} else {
  align(center)[
    #text(size: 20pt, weight: "bold")[Lecture 3: Oly]
    #v(1cm)
  ]
}

= Core Definitions


#theorem[
  There are infinitely many prime numbers.
]
