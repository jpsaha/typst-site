// Navigation bar
#let html-nav-header() = {
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("nav", attrs: (class: "global-nav-header"))[
      #link("index.html")[🏠 Home]
      #text(fill: rgb("#cbd5e1"))[ | ]
      #link("lec1.html")[Lecture 1]
      #link("lec2.html")[Lecture 2]
      #link("lec3.html")[Lecture 3]
      #link("fun.html")[Fun Lecture]
    ]
  }
}