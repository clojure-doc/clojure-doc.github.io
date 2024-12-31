{:title "Language: Functions"
 :page-index 2100
 :klipse true
 :layout :page}

This guide covers:

 * How to define functions
 * How to invoke functions
 * Multi-arity functions
 * Variadic functions
 * Higher order functions
 * Other topics related to functions

This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>
(including images & stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).

## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.12.


## Overview

Clojure is a functional programming language. Naturally, functions are very important part of Clojure.


## How To Define Functions

Functions are typically defined using the [defn](https://clojuredocs.org/clojure.core/defn) macro:

``` clojure
(defn round
  [d precision]
  (let [factor (Math/pow 10 precision)]
    (/ (Math/floor (* d factor)) factor)))
```

Functions can have doc strings (documentation strings) and it is a good idea to document functions that
are part of the public API:

``` clojure
(defn round
  "Round down a double to the given precision (number of significant digits)"
  [d precision]
  (let [factor (Math/pow 10 precision)]
    (/ (Math/floor (* d factor)) factor)))
```

The benefit of writing docstrings is that they show up in editors and the REPL:

``` clojure
user=> (doc round)
user/round
([d precision])
Round down a double to the given precision (number of significant digits)
nil
```

In Clojure, function arguments may have optional type hints:

``` clojure
(defn round
  [^double d ^long precision]
  (let [factor (Math/pow 10 precision)]
    (/ (Math/floor (* d factor)) factor)))
```

The result of a function can also have a type hint (note that it goes in
front of the argument list, not in front of the function name):

``` clojure
(defn round
  ^double [^double d ^long precision]
  (let [factor (Math/pow 10 precision)]
    (/ (Math/floor (* d factor)) factor)))
```

Type hints sometimes allow the compiler to avoid reflective method calls
when using Java interop (as the above examples do) and may produce
significantly more efficient bytecode.
However, as a rule of thumb, it is usually not necessary to use type hints.
Start writing your code without them. The compiler
is also free to ignore provided hints.

The examples above use Java interop (static methods of the `java.lang.Math` class).
As of Clojure 1.11, `clojure.math` is available and provides a more idiomatic
way to perform mathematical operations that do not need type hints:

``` clojure
(require '[clojure.math :as math])
(defn round
  [d precision]
  (let [factor (math/pow 10 precision)]
    (/ (math/floor (* d factor)) factor)))
```

Functions can also define *preconditions* and *postconditions* that put restrictions on argument values and
the value function returns:

``` clojure
(require '[clojure.math :as math])
(defn round
  "Round down a double to the given precision (number of significant digits)"
  [d precision]
  {:pre [(not-nil? d) (not-nil? precision)]}
  (let [factor (math/pow 10 precision)]
    (/ (math/floor (* d factor)) factor)))
```

In the example above, we use preconditions to check that both arguments are not
nil. The `not-nil?` macro (or function) is not
demonstrated in this example and assumed to be implemented elsewhere.

> Note: pre- and post-conditions produce `AssertionError` exceptions when the fail. They are not intended to be caught/handled by code, and should be considered purely a debugging aid, and not for argument validation in production code.

## Anonymous Functions

Anonymous functions are defined using the `fn` special form:

``` clojure
(fn [x]
  (* 2 x))
```

Anonymous functions can be bound to locals, passed between functions (higher order functions are covered later in this document)
and returned from functions:

```klipse-clojure
(let [f (fn [x]
          (* 2 x))]
  (map f (range 0 10)))
```

There is also a reader macro for anonymous functions:

```klipse-clojure
(let [f #(* 2 %)]
  (map f (range 0 10)))
```

The `%` in the example above means "the first argument". To refer to more than one argument, use `%1`, `%2` and so on:

```klipse-clojure
;; an anonymous function that takes 3 arguments and adds them together
(let [f #(+ %1 %2 %3)]
  (f 1 2 3))
```

Please **use this reader macro sparingly**; excessive use may lead to unreadable code.

> Note: in the `fn` form, you can provide a name for the "anonymous" function -- between `fn` and the argument list -- that will be used in stack traces and debugging output.

## How To Invoke Functions

Functions are invoked by placing a function in the leading position (*the calling position*) of a list:

<pre style="visibility:hidden; height:0;"><code class="klipse-clojure" >
(import '(goog.string format))
</code></pre>

```klipse-clojure
(format "Hello, %s" "world")
```

This works also if you have a function stored in a local, a var or passed as an argument:

```klipse-clojure
(let [f format]
  (f "Hello, %s" "world"))
```

Alternatively, you can call a function using [clojure.core/apply](https://clojuredocs.org/clojure.core/apply)

```klipse-clojure
(apply format "Hello, %s" ["world"])
```

```klipse-clojure
(apply format "Hello, %s %s" ["Clojure" "world"])
```

`clojure.core/apply` is usually only necessary when calling variadic functions or having the list of arguments passed in
as a collection.


## Multi-arity Functions

Functions in Clojure can have multiple *arities*, or sets of arguments:

``` clojure
(require '[clojure.math :as math])
(defn tax-amount
  ([amount]
     (tax-amount amount 35))
  ([amount rate]
     (math/round (double (* amount (/ rate 100))))))
```

In the example above, the version of the function that takes only one argument (so called *one-arity* or *1-arity* function)
calls another version (*2-arity*) with a default parameter. This is a common use case for multiple arities: to have default
argument values. Clojure is a hosted language and JVM (and JavaScript VMs, for that matter) does not support default argument
values, however, it does support *method overloading* and Clojure takes advantage of this.

Arities in Clojure can only differ by the number of arguments, not types.
This is because Clojure is a strongly dynamically typed language and type information about
parameters may or may not be available to the compiler.

A larger example:

``` clojure
(defn my-range
  ([]
    (my-range 0 Double/POSITIVE_INFINITY 1))
  ([end]
    (my-range 0 end 1))
  ([start end]
    (my-range start end 1))
  ([start end step]
    (comment Omitted for clarity)))
```

## Destructuring of Function Arguments

Sometimes function arguments are data structures: vectors, sequences, maps. To access parts of such
data structure, you may do something like this:

``` clojure
(defn currency-of
  [m]
  (let [currency (get m :currency)]
    currency))
```

For vector arguments:

``` clojure
(defn currency-of
  [pair]
  (let [amount   (first  pair)
        currency (second pair)]
    currency))
```

However, this is boilerplate code that has little to do with what the function really does. Clojure
lets developer **destructure** parts of arguments, for both maps and sequences.

### Positional Destructuring

Destructuring over vectors (**positional destructuring**) works like this: you replace the argument
with a vector that has "placeholders" (symbols) in positions you want to bind. For example, if the
argument is known to be a pair and you need second argument, it would look like this:

``` clojure
(defn currency-of
  [[amount currency]]
  currency)
```

In the example above the first element in the pair is bound to `amount` and the second one is bound to
`currency`. So far so good. However, notice that we do not use the `amount` local. In that case, we can
ignore it by replacing it with an underscore:

``` clojure
(defn currency-of
  [[_ currency]]
  currency)
```

Destructuring can nest (destructure deeper than one level):

``` clojure
(defn first-first
  [[[i _] _]]
  i)
```

While this article does not cover `let` and locals, it is worth demonstrating that positional destructuring works
exactly the same way for let bindings:

```klipse-clojure
(let [pair         [10 :gbp]
      [_ currency] pair]
  currency)
```


### Map Destructuring

Destructuring over maps and records (**map destructuring**) works slightly differently:

``` clojure
(defn currency-of
  [{currency :currency}]
  currency)
```

In this case example, we want to bind the value for key `:currency` to `currency`. Keys don't have to be
keywords:

``` clojure
(defn currency-of
  [{currency "currency"}]
  currency)
```

``` clojure
(defn currency-of
  [{currency 'currency}]
  currency)
```

When destructuring multiple keys at once, it is more convenient to use a slightly different syntax:

``` clojure
(defn currency-of
  [{:keys [currency amount]}]
  currency)
```

The example above assumes that map keys will be keywords and we are interested in two values: `currency`
and `:amount`. The same can be done for strings:

``` clojure
(defn currency-of
  [{:strs [currency amount]}]
  currency)
```

and symbols:

``` clojure
(defn currency-of
  [{:syms [currency amount]}]
  currency)
```

In practice, keywords are very commonly used for map keys so destructuring with `{:keys [...]}` is very common
as well.

If you want to destructure a map that has namespaced keys, you can either
specify the prefix on each name in the binding or as a prefix on `:keys` itself:

``` clojure
;; instead of {:currency "GBP" :amount 95.99} let's assume we have namespaced
;; keys: {:invoice/currency "GBP" :invoice/amount 95.99}
(defn currency-of
  [{:keys [invoice/currency invoice/amount]}] ; prefixed names
  currency) ; bind to unprefixed symbols

;; or

(defn currency-of
  [{:invoice/keys [currency amount]}] ; prefixed :keys
  currency) ; bind to unprefixed symbols
```

Map destructuring also lets us specify default values for keys that may be missing:

``` clojure
(defn currency-of
  ;; unqualified keys:
  [{:keys [currency amount] :or {currency :gbp}}]
  currency)

;; or:

(defn currency-of
  ;; qualified keys -- note the currency symbol is not qualified:
  [{:invoice/keys [currency amount] :or {currency :gbp}}]
  currency)

;; invocation without currency key:
(currency-of {})
;; => :gbp
```

This is very commonly used for implementing functions that take "extra options" (faking named arguments support).


Just like with positional destructuring, map destructuring works exactly the same way for let bindings:

```klipse-clojure
(let [money               {:currency :gbp :amount 10}
     {currency :currency} money]
  currency)
```


## Variadic Functions

Variadic functions are functions that take varying number of arguments (some arguments are optional). Two examples
of such function in `clojure.core` are `clojure.core/str` and `clojure.core/format`:

```klipse-clojure
(str "a" "b")
; ⇒ "ab"
```

```klipse-clojure
(str "a" "b" "c")
; ⇒ "abc"
```

```klipse-clojure
(format "Hello, %s" "world")
; ⇒ "Hello, world"
```

```klipse-clojure
(format "Hello, %s %s" "Clojure" "world")
; ⇒ "Hello, Clojure world"
```

To define a variadic function, prefix optional arguments with an ampersand (`&`):

``` clojure
(defn log
  [message & args]
  (comment ...))
```

In the example above, one argument is required and the rest is optional. Variadic functions
are invoked as usual:

```klipse-clojure
(defn log
  [message & args]
  (println "args: " args))

(log "message from " "192.0.0.76")
```

```klipse-clojure
(log "message from " "192.0.0.76" "service:xyz")
```

As you can see, optional arguments (`args`) are packed into a list.

### Extra Arguments (aka Named Parameters)

Named parameters are achieved through the use of destructuring a variadic function.

Approaching named parameters from the standpoint of destructuring a variadic
function allows for more clearly readable function invocations.
This is an example of named parameters:

```klipse-clojure
(defn job-info
  [& {:keys [name job income] :or {job "unemployed" income "$0.00"}}]
  (if name
    [name job income]
    (println "No name specified")))
```

Using the function looks like this:

```klipse-clojure
(job-info :name "Robert" :job "Engineer")
;; ["Robert" "Engineer" "$0.00"]
```

```klipse-clojure
(job-info :job "Engineer")
;; No name specified
```

Without the use of a variadic argument list, you would have to call the function with a single map argument such as `{:name "Robert" :job "Engineer}`.

As of Clojure 1.11, you can also pass named parameters as a map, or a mix of named parameters followed by a map:

``` clojure
(job-info {:name "Robert" :job "Engineer"})
;;=> ["Robert" "Engineer" "$0.00"]
```

``` clojure
(job-info :name "Robert" {:job "Engineer"})
;;=> ["Robert" "Engineer" "$0.00"]
```

``` clojure
(job-info {:job "Engineer"})
;;=> No name specified
```

This allows for easier programmatic invocation of functions with named parameters
where you might be building a map of parameters and passing it through your code.


Keyword default values are assigned by use of the `:or` keyword followed by a map of keywords to their default value.
Keywords not present and not given a default will be nil.



## Higher Order Functions

Higher-order functions (*HOFs*) are functions that take other functions as arguments. HOFs
are an important functional programming technique and are quite commonly used in Clojure. One example
of an HOF is a function that takes a function and a collection and returns a collection of elements
that satisfy a condition (a predicate). In Clojure, this function is called `clojure.core/filter`:

```klipse-clojure
(filter even? (range 0 10))  ; ⇒ (0 2 4 6 8)
```

In the example above, `clojure.core/filter` takes `clojure.core/even?` as an argument.

`clojure.core` has dozens of other higher-order functions. The most commonly used ones are covered in [clojure.core Overview](/articles/language/core_overview/).


## Private Functions

Functions in Clojure can be private to their namespace.

They are covered in more detail in the [Namespaces](/articles/language/namespaces/) guide.


## Keywords as Functions

In Clojure, keywords can be used as functions. They take a map or record and look themselves up in it:

```klipse-clojure
(:age {:age 27 :name "Michael"})
; ⇒ 27
```

This is commonly used with higher order functions:

```klipse-clojure
(map :age [{:age 45 :name "Joe"}
           {:age 42 :name "Jill"}
           {:age 17 :name "Matt"}])
;; ⇒ (45 42 17)
```

and the `->` macro:

```klipse-clojure
(-> [{:age 45 :name "Joe"} {:age 42 :name "Jill"}]
    first
    :name)
;; ⇒ "Joe"
```

Like with `get`, a "not found" value can be specified:

```klipse-clojure
(:age {:name "Michael"} :unknown)
; ⇒ :unknown
```

## Maps as Functions

Clojure maps are also functions that take keys and look up values for them:

```klipse-clojure
({:age 42 :name "Joe"} :name)
; ⇒ "Joe"
```

```klipse-clojure
({:age 42 :name "Joe"} :age)
; ⇒ 42
```

```klipse-clojure
({:age 42 :name "Joe"} :unknown)
; ⇒ nil
```

Like with `get`, a "not found" value can be specified:

```klipse-clojure
({:age 42 :name "Joe"} :unknown :not-found)
; ⇒ :not-found
```

Note that this is **not true** for Clojure records, which are almost identical to maps in other
cases.


## Sets as Functions

```klipse-clojure
(#{1 2 3} 1)
; ⇒ 1
```

```klipse-clojure
(#{1 2 3} 10)
; ⇒ nil
```

```klipse-clojure
(#{:us :au :ru :uk} :uk)
; ⇒ :uk
```

```klipse-clojure
(#{:us :au :ru :uk} :cn)
; ⇒ nil
```

And, as you might expect from the previous examples, a "not found" value can be specified:

```klipse-clojure
(#{:us :au :ru :uk} :cn :not-found)
; ⇒ :not-found
```

This is often used to check if a value is in a set:

``` clojure
(when (countries :in)
  (comment ...))

(if (countries :in)
  (comment Implement positive case)
  (comment Implement negative case))
```

because everything but `false` and `nil` evaluates to `true` in Clojure.


## Clojure Functions As Comparators

Clojure functions implement the [java.util.Comparator](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Comparator.html)
interface and can be used as comparators.

See [the official Clojure guide to Comparators](https://clojure.org/guides/comparators) for more details.

## Wrapping Up

Functions are at the heart of Clojure. They are defined using the `defn` macro, can have multiple arities,
be variadic and support parameter destructuring. Function arguments and return value can optionally be
type hinted.

Functions are first class values and can be passed to other functions (called Higher Order Functions or HOFs).
This is fundamental to functional programming techniques.

Several core data types behave like functions. When used reasonably, this can lead to more concise, readable
code.


## Contributors

Michael Klishin <michael@defprotocol.org>, 2012 (original author)

Sean Corfield <sean@corfield.org>, 2023-2024 (updates to Clojure 1.11 and later)
