// src/lec1.typ
#import "../../templates/course.typ": *

#let lecture = (
  file: "lec1",
  type: "lecture",
  number: 1,
  title: "Group theory",
  category: "Algebra",
  tags: ["Lagrange's theorem", "Cayley's theorem"],
  description: "lec1 description.",
  // og_image: "assets/og/lec1.png", // Open Graph image for social media sharing. Provide or comment out if not needed.
)

#show: lecture-layout(lecture)

#show: doc => {
  reset-counters(lecture.number)
  doc
}

#page-header(lecture, chap: true)

#include "lec1_content.typ"

#previous-next(lecture)
