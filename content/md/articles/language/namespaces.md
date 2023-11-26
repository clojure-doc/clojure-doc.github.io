{:title "Language: Namespaces"
 :page-index 2400
 :layout :page}

This guide covers:

 * An overview of Clojure namespaces and vars
 * How to define namespaces
 * How to use functions in other namespaces
 * `require`, `refer` and `use`
 * Common compilation errors and typical problems that cause them
 * Namespaces and their relation to code compilation in Clojure

This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>
(including images & stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).


## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.11.


## Overview

Clojure functions are organized into *namespaces*. Clojure namespaces
are similar to Java packages and Python modules. Namespaces are
like maps (dictionaries) that map names to *vars*. In many cases,
those vars store functions in them.


## Defining a Namespace

Namespaces are usually defined using the `clojure.core/ns` macro. In its most basic
form, it takes a name as a symbol:

``` clojure
(ns superlib.core)
```

Namespaces can have multiple segments, separated by a dot:

``` clojure
(ns megacorp.service.core)
```

It is **highly recommended** to avoid using single segment namespaces
(e.g. `(ns superlib)`) to avoid potential conflicts with the way Java
handles default packages. If a library or application belongs to an
organization or a group of projects, the
`[organization].[library|app].[group-of-functions]` pattern is
recommended. For example:

``` clojure
(ns clojurewerkz.welle.kv)

(ns megacorp.search.indexer.core)
```

In addition, the `ns` macro takes a number of optional forms:

 * `(:require ...)`
 * `(:import ...)`
 * `(:use ...)`
 * `(:refer-clojure ...)`
 * `(:gen-class ...)`

These are just slightly more concise variants of `clojure.core/import`, `clojure.core/require`, et cetera.


### The :require Helper Form

The `:require` helper form is for setting up access to other Clojure
namespaces from your code. For example:

``` clojure
(ns megacorp.profitd.scheduling
  (:require clojure.set))

;; Now it is possible to do:
;; (clojure.set/difference #{1 2 3} #{3 4 5})
```

This will make sure the `clojure.set` namespace is loaded, compiled, and available as `clojure.set`
(using its fully qualified name). It is possible (and common) to make a namespace available
under an alias:

``` clojure
(ns megacorp.profitd.scheduling
  (:require [clojure.set :as set]))

;; Now it is possible to do:
;; (set/difference #{1 2 3} #{3 4 5})
```
It is common to use the last segment of the namespace name as the alias,
as long as this does not cause a conflict with other namespaces that
would have the same alias. Some namespaces have widely-used aliases
that do not follow this pattern (e.g., `clojure.string` is usually
aliased as `str`).

One more example with two required namespaces:

``` clojure
(ns megacorp.profitd.scheduling
  (:require [clojure.set  :as set]
            [clojure.walk :as walk]))
```

When you `:require` / `:as`, the referenced namespace is loaded (and
compiled) and therefore must exist as a source namespace. If you are
working with qualified keywords, such as Spec names, you may want an
alias to a qualified keyword that does not match a source namespace.
`:require` / `:as-alias` can be used in that case to introduce an
alias for a qualified name, without attempting to load a namespace.

``` clojure
(ns megacorp.profitd.example
  (:require [megacorp.profitd.scheduling :as scheduling]
            [megacorp.profitd :as-alias profitd]))
```

`megacorp.profitd.scheduling` must exist as a source namespace
and will be loaded and compiled. `megacorp.profitd` does not need to
exist as a source namespace and no attempt will be made to load it.
You can then use `::profitd/data` to refer to the qualified keyword
`:megacorp.profitd/data` without having to type the full name.

