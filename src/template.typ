// src/template.typ

#let is-html = sys.inputs.at("format", default: "pdf") == "html"

// ------------------------------------------------------------
// Shared counter
// ------------------------------------------------------------

#let math-counter = counter("math-blocks")

// ------------------------------------------------------------
// Box styles
// ------------------------------------------------------------

#let box-styles = (
  theorem: (
    label: "Theorem",
    color: "#0066cc",
    bg: "#f0f7ff",
  ),

  definition: (
    label: "Definition",
    color: "#2e7d32",
    bg: "#f1f8e9",
  ),

  exercise: (
    label: "Exercise",
    color: "#c62828",
    bg: "#ffebee",
  ),
)

// ------------------------------------------------------------
// Generic box
// ------------------------------------------------------------

#let box(kind, title: "", solution: none, body) = {

  math-counter.step()

  let n = context math-counter.display()

  let style = box-styles.at(kind)

  let label = style.label + " " + n

  if is-html {

    html.elem(
      "section",
      attrs: (
        class: "math-box " + str(kind),
        style:
          "border-left:5px solid " + style.color + ";" +
          "background:" + style.bg + ";" +
          "padding:15px;" +
          "margin:20px 0;" +
          "border-radius:6px;" +
          "line-height:1.6;",
      ),
    )[
      html.elem(
        "header",
        attrs: (
          style:
            "font-weight:bold;" +
            "font-size:1.1em;" +
            "color:" + style.color + ";",
        ),
      )[
        #label
        #if title != "" [: #title]
      ]

      html.elem("div", attrs:(style:"margin-top:8px;"))[
        #body
      ]

      #if kind == "exercise" and solution != none {

        html.elem(
          "details",
          attrs:(style:"margin-top:12px;"),
        )[
          html.elem("summary")[
            💡 Click to Reveal Solution
          ]

          html.elem(
            "div",
            attrs:(style:"margin-top:10px;"),
          )[
            #solution
          ]
        ]
      }

    ]

  } else {

    block(
      width:100%,
      stroke:(left:4pt + rgb(style.color)),
      fill:rgb(style.bg),
      inset:12pt,
      radius:(right:4pt),
      breakable:true,

      [
        #text(
          weight:"bold",
          fill:rgb(style.color),
          size:1.1em,
        )[
          #label
          #if title != "" [: #title]
        ]

        \

        #v(4pt)

        #body

        #if kind == "exercise" and solution != none [

          #v(8pt)

          #line(
            length:100%,
            stroke:0.5pt + rgb("#ffcdd2"),
          )

          #text(
            weight:"bold",
            fill:rgb(style.color),
          )[Solution:]

          \

          #v(4pt)

          #solution
        ]
      ],
    )
  }
}

// ------------------------------------------------------------
// Public wrappers
// ------------------------------------------------------------

#let theorem(title: "", body) = box("theorem", title: title, body)

#let definition(title: "", body) = box("definition", title: title, body)

#let exercise(title: "", solution: none, body) = box("exercise", title: title, solution: solution, body)

// ------------------------------------------------------------
// Navigation
// ------------------------------------------------------------

#let html-nav-header() = {

  html.elem(
    "nav",
    attrs:(
      class:"course-nav",
      style:
        "background:#f8f9fa;" +
        "padding:12px 20px;" +
        "display:flex;" +
        "gap:20px;" +
        "margin:-2.5cm -2.5cm 40px -2.5cm;",
    ),
  )[
    html.elem("a", attrs:(href:"index.html"))[
      🏠 Home
    ]

    html.elem("span")[|]

    html.elem("a", attrs:(href:"lec1.html"))[
      Lecture 1
    ]

    html.elem("a", attrs:(href:"lec2.html"))[
      Lecture 2
    ]
  ]
}
