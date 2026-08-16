// src/lec3.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "gt3",
  number: 3,
  title: "Sylow's theorems",
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

#include "lec3_content.typ"

#previous-next(lecture)