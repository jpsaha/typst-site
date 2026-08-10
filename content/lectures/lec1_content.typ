// #import "../../pdflayout.typ":* // required so that defn etc makes sense
// #import "../../templates/theorems.typ":*
#import "../../templates/course.typ": *

#exer("26")[
  Consider a 
]

#exer[funn]

= Core Definitions

We begin by establishing the properties of fields mapping vector components.

#defn("Linear Map")[
  A function $T: V -> W$ between two vector spaces over the same field $F$ 
  is called a *linear transformation* if it satisfies:
  
  1. Additivity: $T(u + v) = T(u) + T(v)$ for all $u, v in V$
  2. Homogeneity: $T(c v) = c T(v)$ for all $c in F$ and $v in V$
]

#defn("Vector Space")[
  ...
]<def-vector-space>

= Fundamental Theorems

#thm("Rank-Nullity Theorem")[
  Let $V$ and $W$ be vector spaces, where $V$ is finite-dimensional. 
  If $T: V -> W$ is a linear map, then:
  
  $ dim("null" T) + dim("range" T) = dim V $
]<thm-rank>

= Homework Practice

// See @def-vector-space.

// See @thm-rank.

#exer("Identity Dimension Mapping")[
  Let $T: RR^3 -> RR^2$ be defined by $T(x, y, z) = (x + y, z)$. 
  Find a structured matrix representation $M_T$ and verify the output dimension explicitly:
  
  $ M_T = mat(1, 1, 0; 0, 0, 1) $
]

// #exercise(title: "Identity Dimension Mapping", solution: [
//   By inspecting the matrix row parameters:
//   $ M_T = mat(1, 1, 0; 0, 0, 1) $
//   The rank is clearly 2 because the two rows are linearly independent. 
//   By Rank-Nullity, $dim("null" T) = 3 - 2 = 1$.
// ])[
//   Let $T: RR^3 -> RR^2$ be defined by $T(x, y, z) = (x + y, z)$. 
//   Find the dimension of the null space.
// ]
/*
#note[
Remember that every basis is linearly independent.
]

#warning[
Do *not* confuse image and codomain.
]

#example[
Let

$
T(x,y)=(x+y,y).
$
]

#proof[
We proceed by induction...
]

#remark[
The converse is false.
]

#history[
The Rank-Nullity theorem appeared in the nineteenth century.
]

#lemma[lemma statement]
#proposition[proposition statement]
#claim[claim statement]
#corollary[corollary statement]
*/