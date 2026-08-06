// HTML/PDF rendering helpers
#import "counters.typ": math-counter
#import "utils.typ": is-html
#import "nav.typ": html-nav-header, breadcrumb

#let page-header(lecture) = {

  if is-html {

    html-nav-header()

    breadcrumb(lecture)

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


    // Metadata box

    html.elem(
      "div",
      attrs: (
        class: "lecture-meta"
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
        ⏱ #lecture.duration
      ]

    ]

  }
}

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