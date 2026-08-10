// src/lec1.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec1",
  number: 1,
  title: "Polynomial rings",
  category: "Fields and Galois theory",
  date: "2026-08-10",
  reading: "Chapter 2",
  duration: "75 minutes",
  difficulty: "Intermediate",
)

#show: doc => {
  reset-counters(lecture.number)
  // setup-document(doc)
  doc
}

#page-header(lecture)

#include "lec1_content.typ"

#previous-next(lecture)