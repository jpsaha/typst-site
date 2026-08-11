// src/lec3.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec3",
  number: 30,
  title: "Olympiad Inequalities",
  category: "Olympiad",
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

#page-header(lecture)

#include "lec3_content.typ"

#previous-next(lecture)