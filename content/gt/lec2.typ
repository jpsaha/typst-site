// src/lec2.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "gt2",
  number: 2,
  title: "Symmetric groups",
  category: "Group theory",
  description: "Introduction to Group theory.",
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