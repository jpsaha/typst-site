// content/rmo2025.typ
#import "../../../templates/course.typ": *

#let lecture = (
  file: "rmo2025",
  number: none,
  title: "RMO 2025",
  category: "R-M-O",
)

#show: doc => {
  reset-counters(lecture.number)
  setup-document(doc)
}


#page-header(lecture)

#include "rmo2025_content.typ"

#previous-next(lecture)
