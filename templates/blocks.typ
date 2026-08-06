// theorem / definition / exercise
// #import "counters.typ": math-counter
#import "render.typ": block-container

// ├── imports colors.typ
// └── imports utils.typ
// #import "counters.typ": *
// theorem-counter, theorem-number
// 
#import "counters.typ": (
  math-counter,
  math-number,
)

#import "render.typ": block-container
#import "counters.typ": (
  math-counter,
  math-number,
)


// ------------------------------------------------------------
// Theorem
// ------------------------------------------------------------

#let theorem(title: "", content) = {

  block-container(
    math-counter,
    math-number,
    "Theorem",
    title,
    "#0066cc",
    "#f0f7ff",
    "theorem",
    content,
  )

}


// ------------------------------------------------------------
// Definition
// ------------------------------------------------------------

#let definition(title: "", content) = {

  block-container(
    math-counter,
    math-number,
    "Definition",
    title,
    "#2e7d32",
    "#f1f8e9",
    "definition",
    content,
  )

}


// ------------------------------------------------------------
// Exercise
// ------------------------------------------------------------

#let exercise(
  title: "",
  solution: none,
  content,
) = {

  block-container(
    math-counter,
    math-number,
    "Exercise",
    title,
    "#c62828",
    "#ffebee",
    "exercise",
    content,
  )

}