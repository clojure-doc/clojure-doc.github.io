{:title "Language: Collections and Sequences"
 :page-index 2300
 :klipse true :toc true
 :layout :page}

This guide covers:

 * Collections in Clojure
 * Sequences in Clojure
 * Core collection types
 * Key operations on collections and sequences
 * Other topics related to collections and sequences

This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>
(including images & stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).

## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.11.


## Overview

Clojure provides a number of powerful abstractions including *collections* and *sequences*.
When working with Clojure,
many operations are expressed as a series of operations on collections or sequences.

Most of Clojure's core library treats collections and sequences the same way, although
sometimes a distinction has to be made (e.g. with lazy infinite sequences).

`clojure.core` provides many fundamental operations on collections, such as:
`map`, `filter`, `remove`, `take`, and `drop`.
Basic operations on collections and sequences can be combined to implement
more complex operations.

### Clojure Collections are Immutable (Persistent)

Clojure collections are *immutable* (*persistent*). The term "persistent data structures" has
nothing to do with durably storing them on disk. What it means is that collections are
mutated (updated) by producing new collections. To quote Wikipedia:

> In computing, a persistent data structure is a data structure that always preserves
> the previous version of itself when it is modified. Such data structures are effectively
> immutable, as their operations do not (visibly) update the structure in-place, but instead
> always yield a new updated structure.

Clojure's persistent data structures are implemented as trees and [*tries*](https://en.wikipedia.org/wiki/Hash_array_mapped_trie) and
typically have O(log<sub>32</sub> *n*) access complexity where *n* is the number of elements.


## The Collection Abstraction

Clojure has a collection abstraction with several key operations supported for
all collection implementations. They are

 * `=`: checks value equality of a collection compared to other collections
 * `count`: returns number of elements in a collection
 * `conj`: adds an item to a collection in the most efficient way
 * `empty`: returns an empty collection of the same type as the argument
 * `seq`: gets a sequence of a collection

Collections satisfy the `coll?` predicate.

These functions work on all core Clojure collection types.


## Core Collection Types

Clojure has several core collection types:

 * Maps (called hashes or dictionaries in some other languages)
 * Vectors
 * Lists
 * Sets

### Maps

Maps associate keys with values. Both keys and values can be of any type, but
keys must be comparable. There are several implementations of maps with
different guarantees about ordering but the general hash map in Clojure is
unordered.
Hash maps are typically instantiated with literals:

``` clojure
{:language "Clojure" :creator "Rich Hickey"}
```

Commas can be used in map literals (Clojure compiler treats the comma as whitespace):

``` clojure
{:language "Clojure", :creator "Rich Hickey"}
```

`clojure.core/sorted-map` and `clojure.core/array-map` produce ordered maps:

```klipse-clojure
(sorted-map :language "Clojure" :creator "Rich Hickey")
;; ⇒ {:creator "Rich Hickey", :language "Clojure"}
```

```klipse-clojure
(array-map :language "Clojure" :creator "Rich Hickey")
;; ⇒ {:language "Clojure", :creator "Rich Hickey"}
```

Unsurprisingly, map literals must contain an even number of forms (as many keys as values). Otherwise
the code will not compile:

```klipse-clojure
{:language "Clojure" :creator}
```

In general, the only major difference between Clojure maps and maps/hashes/dictionaries in some other languages
is that Clojure maps are *immutable*. When a Clojure map is modified, the result is a new map that internally
has structural sharing (for efficiency reasons) but semantically is a separate immutable value.

You can `conj` a key/value pair into a map:

```klipse-clojure
(conj {:language "Clojure"} [:creator "Rich Hickey"])
;; ⇒ {:creator "Rich Hickey", :language "Clojure"}
```

Maps can be iterated over in their "natural order" so they are `seqable?`
-- you can call `seq` on them -- but they are not `sequential?` as they have
no guaranteed order. You can get
a sequence of keys by calling `keys` or a sequence of values by calling `vals`
on the map, and the order of those sequences will be consistent with each other and also
with the order of key/value pairs you get by calling `seq` on the same map.
Maps are also `associative?` and `counted?`.

