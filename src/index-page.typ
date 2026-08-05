// src/index-page.typ
#let is-html = sys.inputs.at("format", default: "pdf") == "html"

#show: doc => {
  if is-html {
    // Force a semantic body wrapper container for the web engine
    return html.elem("body", attrs: (
      style: "font-family: system-ui, -apple-system, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #222; line-height: 1.6;"
    ))[#doc]
  }
  set page(paper: "a4", height: 29.7cm, margin: 2.5cm)
  set text(size: 11pt, font: "Liberation Serif")
  doc
}

// Target-aware main title layout
#if is-html {
  html.elem("div", attrs: (style: "text-align: center; margin-bottom: 40px;"))[
    #html.elem("h1", attrs: (style: "font-size: 2.5em; margin-bottom: 5px; color: #111;"))[🧮 Mathematics Lecture Series]
    #html.elem("p", attrs: (style: "color: #666; font-style: italic;"))[Course Materials & Practice Sets]
  ]
} else {
  align(center)[
    #text(size: 24pt, weight: "bold")[🧮 Mathematics Lecture Series]
    #v(0.5cm)
    #text(size: 12pt, style: "italic", fill: gray.darken(20%))[Course Materials & Practice Sets]
  ]
}

#if is-html {
  html.elem("h2", attrs: (style: "border-bottom: 2px solid #eee; padding-bottom: 8px; color: #333;"))[Lecture Modules]
} else {
  [= Lecture Modules]
}

#let lecture-entry(num, title, filename) = {
  if is-html {
    html.elem("div", attrs: (
      style: "padding: 20px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center;"
    ))[
      #html.elem("span")[#html.elem("strong")[Lecture #num:] #title]
      #html.elem("div")[
        #html.elem("a", attrs: (href: filename + ".html", style: "color: #0066cc; text-decoration: none; margin-right: 15px; font-weight: 500;"))[🌐 View Web]
        #html.elem("a", attrs: (href: filename + ".pdf", style: "color: #c62828; text-decoration: none; font-weight: 500;"))[📄 Download PDF]
      ]
    ]
  } else {
    block(width: 100%, stroke: (bottom: 1pt + rgb("#eee")), inset: (bottom: 10pt))[
      *Lecture #num:* #title \
      #v(4pt)
      Available in digital interactive web directories.
    ]
  }
}

#lecture-entry("1", "Linear Transformations & Matrices", "lec1")
#lecture-entry("2", "Eigenvalues & Spectral Mapping", "lec2")
