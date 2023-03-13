{:title "Getting Started with the Clojure CLI"
 :page-index 1001
 :layout :page}

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

To quickly get started, first make sure you've got Java installed.

Then install the [official Clojure CLI](https://clojure.org/guides/install_clojure).

For macOS, Linux, and Windows with WSL2, the [POSIX](https://clojure.org/guides/install_clojure#_posix_instructions)
or [Linux](https://clojure.org/guides/install_clojure#_linux_instructions)
instructions will work. For the small percentage of Clojure users on Windows
planning to use Powershell or `cmd.exe`, the
[MSI installer](https://github.com/casselc/clj-msi) provided by the community
is probably your easiest route.

A useful shortcut to get the latest stable version is to use the script name
without the version number:

```shell
curl -O https://download.clojure.org/install/posix-install.sh
# or:
curl -O https://download.clojure.org/install/linux-install.sh
```

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
$ clojure -M -e '(println "Hello, World!")'
Hello, World!
```

or:

```
$ clojure -M -e '(clojure-version)'
"1.11.1"
```

The `-e` option prints the value returned by the expression (if it is not `nil`).

## Interactive Development

_[This is currently a copy of the Leiningen Interactive Development section but will be updated to cover the Clojure CLI shortly!]_

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


## See Also

Other getting started documentation you might find useful:

  * [Clojure Distilled](http://yogthos.github.io/ClojureDistilled.html):
    introduction to core concepts necessary for working with Clojure
  * [A Brief Beginner's Guide to
    Clojure](http://www.unexpected-vortices.com/clojure/brief-beginners-guide/index.html):
    contains a bit more overview and background material for learning your way
    around the landscape.


## Next Stop

Next stop: [the basic Clojure language tutorial](/articles/tutorials/introduction/).



## Contributors

John Gabriele <jmg3000@gmail.com> (original Leiningen version)
