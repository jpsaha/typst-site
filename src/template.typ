// Define target-aware container styling
#let block-container(title, label-text, primary-color, bg-color, content) = {
  // If compiling with '--input format=html', inject native web elements
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
    // Elegant fallback design for your print-ready PDFs
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

// Exportable functions for notes and problems
#let theorem(title: "", content) = block-container(title, "Theorem", "#0066cc", "#f0f7ff", content)
#let definition(title: "", content) = block-container(title, "Definition", "#2e7d32", "#f1f8e9", content)
#let exercise(title: "", content) = block-container(title, "Exercise", "#c62828", "#ffebee", content)

// Master page layout controller
#let course-layout(title: "Lecture Notes", body) = {
  let is-html = sys.inputs.at("format", default: "pdf") == "html"
  
  set page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
    // Continuous scroll for web browsers, fixed bounds for standard PDF printing
    height: if is-html { auto } else { 29.7cm }
  )
  set text(size: 11pt, font: "Liberation Serif")
  
  // Custom header handling
  if is-html {
    html.elem("h1", attrs: (style: "font-family: system-ui, sans-serif; color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;"))[#title]
  } else {
    align(center)[
      #text(size: 20pt, weight: "bold")[#title]
      #v(1cm)
    ]
  }
  
  body
}
