// content/ioqm2025.typ
#import "../../../templates/course.typ": *

#let lecture = (
  file: "ioqm2025",
  number: 2025,
  title: "IOQM 2025",
  category: "IOQM",
)

#let pdf-layout = (
  if sys.inputs.at("format", default: "pdf") == "pdf" {
    import "../../../templates/pdflayout.typ": *
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

#include "ioqm2025_content.typ"

#previous-next(lecture)
