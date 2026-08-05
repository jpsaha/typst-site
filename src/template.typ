// src/template.typ

#let block-container(title, label-text, primary-color, bg-color, content) = {
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("div", attrs: (
      style: "border-left: 5px solid " + primary-color + "; " +
             "background-color: " + bg-color + "; " +
             "padding: 15px; margin: 20px 0; border-radius: 4px; " +
             "font-family: system-ui, -apple-system, sans-serif; line-height: 1.6;"
    ))[
      #html.elem("strong", attrs: (style: "color: " + primary-color + "; font-size: 1.1em;"))[#label-text: #title]
      #html.elem("div", attrs: (style: "margin-top: 8px;"))[#content]
    ]
  } else {
    block(
      width: 100%,
      stroke: (left: 4pt + rgb(primary-color)),
      fill: rgb(bg-color),
      inset: 12pt,
      radius: (right: 4pt),
      breakable: true,
      [
        #text(weight: "bold", fill: rgb(primary-color), size: 1.1em)[#label-text #if title != "" [: #title]] \
        #v(4pt)
        #content
      ]
    )
  }
}

#let theorem(title: "", content) = block-container(title, "Theorem", "#0066cc", "#f0f7ff", content)
#let definition(title: "", content) = block-container(title, "Definition", "#2e7d32", "#f1f8e9", content)

// UPGRADED: Exercise with an optional interactive solution field
#let exercise(title: "", solution: none, content) = {
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("div", attrs: (
      style: "border-left: 5px solid #c62828; background-color: #ffebee; " +
             "padding: 15px; margin: 20px 0; border-radius: 4px; " +
             "font-family: system-ui, -apple-system, sans-serif; line-height: 1.6;"
    ))[
      #html.elem("strong", attrs: (style: "color: #c62828; font-size: 1.1em;"))[Exercise: #title]
      #html.elem("div", attrs: (style: "margin-top: 8px;"))[#content]
      
      // Inject interactive details tag if a solution is present
      #if solution != none {
        html.elem("details", attrs: (style: "margin-top: 12px; cursor: pointer; background: #fff; padding: 10px; border-radius: 4px; border: 1px solid #ffcdd2;"))[
          #html.elem("summary", attrs: (style: "color: #c62828; font-weight: bold; outline: none;"))[💡 Click to Reveal Solution]
          #html.elem("div", attrs: (style: "margin-top: 10px; color: #333; cursor: default;"))[#solution]
        ]
      }
    ]
  } else {
    block(
      width: 100%,
      stroke: (left: 4pt + rgb("#c62828")),
      fill: rgb("#ffebee"),
      inset: 12pt,
      radius: (right: 4pt),
      breakable: true,
      [
        #text(weight: "bold", fill: rgb("#c62828"), size: 1.1em)[Exercise: #title] \
        #v(4pt)
        #content
        #if solution != none [
          #v(8pt)
          #line(length: 100%, stroke: 0.5pt + rgb("#ffcdd2"))
          #text(weight: "bold", fill: rgb("#c62828"))[Solution:] \
          #v(4pt)
          #solution
        ]
      ]
    )
  }
}

#let html-nav-header() = {
  html.elem("nav", attrs: (
    style: "background-color: var(--nav-bg, #f8f9fa); border-bottom: 1px solid var(--border, #e9ecef); " +
           "padding: 12px 20px; margin: -2.5cm -2.5cm 40px -2.5cm; " +
           "display: flex; gap: 20px; align-items: center; " +
           "font-family: system-ui, -apple-system, sans-serif;"
  ))[
    #html.elem("a", attrs: (href: "index.html", style: "color: var(--text, #333); text-decoration: none; font-weight: bold;"))[🏠 Home]
    #html.elem("span", attrs: (style: "color: #ccc;"))[|]
    #html.elem("a", attrs: (href: "lec1.html", style: "color: #0066cc; text-decoration: none;"))[Lecture 1]
    #html.elem("a", attrs: (href: "lec2.html", style: "color: #0066cc; text-decoration: none;"))[Lecture 2]
  ]
}
