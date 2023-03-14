{:title "Getting Started with Clojure"
 :page-index 1000
 :layout :page}

This guide covers:

 * prerequisites (such as the Clojure CLI or Leiningen) and installation
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

Then install either the [official Clojure CLI](https://clojure.org/guides/deps_and_cli)
or the [Leiningen](https://leiningen.org/) project management
tool.

### Clojure CLI or Leiningen?

If you are already following a book or tutorial that uses Leiningen,
you can follow the [Getting Started with Clojure and Leiningen](/articles/tutorials/getting_started_lein)
guide here.

If you are following a book or tutorial that uses the Clojure CLI,
there will be a similar Getting Started with the Clojure CLI guide soon!

Leiningen is "batteries-included", providing the ability to run code, start a
REPL, run tests, build and deploy a JAR file, create a new project, etc.
The Clojure CLI is focused on running code and starting a REPL. Additional
libraries and tools exist for use with the CLI to run tests, build and deploy
a JAR file, create a new project, etc. Leiningen is "easy". The CLI is "simple".

> **Why are there multiple tools?**
>
> When Clojure first appeared, developers used existing tooling from the Java
world (or earlier). In late 2009, Leiningen appeared as a "batteries-included"
tool to make it easy to run Clojure code, start a REPL, run tests, build a
JAR file for distribution or deployment. It was designed around a "plugin"
architecture so that the community could provide new functionality -- such as
creating new application and library projects, which was later incorporated
into the core Leiningen project. For years, Leiningen was really the only
option, if you didn't want to do things "manually" using older, more general
tooling.
>
> Boot appeared as an alternative to Leiningen in 2013 but didn't really take
off until 2015 (with its 2.0 release). Instead of a "plugin" architecture,
Boot let you extend the core functionality using regular Clojure functions.
It also provided a more programmatic approach to specifying dependencies
(compared to Leiningen's declarative `project.clj` file). Boot never
achieved the popularity of Leiningen and has mostly faded away over time.
>
> In 2018, the core Clojure team released the official Clojure CLI that used
a declarative approach to specifying dependencies (the `deps.edn` file) and
focused on "running Clojure code". The community responded by providing a
number of tools based on the CLI's underlying library: `tools.deps`.
The CLI also offered git dependencies out of the box, so that libraries and
tools could be made available directly on GitHub (or other similar public
repositories) with needing JAR files to be built and deployed.
>
> Since the release of the official Clojure CLI, usage of Leiningen has dropped
as the community adopted the new CLI and associated libraries such as
`tools.deps` and `tools.build`.
_[See [State of Clojure 2022 Survey Results](https://clojure.org/news/2022/06/02/state-of-clojure-2022)]_
>
> **Too Much Information! What Should I Use?**
>
> As noted above, if you're following a book or tutorial that uses Leiningen,
or working with a project that uses Leiningen, then keep using Leiningen.
>
> If you're following a book or tutorial that uses the newer CLI, or working
with a project that uses it, then keep using the Clojure CLI and associated
libraries.
>
> If you're starting from scratch, learning the Clojure CLI is probably a
better option because that's where most of the community effort (and core
Clojure team effort) is going to be focused these days.

The reality is that you'll probably have to learn at least a bit of the Clojure CLI **and** Leiningen for the time being!


## Next Stop

Next stop: [the basic Clojure language tutorial](/articles/tutorials/introduction/).



## Contributors

John Gabriele <jmg3000@gmail.com> (original author)