See also the [official Clojure guide for maps](https://clojure.org/guides/learn/hashed_colls#_maps) on clojure.org.

#### Maps As Functions

Maps in Clojure can be used as functions on their keys. See the [Functions guide](/articles/language/functions/#maps-as-functions)
for more information.

#### Keywords As Functions

Keywords in Clojure can be used as functions on maps. See the [Functions guide](/articles/language/functions/#keywords-as-functions)
for more information.


### Vectors

Vectors are collections that offer efficient random access (by index). They are typically instantiated with
literals:

``` clojure
[1 2 3 4]

["clojure" "scala" "erlang" "f#" "haskell" "ocaml"]
```

Commas can be used to separate vector elements (Clojure compiler treats
the comma as whitespace):

``` clojure
["clojure", "scala", "erlang", "f#", "haskell", "ocaml"]
```

Unlike lists, vectors are not used for function invocation. They are, however, used to make certain
forms (e.g. the list of locals in `let` or parameters in `defn`) stand out visually. This was
an intentional decision in Clojure design.

You can `conj` a value into a vector and it will be appended:

```klipse-clojure
(conj [1 2 3 4] 5)
;; ⇒ [1 2 3 4 5]
```

Vectors are both `seqable?` and `sequential?` as their natural order is based
on the indices into the vector. Vectors are `associative?` and `counted?`.
Vectors are associative on their indices:

```klipse-clojure
(get [1 2 3 4] 2)
;; => 3
```

```klipse-clojure
(assoc [1 2 3 4] 2 :three)
;; ⇒ [1 2 :three 4]
```

See also the [official Clojure guide for vectors](https://clojure.org/guides/learn/sequential_colls#_vectors) on clojure.org.

### Lists

Lists in Clojure are singly linked lists. Access or modifications of list head is efficient, random access
is not.

Lists in Clojure are special because they represent code forms, from function calls to macro calls to special forms.
Code is data in Clojure and it is represented primarily as lists:

```klipse-clojure
(empty? [])
```

First item on the list is said to be in the *calling position*.

When used as "just" data structures, lists are typically instantiated with literals with quoting:

```klipse-clojure
'(1 2 3 4)
```

```klipse-clojure
'("clojure" "scala" "erlang" "f#" "haskell" "ocaml")
```

Or you can explicitly use the `list` form:

```klipse-clojure
(list 1 2 3 4)
;; ⇒ (1 2 3 4)
```

Commas can be used to separate list elements (Clojure compiler treats
the comma as whitespace):

```klipse-clojure
'("clojure", "scala", "erlang", "f#", "haskell", "ocaml")
```

You can `conj` a value into a list and it will be prepended:

```klipse-clojure
(conj '(1 2 3 4) 5)
;; ⇒ (5 1 2 3 4)
```

Lists are both `seqable?` and `sequential?` but not all lists are `counted?`:
lazily constructed lists, such as `(cons 1 (list 1 2 3 4))`, are not `counted?`
because they do not have a known length until they are fully realized. You
can still call `count` on such lists (as long as they are not infinite!) but
that will cause the entire list to be realized.


See also the [official Clojure guide for lists](https://clojure.org/guides/learn/sequential_colls#_lists) on clojure.org.

#### Lists and Metaprogramming in Clojure

Metaprogramming in Clojure (and other Lisp dialects) is different from metaprogramming in, say, Ruby, because
in Ruby metaprogramming is *primarily* about producing strings while in Clojure it is about producing
*data structures* (mostly *lists*). For sophisticated DSLs, producing data structures directly lets
developers avoid a lot of incidental complexity that string generation brings along.

This topic is covered in detail in the [Macros and Metaprogramming](/articles/language/macros/).


### Sets

Sets are collections that offer efficient membership check operation and only allow each element to appear in the collection
once. They are typically instantiated with literals:

```klipse-clojure
#{1 2 3 4}
```

```klipse-clojure
#{"clojure" "scala" "erlang" "f#" "haskell" "ocaml"}
```

Commas can be used to separate set elements (Clojure compiler treats the as whitespace):

```klipse-clojure
#{"clojure", "scala", "erlang", "f#", "haskell", "ocaml"}
```

You can `conj` a value into a set:

```klipse-clojure
(conj #{:tea :coffee} :juice)
;; ⇒ #{:coffee :tea :juice}
```

Like maps, sets are `seqable?` but not `sequential?` because they have no
guaranteed order. You can call `seq` on a set to get a sequence of its elements
in "natural order" (based on the hash of the elements, essentially).
Sets are `counted?` but they are not `associative?` (they support lookup by
their elements but have no associated values for those "keys").

See also the [official Clojure guide for sets](https://clojure.org/guides/learn/hashed_colls#_sets) on clojure.org.

#### Sets As Functions

Sets in Clojure can be used as functions on their elements. See the [Functions guide](/articles/language/functions/#sets-as-functions)
for more information.


#### Set Membership Checks

The most common way of checking if an element is in a set is by using set as a function:

```klipse-clojure
(#{1 2 3 4} 1)
;; ⇒ 1
```

```klipse-clojure
(#{1 2 3 4} 10)
;; ⇒ nil
```

```klipse-clojure
(if (#{1 2 3 4} 1)
  :hit
  :miss)
;; ⇒ :hit
```



## Sequences

The sequence abstraction represents a sequential view of a collection or collection-like
entity (computation result).

`clojure.core/seq` is a function that produces a sequence over the given argument.
Data types that `clojure.core/seq` can produce a sequence over are called *seqable*:

 * Clojure collections
 * Java maps
 * All iterable types (types that implement `java.util.Iterable`)
 * Java collections (`java.util.Set`, `java.util.List`, etc)
 * Java arrays
 * All types that implement `java.lang.CharSequence` interface, including Java strings
 * All types that implement `clojure.lang.Seqable` interface
 * nil


The sequence abstraction supports several operations:

 * `first`
 * `rest`
 * `next`

and there are two ways to produce a sequence:

 * `seq` produces a sequence over its argument (often a collection)
 * `lazy-seq` creates a *lazy sequence* (that is produced by performing computation)

### seq, cons, list*

`clojure.core/seq` takes a single argument and returns a sequential view over it:

```klipse-clojure
(seq [1 2 3])
;; ⇒ (1 2 3)
```

When given an empty collection or sequence, `clojure.core/seq` returns nil:

```klipse-clojure
(seq [])
;; ⇒ nil
```

this is commonly used in the following pattern:

```klipse-clojure
(def xs [1 2 3])
(if (seq xs)
  (println "Do something with this sequence")
  (println "Do something else"))
```

Another function that constructs sequences is `clojure.core/cons`. It prepends values to the head of
the given sequence:

```klipse-clojure
(cons 0 (range 1 3))
;; ⇒ (0 1 2)
```

`clojure.core/list*` does the same for a number of values:

```klipse-clojure
(list* 0 1 (range 2 5))
;; ⇒ (0 1 2 3 4)
```

`clojure.core/cons` and `clojure.core/list*` are primarily used to produce lazy sequences and in metaprogramming (when writing
macros). As far as metaprogramming goes, sequences and lists are the same and it is common to
add items in the beginning of the list (into the *calling position*).

Note that `clojure.core/cons` does not create "cons cells" and lists in Clojure are not implemented
as linked "cons cells" (like in many other dialects of Lisp).


### first, rest, next

`clojure.core/first` returns the first item in the sequence. `clojure.core/next` and `clojure.core/rest`
return the sequence without the first element:

```klipse-clojure
(first (seq [1 2 3 4 5 6]))
;; ⇒ 1

(rest (seq [1 2 3 4 5 6]))
;; ⇒ (2 3 4 5 6)

(next (seq [1 2 3 4 5 6]))
;; ⇒ (2 3 4 5 6)
```

The difference between them is what they return on a single element sequence:

```klipse-clojure
(rest (seq [:one]))
;; ⇒ ()
```

```klipse-clojure
(next (seq [:one]))
;; ⇒ nil
```

Note that all three functions implicitly call `seq` on their argument so you
can omit the explicit call:

```klipse-clojure
(first [1 2 3 4 5 6])
;; ⇒ 1

(rest [1 2 3 4 5 6])
;; ⇒ (2 3 4 5 6)

(next [1 2 3 4 5 6])
;; ⇒ (2 3 4 5 6)
```



### Lazy Sequences in Clojure

*Lazy sequences* are produced by performing computation or I/O. They can be infinite
or not have exact length (e.g. a sequence of all powers of 2 or an audio stream).

Lazy sequences is an broad topic and covered in the [Laziness](/articles/language/laziness/) guide.



## Key Operations on Collections and Sequences

Below is an overview of `clojure.core` functions that work on collections and sequences. Most of them
work the same way for all types of collections, however, there are exception to this rule. For example,
functions like `clojure.core/assoc`, `clojure.core/dissoc` and `clojure.core/get-in` only really
make sense in the context of maps and other associative data structures (for example, records).

`clojure.core/conj` adds elements to a collection in the most efficient manner, which depends on
collection implementation details and won't be the same for vectors and lists.

In general, Clojure design emphasizes that operations on collections and sequences should be uniform and
follow the principle of least surprise. In real world projects, however, the difference between
algorithmic complexity and other runtime characteristics of various collection types often cannot
be ignored. Keep this in mind.

You can find more information in the [clojure.core Overview](/articles/language/core_overview/) and [Clojure cheatsheet](https://clojure.org/cheatsheet).


### count

Returns a count of the number of items in a collection. An argument of nil returns 0.

```klipse-clojure
(count "Hello")
;; ⇒ 5
```

```klipse-clojure
(count [1 2 3 4 5 6 7])
;; ⇒ 7
```

```klipse-clojure
(count nil)
;; ⇒ 0
```

Note that count does not return in constant time for all collections. This can be determined with `counted?`.
Keep in mind that lazy sequences must be realized to get a count of the items. This is often not intended and
can cause a variety of otherwise cryptic errors.

```klipse-clojure
(counted? "Hello")
;; ⇒ false
```

(even tho' Clojure strings are Java `String`s and have a known length without iteration)


```klipse-clojure
;; will be fully realized when using (count (range 10))
(counted? (range 10))
;; ⇒ true
```

(a range with an upper bound knows its length without iteration)

```klipse-clojure
;; (range) is an infinite sequence
(counted? (range))
;; ⇒ false
```

(an unbounded range has no known length)

```klipse-clojure
;; Constant time return of (count)
(counted? [1 2 3 4 5])
;; ⇒ true
```

### conj

`conj` is short for "conjoin". As the name implies, `conj` takes a collection and argument(s) and returns the collection with those arguments added.

Adding items to a collection occurs at different places depending on the concrete type of collection.

List addition occurs at the beginning of the list. This is because accessing the head of the list is a constant time operation, and accessing
the tail requires traversal of the entire list.

```klipse-clojure
(conj '(1 2) 3)
;; ⇒ (3 1 2)
```

Vectors have constant time access across the entire data structure. `conj` appends to the end of a vector.

```klipse-clojure
(conj [1 2] 3)
;; ⇒ [1 2 3]
```

Maps do not have guaranteed ordering, so the location that items are added is irrelevant. `conj` requires vectors of [key value] pairs to be
added to the map.

```klipse-clojure
(conj {:a 1 :b 2 :c 3} [:d 4])
;; ⇒ {:d 4, :a 1, :c 3, :b 2}
```

```klipse-clojure
(conj {:cats 1 :dogs 2} [:ants 400] [:giraffes 13])
;; ⇒ {:giraffes 13, :ants 400, :cats 1, :dogs 2}
```

Sets also do not have guaranteed ordering. `conj` returns a set with the item added. As the concept of sets implies, added items will not duplicate equivalent items if they are present in the set.

```klipse-clojure
(conj #{1 4} 5)
;; ⇒ #{1 4 5}
```

```klipse-clojure
(conj #{:a :b :c} :b :c :d :e)
;; ⇒ #{:a :c :b :d :e}
```

### get

`get` returns the value for the specified key in a map or record, for the
index of a vector or for the value in a set. If the key is not present,
`get` returns nil or a supplied default value.

```klipse-clojure
;; val of a key in a map
(get {:a 1 :b 2 :c 3} :b)
;; ⇒ 2
```

```klipse-clojure
;; index of a vector
(get [10 15 20 25] 2)
;; ⇒ 20
```

```klipse-clojure
;; in a set, returns the value itself if present
(get #{1 10 100 2 20 200} 1)
;; ⇒ 1
```

```klipse-clojure
;; returns nil if key is not present
(get {:a 1 :b 2} :c)
;; ⇒ nil
```

```klipse-clojure
;; vector does not have an _index_ of 4. nil is returned
(get [1 2 3 4] 4)
;; ⇒ nil
```

```klipse-clojure
(defrecord Hand [index middle ring pinky thumb])
(get (Hand. 3 4 3.5 2 2) :index)
;; ⇒ 3
```

`get` also supports a default return value supplied as the last argument.

```klipse-clojure
;; index 4 does not exist. return default value
(get [1 2 3 4] 4 "Not Found")
;; ⇒ "Not Found"
```

```klipse-clojure
;; key :c does not exist, so return default value of 3
(get {:a 1 :b 2} :c 3)
;; ⇒ 3
```

### assoc

`assoc` takes a collection, a key, and a value and returns a collection of the same type as the supplied collection with the key mapped to the new value.

`assoc` is similar to `get` in how it works with maps, records or vectors. When applied to a map or record, the same type is returned with the key/value pairs added or modified.  When applied to a vector, a vector is returned with the key acting as an index and the index being replaced by the value.

Since maps and records can not contain multiple equivalent keys, supplying `assoc` with a key/value that exists in the one will cause `assoc` to return modify the key at that value in the result and not duplicate the key.

```klipse-clojure
(assoc {:a 1} :b 2)
;; ⇒ {:b 2, :a 1}
```

```klipse-clojure
(assoc {:a 1 :b 45 :c 3} :b 2)
;; ⇒ {:a 1, :c 3, :b 2}
```

```klipse-clojure
(defrecord Hand [index middle ring pinky thumb])
(assoc (Hand. 3 4 3.5 2 2) :index 3.75)
;; ⇒ #user.Hand{:index 3.75, :middle 4, :ring 3.5, :pinky 2, :thumb 2}
```

When using `assoc` with a vector, the key is the index and the value is the value to assign to that index in the returned vector.
The key must be <= (count vector) or an index out of bounds error will occur.

```klipse-clojure
(assoc [1 2 76] 2 3) ; ⇒ [1 2 3]
```

```klipse-clojure
;; index 5 does not exist. valid indexes for this vector are: 0, 1, 2
(assoc [1 2 3] 5 6)
;; the error here is slightly different in Clojure/Script
```

When the key is equal to `(count vector)`, `assoc` will add an item to the
end of the vector.

```klipse-clojure
(assoc [1 2 3] 3 4) ; ⇒ [1 2 3 4]
```

### dissoc

`dissoc` returns a map with the supplied keys, and subsequently their values, removed. Unlike `assoc`, `dissoc` does not work on vectors. When a record is provided, `dissoc` returns a map. For similar functionality with vectors, see `subvec` and `concat`.

```klipse-clojure
(dissoc {:a 1 :b 2 :c 3} :b)
;; ⇒ {:a 1, :c 3}
```

```klipse-clojure
(dissoc {:a 1 :b 14 :c 390 :d 75 :e 2 :f 51} :b :c :e)
;; ⇒ {:a 1, :f 51, :d 75}
```

```klipse-clojure
;; note that a map is returned, not a record.
(defrecord Hand [index middle ring pinky thumb])
;; always be careful with the bandsaw!
(dissoc (Hand. 3 4 3.5 2 2) :ring)
;; ⇒ {:index 3, :middle 4, :pinky 2, :thumb 2}
```

### first

`first` returns the first item in the collection. `first` returns nil if the argument is empty or is nil.

Note that for collections that do not guarantee order like some maps and sets, the behaviour of `first` should not be relied on.

```klipse-clojure
(first (range 10))
;; ⇒ 0
```

```klipse-clojure
(first [:floor :piano :seagull])
;; ⇒ :floor
```

```klipse-clojure
(first [])
;; ⇒ nil
```

### rest

`rest` returns a seq of items starting with the second element in the collection. `rest` returns an empty seq if the collection only contains a single item.

`rest` should also not be relied on when using maps and sets unless you are sure ordering is guaranteed (or you don't care about ordering at all).

```klipse-clojure
(rest [13 1 16 -4])
;; ⇒ (1 16 -4)
```

```klipse-clojure
(rest '(:french-fry))
;; ⇒ '()
```

The behaviour of `rest` should be contrasted with `next`. `next` returns `nil` if the collection only has a single item. This is important when considering "truthiness" of values since an empty seq is still a truthy value but `nil` is not.

```klipse-clojure
(if (rest '("stuff"))
  (println "Does this print?"))
;; yes, it prints.
```

```clojure
;; NEVER FINISHES EXECUTION!!!
;; "done" is never reached because (rest x) is always a "true" value
(defn inf
  [x]
  (if (rest x)
    (inf (rest x))
    "done"))
```

### empty?

`empty?` returns true if the collection has no items, or false if it has 1 or more items.

```klipse-clojure
(empty? [])
;; ⇒ true
```

```klipse-clojure
(empty? '(1 2 3))
;; ⇒ false
```

Do not confuse `empty?` with `empty`. This can be a source of great confusion:

```klipse-clojure
(if (empty [1 2 3]) ;; empty returns an empty seq, which is true! use empty? here.
  "It's empty"
  "It's not empty")
;; ⇒ "It's empty"
```

### empty

`empty` returns an empty collection of the same type as the collection provided.

```klipse-clojure
(empty [1 2 3])
;; ⇒ []
```

```klipse-clojure
(empty {:a 1 :b 2 :c 3})
;; ⇒ {}
```

### not-empty

`not-empty` returns nil if the collection has no items. If the collection contains items, the collection is returned.

```klipse-clojure
(not-empty '(:mice :elephants :children))
;; ⇒ (:mice :elephants :children)
```

```klipse-clojure
(not-empty '())
;; ⇒ nil
```

### contains?

`contains?` returns true if the provided *key* is present in a collection. `contains?` is similar to `get` in that vectors treat the key as an index. `contains?` does not work for lists.

```klipse-clojure
(contains? {:a 1 :b 2 :c 3} :c)
;; ⇒ true
```

```klipse-clojure
;; true if index 2 exists
(contains? ["John" "Mary" "Paul"] 2)
;; ⇒ true
```

```klipse-clojure
;; false if index 5 does not exist
(contains? ["John" "Mary" "Paul"] 5)
;; ⇒ false
```

```klipse-clojure
;; "Paul" does not exist as an index
(contains? ["John" "Mary" "Paul"] "Paul")
;; ⇒ false
```

```klipse-clojure
;; lists are not supported. contains? won't traverse a collection for a result.
(contains? '(1 2 3) 0)
;; ⇒ java.lang.IllegalArgumentException: contains? not supported on type: clojure.lang.PersistentList
;; => ClojureScript produces false here
```

(in Clojure, this throws an exception; in ClojureScript, it produces `false`)

### some

`some` will apply a predicate to each value in a collection until a non-false/nil result is returned then immediately return that result.

```klipse-clojure
(some even? [1 2 3 4 5])
;; ⇒ true
```

If you want to return the element itself, rather than the result of applying the predicate:

```klipse-clojure
;; predicate returns the value rather than simply true
(some #(if (even? %) %) [1 2 3 4 5])
;; ⇒ 2
```

Since maps can be used as functions, you can use a map as a predicate. This will return the value of the first key in the collection that is also in the map.

```klipse-clojure
(some {:a 1 :b 5} [:h :k :d :b])
;; ⇒ 5
```

Sets can also be used as functions and will return the first item in the collection that is present in the set.

```klipse-clojure
(some #{4} (range 20))
;; ⇒ 4
```

### every?

`every` returns true if the predicate returns true for every item in the collection, otherwise it returns false.

```klipse-clojure
(every? even? (range 0 10 2))
;; ⇒ true
```

```klipse-clojure
;; set can be used to see if collection only contains items in the set.
(every? #{2 3 4} [2 3 4 2 3 4])
;; ⇒ true
```

### map, mapv

`map` is used to sequence of values and generate a new sequence of
values. `map` produces a lazy sequence. `mapv` is the same as `map` but
produces a vector (and is not lazy).

Essentially, you're creating a *mapping* from an old sequence of values
to a new sequence of values.

```klipse-clojure
(def numbers
  (range 1 10))
;; ⇒ (1 2 3 4 5 6 7 8 9)
```

```klipse-clojure
(map (partial * 2) numbers)
;; ⇒ (2 4 6 8 10 12 14 16 18)
```

```klipse-clojure
(mapv (partial * 2) numbers)
;; ⇒ [2 4 6 8 10 12 14 16 18]
```

```klipse-clojure
(def scores
  {:clojure 10
   :scala 9
   :jruby 8})

(map #(str "Team " (name (key %)) " has scored " (val %)) scores)
;; ⇒ ("Team scala has scored 9" "Team jruby has scored 8" "Team clojure has scored 10")
```

### reduce

`reduce` takes a sequence of values and a function. It applies that
function repeatedly with the sequence of values to *reduce* it to a
single value.

```klipse-clojure
(def numbers
  (range 1 10))
;; ⇒ (1 2 3 4 5 6 7 8 9)
```

```klipse-clojure
(reduce + numbers)
;; ⇒ 45
```

```klipse-clojure
(def scores
  {:clojure 10
   :scala 9
   :jruby 8})

(reduce + (vals scores))
;; ⇒ 27
```

```klipse-clojure
;; Provide an initial value for the calculation
(reduce + 10 (vals scores))
;; ⇒ 37
```

### filter, filterv

`filter` returns a lazy sequence of items that return `true` for the provided predicate. Contrast to `remove`.
`filterv` is the same as `filter` but produces a vector (and is not lazy).

```klipse-clojure
(filter even? (range 10))
;; ⇒ (0 2 4 6 8)
```

```klipse-clojure
(filterv even? (range 10))
;; ⇒ [0 2 4 6 8]
```

```klipse-clojure
(filter #(< (count %) 5) ["Paul" "Celery" "Computer" "Rudd" "Tayne"])
;; ⇒ ("Paul" "Rudd")
```

When using sets with `filter`, remember that if nil or false is in the set and in the collection, then the predicate will return itself: `nil`.

In this example, when nil and false are tested with the predicate, the predicate returns nil. This is because if the item is present in the set it is returned. This will cause that item to /not/ be included in the returned lazy-sequence.

```klipse-clojure
(filter #{:nothing :something nil}
       [:nothing :something :things :someone nil false :pigeons])
;; ⇒ (:nothing :something)
```

### remove

`remove` returns a lazy sequence of items that return `false` or `nil` for the provided predicate. Contrast to `filter`.

```klipse-clojure
(remove even? (range 10))
;; ⇒ (1 3 5 7 9)
```

```klipse-clojure
;; relative complement. probably useless?
(remove {:a 1 :b 2} [:h :k :z :b :s])
;; ⇒ (:h :k :z :s)
```

When using sets with `remove`, remember that if nil or false is in the set and
in the collection, then the predicate will return that falsey value, and the
item will not be removed -- the item will be included in the returned lazy sequence.

In this example, when nil and false are tested with the predicate, the predicate
returns falsey. This is because if the item is present in the set it is returned.

```klipse-clojure
(remove #{:nothing :something nil false}
        [:nothing :something :things :someone nil false :pigeons])
;; ⇒ (:things :someone nil false :pigeons)
```

### sort, sort-by

`sort` and `sort-by` are flexible higher-order functions for sorting sequential collections like lists and vectors. Both take an optional `Comparator` which defaults to `compare`, and `sort-by` takes a function that transforms each value before comparison.

#### sort

`sort` using the default comparator can handle numbers...
```klipse-clojure
(sort [0.0 -1 1.3 nil 0.18 7])
;; ⇒ (nil -1 0.0 0.18 1.3 7)
```
... and strings
```klipse-clojure
(sort ["the case matters" "lexicographic ordering" "The case matters" nil "%%"])
;; ⇒ (nil "%%" "The case matters" "lexicographic ordering" "the case matters")
```
... and vectors whose elements are element-wise comparable
```klipse-clojure
(sort [[1 "banana"] [1 "apple"] [0 "grapefruit"]])
;; ⇒ ([0 "grapefruit"] [1 "apple"] [1 "banana"])
```
... but it can't "cross" types.
```klipse-clojure
; `compare` doesn't know how to compare Strings and numbers
(sort [5 1.0 "abc"])
;; Execution error (ClassCastException)...
;; class java.lang.Double cannot be cast to class java.lang.String
```

In order to do more complicated sorting, we can create our own `Comparator`. There's a wealth of information
about comparators in the [clojure.org comparators guide](https://clojure.org/guides/comparators), but for now, one possible comparator is a
function that takes two arguments and returns a negative, positive, or zero integer when the first argument is 'less than', 'greater than', or equal to (respectively) the second argument.

```klipse-clojure
(letfn [(strings-before-numbers
          [x y]
          (cond
            ; string is 'less than' number
            (and (string? x) (number? y)) -1
            ; number is 'greater than' string
            (and (number? x) (string? y))  1
            ; otherwise we can use `compare`
            :else (compare x y)))]
  (sort strings-before-numbers [1 0.0 nil "abc"]))
;; ⇒ (nil "abc" 0.0 1)
```

A common way to reverse a sort is to `comp` the `-` function with a comparator that returns a number, which effectively
swaps 'greater than' and 'less than' returns.

```klipse-clojure
(sort (comp - compare) ["charlie" "delta" "alpha" "bravo"])
;; ⇒ ("delta" "charlie" "bravo" "alpha")
```

#### sort-by

`sort-by` takes a `keyfn` function and uses `sort` based on the result of appying `keyfn` to the values to be sorted.
It's typically a good candidate for sorting collections of maps/records/objects.

```klipse-clojure
(sort-by :last [{:first "Fred" :last "Mertz"}
                {:first "Lucy" :last "Ricardo"}
                {:first "Ricky" :last "Ricardo"}
                {:first "Ethel" :last  "Mertz"}])
;; ⇒ ({:first "Fred", :last "Mertz"}
;;     {:first "Ethel", :last "Mertz"}
;;     {:first "Lucy", :last "Ricardo"}
;;     {:first "Ricky", :last "Ricardo"})
```

Because `compare` compares vectors element-wise, it's possible to use `juxt` to effectively sort by a few values without a custom comparator.

Sort the strings from shortest to longest, and then alphabetically (ignoring case):
```klipse-clojure
(sort-by (juxt count clojure.string/lower-case) ["Alpha" "bravo" "Charlie" "Delta" "echo"])
;; ⇒ ("echo" "Alpha" "bravo" "Delta" "Charlie")
```

### iterate

`iterate` takes a function and an initial value, returns the result of
applying the function on that initial value, then applies the function
again on the resultant value, and repeats forever, lazily. Note that the
function *iterates* on the value.

```klipse-clojure
(take 5 (iterate inc 1))
;; ⇒ (1 2 3 4 5)
```

```klipse-clojure
(defn multiply-by-two
  [value]
  (* 2 value))

(take 10 (iterate multiply-by-two 1))
;; ⇒ (1 2 4 8 16 32 64 128 256 512)
```

### get-in

`get-in` is used to *get* a value that is deep *inside* a data
structure.

You have to provide the data structure and a sequence of keys, where a
key is valid at each subsequent level of the nested data structure.

If the sequence of keys does not lead to a valid path, `nil` is
returned.

```klipse-clojure
(def family
  {:dad {:shirt 5
         :pants 6
         :shoes 4}
   :mom {:dress {:work 6
                 :casual 7}
         :book 3}
   :son {:toy 5
         :homework 1}})
```

```klipse-clojure
(get-in family [:dad :shirt])
;; ⇒ 5
```

```klipse-clojure
(get-in family [:mom :dress])
;; ⇒ {:work 6, :casual 7}
```

```klipse-clojure
(get-in family [:mom :dress :casual])
;; ⇒ 7
```

```klipse-clojure
(get-in family [:son :pants])
;; ⇒ nil
```

```klipse-clojure
(def locations
  [:office :home :school])

(get-in locations [1])
;; ⇒ :home
```

### update-in

`update-in` is used to *update* a value deep inside a structure
*in-place*.

Note that since data structures are immutable, it only returns a
"modified" data structure, it does not actually alter the original
reference.

The "update" function takes the old value and returns a new value which
`update-in` uses in the new modified data structure.

```klipse-clojure
(def family
  {:dad {:shirt 5
         :pants 6
         :shoes 4}
   :mom {:dress {:work 6
                 :casual 7}
         :book 3}
   :son {:toy 5
         :homework 1}})
```

```klipse-clojure
(update-in family [:dad :pants] inc)

;; ⇒ {:son {:toy 5, :homework 1}, :mom {:dress {:work 6, :casual 7}, :book 3}, :dad {:shoes 4, :shirt 5, :pants 7}}
```

Notice that "pants" gets incremented but the original `family` data is untouched.

```klipse-clojure
(def locations
  [:office :home :school])

(update-in locations [2] #(keyword (str "high-" (name %))))
;; ⇒ [:office :home :high-school]
```

Again, the original `locations` data is untouched.

### assoc-in

`assoc-in` is used to *associate* a new value deep inside a structure
*in-place*.

Note that since data structures are immutable, it only returns a
"modified" data structure, it does not actually alter the original
reference.

Note the difference between `update-in` and `assoc-in`: `update-in`
takes a function that applies on the old value to return a new value,
whereas `assoc-in` takes a new value as-is.

```klipse-clojure
(def family
  {:dad {:shirt 5
         :pants 6
         :shoes 4}
   :mom {:dress {:work 6
                 :casual 7}
         :book 3}
   :son {:toy 5
         :homework 1}})
```

```klipse-clojure
(assoc-in family [:son :crayon] 3)
;; ⇒ {:son {:toy 5, :crayon 3, :homework 1}, :mom {:dress {:work 6, :casual 7}, :book 3}, :dad {:shoes 4, :shirt 5, :pants 6}}
```

As with `update-in`, the original `family` data is untouched.

```klipse-clojure
(def locations
  [:office :home :school])

(assoc-in locations [3] :high-school)
;; ⇒ [:office :home :school :high-school]
```

Similarly, the original `locations` data is untouched.

### keys

`keys` returns a sequence of the keys in a map or record.

```klipse-clojure
(keys {1 "one" 2 "two" 3 "three"})
;; ⇒ (1 2 3)
```

```klipse-clojure
(defrecord Hand [index middle ring pinky thumb])
(keys (Hand. 2 4 3 1 2))
;; ⇒ (:index :middle :ring :pinky :thumb)
```

### vals

`vals` returns a sequence of vals in a map or record.

```klipse-clojure
(vals {:meows 20 :barks 2 :moos 5})
;; ⇒ (5 2 20)
```

```klipse-clojure
(defrecord Hand [index middle ring pinky thumb])
(vals (Hand. 1 2 3 4 5))
;; ⇒ (1 2 3 4 5)
```

### select-keys

`select-keys` is used to extract a subset of a map:

```klipse-clojure
(def family
  {:dad {:shirt 5
         :pant 6
         :shoes 4}
   :mom {:dress {:work 6
                 :casual 7}
         :book 3}
   :son {:toy 5
         :homework 1}})
```

```klipse-clojure
(select-keys family [:dad])
;; ⇒ {:dad {:shoes 4, :shirt 5, :pant 6}}
```

```klipse-clojure
(select-keys family [:mom :son])
;; ⇒ {:son {:toy 5, :homework 1}, :mom {:dress {:work 6, :casual 7}, :book 3}}
```

### take

`take` returns a lazy sequence of the first `n` items of a collection `coll`.

```klipse-clojure
(take 3 [1 3 5 7 9])
;; ⇒ (1 3 5)
```

```klipse-clojure
(type (take 3 (range)))
;; ⇒ clojure.lang.LazySeq
```

If there are fewer than `n` items in `coll`, all items will be returned.

```klipse-clojure
(take 5 [1 2 3])
;; ⇒ (1 2 3)
```

```klipse-clojure
(take 3 nil)
;; ⇒ ()
```

### drop

`drop` drops `n` items from a collection `coll` and returns a lazy sequence of the rest of it.

```klipse-clojure
(drop 3 '(0 1 2 3 4 5 6))
;; ⇒ (3 4 5 6)
```

```klipse-clojure
(drop 2 [1 2])
;; ⇒ ()
```

```klipse-clojure
(drop 2 nil)
;; ⇒ ()
```

### take-while

`take-while` returns a lazy sequence of items from a collection as long
as the predicate returns `true` for each item:

```klipse-clojure
(take-while #(< % 5) (range))
;; ⇒ (0 1 2 3 4)
```

### drop-while

`drop-while` drops items from a collection as long as the predicate
returns `false` for the item and when the first non-false item is found,
it returns a lazy sequence from that item onwards:

```klipse-clojure
(drop-while #(< % 5) (range 10))
;; ⇒ (5 6 7 8 9)
```

## Transducers

Rich Hickey introduced the [concept of transducers](https://clojure.org/news/2014/08/06/transducers-are-coming)
in a mid-2014 blog post, and they arrived in Clojure 1.7. The official
documentation has a good [reference page for transducers](https://clojure.org/reference/transducers).

The core idea is to separate the transformation function from the input
and output sources, specifying just the transformation itself. This allows
transformations to be composed and reused in a variety of contexts.

We might write the following code to transform a sequence of numbers:

```klipse-clojure
(->> (range 10)
     (map inc)
     (filter even?)
     (take 3)
     (into []))
```

At each step, the input is explicitly turned into a sequence and transformed
into a new sequence. The longer the pipeline of transformations, the more
intermediate sequences are created and later thrown away. In the above example,
the final step forces the initial portions of those sequences to be realized.
but up to that point, the transformations are all lazy because the functions
themselves are lazy.

Many of the sequence and collection functions you've seen in earlier sections
above have an arity that omits the sequence or collection argument, e.g.,
`(map inc)` instead of `(map inc my-seq)`. When the sequence or collection
argument is omitted, these calls return a *transducer* that can be composed
and applied as part of a transformation.

Transducers allow us to separate the transformation from the input and output:

```klipse-clojure
(def xf (comp (map inc) (filter even?) (take 3)))
(into [] xf (range 10))
```

We can apply this transformation (`xf`) to any input source and produce
any output -- and no intermediate sequences are created: the composed transformation
is applied directly to the elements from the input to produce the output.

### Lazy or Eager?

Transducers may shrink the input (as above) or expand it. Transducers are not
inherently lazy or eager since they are called, as needed, by the process
that applies the transformation to the input to produce the output.

We've seen eager transformations in the earlier sections above, such as
`(into [] my-seq)` which is implemented as `(reduce conj [] my-seq)`
under the hood. In a similar way, `(into [] xf my-seq)` is equivalent to
`(reduce (xf conj) [] my-seq)`. Since `(reduce (xf f) init my-seq)` would
be a common construct when eagerly transforming sequences, Clojure provides
`(transduce xf f init my-seq)` as a shorthand.

```klipse-clojure
(def xf (comp (map inc) (filter even?) (take 3)))
(transduce xf + 0 (range 10))
```

Whereas `(into [] xf (range 10))` produces a vector of three numbers,
because it is `(transduce xf conj [] (range 10))`, we can reuse the transformation
in `(transduce xf + 0 (range 10))` to produce a single number.

Clojure also provides `(sequence xf my-seq)` as a way to get a lazy sequence
of applications of the transformation to the input.

(note how the transducer is applied to the
reducing function `conj` to produce a new reducing function).

Additional reading:

* [Getting Started with Transducers](https://practical.li/blog/posts/transducers-in-clojure-getting-started) -- [Practicalli](https://practical.li/)
* [Transducers Reference](https://clojure.org/reference/transducers) -- [clojure.org](https://clojure.org/)
* [Examples of `transduce`](https://clojuredocs.org/clojure.core/transduce) -- [clojuredocs.org](https://clojuredocs.org/)
* [Examples of `sequence`](https://clojuredocs.org/clojure.core/sequence) -- [clojuredocs.org](https://clojuredocs.org/)

## Transients

Clojure data structures are immutable, they do not change. Mutating them produces
a new data structure that internally has structural sharing with the original
one. This makes a whole class of concurrency hazards go away but has some
performance penalty and additional GC pressure.

For cases when raw performance for a piece of code is more important than safety,
Clojure provides mutable versions of vectors and unsorted maps. They are known
as *transients* and should only be used for locals and as an optimization
technique after profiling.

Transients are produced from immutable data structures using the `clojure.core/transient`
function:

```klipse-clojure
(let [m (transient {})
      ;; assoc! returns the updated transient
      m (assoc! m :key "value")]
  (count m))
;; ⇒ 1
```

Operations on a transient may update in place or they may return an updated
collection so you must still bind or reuse their return values, and not rely
on the original transient being updated.

Note that `clojure.core/transient` does not affect nested collections, for
example, values in a map of keywords to vectors.

To mutate transients, use `clojure.core/assoc!`, `clojure.core/dissoc!` and
`clojure.core/conj!`. The exclamation point at the end hints that these
functions work on transients and may modify data structures in place, which
is not safe if transient data structures are shared between threads.

To create an immutable data structure out of a transient, use `clojure.core/persistent!`:

```klipse-clojure
(let [m (transient {})
      m (assoc! m :key "value")]
  (persistent! m)) ;; ⇒ {:key "value"}
```

In conclusion: use transients only as an optimization technique and only
after profiling and identifying hot spots in your code. Guessing is the
shortest way we know to blowing the performance.


## Custom Collections and Sequences

It is possible to develop custom collection types in Clojure or Java and have
`clojure.core` functions work on them just like they do on builtin types.

[How to Contribute](/articles/about/#how-to-contribute)


## Wrapping Up

When working with Clojure, it is common to operate and transform collections and sequences.
Clojure's core library unify operations on collections and sequences where possible.
This extends to Java collections, arrays and iterable objects for seamless interoperability.

Most of the time, whenever you need a function that transforms sequences, chances are, there is
one already that does that in `clojure.core` or you can compose more than one `clojure.core` function
to achieve the same result.


## Contributors

Michael Klishin <michael@defprotocol.org>
Robert Randolph <audiolabs@gmail.com>
satoru <satorulogic@gmail.com>
