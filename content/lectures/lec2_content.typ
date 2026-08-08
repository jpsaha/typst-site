#import "../../templates/course.typ": *

= Core Definitions

In this session, we analyze how linear transformations scale specific vector subspaces.

#definition(title: "Eigenvalues and Eigenvectors")[
  Let $T: V -> V$ be a linear operator on a vector space $V$ over a field $F$. 
  A non-zero vector $v in V$ is called an *eigenvector* of $T$ if there exists a 
  scalar $lambda in F$ such that:
  
  $ T(v) = lambda v $
  
  The scalar $lambda$ is called the *eigenvalue* corresponding to the eigenvector $v$.
]

= Fundamental Theorems

#theorem(title: "Linear Independence of Eigenvectors")[
  Let $T: V -> V$ be a linear operator. If $v_1, v_2, ..., v_m$ are eigenvectors 
  corresponding to *distinct* eigenvalues $lambda_1, lambda_2, ..., lambda_m$, 
  then the set $\{v_1, v_2, ..., v_m\}$ is linearly independent.
]

= Homework Practice

#exercise(title: "Characteristic Polynomial Evaluation")[
  Consider the $2 times 2$ matrix $A$ representing a linear transformation on $RR^2$:
  
  $ A = mat(4, 2; 1, 3) $
  
  1. Compute the characteristic polynomial $p(lambda) = det(A - lambda I)$.
  2. Find the distinct eigenvalues $lambda_1$ and $lambda_2$ by solving:
  
  $ lambda^2 - 7lambda + 10 = 0 $
]
