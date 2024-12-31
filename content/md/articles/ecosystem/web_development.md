{:title "Ecosystem: Web Development"
 :layout :page :page-index 3400}

This guide covers:

  * popular tools and libraries for web development

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).



## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.12.



## Overview

The web development space for Clojure is large and still evolving.
Your options start with basic server-side web applications, generating
HTML from either Clojure data structures or from more traditional
template files, and can go all the way to full-stack web "frameworks"
where you build a "single page application" (SPA) in ClojureScript for
the frontend and a Clojure-powered API for the backend.

This guide doesn't clam to be comprehensive, but it does try to
cover the most popular and well-maintained options, across that spectrum.

## Static Sites

Before we get into web _applications_, it's worth mentioning that there
are several Clojure-based solutions for generating static sites.

* [cryogen](http://cryogenweb.org/) - simple static site generator written in Clojure
* [stasis](https://github.com/magnars/stasis) - some Clojure functions for creating static websites

The README for the latter lists several other options.

You can also add ClojureScript interactivity to a static site using
[scittle](https://babashka.org/scittle/) which exposes the
[Small Clojure Interpreter](https://github.com/babashka/sci) to the browser.

> Note: this can even support Reagent and re-frame, which are ClojureScript wrappers around React, but without the complexity of a full-blown SPA. See [UI-Focused options](#ui-focused-options) in the **Frontend Development** section below.

## Fundamentals

If you're building any backend component for a web application, you're
going to need a web server and some sort of routing mechanism (mapping
HTTP requests and URLs to Clojure functions that handle them).

### Ring and Compojure

Perhaps the simplest and most minimal setup is to use only Ring and
Compojure. To get started, see the [basic web development
tutorial](/articles/tutorials/basic_web_development/).

In addition to the long-established [Ring server library](https://github.com/ring-clojure/ring),
which has an adapter for Jetty 11.x as the underlying web server, with WebSocket support built-in,
here are some alternatives:

* [http-kit](https://github.com/http-kit/http-kit) - simple, high-performance, Ring-compatible web server
* [aleph](https://github.com/clj-commons/aleph) - asynchronous communication server, including a Ring-compatible web server
* [sunng87 ring adapter](https://github.com/sunng87/ring-jetty9-adapter) - Ring adapter for Jetty 12 and 11

For routing, while [Compojure](https://github.com/weavejester/compojure) is the most
well-established and maybe most popular option, it is based on macros and
some people prefer something more data-oriented, such as
[reitit](https://github.com/metosin/reitit).

### HTML Templating

If you are generating HTML pages on the server, you will want a library
to simplify that task.

The two most popular options are probably:

* [hiccup](https://github.com/weavejester/hiccup) - generate HTML from Clojure data structures
* [selmer](https://github.com/yogthos/Selmer) - Django-inspired templating library

If you are going to collaborate with frontend developers who are not
familiar with Clojure, Selmer can be an excellent choice since the templates
are written as HTML with a range of embedded variables, loops, and conditionals
that will be familiar to anyone who has used a templating library in another
language.

If you are working entirely with Clojure and ClojureScript developers, you
may prefer to work mainly with Clojure data structures, and use Hiccup to
generate HTML from those.

Hiccup-style data structures are also used in several ClojureScript libraries.

## Frameworks and Integrated Libraries

Although Clojure eschews the idea of a "framework" in favor of composable
libraries, there are a few "framework"-like options that are popular as
"batteries-included" choices for web development.

### Luminus

_See **Kit** below for a more modern alternative!_

Probably the most well-established choice in this category is
[Luminus](http://www.luminusweb.net/), which is driven by [a Leiningen
template](https://github.com/yogthos/luminus-template) for creating
batteries-included web applications. In its most basic form, it uses Ring,
[reitit](https://github.com/metosin/reitit),
[Mount](https://github.com/tolitius/mount), and the JBoss Undertow web server.

However, it offers options to create web application projects that use
a wide variety of different libraries:

* aleph, http-kit, or jetty for web servers
* h2, mysql, postgres, or sqlite for traditional databases
* datomic or xtdb for temporal databases with a datalog query language
* mongodb for a document database
* REST or GraphQL for APIs, with optional Swagger-UI support
* reagent, re-frame, shadow-cljs, etc for frontend development

and many other options.

### Kit

From the same author as Luminus, [Kit](https://kit-clj.github.io/) is a
lightweight, modular framework for scalable web development in Clojure.
It builds on the lessons learned from Luminus and should be considered
a modern alternative to it.

Unlike Luminus, it uses the Clojure CLI and [clj-new](https://github.com/seancorfield/clj-new)
to create and run new projects. In its most basic form, it uses Ring,
[reitit](https://github.com/metosin/reitit),
[integrant](https://github.com/weavejester/integrant),
[aero](https://github.com/juxt/aero) (for handling configuration),
and the JBoss Undertow web server.

Like Luminus, you can add a wide variety of different libraries to your
web application projects -- however, Kit is more modular than Luminus
and lets you add new libraries to your project more easily, after you
have created it, instead of having to choose all the libraries up front.

You can use [HTMX](https://htmx.org/) with Kit via the [ctmx module](https://whamtet.github.io/ctmx/).

### Biff

[Biff](https://biffweb.com/) is a batteries-included web framework for Clojure
that is fairly opinionated about the libraries it uses. It is based on Ring
(but using the [sunng87](https://github.com/sunng87/ring-jetty9-adapter) adapter for the Jetty 11 web server),
[reitit](https://github.com/metosin/reitit),
[XTDB](https://www.xtdb.com/) for the database,
with [malli](https://github.com/metosin/malli) to provide schema definition and validation,
and produces HTML that uses
[HTMX](https://htmx.org/) to provide an interactive experience without
the complexity of a full-blown SPA.

### JUXT Site

[Site](https://github.com/juxt-site/site) is a platform for building stateful API services.
It is based on [XTDB](https://www.xtdb.com/) for the database, supports
[OpenAPI](https://swagger.io/specification/) and [OpenID](https://openid.net/),
and provides flexible access control.

The linked version of Site is 2.0 and has a note that it is
"not yet ready for evaluation outside of JUXT" but it is an evolution
of [Site 1.0](https://github.com/juxt/site) which is also based on XTDB and
supports OpenAPI.

### Pedestal

Another option for backend services is [Pedestal](http://pedestal.io/),
a sturdy and reliable base for services and APIs. It provides its own
routing and interceptor-based approach to web development, but is based
on Ring under the hood and uses Jetty 9 (currently an older 9.4.18,
which is not the latest 9.4.x release). This was originally part of a
full-stack project created by Relevance back in 2013 but can be used with various
frontend options now.

### Other Options

* [electric](https://github.com/hyperfiddle/electric) - a reactive Clojure dialect for web development that uses a compiler to infer the frontend/backend boundary
* [ripley](https://github.com/tatut/ripley) - server rendered UIs over WebSockets.

## Frontend Development

If you plan to use ClojureScript for the frontend of your web application,
you again have a range of choices from "plain" ClojureScript up to
various wrappers for React, and some other options.

> Note: as a contributor to clojure-doc.org, I don't have enough experience to make recommendations about ClojureScript so I'm mostly just listing some options here -- Sean Corfield, 2023-10-09.

You will want to start with the [ClojureScript Quick Start](https://clojurescript.org/guides/quick-start)
and then probably look at [shadow-cljs](https://github.com/thheller/shadow-cljs) as a build tool.
An alternative build tool for ClojureScript is [figwheel-main](https://figwheel.org/),
but this seems to be less popular than `shadow-cljs` these days.

The creator of `shadow-cljs` has written a number of good
[articles about various approaches to using ClojureScript](https://code.thheller.com/)
for frontend development, that show how to use "plain" ClojureScript without
reaching for wrappers around JavaScript frameworks.
Several frontend / full-stack options for ClojureScript wrap React.js in various ways
but, as those articles show, building on top of React is not the only option!

### UI-Focused Options

* [reagent](https://reagent-project.github.io/) - a minimalistic ClojureScript interface to React
* [re-frame](http://day8.github.io/re-frame/) - a functional reactive framework built on top of Reagent
* [helix](https://github.com/lilactown/helix) - a simple, easy to use library for React development in ClojureScript
* [UIx](https://pitch-io.github.io/uix/docs/) - an idiomatic interface into modern React

While those are all based on or wrappers around React, there are other options:

* [hoplon](https://hoplon.io/) - a ClojureScript library that unify some of the web platform's idiosyncrasies and present a fun way to design and build single-page web applications; hoplon builds on [javelin](https://github.com/hoplon/javelin) which provides spreadsheet-like dataflow programming in ClojureScript

### Full-Stack Options

* [fulcro](https://fulcro.fulcrologic.com/) - a library for development of single-page full-stack web applications in clj/cljs
* [sitefox](https://github.com/chr15m/sitefox) - full-stack ClojureScript development on node.js

### Producing JavaScript

Although ClojureScript (and thus all of the above **Frontend Development** options)
produce JavaScript under the hood, there are times when you have an existing
ecosystem based on HTML, CSS, and JavaScript and you want to add some ClojureScript
to that. In that case, you can either use `scittle`, mentioned above or
one of these ClojureScript to JavaScript compilers:

* [cherry](https://github.com/squint-cljs/cherry) - experimental ClojureScript to ES6 module compiler
* [squint](https://github.com/squint-cljs/squint) - experimental ClojureScript syntax to JavaScript compiler

The former maintains ClojureScript _semantics_ and syntax while the latter
maintains only the syntax, compiling to JavaScript semantics. These projects
can both be useful for adding ClojureScript components and modules
to an existing JavaScript project.

## See Also

  * [The Clojure Toolbox](https://www.clojure-toolbox.com/) has categorized lists of libraries including many that are useful for web development.

  * [The Clojure Web Stack and the CRUD Stack](http://brehaut.net/blog/2012/clojure_web_and_the_crud_stack) -- why web frameworks are not common in Clojure.

  * [A Brief Overview of the Clojure Web Stack](http://brehaut.net/blog/2011/ring_introduction) -- although some libraries mentioned are outdated, this (old) article still provides a good overview of Ring and the general architecture of web applications and APIs in Clojure.



## Contributors

* John Gabriele, Clinton Dreisbach (original authors)
* Sean Corfield (2023 rewrite)
