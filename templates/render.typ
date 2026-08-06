// HTML/PDF rendering helpers
// #import "counters.typ": *
#import "counters.typ": (
  math-counter,
  math-number,
  reset-counters,
  lecture-number,
)
#import "utils.typ": is-html
#import "nav.typ": html-nav-header, breadcrumb, download-buttons

// ------------------------------------------------------------
// Lecture metadata display
// ------------------------------------------------------------

#let lecture-info(lecture) = {

  if is-html {

    html.elem(
      "div",
      attrs: (
        class: "lecture-meta",
      ),
    )[

      #if "date" in lecture [
        📅 #lecture.date
        #linebreak()
      ]

      #if "reading" in lecture [
        📖 Reading: #lecture.reading
        #linebreak()
      ]

      #if "duration" in lecture [
        ⏱ Duration: #lecture.duration
        #linebreak()
      ]

      #if "difficulty" in lecture [
        ⭐ Difficulty: #lecture.difficulty
      ]

    ]

  } else {

    // PDF metadata

    if "date" in lecture {
      text(size: 10pt)[
        Date: #lecture.date
      ]
      linebreak()
    }

    if "reading" in lecture {
      text(size: 10pt)[
        Reading: #lecture.reading
      ]
      linebreak()
    }

    if "duration" in lecture {
      text(size: 10pt)[
        Duration: #lecture.duration
      ]
      linebreak()
    }

    if "difficulty" in lecture {
      text(size: 10pt)[
        Difficulty: #lecture.difficulty
      ]
    }

    v(0.5cm)
  }
}

#let page-header(lecture) = {
  
  if is-html {
    html-nav-header()
    breadcrumb(lecture)
    download-buttons(lecture)

    html.elem(
      "h1",
      attrs: (
        style: "font-family: system-ui, sans-serif;
        color: #111;
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;"
      ),
    )[
      #if lecture.number != none {
        [Lecture #lecture.number: ]
      }
      #lecture.title
    ]

    lecture-info(lecture)

  } else {

    align(center)[
      #text(size: 20pt, weight: "bold")[
        #if lecture.number != none {
          [Lecture #lecture.number: ]
        }
        #lecture.title
      ]

      #lecture-info(lecture)

      #v(1cm)
    ]

  }
}
#let block-container(
  counter,
  number-function,
  label-text,
  title,
  primary-color,
  bg-color,
  class-name,
  content,
) = {

  counter.step()

  let full-label = context [
    #label-text #number-function()
  ]

  if sys.inputs.at("format", default: "pdf") == "html" {

    html.elem(
      "div",
      attrs: (
        class: "math-card " + class-name,
        style:
          "border-left: 5px solid "
          + primary-color
          + "; background-color: "
          + bg-color
          + "; padding: 18px; margin: 24px 0; border-radius: 0 4px 4px 0;"
      ),
    )[

      #html.elem(
        "strong",
        attrs: (
          class: "math-card-title",
          style:
            "color: "
            + primary-color
            + "; display:block; font-size:1.1em;"
        ),
      )[
        #full-label#if title != "" [: #title]
      ]


      #html.elem(
        "div",
        attrs: (
          class: "math-card-body",
        ),
      )[
        #content
      ]
    ]


  } else {

    block(
      width: 100%,
      stroke: (left: 4pt + rgb(primary-color)),
      fill: rgb(bg-color),
      inset: 12pt,
      radius: (right: 4pt),
      breakable: true,
    )[

      #text(
        weight: "bold",
        fill: rgb(primary-color),
        size: 1.1em,
      )[
        #full-label#if title != "" [: #title]
      ]

      #v(4pt)

      #content
    ]

  }
}

#let setup-document(doc) = {
  if is-html {
    doc
  } else {
    set page(
      paper: "a4",
      margin: (x: 2.5cm, y: 2.5cm),
      height: 29.7cm,
    )

    set text(
      size: 11pt,
      font: "Liberation Serif",
    )

    doc
  }
}