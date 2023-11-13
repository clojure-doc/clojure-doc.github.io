{:title "Table of Contents"
 :page-index 1
 :layout :page}

The content on this site
([source](https://github.com/clojure-doc/clojure-doc.github.io)) is a categorized and
manifold collection of documentation guides for the Clojure programming language and
its ecosystem.

We recognize that different Clojure users have different level of expertise
and separates content into several groups:

 * [Essentials](#essentials)
 * [Language Guides](#language-guides)
 * [Ecosystem & Tools](#the-clojure-ecosystem) (tools, libraries, community, books) guides
 * [Tutorials & Cookbooks](#tutorials-and-cookbooks)


## Essentials

What makes developing in Clojure unique is that we have a focus on
interactive programming: not just the REPL (Read Eval Print Loop) that
Clojure provides but working in an editor that integrates well with the
REPL experience to allow you to evaluate your code, in small pieces,
directly from your editor as you write the code. This provides immediate
feedback as you are exploring your problem space and "growing" your
application.

These first three sections should help you get Clojure and some basic
tooling installed, learn the basics of the language, and get a good
editor setup that allows you to program interactively.

### [Getting Started](/articles/tutorials/getting_started/)

If you're new to Clojure, this is a good place to start.

This guide covers:

  * How to install the Clojure CLI (or Leiningen)
  * Accessing the REPL
  * How to create a minimal project
  * What is interactive development


### [Introduction](/articles/tutorials/introduction/)

A swift introduction to the Clojure language, covering most of the
basics.

### [Editors for Clojure Development](/articles/tutorials/editors/)

A list of popular options for editing Clojure code and working with
Clojure data.


## Language Guides

### [Functions](/articles/language/functions/)

Functions are at the heart of Clojure.

This guide covers:

 * How to define functions
 * How to invoke functions
 * Multi-arity functions
 * Variadic functions
 * Higher order functions
 * Other topics related to functions


### [clojure.core Overview](/articles/language/core_overview/)

`clojure.core` is the core Clojure library.

This guide covers:

 * Key functions of `clojure.core`
 * Key macros of `clojure.core`
 * Key vars of `clojure.core`


### [Collections and Sequences](/articles/language/collections_and_sequences/)

This guide covers:

 * Collections in Clojure
 * Sequences in Clojure
 * Core collection types
 * Key operations on collections and sequences
 * Other topics related to collections and sequences

### [Namespaces](/articles/language/namespaces/)

Namespaces organize Clojure functions.

This guide covers:

 * An overview of Clojure namespaces
 * How to define a namespace
 * How to use functions in other namespaces
 * `require`, `refer` and `use`
 * How to Look up and invoke a function by name
 * Common compilation exceptions and their causes
 * How code compilation works in Clojure

### [Interoperability with Java](/articles/language/interop/)

The Clojure language implementation is symbiotic with its host
platform (the JVM), providing direct interoperability.

This guide covers:

 * How to instantiate Java classes
 * How to invoke Java methods
 * How to extend Java classes with proxy
 * How to implement Java interfaces with reify
 * How to generate Java classes with gen-class
 * Other topics related to interop



### [Polymorphism: Protocols and Multimethods](/articles/language/polymorphism/)

This guide covers:

 * What are polymorphic functions
 * Type-based polymorphism with protocols
 * Ad-hoc polymorphism with multimethods
 * How to create your own data types that behave like core Clojure data types



### [Concurrency & Parallelism](/articles/language/concurrency_and_parallelism/)

This guide covers:

 * An overview of concurrency hazards
 * Clojure's approach to state and identity
 * Immutable data structures
 * Reference types (atoms, vars, agents, refs)
 * Using Clojure functions with `java.util.concurrent` abstractions
 * The Reducers framework (Clojure 1.5+)
 * Other topics related to concurrency and runtime parallelism


### [Macros and Metaprogramming](/articles/language/macros/)

This guide covers:

 * Clojure macros
 * Clojure compilation process
 * Other topics related to metaprogramming


### [Laziness and Lazy Sequences](/articles/language/laziness/)

This guide covers:

 * What are lazy sequences
 * How to create functions that produce lazy sequences
 * How to force evaluation
 * Pitfalls with lazy sequences


### [Glossary](/articles/language/glossary/)

This guide includes definitons of various Clojure-related terminology.



## The Clojure Ecosystem

### [Clojure Community](/articles/ecosystem/community/)

This guide covers:

 * Planet Clojure, mailing lists, IRC channel
 * Clojure conferences
 * Local Clojure user groups
 * Other Clojure community resources

### The Official Clojure CLI

* [Getting Started with the Clojure CLI](/articles/tutorials/getting_started_cli/) on this site
* The [official `deps.edn` and CLI guide](https://clojure.org/guides/deps_and_cli) on clojure.org
* The [official `deps.edn` and CLI reference](https://clojure.org/reference/deps_and_cli) on clojure.org


### [Library Development and Distribution](/articles/ecosystem/libraries_authoring/)

This guide covers:

 * Creating new library projects with the Clojure CLI
 * Basic setup for library development
 * How to publish a library to GitHub
 * How to publish a library to Clojars

### [The Clojure Toolbox](https://www.clojure-toolbox.com/)

This is a well-maintained directory of libraries, organized by category, and is interactively searchable.


### Leiningen

* [Getting Started with Leiningen](https://github.com/technomancy/leiningen/blob/master/doc/TUTORIAL.md) covers
  * What is Leiningen and what it can do for you
  * How to create a project with Leiningen
  * How to manage project dependencies
  * Accessing the REPL
  * How to run tests for your project
  * How to run the app
  * How to compile your code and dependencies into a single JAR for deployment ("überjar")
  * How to share (publish) a library
* [Leiningen Profiles](https://github.com/technomancy/leiningen/blob/master/doc/PROFILES.md) covers
  * What are Leiningen profiles
  * How to use them
* [Distributing Libraries with Leiningen](https://github.com/technomancy/leiningen/blob/master/doc/DEPLOY.md) covers
  * How Clojure libraries are distributed
  * How to publish Clojure libraries to clojars.org
  * How to publish Clojure libraries to Maven Central
  * How to publish Clojure libraries to your own Maven repository
* [Writing Leiningen Plugins](https://github.com/technomancy/leiningen/blob/master/doc/PLUGINS.md) covers
  * What Leiningen plugins can do
  * How to install Leiningen plugins
  * How to develop plugins
  * How to distribute plugins

### [Web Development Overview](/articles/ecosystem/web_development/)

This guide provides a partial overview of the more
popular tools and libraries for web development.

### [Documentation Tools](/articles/ecosystem/generating_documentation/)

 * Tools for generating documentation from docstrings and other project
metadata.


## Tutorials and Cookbooks

### [Getting Started](/articles/tutorials/getting_started/)

This tutorial will get you up and running with the official
Clojure CLI or Leiningen.

### [Introduction to Clojure](/articles/tutorials/introduction/)

This tutorial will introduce you to the Clojure language.

### [Clojure Editors](/articles/tutorials/editors/)

This tutorial covers the most popular editors used
for Clojure development and points you to the relevant
documentation for each editor.

### [Basic Web Development](/articles/tutorials/basic_web_development/)

A brief tutorial/walkthrough of building a small web app using Ring,
Compojure, Hiccup, and H2.

### [Building Projects: `tools.build` and the Clojure CLI](/articles/cookbooks/cli_build_projects/)

This cookbook shows you the power of the `tools.build`
library, which is used with a `build.clj` file and the
Clojure CLI to build, test, deploy, and more.

### [Data Structures](/articles/cookbooks/data_structures/)

This cookbook covers:

 * Vectors
 * Maps
 * Lists
 * Sets
 * Generic operations on sequences

### [Strings](/articles/cookbooks/strings/)

This cookbook covers:

 * How to work with strings
 * How to work with characters
 * How to work with regular expressions
 * How to work with context-free grammars
 * How to format text

### [Mathematics](/articles/cookbooks/math/)

Includes coverage of facilities for doing math with Clojure.


### [Date and Time](/articles/cookbooks/date_and_time/)

This guide covers:

 * Working with `clojure.java-time`
 * Working with `java-time` via interop
 * Working with `cljc.java-time`

### [Files and Directories](/articles/cookbooks/files_and_directories/)

This cookbook covers:

 * Reading and writing text and binary files
 * Listing directory contents
 * Creating files and directories
 * Moving files and directories
 * Removing files and directories
 * Accessing file metadata
 * Other operations on files and directories


### [Middleware](/articles/cookbooks/middleware/)

This guide covers:

 * What middleware is and how it works
 * Creating middleware for a client function
 * Combining middleware to create a new client

### [Parsing XML in Clojure](/articles/cookbooks/parsing_xml_with_zippers/)

This guide covers:

 * How to parse XML in Clojure with zippers (`clojure.data.zip`)

### [Growing a DSL with Clojure](/articles/cookbooks/growing_a_dsl_with_clojure/)

How to create a simple DSL with Clojure.

Includes introductions to:

 * Multimethods
 * Hierarchies
 * Metaprogramming and the "Code as data" philosophy





## License

All the content is distributed under the
[CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) license
and are copyright their respective primary author(s).


## Tell Us What You Think!

Please take a moment to tell us what you think about this guide on the [Clojurians Slack `#clojure-doc` channel](https://clojurians.slack.com/archives/C02M6N5C137) or the [Clojure mailing list](https://groups.google.com/group/clojure).

Let us know what was unclear or what has not been covered. Maybe you do not like the guide style or grammar or discover spelling mistakes.
Reader feedback is key to making the documentation better.
