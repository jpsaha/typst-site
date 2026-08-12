// src/lec2.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec2",
  number: 2,
  title: "Field extensions",
  category: "Fields and Galois theory",
)

#let pdf-layout = (
  if sys.inputs.at("format", default: "pdf") == "pdf" {
    import "../../templates/pdflayout.typ": *
    pdflayout.with(
      title: lecture.title,
      report-style: true,
      flipp: false,
    )
  } else {
    doc => doc
  }
)

#show: pdf-layout

#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}

#page-header(lecture, chap: true)

#include "lec2_content.typ"

#previous-next(lecture)