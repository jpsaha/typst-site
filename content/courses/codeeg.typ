// src/codeeg.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "codeeg",
  number: none,
  title: "Code Listing Showcase",
  category: "Developer",
)

#show: doc => {
  reset-counters(lecture.number)
  setup-document(doc)
}

#page-header(lecture)

#include "codeeg_content.typ"
