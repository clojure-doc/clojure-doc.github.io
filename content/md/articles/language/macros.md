{:title "Language: Macros"
 :page-index 2800
 :klipse true
 :layout :page}

This guide covers:

  * Clojure macros
  * the Clojure compilation process

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).



## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.11.



## Before You Read This Guide

This is one of the most hardcore guides of the entire Clojure documentation
project. It describes concepts that are relatively unique to the Lisp family of languages
that Clojure belongs to. Understanding them may take some time for folks without
a metaprogramming background. Don't let this learning curve
discourage you.

If some parts are not clear, please ask for clarification
[in the `#clojure-doc` channel on Slack](https://clojurians.slack.com/archives/C02M6N5C137)
([self-signup at clojurians.net](http://clojurians.net))
or [file an issue](https://github.com/clojure-doc/clojure-doc.github.io/issues) on GitHub.
We will work hard on making this guide easy to follow with edits and
images to illustrate the concepts.


## Overview

Clojure is a dialect of Lisp and while it departs from some features of "traditional" Lisps,
the fundamentals are all there. One very powerful feature that comes with Lisps is *macros*,
a way to do metaprogramming using the language itself. This is pretty different from
other languages known for good metaprogramming capabilities (e.g. Ruby) in that
in Clojure, metaprogramming does not mean string generation. Instead, it means
constructing a tree [of S-expressions, or lists]. This enables very powerful
DSLs (domain-specific languages).


## Compile Time and Run Time

Clojure is a compiled language. The compiler reads source files or strings (of source code),
produces data structures (aka the AST), and performs *macroexpansion*. Macros are evaluated at
*compile time* and produce modified data structures that are compiled to the JVM
bytecode. That bytecode is executed at *run time*.

Clojure code is compiled when it is loaded with `clojure.core/require`
(or other, lower-level functions like `clojure.core/load-file`).
Clojure code can also be compiled ahead of time (referred to as "AOT compilation")
using tools such as [`tools.build`](https://clojure.org/guides/tools_build),
via the Clojure CLI, or [Leiningen](https://leiningen.org).


## Clojure Reader

Reader is another name for parser. Unlike many other languages, the reader in Clojure
can be extended in the language itself. It is also exposed to the language
with `clojure.core/read` and `clojure.core/read-string` functions that
return data structures:

<pre style="visibility:hidden; height:0;"><code class="klipse-clojure" >
(require '[cljs.reader :refer [read-string]])
</code></pre>

```klipse-clojure
(read-string "(if true :truth :false)")
;= (if true :truth :false)
```

Here we got back a list that is not evaluated.

The reader produces data structures (in part that's why "code is data" in
what we refer to as "homoiconic languages") which are then evaluated:

 * Literals (e.g., strings, integers, vectors) evaluate to themselves
 * Lists evaluate to invocations (calls) of functions and so on
 * Symbols are resolved to a var value

Expressions that can be evaluated (invoked) are known as *forms*. Forms consist of:

 * Functions
 * Macros
 * Special forms

### Special Forms

The reader parses some forms in special ways that are not consistent
with the rest of Clojure's syntax.

Such forms are called *special forms*. Commonly used examples include:

 * def
 * if
 * do
 * let
 * loop
 * recur

See [Special Forms](https://clojure.org/reference/special_forms) in the official
Clojure reference documentation for a complete list and more detail.

Some of these special forms are actually macros that expand to underlying special forms
that the compiler implements directly, but that should be considered an
implementation detail (`loop` is implemented as a macro on top of `loop*`, for example).

## First Taste of Macros

Some programming languages include an `unless` expression (or statement) that is
the opposite of `if`. Clojure is not one of them but it can be added by using
a macro:

<pre style="visibility:hidden; height:0;"><code class="klipse-clojure" >
(require '[chivorcam.core :refer [defmacro defmacfn]])
</code></pre>

```klipse-clojure
(defmacro unless
  "Similar to if but negates the condition"
  [condition & forms]
  `(if (not ~condition)
     ~@forms))
```

Macros are defined using the `clojure.core/defmacro` function that takes
macro name as a symbol, an optional documentation string, a vector
of arguments and the macro body.

This macro can be used like similarly to the `if` form:

```klipse-clojure
(unless (= 1 2)
  "one does not equal two"
  "one equals two. How come?")
```

Just like the `if` special form, this macro produces an expression that
returns a value:

``` clojure
(unless (= 1 2)
  "one does not equal two"
  "one equals two. How come?")
```

in fact, this is because the macro piggybacks on the `if` form.
To see what the macro expands to, we can use `clojure.core/macroexpand-1`:

```klipse-clojure
(macroexpand-1 '(unless (= 1 2) true false))
;= (if (clojure.core/not (= 1 2)) true false)
```

> Note: Clojure on the JVM would expand to a call to `clojure.core/not` here but the interactive examples use Klipse which runs as ClojureScript in the browser, so it expands to `cljs.core/not` instead.

This simplistic macro and the way we expanded it with `macroexpand-1`
demonstrates three features of the Clojure reader that are used when
writing macros:

 * Quote (')
 * Syntax quote (`)
 * Unquote (~)
 * Unquote splicing (~@)

## Quote

Quote suppresses evaluation of the form that follows it. In other words,
instead of being treated as an invocation, it will be treated as a list.

Compare:

```klipse-clojure
;; this form is evaluated by calling the clojure.core/+ function
(+ 1 2 3)
;= 6
```

```klipse-clojure
;; quote suppresses evaluation so the + is treated as a regular
;; list element
'(+ 1 2 3)
;= (+ 1 2 3)
```

## Syntax Quote

Syntax quote also suppresses evaluation of the form that follows it
but allows for substitution of parts of that form using unquote (`~`).
It is similar to templating languages where parts
of the template are "fixed" and parts are "inserted" (evaluated).
The syntax quote makes the form that follows it "a template".

```klipse-clojure
;; syntax quote suppresses evaluation but `~x` is evaluated:
(let [x 2] `(+ 1 ~x 3))
;= (clojure.core/+ 1 2 3)
```

Unquote is covered in more detail in the next section.

## Unquote

Unquote is how parts of the template are evaluated
(like variables in templates in templating languages).

Let's take another look at the same `unless` macro:

```klipse-clojure
(defmacro unless
  [condition & forms]
  `(if (not ~condition)
     ~@forms))
```

and how we invoke it:

```klipse-clojure
(unless (= 1 2)
  "one does not equal two"
  "one equals two. How come?")
```

When the macro is expanded, the `condition` local in this example has the value
of `(= 1 2)` (a list). We want to substitute the _value_ of `condition` into
the `if` form in our template, and that's what unquote (`~`) does as can be seen
from macroexpansion:

```klipse-clojure
(macroexpand-1 '(unless (= 1 2) true false))
;= (if (clojure.core/not (= 1 2)) true false)
```

Compare this with what the macro expands to when the unquote is removed:

```klipse-clojure
;; incorrect, missing unquote!
(defmacro unless
  [condition & forms]
  `(if (not condition)
     ~@forms))

(macroexpand-1 '(unless (= 1 2) true false))
;= (if (clojure.core/not user/condition) true false)
```

### Implementation Details

The unquote operator is replaced by the reader with a call to a core
Clojure function, `clojure.core/unquote`.

## Unquote-splicing

Some macros take multiple forms. This is common in DSLs, for example.
Each of those forms is often need to be quoted and concatenated.

The unquote-splicing operator (`~@`) is a convenient way to do it,
unrolling a collection of forms into the expanded code:

```klipse-clojure
(defmacro unsplice
        [& coll]
        `(do ~@coll))
```

```klipse-clojure
(macroexpand-1 '(unsplice (def a 1) (def b 2)))
;= (do (def a 1) (def b 2))
```

```klipse-clojure
(unsplice (def a 1) (def b 2))
;= #'user/b
```

```klipse-clojure
a
;= 1
```

```klipse-clojure
b
;= 2
```

### Implementation Details

The unquote-splicing operator is replaced by the reader with a call to a core
Clojure function, `clojure.core/unquote-splicing`.


## Macro Hygiene and gensym

When writing a macro, there is a possibility that the macro will interact with
vars or locals outside of it in unexpected ways, for example, by [shadowing](http://en.wikipedia.org/wiki/Variable_shadowing) them.
Such macros are known as *unhygienic macros*.

Clojure does not implement a full solution to hygienic macros but
provides solutions to the biggest pitfalls of unhygienic macros:

 * Symbols within a syntax quoted form are namespace-qualified
 * Unique symbol name generation (aka *gensyms*)

### Namespace Qualification Within Syntax Quote

To demonstrate this behavior of syntax quote, consider the following example
that replaces values "yes" and "no" with true and false, respectively, at compile
time:

```klipse-clojure
(defmacro yes-no->boolean
  [val]
  `(let [b (= ~val "yes")]
    b))
;= #'user/yes-no->boolean
```

```klipse-clojure
(macroexpand-1 '(yes-no->boolean "yes"))
;= (clojure.core/let [user/b (clojure.core/= "yes" "yes")] user/b)
```

Macroexpansion demonstrates that the Clojure compiler makes the `b` symbol namespace-qualified
(`user` is the default namespace in the Clojure REPL). This helps avoid var and local
shadowing -- but `let` does not allow namespace-qualified symbol so this macro
produces invalid code. We'll see how to avoid this in the next section.

> Note: Special forms are not necessarily qualified. See section 'Special Forms in Detail'.

### Generated Symbols (gensyms)

Automatic namespace generation is fine in some cases, but not every time. Sometimes
a symbol name that is unique in the macro scope is necessary.

Unique symbols names can be generated with the `clojure.core/gensym` function that
take an optional base string:

```klipse-clojure
(gensym)
;= G__54
```

```klipse-clojure
(gensym "base")
;= base57
```

There is a shortcut: if a symbol ends in `#` within a syntax quote form, it will be
expanded by the compiler into a gensym (also known as an auto-gensym):

```klipse-clojure
(defmacro yes-no->boolean
  [val]
  `(let [b# (= ~val "yes")]
     b#))
;= #'user/yes-no->boolean
```

```klipse-clojure
(macroexpand-1 '(yes-no->boolean "yes"))
;= (clojure.core/let [b__148__auto__ (clojure.core/= "yes" "yes")] b__148__auto__)
```

The name that replaced `b#` was generated by the compiler to make unwanted variable
capture very unlikely in practice, and impossible if all bindings are named with auto-gensym.

Theoretically, Clojure's approach to generating uncaptured gensyms (incrementing a global counter) can be circumvented
via a mischievous macro or very bad luck.

Tip:
Avoid code with `__` in local binding names. This ensures
auto-gensyms are *never* captured in unwanted ways.

## Macroexpansions

During macro development, it is important to be able to test the macro
and see what data structures the macro expands to. This can be done
with two functions in the core Clojure library, and an additional one
from `clojure.walk`:

 * `clojure.core/macroexpand-1`
 * `clojure.core/macroexpand`
 * `clojure.walk/macroexpand-all`

The difference between the first two is that `macroexpand-1` will expand the macro
only once. If the result contains calls to other macros, those won't be expanded.
`macroexpand`, however, will continue expanding macros until the top level form
is no longer a macro.

All of these macroexpansion functions take quoted forms.

Macro expansion functions can be used to find out that `when` is a macro implemented on top of
the `if` special form, for example:

```klipse-clojure
(macroexpand '(when true 1 42))
```

Neither `macroexpand-1` nor `macroexpand` expand nested
forms. To fully expand macros including those in nested forms, there is `clojure.walk/macroexpand-all`
which can be useful for debugging macros but does not behave exactly the same way
as the Clojure compiler.


## Difference Between Quote and Syntax Quote

The key differences between quote (') and syntax quote (`) are that
symbols within a syntax quoted form are automatically namespace-qualified,
and unquote (~) only works in a syntax quoted form.


## Security Considerations

`clojure.core/read-string` *can execute arbitrary code* and *must not* be used
on inputs coming from untrusted sources. This behavior is controlled by the `clojure.core/*read-eval*`
var, which defaults to `true` (unsafe), but can be set to `false` (safe)
via `binding`.

`*read-eval*` can also be set via a property when starting the JVM:

```
-Dclojure.read.eval=false
```

See the [`*read-eval*` documentation](https://clojure.github.io/clojure/clojure.core-api.html#clojure.core/*read-eval*)
for more information.

When reading Clojure forms from untrusted sources, use `clojure.edn/read-string`, which is
does not perform arbitrary code execution and is safer. `clojure.edn/read-string` implements
the [EDN format](https://github.com/edn-format/edn), a subset of Clojure syntax for data
structures. `clojure.edn` was introduced in Clojure 1.5.


## Special Forms in Detail

Special forms as symbols have some limitations on their use and cannot
be used like other `clojure.core` functions in certain situations.

 * Special forms must be a list with a special name as the first element.

   A special name in a higher-order context is not a special form.

   ```clojure
   do
   ;; Syntax error compiling at (REPL:0:0).
   ;; Unable to resolve symbol: do in this context
   ```

   Macros have a similar restriction, but notice: the macro's var is identified in the error while
   special names have no meaning at all outside the first element of a list.

   ```clojure
   dosync
   ;; Syntax error compiling at (REPL:0:0).
   ;; Can't take value of a macro: #'clojure.core/dosync
   ```

 * Special form names are not namespace-qualified.

   Most special forms (all except `clojure.core/import*`) are not namespace
   qualified. The reader must circumvent syntax quote's policy of namespace-qualifying
   all symbols.

   ```klipse-clojure
   `a
   ;; user/a
   ```

   ```klipse-clojure
   `do
   ;; do
   ```

   ```clojure
   user=> `if
   if
   user=> `import
   import
   ```

 * Special forms conflict with local scope.

   Never use special names as local binding or global variable names.

   ```clojure
   (let [do 1] do)
   nil
   ```

   Ouch!

   This includes destructuring:

   ```clojure
   user=> (let [{:keys [do]} {:do 1}] do)
   nil
   ```

   Note: Be wary of maps with keyword keys with special names, they are more
   likely to be destructured this way.

Keep these special cases in mind as you work through the tutorial.

## Contributors

* Michael Klishin <michael@defprotocol.org>, 2013 (original author)
* Ambrose Bonnaire-Sergeant <abonnairesergeant@gmail.com>, 2013
