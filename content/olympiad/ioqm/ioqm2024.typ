// content/ioqm2025.typ
#import "../../../templates/course.typ": *

#let lecture = (
  file: "ioqm2024",
  number: none,
  title: "IOQM 2024",
  category: "IOQM",
)

#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}


#page-header(lecture)

#include "ioqm2024_content.typ"

#previous-next(lecture)
