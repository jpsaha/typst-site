// src/lec1.typ
// #import "../templates/template.typ": theorem, definition, exercise, html-nav-header
#import "../templates/course.typ": *

#let lecture = (
  file: "lec1",
  number: 1,
  title: "Linear Transformations & Matrices",
  category: "Linear Algebra",
  date: "2026-08-10",
  reading: "Chapter 2",
  duration: "75 minutes",
  difficulty: "Intermediate",
)

#show: doc => {
  reset-counters(lecture.number)
  setup-document(doc)
}

// #if is-html {
//   html-nav-header()
//   html.elem(
//     "h1",
//     attrs: (
//       style: "font-family: system-ui, sans-serif; color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;"
//     ),
//   )[
//     Lecture #lecture.number: #lecture.title
//   ]
// } else {
//   align(center)[
//     #text(size: 20pt, weight: "bold")[
//       Lecture #lecture.number: #lecture.title
//     ]
//     #v(1cm)
//   ]
// }

#page-header(lecture)

#include "lec1_content.typ"

#previous-next(lecture)