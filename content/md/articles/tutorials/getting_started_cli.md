{:title "Getting Started with the Clojure CLI"
 :sidebar-omit? true
 :layout :page :toc true}

This guide covers:

 * prerequisites (such as the CLI) and installing
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

To quickly get started, first make sure you've got
[Java installed](https://clojure.org/guides/install_clojure#java).

Then install the [official Clojure CLI](https://clojure.org/guides/install_clojure).

For macOS, Linux, and Windows with WSL2, the [POSIX](https://clojure.org/guides/install_clojure#_posix_instructions)
or [Linux](https://clojure.org/guides/install_clojure#_linux_instructions)
instructions will work. For the small percentage of Clojure users on Windows
planning to use Powershell or `cmd.exe`, the
[MSI installer](https://github.com/casselc/clj-msi) provided by the community
is probably your easiest route.

> For macOS and Linux, [`brew`](https://brew.sh/) (or [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux)) are also reasonable options.

Clojure programs are typically developed inside their own project
directory, with a `deps.edn` file at the top level and a `src` directory
containing one or more source files (Clojure scripts). The CLI takes care of
pulling in dependencies (including Clojure itself), running the REPL,
and running your program. Run `clojure -h` to
see the list of all the options available.


## Trying out the REPL

Once you have the Clojure CLI installed, you can run it from anywhere you like
to get a REPL:

    $ clj

You should be greeted with the Clojure version and a "`user=>`" prompt. Try it out:

```clojure
$ clj
Clojure 1.11.1
user=> (+ 1 1)
;; ⇒ 2
user=> (distinct [:a :b :a :c :a :d])
;; ⇒ (:a :b :c :d)
user=> (dotimes [i 3]
         (println (rand-nth ["Fabulous!" "Marvelous!" "Inconceivable!"])
                  i))
;; Marvelous! 0
;; Inconceivable! 1
;; Fabulous! 2
;; ⇒ nil
```


## Your first project

A Clojure CLI project can start with a `deps.edn` file containing just `{}`
and a `src` folder containing your program:

```
.
├── deps.edn
└── src
    └── my
        └── proj.clj
```

Where `src/my/proj.clj` contains:

```clojure
(ns my.proj)

(defn -main []
  (println "Hello, World!"))
```

You can run this program with:

```
$ clojure -M -m my.proj
```

And it should display:

```
Hello, World!
```

`clojure -M` says we want to run `clojure.main` -- a part of the core Clojure runtime that knows how to run code and/or programs.
The `-m my.proj` option tells `clojure.main` that we want it to load the `my.proj` namespace and run the `-main` function.
`clojure.main` can also evaluate expressions:

```
$ clojure -M -e '(println "Hello, Command!")'
Hello, Command!
```

or:

```
$ clojure -M -e '(clojure-version)'
"1.11.1"
```

The `-e` option prints the value returned by the expression (if it is not `nil`).

### Working in the REPL

In your project directory, start up a repl (`clj`) and
run your `-main` function to see its output in the repl:

    $ clj
    Clojure 1.11.1
    user=> (require 'my.proj)
    nil
    user=> (my.proj/-main)
    Hello, World!
    nil

From elsewhere, open up your `src/my/proj.clj` file
in your editor. Modify the text in that `println` call.

Back in the repl, reload your source file and run `-main` again:

    user=> (require 'my.proj :reload)
    nil
    user=> (my.proj/-main)

to see your changes.

### Interactive Development

While you can work with the REPL as shown above for small projects while
you are getting started, the real benefits of Clojure's "interactive
development" mindset require an approach that more tightly integrates your
editor with a running REPL.

Most Clojure-enabled editors have a way to automatically start a REPL for
a CLI project and connect to it in such a way that you can evaluate code
directly inside your editor, allowing you to "grow" your program incrementally
while testing each piece of it and exploring how code works, alongside your
running program.

It's common to use `comment` as a way to include exploratory code in your
source files, so you can evaluate calls to functions and experiment with
data transformations:

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

  * [Getting Started](https://clojure.org/guides/getting_started): the official Clojure CLI guide
  * [Learn Clojure](https://clojure.org/guides/learn/clojure): the official guide to learning the language
  * [Programming at the REPL](https://clojure.org/guides/learn/clojure): the official guide to working with the REPL
  * [Clojure Editors](/articles/tutorials/editors/)


## Next Stop

Next stop: [the basic Clojure language tutorial](/articles/tutorials/introduction/).



## Contributors

John Gabriele <jmg3000@gmail.com> (original Leiningen version)
