// Navigation bar
#import "generated.typ": lectures
#import "utils.typ": is-html

#let html-nav-header() = {
  if sys.inputs.at("format", default: "pdf") == "html" {
    html.elem("nav", attrs: (class: "global-nav-header"))[
      #link("index.html")[🏠 Home]

      #for lec in lectures {
        text(fill: rgb("#cbd5e1"))[ | ]
        link(lec.file + ".html")[#lec.title]
      }
    ]
  }
}