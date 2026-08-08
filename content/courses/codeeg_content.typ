#import "../../templates/course.typ": *



= Code Listings Showcase

This page demonstrates all supported code environments.

== Python


/*

#python[
from math import gcd

def lcm(a, b):
    c = a * b
    return c / gcd(a, b)

for n in range(1, 6):
    print(n, lcm(n, 12))
]

#python[
def fib(n):
    a, b = 0, 1
    while n > 0:
        print(a)
        a, b = b, a + b
        n = n - 1

fib(10)
]


== SageMath

#sage[
R.<x> = PolynomialRing(QQ)

f = x^4 - 1

print(f.factor())

A = matrix([[1,2],[3,4]])

print(A.det())

print(A.eigenvalues())
]

== Lean

#lean[
import Mathlib

theorem add_zero (n : ℕ) :
  n + 0 = n := by
  simp

example (a b : ℕ) :
  a + b = b + a := by
  omega
]

== Julia

#julia[
using LinearAlgebra

A = [1 2;
     3 4]

println(det(A))
println(eigvals(A))

v = [1,2]
println(A * v)
]

== Asymptote

#asy[
size(5cm);

draw((0,0)--(2,0)--(1,1.5)--cycle);

label("$A$", (0,0), SW);
label("$B$", (2,0), SE);
label("$C$", (1,1.5), N);

dot((0,0));
dot((2,0));
dot((1,1.5));
]

== Longer Python Example

#python[
class Matrix:

    def __init__(self, rows):
        self.rows = rows

    def transpose(self):
        return [
            [self.rows[i][j]
             for i in range(len(self.rows))]
            for j in range(len(self.rows[0]))
        ]

A = Matrix([
    [1,2,3],
    [4,5,6],
])

print(A.transpose())
]

== Longer SageMath Example

#sage[
var("x y")

f = x^2 + y^2

print(diff(f, x))
print(diff(f, y))

P = plot(sin(x), (x, 0, 2*pi))

show(P)
]
*/