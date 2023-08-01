{:title "Data Structures (Help wanted)"
 :layout :page :page-index 4050}


## Help wanted

Please follow the [instructions](https://github.com/clojure-doc/clojure-doc.github.io/tree/source#how-to-contribute) on how to contribute and start writing over [here](https://github.com/clojure-doc/clojure-doc.github.io/blob/source/content/md/articles/cookbooks/data_structures.md)

This cookbook covers working with core Clojure data structures.

## Intro

Clojure comes with a number of aggregate data structures that have different attributes when it comes to access patterns, ordering, allowing duplicates, etc. 
This cookbook will cover the most common of these data structures, and also a core abstraction (the sequence) that can be applied across all of them.

All the data structures/collections to be discussed have some common properties:
- they're immutable, so when "change" (adding/subtracting/modifying elements) is mentioned, it really means that a new collection is returned that reflects the change  to the original
- they're fully persistent, meaning that when one is "changed", the unchanged version is still available and can be "changed" again
- they can have metadata
- they are 'counted', meaning that getting their size with the `count` function is a constant-time operation
- they can be turned into sequences, allowing for a wealth of core functions to be used on any of them
- they implement Java's `Iterable` interface, meaning that Java code that operates on Iterables can be used directly

> #### A note about "near-constant time"
> In order to provide immutability and still allow for efficient "changes", many of Clojure's data structures are implemented so that some lookup/change operations happen in O(log<sub>32</sub>n) time. These operations may be referred to as "near-constant time" as a shorthand.


## Vectors

A vector is a collection of elements (of the same or different types) where:
- the order of elements is significant
- each element has a zero-based index
- near-constant time "random access" by index is supported (e.g. accessing the 300th element takes about the same time as accessing the third element)
- adding an element to the end is near-constant time

### Constructing a vector

Vectors can be written using a literal notation or with a function call, and
the REPL will (by default) print a vector using the literal notation. The vectors
created below contain the keyword `:a`, the string `"b"`, and the number
`3`.

``` clojure
; using the vector literal notation of []
user=> [:a "b" 3]
[:a "b" 3]

; calling the vector function
user=> (vector :a "b" 3)
[:a "b" 3]
```

### Basics
Because vector access is most efficient by index, they can be thought of as
"associative" - each index is associated with a value.

#### Reading Elements
``` clojure
; define `v` to be a vector (note that collections can be nested)
user=> (def v [:a :b :c [:y :z]])
#'user/v

; get an element by its index
user=> (get v 2)
:c

; using an index beyond the end of the vector returns nil
user=> (get v 26)
nil

; `nth` works a lot like `get`, and can be used to communicate that the
; intent is to use the vector for its sequential properties
user=> (nth v 2)
:c

; `nth` will throw an exception when given an index beyond the end of the 
; vector (contrast this with the behavior of `get`)
user=> (nth v 4)
Execution error (IndexOutOfBoundsException)

; vectors can be called as functions
; to look up an index, much like calling `nth`
user=> (v 2)
:c
```

#### Writing elements
``` clojure
; `conj` adds one or more items to the end of a vector
user=> (conj v 7 8 9)
[:a :b :c [:y :z] 7 8 9]

; remember immutability; `v` isn't changed by `conj`
; to remember the result, bind the return value using something like `def` or `let`
user=> v
[:a :b :c [:y :z]]

; `assoc` can replace an item at an index, up to and including one 
; index beyond the end (in which case it will append the item)
user=> (assoc v 2 "changed")
[:a :b "changed" [:y :z]]

user=> (assoc v 4 "additional")
[:a :b :c [:y :z] "additional"]

; but assoc will error with any indexes greater than the count of elements
user=> (assoc v 5 "uh-oh")
Execution error (IndexOutOfBoundsException)

; `update` changes an element at an index by applying a function
user=> (update v 1 (fn [x] (vector x (name x))))
[:a [:b "b"] :c [:y :z]]
```

### Recipes

#### More Accessing Elements
``` clojure
; setup a vector to use for our recipes
user=> (def v [42 nil [7 8 9] "a string" :my-ns/some-key])
#'user/v

; get/assoc/update have `-in` counterparts for getting to
; nested collections
user=> (get-in v [2 0])
7
user=> (assoc-in v [2 1] "a new element")
[42 nil [7 "a new element" 9] "a string" :my-ns/some-key]
user=> (update-in v [2 2] + 6)
[42 nil [7 8 15] "a string" :my-ns/some-key]

; what happens if get is used on a vector that contains nils?
user=> (get [nil nil] 1)
nil
; and with an index that's beyond the end?
user=> (get [nil nil] 42)
nil

; get takes an optional 'not present' argument to
; differentiate between a nil in the vector and an index
; that doesn't exist
user=> (get [nil nil] 1 :whoops)
nil
user=> (get [nil nil] 42 :whoops)
:whoops

; `into` uses `conj` to put items from one
; collection onto another
user=> (into v ["some" "more" "elements"])
[42 nil [7 8 9] "a string" :my-ns/some-key "some" "more" "elements"]

; `subvec` returns the elements between two indexes
user=> (subvec v 2 4)
[[7 8 9] "a string"]

; vectors are also usable as stacks, meaning `peek` and `pop` return
; the last element and the vector without the last element, respectively
user=> (peek v)
:my-ns/some-key
user=> (pop v)
[42 nil [7 8 9] "a string"]
```

#### Counting and (non-)emptiness
``` clojure
; count is constant-time
user=> (count [:x :y :z])
3

; check if empty
user=> (empty? [])
true
user=> (empty? [1])
false
```

Sometimes it's desirable to treat an empty vector as a falsey value, especially in conditionals. The `not-empty` function will return its argument if it's not empty, otherwise it will return nil.
``` clojure
user=> (defn notate-range 
         "takes a vector of [start end] (both optional) and returns a range notation"
         [coords]
         (if-not (empty? coords)
           (let [[start end] coords]
             (str start ".." end))
           "empty range"))
#'user/notate-range
user=> (notate-range [1 5])
"1..5"
user=> (notate-range [7])
"7.."
user=> (notate-range [])
"empty range"

; we can also write this as
user=> (defn notate-range 
         "takes a vector of [start end] (both optional) and returns a range notation"
         [coords]
         (if-let [[start end] (not-empty coords)]
           (str start ".." end)
           "empty range"))
```
Here, `not-empty` is used to make the conditional false (the empty vector is truthy, and `not-empty` makes it `nil`).

The code used thus far is mostly quite efficient because it uses the fast access mechanisms of vectors. Adding an item to the end of a vector and operating on individual elements are near-constant time operations. Operations that need to search through elements one-by-one or operate on a large number of elements are less efficient, but still valuable.

#### Searching/Linear Operations

The `replace` function has a special case for vectors. It takes a map where the keys are the values to replace and the values are the replacements. 
``` clojure
; change :begin to :start and :finish to :end
user=> (replace {:begin :start, :finish :end} 
                [:begin :middle :finish :begin :finish])
[:start :middle :end :start :end]
```

"Deleting" an item from anywhere but the last position is not a 'fast' operation, because conceptually all the indexes after the deleted item need to be decremented by one. We can use `into` to combine two sub-vectors, but the trade-off is that this operation adds the items from the second sub-vector one at a time.
``` clojure
user=> (defn delete-at [v pos]
         (into (subvec v 0 pos) (subvec v (inc pos))))
#'user/delete-at
user=> (delete-at [:a :b :c] 1)
[:a :c]
```

Inserting an item at an arbitrary position has the same issue as deleting - it potentially changes a lot of indexes. An implementation is also similar to `delete-at`, with the same caveat about efficiency.
``` clojure
user=> (defn insert-at [v pos value]
         (into (conj (subvec v 0 pos) value) (subvec v pos)))
#'user/insert-at
user=> (insert-at [:a :b :c] 2 "interloper!")
[:a :b "interloper!" :c]
```

Checking for the existence of a _value_ (as opposed to an index) requires examining the elements one-by-one. A point of confusion that sometimes arises is the `contains?` function, which searches an associative collection for the existence of α _key/index_, and is very seldom desirable for vectors.
``` clojure
; `contains?` looks for an index!!!
user=> (contains? [:a :b :c] :b)
false
user=> (contains? [:a :b :c] 2)
true ; because the indexes are 0, 1, and 2
```

A commonly-used way to search collections for a certain value is the `some` function with a set as a predicate. `some` stops at the first truthy return, so there's no 'wasted' computation.
``` clojure
user=> (some #{:b} [:a :b :c])
:b
```

More generally, `some` returns the first truthy value returned by applying a function to successive elements of a collection.
``` clojure
; does the vector have any keywords?
user=> (some keyword? [14 26 :two])
true
; what's the first set member in the vector?
user=> (some #{6 7 8} [1 8 2 6])
8
```

Java interop can be used to get the first or last index of a specific value.
``` clojure
user=> (.indexOf [:a :b :c :b :a] :b)
1
user=> (.lastIndexOf [:a :b :c :b :a] :b)
3
; indexOf returns -1 when the value isn't found
user=> (.indexOf [:a :b] :c)
-1
```

`keep-indexed` can be used to find all the indexes. Note that this is actually a function
that works on (and returns) sequences.
``` clojure
user=> (defn indexes-of [search-value coll]
         (keep-indexed (fn [i v] (when (= search-value v) i)) coll))
#'user/indexes-of
user=> (indexes-of 15 [5 10 15 30 15 5])
(2 4)
```

### Maps

### Lists

### Sets

### Sequences



This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).
