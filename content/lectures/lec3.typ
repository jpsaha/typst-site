// src/lec3.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec3",
  number: 30,
  title: "Olympiad Inequalities",
  category: "lecture",
)

#show: setup-document

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

#include "lec3_content.typ"

#previous-next(lecture)