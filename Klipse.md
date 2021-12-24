# How to Klipsify an article

## Basic steps

Having interactive code snippets in an article is straightforward. You need to:

1. Add `:klipse true` in the map at the beginning of the article
1. Instead of a clojure block, you make a `klipse-clojure` block and Boom the code snippet becomes interactive

## Macros

Write macros in Klipse require using `defmacro` from `https://github.com/mfikes/chivorcam`, like this:

```clojure
(require '[chivorcam.core :refer [defmacro defmacfn]])
```

You might want to put hide this code snippet, by using HTML tags:

```html
<pre style="visibility:hidden; height:0;"><code class="klipse-clojure">
(require '[chivorcam.core :refer [defmacro defmacfn]])
</code></pre>
```

Dealing with macros in Klipse is a bit cumbersome. You need to

1. Define the macro in a namespaces whose name ends with `$macros`
1. Use the macro with its fully-qualified names (without the `$macros`)

Imagine you want to create a macro named `foo` and use it in `cljs.user` namespace.

First, you switch to `cljs.user$macros` namespace to create the macro:

```clojure
(ns cljs.user$macros)

(defmacro foo [m]
  m)
```

Then, you use the macro with its fully-qualified name `cljs.user/foo`, like this:

```clojure
(ns cljs.user)

(cljs.user/foo 123)
```
