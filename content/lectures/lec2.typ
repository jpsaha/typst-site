// src/lec2.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec2",
  number: 2,
  title: "Field extensions",
  category: "Fields and Galois theory",
)


#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}

#page-header(lecture)

#include "lec2_content.typ"

#previous-next(lecture)