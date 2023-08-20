{:title "Data Structures (Help wanted)"
 :layout :page :page-index 4050}


## Help wanted

Please follow the [instructions](https://github.com/clojure-doc/clojure-doc.github.io/tree/source#how-to-contribute) on how to contribute and start writing over [here](https://github.com/clojure-doc/clojure-doc.github.io/blob/source/content/md/articles/cookbooks/data_structures.md)

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).

## Intro

This cookbook covers some common tasks with core Clojure data structures. It assumes that the reader is familiar with foundational read and write operations (get, conj, assoc, update, etc). For more coverage of getting started with Clojure data structures, some recommended resources are:
- [Clojure.org's reference on collections](https://clojure.org/reference/data_structures#Collections)
- [Intro to Clojure: Data Structures](/articles/tutorials/introduction/#data-structures)
- [Intro to Clojure: Functions for Creating Data Structures](/articles/tutorials/introduction/#functions-for-creating-data-structures) - also, the section right after this one, which covers manipulating them

## Vectors

### Intro
Vectors are probably the most commonly used data structure for sequential data that isn't code. The random access capability and the fact that vectors aren't treated as function calls make them often a better choice than lists.

### Constructing Vectors

`mapv` and `filterv` are eager versions of `map` and `filter` that return vectors
```clojure
user=> (mapv second [[1 1] [2 4] [3 9]])
[1 4 9]

user=> (filterv even? (range 10))
[0 2 4 6 8]
```

### Accessing Elements
Vectors implement the stack protocol, meaning `peek` and `pop` return the last element and the vector without the last element, respectively.
```clojure
user=> (peek [7 8 9])
9
user=> (pop [7 8 9])
[7 8]
```

### (Non-)emptiness

Sometimes it's desirable to treat an empty vector as a falsey value, especially in conditionals. The `not-empty` function will return its argument if it's not empty, otherwise it will return nil.
```clojure
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

### Linear-time Operations

Operations that need to search through elements one-by-one or operate on a large number of elements are less efficient, but still valuable in some contexts.

The `replace` function has a special case for vectors that returns a vector. It takes a map where the keys are the values to replace and the values are the replacements. 
```clojure
; change :begin to :start and :finish to :end
user=> (replace {:begin :start, :finish :end} 
                [:begin :middle :finish :begin :finish])
[:start :middle :end :start :end]
```

"Deleting" an item from anywhere but the last position is not a 'fast' operation, because conceptually all the indexes after the deleted item need to be decremented by one. We can use `into` to combine two sub-vectors, but the trade-off is that this operation adds the items from the second sub-vector one at a time, so this function is O(n) in the size of the second sub-vector.
```clojure
user=> (defn delete-at [v pos]
         (into (subvec v 0 pos) (subvec v (inc pos))))
#'user/delete-at
user=> (delete-at [:a :b :c] 1)
[:a :c]
```

Inserting an item at an arbitrary position has the same issue as deleting - it potentially changes a lot of indexes. An implementation is also similar to `delete-at`, with the same caveat about efficiency.
```clojure
user=> (defn insert-at [v pos value]
         (into (conj (subvec v 0 pos) value) (subvec v pos)))
#'user/insert-at
user=> (insert-at [:a :b :c] 2 "interloper!")
[:a :b "interloper!" :c]
```

### Searching

Checking for the existence of a _value_ (as opposed to an index) requires examining the elements one-by-one. A point of confusion that sometimes arises is the `contains?` function, which searches an associative collection for the existence of a _key/index_, and is very seldom desirable for vectors.
```clojure
; `contains?` looks for an index!!!
user=> (contains? [:a :b :c] :b)
false
user=> (contains? [:a :b :c] 2)
true ; because the indexes are 0, 1, and 2
```

A commonly-used way to check for an occurrence of a certain value in a collection is the `some` function with a set as a predicate. `some` stops at the first truthy return, so there's no 'wasted' computation.
```clojure
user=> (some #{:b} [:a :b :c])
:b
```

Note that searching for `false` or `nil` in this way won't work. In those cases use the `nil?` or `false?` functions.

Java interop can be used to get the first or last index of a specific value.
```clojure
user=> (.indexOf [:a :b :c :b :a] :b)
1
user=> (.lastIndexOf [:a :b :c :b :a] :b)
3
; indexOf returns -1 when the value isn't found
user=> (.indexOf [:a :b] :c)
-1
```

`keep-indexed` can be used to find all the indexes of a value (or indexes that match some predicate). Note that this is actually a function that works on (and returns) a sequence.
```clojure
user=> (defn indexes-of [search-value coll]
         (keep-indexed (fn [i v] (when (= search-value v) i)) coll))
#'user/indexes-of
user=> (indexes-of 15 [5 10 15 30 15 5])
(2 4)
```

## Maps

### Building Maps

`zipmap` associates corresponding entries from two seqs into a map. This is used here to assign people to teams.
```clojure
; assign participants to teams
user=> (let [participants ["Mike" "Tina" "Alice" "Fred"]
             team-nums    (cycle [1 2])]
         (zipmap participants team-nums))
{"Mike" 1, "Tina" 2, "Alice" 1, "Fred" 2}
```

`group-by` could be used to build the team rosters, but the result still has the team numbers in the roster.
```clojure
user=> (group-by val {"Mike" 1, "Tina" 2, "Alice" 1, "Fred" 2})
{1 [["Mike" 1] ["Alice" 1]], 2 [["Tina" 2] ["Fred" 2]]}
```

`update-vals` (added in Clojure 1.11) could be tacked on to clean up the output
```clojure
user=> (-> (group-by val {"Mike" 1, "Tina" 2, "Alice" 1, "Fred" 2})
           (update-vals #(mapv first %)))
{1 ["Mike" "Alice"], 2 ["Tina" "Fred"]}
```

`reduce-kv` allows more control over the values, meaning it's possible to go directly to "clean" output (and maybe even different data structures).
```clojure
user=> (reduce-kv
        (fn [acc k v] (update acc v (fnil conj #{}) k))
        {} {"Mike" 1, "Tina" 2, "Alice" 1, "Fred" 2})
{1 #{"Alice" "Mike"}, 2 #{"Tina" "Fred"}}
```

`frequencies` takes a collection and returns a map of elements in that collection to how many times it appears. This is used here for a rudimentary word counter.
```clojure
user=> (-> "the cat in the hat fell in the vat"
           (str/split #" ")
           frequencies)
{"the" 3, "cat" 1, "in" 2, "hat" 1, "fell" 1, "vat" 1}
```

### Accessing Entries

While `select-keys` can be used to create a submap, it is sometimes desirable to pull some keys into a sequence. In this example, `juxt` is used to make a vector of the `:x` and `:y` values of maps for passing to another function.
```clojure
user=> (defn manhattan-distance [[x1 y1] [x2 y2]]
        (let [distance (comp abs -)]
         (+ (distance x1 x2) (distance y1 y2))))
#'user/manhattan-distance
user=> (let [point1 {:x 2 :y 0}
             point2 {:x 0 :y 2}
             xy-coords (juxt :x :y)]
        (manhattan-distance (xy-coords point1)
                            (xy-coords point2)))
4 
```

## Lists

## Sets

## Sequences
