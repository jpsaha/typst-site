// src/lec1.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "fgt2",
  type: "lecture",
  number: 2,
  title: "Field extensions and algebraic elements",
  category: "Fields and Galois theory",
  tags: ["field extensions", "algebraic elements"],
  description: "fgt2 description.",
)

#show: lecture-layout(lecture)

#show: doc => {
  reset-counters(lecture.number)
  doc
}

#page-header(lecture, chap: true)

#include "lec2_content.typ"

#previous-next(lecture)
