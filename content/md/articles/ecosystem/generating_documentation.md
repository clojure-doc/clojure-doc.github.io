{:title "Generating Documentation"
 :layout :page :page-index 3800}

This guide notes some commonly-used tools for generating project
documentation.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).


## Overview

Projects commonly (hopefully?) have at least two types of
documentation:

  * standalone
    [Markdown](http://en.wikipedia.org/wiki/Markdown)-formatted docs
    in the project's doc directory
  * docstrings in the project's source code (in both `ns` and `defn`)

There are a number of tools for generating handsome API docs from
docstrings and other project metadata.

## cljdoc.org

Probably the most popular solution for generating _and hosting_ API
documentation for libraries in [cljdoc.org](https://cljdoc.org/). It
can build documentation for any library released to [Clojars](https://clojars.org/),
and lets you combine arbitrary articles alongside API docs generated
from your source code. It also provides _versioned_ documentation, so
that every published version of your library can have its own set of
documentation!

As a library author considering using `cljdoc.org`, you will want to
read [their user guide for library authors](https://github.com/cljdoc/cljdoc/blob/master/doc/userguide/for-library-authors.adoc).

If you are building your library JAR file with the Clojure CLI and
`tools.build`, you will want to read our
[`tools.build` cookbook](/articles/cookbooks/cli_build_projects/) --
in particular **The Generated `pom.xml` File** section, to ensure your
JAR file's `pom.xml` file contains both `<licenses>` (required for
publishing to Clojars) and `<scm>` (required for `cljdoc.org` to find
your source code and build the documentation).

## Codox

If you'd like to generate nice-looking HTML API docs for your library,
directly into your project's `doc` directory, you may want to
use [Codox](https://github.com/weavejester/codox). Usage instructions
are in the Codox README. Running Codox (either via the Clojure CLI
or as a Leiningen plug-in) will create a `doc` subdirectory
containing the resulting HTML.



## Marginalia

If you'd like to render API docs side-by-side with the source code
it's documenting, you may want to use [Marginalia](https://github.com/gdeer81/marginalia).
Usage instructions are in the readme.

It also has a [Leiningen plugin](https://github.com/gdeer81/lein-marginalia).
