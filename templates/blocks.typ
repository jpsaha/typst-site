// theorem / definition / exercise
#import "counters.typ": math-counter
#import "render.typ": block-container

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
      ))[
        #full-label #if title != "" [: #title]
      ]
      #html.elem("div", attrs: (class: "math-card-body"))[#content]
      #if solution != none {
        html.elem("details", attrs: (
          class: "exercise-solution-panel",
          style: "margin-top: 14px; background-color: #ffffff; border: 1px solid #ffcdd2; border-radius: 6px; padding: 12px;"
        ))[
          #html.elem("summary", attrs: (
            style: "font-weight: bold; color: #c62828; cursor: pointer; outline: none;"
          ))[
            💡 Click to Reveal Solution
          ]
          #html.elem("div", attrs: (
            class: "solution-body",
            style: "margin-top: 10px; padding-top: 8px; border-top: 1px dashed #ffcdd2;"
          ))[
            #solution
          ]
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
        #text(weight: "bold", fill: rgb("#c62828"), size: 1.1em)[
          #full-label #if title != "" [: #title]
        ] \
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