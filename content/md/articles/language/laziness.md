{:title "Language: Laziness"
 :page-index 2900
 :klipse true
 :layout :page}

This guide covers:

  * What are lazy sequences
  * Pitfalls with lazy sequences
  * How to create functions that produce lazy sequences
  * How to force evaluation

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).



## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.12.



## Overview

Clojure is not a [lazy language](http://en.wikipedia.org/wiki/Lazy_evaluation).

However, Clojure supports *lazily evaluated sequences*. This means that sequence elements are not
available ahead of time and are produced as the result of a computation. The computation
is performed as needed. Evaluation of lazy sequences is known as *realization*.

Lazy sequences can be infinite (e.g., the sequence of Fibonacci numbers, a sequence of
dates with a particular interval between them, and so on). If a lazy sequence is finite,
when its computation is completed, it becomes *fully realized*.

When it is necessary to fully realize a lazy sequence, Clojure provides a way to
*force evaluation* (force realization).


## Benefits of Lazy Sequences

Lazy sequences have two main benefits:

 * They can be infinite
 * Full realization of interim results can be avoided


## Producing Lazy Sequences

Lazy sequences are produced by functions. Such functions either use the `clojure.core/lazy-seq` macro
or other functions that produce lazy sequences.

`clojure.core/lazy-seq` accepts one or more forms that produce a sequence, or `nil` when the sequence
is fully realized, and returns a seqable data structure that evaluates the body the first time
the value is needed and then caches the result.

For example, the following function produces a lazy sequence of random UUIDs strings:

```klipse-clojure
(defn uuid-seq
  []
  (lazy-seq
   (cons (str (random-uuid))
         (uuid-seq))))
```

> Note: the `random-uuid` function was added to Clojure in version 1.11 but was previously available in ClojureScript.

Another example:

```klipse-clojure
(defn fib-seq
  "Returns a lazy sequence of Fibonacci numbers"
  ([]
     (fib-seq 0 1))
  ([a b]
     (lazy-seq
      (cons b (fib-seq b (+ a b))))))
```

Both examples use `clojure.core/cons` which prepends an element to a sequence. The sequence
can in turn be lazy, which both of the examples rely on.

Even though both of these sequences are infinite, taking first N elements from each does
return successfully:

```klipse-clojure
(take 3 (uuid-seq))
```

```klipse-clojure
(take 10 (fib-seq))
```

```klipse-clojure
(take 20 (fib-seq))
```

## Realizing Lazy Sequences (Forcing Evaluation)

Lazy sequences can be forcefully realized with `clojure.core/dorun` and
`clojure.core/doall`. The difference between the two is that `dorun`
throws away all results and is supposed to be used for side effects,
while `doall` returns computed values:

```klipse-clojure
(dorun (map inc [1 2 3 4]))
```

```klipse-clojure
(doall (map inc [1 2 3 4]))
```


## Commonly Used Functions That Produce Lazy Sequences

Multiple frequently used `clojure.core` functions return lazy sequences,
most notably:

 * `map`
 * `filter`
 * `remove`
 * `range`
 * `take`
 * `take-while`
 * `drop`
 * `drop-while`

The following example uses several of these functions to return 10 first
even numbers in the range of [0, n):

```klipse-clojure
(take 10 (filter even? (range 0 100)))
```

Several functions in `clojure.core` are designed to produce lazy
sequences:

 * `repeat`
 * `iterate`
 * `cycle`

For example:

```klipse-clojure
(take 3 (repeat "ha"))
```

```klipse-clojure
(take 5 (repeat "ha"))
```

```klipse-clojure
(take 3 (cycle [1 2 3 4 5]))
```

```klipse-clojure
(take 10 (cycle [1 2 3 4 5]))
```

```klipse-clojure
(take 3 (iterate inc 1))
```

```klipse-clojure
(take 5 (iterate inc 1))
```


## Lazy Sequences Chunking

There are two fundamental strategies for implementing lazy sequences:

 * Realize elements one-by-one
 * Realize elements in groups (chunks, batches)

In Clojure, most lazy sequences are *chunked* (realized in chunks).

For example, in the following code

```klipse-clojure
(take 10 (map inc (range)))
```

one-by-one realization would realize one element 10 times. With chunked sequences,
elements are realized ahead of time in chunks (32 elements at a time).

You can see this in action:

```klipse-clojure
(take 10 (map #(do (println %) (inc %)) (range 100)))
```

What you'll see here is that even tho' the result is a sequence of 10 elements,
32 elements are printed.
This is because realizing
the first element causes the whole of the first chunk to be realized.

This typically reduces the number of realizations and, for many common workloads, improves
efficiency of lazy sequences.

Clojure on the JVM has optimized some functions, such as `range`, to produce
individual elements efficiently without chunking:

```clojure
user=> (take 10 (map #(do (println %) (inc %)) (range)))
(0
1
1 2
2 3
3 4
4 5
5 6
6 7
7 8
8 9
9 10)
user=>
```

What you'll see here is that only 10 elements are printed, not 32, and
they are printed one-by-one, as each element of the sequence is realized.

If you used `(range 100)` instead of `(range)` in the above example, you'd see
32 elements printed, as before.

## Contributors

Michael Klishin <michael@defprotocol.org>, 2013 (original author)
