// src/lec1.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "fgt1",
  type: "lecture",
  number: 1,
  title: "Polynomial rings and irreducibility criteria",
  category: "Fields and Galois theory",
  tags: ["division algorithm", "Gauss' lemma"],
  description: "fgt1 description.",
  og_image: "assets/og/fgt1.png",
)

#show: lecture-layout(lecture)

#show: doc => {
  reset-counters(lecture.number)
  doc
}

#page-header(lecture, chap: true)

#include "lec1_content.typ"

#previous-next(lecture)
