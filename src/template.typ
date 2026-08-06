// Declare a single shared counter for all math blocks across a single lecture file
#let math-counter = counter("math-blocks")

#let block-container(title, label-text, primary-color, bg-color, class-name, content) = {
  // Step the counter forward by 1 inside a hidden location context
  math-counter.step()
  
  // Format the counter value as an output string (e.g., "1", "2")
  let current-num = context math-counter.display()
  let full-label = label-text + " " + current-num
  
  if sys.inputs.at("format", default: "pdf") == "html" {
    // FIXED: Colors injected inline as fallback values while keeping class hooks active
    html.elem("div", attrs: (
      class: "math-card " + class-name,
      style: "border-left: 5px solid " + primary-color + "; background-color: " + bg-color + "; padding: 18px; margin: 24px 0; border-radius: 0 4px 4px 0;"
    ))[
      #html.elem("strong", attrs: (
        class: "math-card-title",
        style: "color: " + primary-color + "; display: block; font-size: 1.1em; margin-bottom: 8px;"
      ))[
        #full-label #if title != "" [: #title]
      ]
      #html.elem("div", attrs: (class: "math-card-body"))[#content]
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
        #text(weight: "bold", fill: rgb(primary-color), size: 1.1em)[
          #full-label #if title != "" [: #title]
        ] \
        #v(4pt)
        #content
      ]
    )
  }
}

#let theorem(title: "", content) = block-container(title, "Theorem", "#0066cc", "#f0f7ff", "theorem", content)
#let definition(title: "", content) = block-container(title, "Definition", "#2e7d32", "#f1f8e9", "definition", content)

#let exercise(title: "", solution: none, content) = {
  math-counter.step()
  let current-num = context math-counter.display()
  let full-label = "Exercise " + current-num
  
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("div", attrs: (
      class: "math-card exercise",
      style: "border-left: 5px solid #c62828; background-color: #ffebee; padding: 18px; margin: 24px 0; border-radius: 0 4px 4px 0;"
    ))[
      #html.elem("strong", attrs: (
        class: "math-card-title",
        style: "color: #c62828; display: block; font-size: 1.1em; margin-bottom: 8px;"
      ))[#full-label #if title != "" [: #title]]
      #html.elem("div", attrs: (class: "math-card-body"))[#content]
      #if solution != none {
        html.elem("details", attrs: (
          class: "exercise-solution-panel",
          style: "margin-top: 14px; background-color: #ffffff; border: 1px solid #ffcdd2; border-radius: 6px; padding: 12px;"
        ))[
          #html.elem("summary", attrs: (style: "font-weight: bold; color: #c62828; cursor: pointer; outline: none;"))[💡 Click to Reveal Solution]
          #html.elem("div", attrs: (class: "solution-body", style: "margin-top: 10px; padding-top: 8px; border-top: 1px dashed #ffcdd2;"))[#solution]
        ]
      }
    ]
  } else {
    block(
      width: 100%, stroke: (left: 4pt + rgb("#c62828")), fill: rgb("#ffebee"), inset: 12pt, radius: (right: 4pt), breakable: true,
      [
        #text(weight: "bold", fill: rgb("#c62828"), size: 1.1em)[#full-label #if title != "" [: #title]] \
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
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("nav", attrs: (class: "global-nav-header"))[
      #link("index.html")[🏠 Home]
      #text(fill: rgb("#cbd5e1"))[ | ]
      #link("lec1.html")[Lecture 1]
      #link("lec2.html")[Lecture 2]
    ]
  }
}
