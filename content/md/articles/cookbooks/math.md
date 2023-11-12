{:title "Mathematics with Clojure"
 :layout :page :page-index 4200}

This cookbook covers working with mathematics in Clojure, using
built-in functions, contrib libraries, and parts of the JDK via
interoperability.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).


## Preliminaries

This cookbook covers Clojure 1.11 (or later) and the
[`clojure.math` namespace introduced in that release](https://clojure.github.io/clojure/clojure.math-api.html).

It's assumed that either you have the following in
your source code's `ns` macro:

``` clojure
(:require [clojure.math :as math])
```

or else in the repl you've loaded it like so:

``` clojure
(require '[clojure.math :as math])
```

## Recipes

### Boxed and Unboxed Math

_This section is adapted from [Alex Miller's "Inside Clojure" blog post on boxed math warnings](https://insideclojure.org/2014/12/15/warn-on-boxed/)._

By default, Clojure treats numbers as either `java.lang.Long` or
`java.lang.Double` -- known as "boxed numbers" -- rather than the underlying
primitives `long` and `double`. Values are passed around as `java.lang.Object`.
In performance-sensitive code, you may want to use the primitive types
directly and Clojure supports type hints for this purpose.

``` clojure
(defn sum-squares [a b]
  (+ (* a a) (* b b)))
```

In this function, both `a` and `b` are `java.lang.Object` and when you call
`(sum-squares 3 4)` both `3` and `4` are boxed (as `java.lang.Long`) and
the math is compiled into a sequence of calls to methods in `clojure.lang.Numbers`
that accept `java.lang.Object` arguments.

We can improve efficiency by using type hints for both the arguments and the
return type:

```clojure
(defn sum-squares ^long [^long a ^long b]
  (+ (* a a) (* b b)))
```

This lets Clojure produce a more efficient version of the function that
accepts primitive arguments and produces a primitive result.

A useful Var in this context is `*unchecked-math*` which controls whether
the compiler will generate checked or unchecked math operations. It can
also warn you about boxed math operations.

``` clojure
user=> (set! *unchecked-math* :warn-on-boxed)
:warn-on-boxed
user=> (def x 3)
#'user/x
user=> (def y 4)
#'user/y
user=> (* x y)
Boxed math warning, NO_SOURCE_PATH:1:1 - call: public static java.lang.Number clojure.lang.Numbers.unchecked_multiply(java.lang.Object,java.lang.Object).
12
```

You can also set `*unchecked-math*` to `true`, which will cause the compiler
to generate primitive math operations, if it can, without checking for overflow.

### Simple Math

`clojure.core` provides a number of basic math operations as functions:

``` clojure
(+ 3 4)    ;=> 7
(- 3 4)    ;=> -1
(* 3 4)    ;=> 12
(/ 3 4)    ;=> 3/4  (an exact ratio)
(/ 3.0 4)  ;=> 0.75
(double (/ 3 4)) ;=> 0.75 (convert a ratio to a double)

(inc 5)    ;=> 6
(dec 5)    ;=> 4
```

For doing integer division and getting remainders (modulus), see the
docs for
[quot](https://clojuredocs.org/clojure.core/quot),
[rem](https://clojuredocs.org/clojure.core/rem), and
[mod](https://clojuredocs.org/clojure.core/mod), which are all provided
in `clojure.core`.

`abs`, `min`, and `max` are also provided in `clojure.core` and are optimized
for both `long` and `double` primitive types, as well as working with boxed
numbers.

For exponents, square roots, rounding, ceiling, floor, etc, see the
[`clojure.math` namespace](https://clojure.github.io/clojure/clojure.math-api.html):

``` clojure
(math/pow 2 3)   ;=> 8.0
(math/sqrt 9)    ;=> 3.0
(math/round 3.4) ;=> 3
(math/round 3.6) ;=> 4
(math/ceil 3.4)  ;=> 4.0
(math/floor 3.6) ;=> 3.0
```

Prior to Clojure 1.11, you could use the Java platform's `java.lang.Math` class
for these operations, e.g., `(Math/pow 2 3)`.

### Trigonometry

Use what `clojure.math` provides, for example:

``` clojure
math/PI       ;=> 3.14159...
(math/sin x)
(math/cos x)
(math/tan x)
```

As with **Simple Math** above, prior to Clojure 1.11, you could use the Java
platform's `java.lang.Math` class for these operations, e.g., `(Math/sin x)`.

### Combinatorics

For combinatoric functions (such as `combinations` and
`permutations`), see the
[math.combinatorics](https://clojure.github.io/math.combinatorics/)
contrib library.
