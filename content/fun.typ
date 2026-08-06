// src/fun.typ
#import "../templates/course.typ": *

#let lecture = (
  file: "fun",
  number: none,
  title: "Fun Lecture",
)


#show: doc => {
  if is-html {
    return doc
  }
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), height: 29.7cm)
  set text(size: 11pt, font: "Liberation Serif")
  doc
}

#if is-html {
  html-nav-header()
  html.elem(
    "h1",
    attrs: (
      style: "font-family: system-ui, sans-serif; color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;"
    ),
  )[
    Lecture #lecture.number: #lecture.title
  ]
} else {
  align(center)[
    #text(size: 20pt, weight: "bold")[
      Lecture #lecture.number: #lecture.title
    ]
    #v(1cm)
  ]
}

= Core Definitions

aaa


#previous-next(lecture)