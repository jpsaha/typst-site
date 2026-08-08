// src/fun.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "fun",
  number: none,
  title: "Fun Lecture",
  category: "Extras",
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


#include "fun_content.typ"

#previous-next(lecture)