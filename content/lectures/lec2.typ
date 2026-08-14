// src/lec2.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec2",
  number: 2,
  title: "Field extensions",
  category: "Fields and Galois theory",
  description: "Introduction to Fields and Galois theory.",
)

#show: lecture-layout(lecture)

#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}

#page-header(lecture, chap: true)

#include "lec2_content.typ"

#previous-next(lecture)