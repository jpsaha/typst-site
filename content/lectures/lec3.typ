// src/lec3.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec3",
  number: 30,
  title: "Olympiad Inequalities",
  category: "Olympiad",
)

#show: lecture-layout(lecture)

#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}

#page-header(lecture, chap: true)

#include "lec3_content.typ"

#previous-next(lecture)