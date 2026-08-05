// src/lec1.typ
#import "template.typ": theorem, definition, exercise

#let is-html = sys.inputs.at("format", default: "pdf") == "html"

// FIX: Setting global parameters directly at the root layer prevents container isolation warnings
#show: doc => {
  if is-html {
    // If targeted for web engines, ignore paged limits entirely
    return doc
  }
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), height: 29.7cm)
  set text(size: 11pt, font: "Liberation Serif")
  doc
}

// Render dynamic header logic depending on target format output
#if is-html {
  html.elem("h1", attrs: (style: "font-family: system-ui, sans-serif; color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;"))[Lecture 1: Linear Transformations & Matrices]
} else {
  align(center)[
    #text(size: 20pt, weight: "bold")[Lecture 1: Linear Transformations & Matrices]
    #v(1cm)
  ]
}

= Core Definitions

We begin by establishing the properties of fields mapping vector components.

#definition(title: "Linear Map")[
  A function $T: V -> W$ between two vector spaces over the same field $F$ 
  is called a *linear transformation* if it satisfies:
  
  1. Additivity: $T(u + v) = T(u) + T(v)$ for all $u, v in V$
  2. Homogeneity: $T(c v) = c T(v)$ for all $c in F$ and $v in V$
]

= Fundamental Theorems

#theorem(title: "Rank-Nullity Theorem")[
  Let $V$ and $W$ be vector spaces, where $V$ is finite-dimensional. 
  If $T: V -> W$ is a linear map, then:
  
  $ dim("null" T) + dim("range" T) = dim V $
]

= Homework Practice

#exercise(title: "Identity Dimension Mapping")[
  Let $T: RR^3 -> RR^2$ be defined by $T(x, y, z) = (x + y, z)$. 
  Find a structured matrix representation $M_T$ and verify the output dimension explicitly:
  
  $ M_T = mat(1, 1, 0; 0, 0, 1) $
  
]