See [Use Idiomatic Namespace Aliases](https://guide.clojure.style/#use-idiomatic-namespace-aliases) in the community style guide for more information on namespace aliases.

#### The :refer Option

To make functions in `clojure.set` available in the defined namespace via short names
(i.e., their unqualified names, without the `clojure.set` or other prefix), you can tell Clojure compiler
to *refer* to certain functions:

``` clojure
(ns megacorp.profitd.scheduling
  (:require [clojure.set :refer [difference intersection]]))

;; Now it is possible to do:
;; (difference #{1 2 3} #{3 4 5})
```

The `:refer` feature of the `:require` form was added in Clojure 1.4.

It is possible to refer to all functions in a namespace (usually not necessary):

``` clojure
(ns megacorp.profitd.scheduling
  (:require [clojure.set :refer :all]))

;; Now it is possible to do:
;; (difference #{1 2 3} #{3 4 5})
```

It is recommended you avoid `:refer :all` and prefer an alias instead.
Use `:refer` to make specific functions available if it makes the
code easier to read. A couple of good examples are:

* `(:require [clojure.test :as test :refer [deftest is are]])`
* `(:require [clojure.core.async :as async :refer [<! <!! >! >!!]])`


### The :import Helper Form

The `:import` helper form is for setting up access to Java classes
from your Clojure code. For example:

``` clojure
(ns megacorp.profitd.scheduling
  (:import java.util.concurrent.Executors))
```

This will make sure the `java.util.concurrent.Executors` class is imported and can be used by its short
name, `Executors`. It is possible to import multiple classes:

``` clojure
(ns megacorp.profitd.scheduling
  (:import java.util.concurrent.Executors
           java.util.concurrent.TimeUnit
           java.util.Date))
```

If multiple imported classes are in the same namespace (like in the example above),
it is possible to avoid some duplication by using an *import list*. The first element
of an import list is the package and other elements are class names in that package:

``` clojure
(ns megacorp.profitd.scheduling
  (:import [java.util.concurrent Executors TimeUnit]
           java.util.Date))
```

Even though *import list* is called a list, it can be a vector as
shown here. Some people prefer to use lists for import lists, on
the grounds that the first element is special: it's a package name
and subsequent elements are class names.



### The Current Namespace

Under the hood, Clojure tracks the **current namespace** in a special var, [\*ns\*](https://clojuredocs.org/clojure.core/*ns*).
When vars are defined using the [def](https://clojuredocs.org/clojure.core/def) special form, they are
added to the current namespace.




### The :refer-clojure Helper Form

Functions like `clojure.core/get` and macros like `clojure.core/defn` can be used without
namespace qualification because they reside in the `clojure.core` namespace and the `ns` macro automatically *refers* all vars in `cloure.core` by default. Therefore, if your
namespace defines a function with the same name (e.g. `find`), you will get a warning
from the compiler, like this:

```
WARNING: find already refers to: #'clojure.core/find in namespace: megacorp.profitd.scheduling, being replaced by: #'megacorp.profitd.scheduling/find
```

This means that in the `megacorp.profitd.scheduling` namespace, `find` already refers to
a value which happens to be `clojure.core/find`, but it is being replaced by a
different value. Remember, Clojure is a very dynamic language and namespaces are
basically maps, as far as the implementation goes. Most of the time, however,
replacing vars like this is not intentional and Clojure compiler emits a warning.

To address this warning, you can either rename your function, or else
exclude certain `clojure.core` functions from being
referred using the `(:refer-clojure ...)` form within the `ns`:

``` clojure
(ns megacorp.profitd.scheduling
  (:refer-clojure :exclude [find]))

(defn find
  "Finds a needle in the haystack."
  [^String haystack]
  (comment ...))
```

In this case, to use `clojure.core/find`, you will have to use its fully
qualified name: `clojure.core/find`:

``` clojure
(ns megacorp.profitd.scheduling
  (:refer-clojure :exclude [find]))

(defn find
  "Finds a needle in the haystack."
  [^String haystack]
  (clojure.core/find haystack :needle))
```

Or introduce an alias for `clojure.core` to reduce the amount of typing:

``` clojure
(ns megacorp.profitd.scheduling
  (:refer-clojure :exclude [find])
  (:require [clojure.core :as core]))

(defn find
  "Finds a needle in the haystack."
  [^String haystack]
  (core/find haystack :needle))
```

`cc` is also a common alias used for `clojure.core` so it is less
likely to conflict with a `core` alias from another namespace:

``` clojure
(ns megacorp.profitd.scheduling
  (:refer-clojure :exclude [find])
  (:require [clojure.core :as cc]))

(defn find
  "Finds a needle in the haystack."
  [^String haystack]
  (cc/find haystack :needle))
```

### The :use Helper Form

In Clojure versions before 1.4, there was no `:refer` support for the
`(:require ...)` form. Instead, a separate form was used: `(:use ...)`:

``` clojure
(ns megacorp.profitd.scheduling-test
  (:use clojure.test))
```

In the example above, **all** functions in `clojure.test` are made available
in the current namespace. This practice (known as "naked use") works for `clojure.test` in
test namespaces, but in general not a good idea. `(:use ...)` supports limiting
functions that will be referred:

``` clojure
(ns megacorp.profitd.scheduling-test
  (:use clojure.test :only [deftest testing is]))
```

which is a pre-1.4 alternative of

``` clojure
(ns megacorp.profitd.scheduling-test
  (:require clojure.test :refer [deftest testing is]))
```

It is highly recommended to use `(:require ...)` (optionally with `... :refer [...]`) in modern Clojure code.
`(:use ...)` is a thing of the past and now that
`(:require ...)` with `:refer` is capable of doing the same thing when you
need it, it is a good idea to let `(:use ...)` go.


### The :gen-class Helper Form

See [`gen-class` and how to implement Java classes in Clojure](interop.md#gen-class-and-how-to-implement-java-classes-in-clojure)
in the **Language: Java Interop** guide.


### Documentation and Metadata

Namespaces can have documentation strings. You can add one after
the namespace name in the `ns` macro:

``` clojure
(ns superlib.core
  "Core functionality of Superlib.

   Other parts of Superlib depend on functions and macros in this namespace."
  (:require [clojure.set :refer [union difference]]))
```

or via metadata before the namespace name:

``` clojure
(ns ^{:doc "Core functionality of Superlib.
            Other parts of Superlib depend on functions and macros in this namespace."
      :author "Joe Smith"}
   superlib.core
  (:require [clojure.set :refer [union difference]]))
```

Metadata can contain any additional keys such as `:author` which may be of use to various tools
(such as [Codox](https://clojars.org/codox) or [cljdoc.org](https://cljdoc.org)).


## How to Use Functions From Other Namespaces in the REPL

The `ns` macro is how you usually require functions from other namespaces.
However, it is not very convenient in the REPL. For that case, the `clojure.core/require` function
can be used directly:

``` clojure
;; Will be available as clojure.set, e.g. clojure.set/difference.
(require 'clojure.set)

;; Will be available as io, e.g. io/resource.
(require '[clojure.java.io :as io])
```

It takes a quoted *[libspec](/articles/language/glossary/#libspec)*. The libspec is either a namespace name or
a collection (typically a vector) of `[name :as alias]`,
`[name :as-alias alias]`,
or `[name :refer [fns]]`:

``` clojure
(require '[clojure.set :refer [difference]])

(difference #{1 2 3} #{3 4 5 6})  ; ⇒ #{1 2}
```

The `:as` and `:refer` options can be used together:

``` clojure
(require '[clojure.set :as set :refer [difference]])

(difference #{1 2 3} #{3 4 5 6})  ; ⇒ #{1 2}
(set/union #{1 2 3} #{3 4 5 6})    ; ⇒ #{1 2 3 4 5 6}
```

`clojure.core/use` does the same thing as `clojure.core/require` but with the
`:refer` option (as discussed above). It is not generally recommended to use `use` with Clojure
versions starting with 1.4. Use `clojure.core/require` with `:refer`
instead.


## Namespaces and Class Generation

See [`gen-class` and how to implement Java classes in Clojure](interop.md#gen-class-and-how-to-implement-java-classes-in-clojure)
in the **Language: Java Interop** guide.


## Namespaces and Code Compilation in Clojure

Clojure is a compiled language: code is compiled when it is loaded (usually with `clojure.core/require`).

A namespace can contain vars or be used purely to extend protocols, add multimethod implementations,
or conditionally load other libraries (e.g. the most suitable JSON parser or key/value store implementation).
In all cases, to trigger compilation, you need to require the namespace.


## Private Vars

Vars (and, in turn, functions defined with `defn`) can be private. There are two equivalent ways to
specify that a function is private: either via metadata or by using the `defn-` macro:

``` clojure
(ns megacorp.superlib)

;;
;; Implementation
;;

(def ^{:private true}
  source-name "supersource")

(defn- data-stream
  [source]
  (comment ...))
```



## How to Look up and Invoke a Function by Name

It is possible to look up a function in a particular namespace by-name with `clojure.core/ns-resolve`. This takes
quoted names of the namespace and function. The returned value can be used just like any other
function, for example, passed as an argument to a higher order function:

``` clojure
(require 'clojure.set) ; must happen before ns-resolve

(ns-resolve 'clojure.set 'difference)  ; ⇒ #'clojure.set/difference

(let [f (ns-resolve 'clojure.set 'difference)]
   (f #{1 2 3} #{3 4 5 6}))  ; ⇒ #{1 2}
```

The namespace must have already been loaded and compiled. If it has not, `ns-resolve` will throw an exception.

To resolve a symbol in the current namespace: `(ns-resolve *ns* 'foo)`.

A more commonly-used alternative to `ns-resolve` is `clojure.core/resolve` which takes a symbol (which may be qualified or not) and
tries to resolve the symbol against the current namespace:

``` clojure
(require 'clojure.set) ; must happen before resolve

(resolve 'clojure.set/difference)  ; ⇒ #'clojure.set/difference

(let [f (resolve 'clojure.set/difference)]
   (f #{1 2 3} #{3 4 5 6}))  ; ⇒ #{1 2}
```

Unlike `ns-resolve`, if the namespace has not already been loaded and compiled, `resolve` will return `nil` instead of throwing an exception.

If you want to resolve a symbol in a namespace that has not yet
been loaded and compiled, use `requiring-resolve`:

``` clojure
;; no require of clojure.set needed:
(let [f (requiring-resolve 'clojure.set/difference)]
   (f #{1 2 3} #{3 4 5 6}))  ; ⇒ #{1 2}
```

## Compiler Exceptions

This section describes some common compilation errors.


### ClassNotFoundException

This exception means that JVM could not load a class. It is either misspelled or not on the
[classpath](/articles/language/glossary/#classpath).
Potentially your project has an unsatisfied dependency.

Example:

``` clojure
user=> (import java.uyil.concurrent.TimeUnit)
Execution error (ClassNotFoundException) at java.net.URLClassLoader/findClass (URLClassLoader.java:445).
java.uyil.concurrent.TimeUnit
```

In the example above, `java.uyil.concurrent.TimeUnit` should have been `java.util.concurrent.TimeUnit`:

``` clojure
user=> (import java.util.concurrent.TimeUnit)
java.util.concurrent.TimeUnit
```

Note that `import` is a macro so the package and class names do not need to be quoted (unlike `require` which is a function and evaluates
its arguments first).

### CompilerException java.lang.RuntimeException: No such var

This means that somewhere in the code a non-existent var is used. It may be a typo, an
incorrect macro-generated var name or a similar issue. Example:

``` clojure
user=> (clojure.java.io/resouce "thought_leaders_quotes.csv")
Syntax error compiling at (REPL:1:1).
No such var: clojure.java.io/resouce
```

In the example above, `clojure.java.io/resouce` should have been `clojure.java.io/resource`. `REPL:1:1`
means that compilation was triggered from the REPL and not a Clojure source file.



## Temporarily Overriding Vars in Namespaces

*TBD: [How to Contribute](https://github.com/clojure-doc/clojure-doc.github.io#how-to-contribute)*



## Getting Information About and Programmatically Manipulating Namespaces

*TBD: [How to Contribute](https://github.com/clojure-doc/clojure-doc.github.io#how-to-contribute)*



## Wrapping Up

Namespaces are basically maps (dictionaries) that map names to
vars. In many cases, those vars store functions in them.

This implementation lets Clojure have many of its highly dynamic
features at a very reasonable runtime overhead cost. For example, vars
in namespaces can be temporarily altered for unit testing purposes.



## Contributors

Michael Klishin <michael@defprotocol.org> (original author)
