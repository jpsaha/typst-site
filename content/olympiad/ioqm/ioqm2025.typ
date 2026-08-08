// content/ioqm2025.typ
#import "../../../templates/course.typ": *

#let lecture = (
  file: "ioqm2025",
  number: none,
  title: "IOQM 2025",
  category: "IOQM",
)

#show: doc => {
  reset-counters(lecture.number)
  setup-document(doc)
}


#page-header(lecture)

#include "ioqm2025_content.typ"

#previous-next(lecture)
