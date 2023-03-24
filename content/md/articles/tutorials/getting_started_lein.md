{:title "Getting Started with Clojure and Leiningen"
 :sidebar-omit? true :page-index 1002
 :layout :page}

This guide covers:

 * prerequisites (such as Leiningen) and installing
 * running the REPL
 * creating a project
 * interactive development

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).


## Overview

Clojure is a wonderfully simple language and you are going to love
it.

To quickly get started, first make sure you've got Java installed.

Then install the [Leiningen](https://leiningen.org/) project management
tool.

> This author (jg) recommends always installing by downloading the
> script directly (as described in the instructions at leiningen.org),
> rather than using your OS's package manager. This will ensure that
> you get the latest lein version 2.

Clojure programs are typically developed inside their own project
directory, and Leiningen manages projects for you. Lein takes care of
pulling in dependencies (including Clojure itself), running the REPL,
running your program and its tests, packaging your program for
distribution, and other administrative tasks. Run `lein help` to
see the list of all the tasks it can perform.

> Again, there's no need to "install" Clojure, per se. Lein
> will take care of fetching it for you.


## Trying out the REPL

Although lein facilitates managing your projects, you can also run it
on its own (outside of any particular project directory). Once you
have the `lein` tool installed, run it from anywhere you like to get a
repl:

    $ lein repl

You should be greeted with a "`user=>`" prompt. Try it out:

``` clojure
user=> (+ 1 1)
;; ⇒ 2
user=> (distinct [:a :b :a :c :a :d])
;; ⇒ (:a :b :c :d)
user=> (dotimes [i 3]
  #_=>   (println (rand-nth ["Fabulous!" "Marvelous!" "Inconceivable!"])
  #_=>            i))
;; Marvelous! 0
;; Inconceivable! 1
;; Fabulous! 2
;; ⇒ nil
```


## Your first project

Create your first Clojure program like so:

``` bash
lein new app my-proj
cd my-proj
# Have a look at the "-main" function in src/my_proj/core.clj.
lein run
```

and see the output from that `println` function call in
my_proj/core.clj!


### Working in the REPL

In your project directory, start up a repl (`lein repl`) and
run your `-main` function to see its output in the repl:

    $ lein repl
    ...
    my-proj.core=> (-main)
    Hello, World!
    nil

(The prompt is now "my-proj.core=>" instead of "user=>" because lein
has started the repl in an app project. More about that ("namespaces")
in the topical guides.)

From elsewhere, open up your my-proj/src/my_proj/core.clj file
in your editor. Modify the text in that `println` call.

Back in the repl, reload your source file and run `-main` again:

    my-proj.core=> (require 'my-proj.core :reload)
    my-proj.core=> (-main)

to see your changes.


### Interactive Development

While you can work with the REPL as shown above for small projects while
you are getting started, the real benefits of Clojure's "interactive
development" mindset require an approach that more tightly integrates your
editor with a running REPL.

Most Clojure-enabled editors have a way to automatically start a REPL for
a Leiningen project and connect to it in such a way that you can evaluate code
directly inside your editor, allowing you to "grow" your program incrementally
while testing each piece of it and exploring how code works, alongside your
running program.

It's common to use `comment` as a way to include exploratory code in your
source files, so you can evaluate calls to functions and experiment with
data tranformations:

```clojure
(defn greet
  "Return a greeting for this person."
  [person]
  (str "Hello, " person "!"))

(comment
  ;; Clojure-enabled editors let you easily evaluate these two
  ;; expressions and will usually show the results inline, so
  ;; you don't need to switch back and forth between your editor
  ;; and a separate window running a REPL, and you don't need to
  ;; copy'n'paste code from the editor into the REPL or type
  ;; directly into the REPL -- and these comment forms can be left
  ;; in your code to show how you arrived at the final solution
  ;; (or remind your future self how you got there!).
  (greet "Programmer") ; "Hello, Programmer!"
  (greet nil) ; "Hello, !"
  )
```

> These are sometimes called "Rich Comment Forms" because not only can they be a rich source of infomation about how the code works or how it was developed, but also because Rich Hickey, Clojure's creator, uses this approach quite a lot in his own code.

## See Also

Other getting started documentation you might find useful:

  * [Learn Clojure](https://clojure.org/guides/learn/clojure): the official guide to learning the language
  * [Programming at the REPL](https://clojure.org/guides/learn/clojure): the official guide to working with the REPL
  * [Clojure Editors](/articles/tutorials/editors/)
  * [Clojure Distilled](http://yogthos.github.io/ClojureDistilled.html):
    introduction to core concepts necessary for working with Clojure
  * [A Brief Beginner's Guide to
    Clojure](http://www.unexpected-vortices.com/clojure/brief-beginners-guide/index.html):
    contains a bit more overview and background material for learning your way
    around the landscape.


## Next Stop

Next stop: [the basic Clojure language tutorial](/articles/tutorials/introduction/).



## Contributors

John Gabriele <jmg3000@gmail.com> (original author)
