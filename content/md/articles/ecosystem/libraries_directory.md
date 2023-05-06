{:title "A Directory of Clojure Libraries"
 :layout :page :sidebar-omit? true :page-index 103000}

This is a categorized and annotated directory of available Clojure
libraries and tools. This directory is **not comprehensive and is necessarily highly opinionated**.

This directory is manually curated by the Clojure community. Please endeavor to keep it up-to-date,
consisting of **high quality** libraries with adequate documentation. There are many more libraries in the Clojure
ecosystem, but some lack documentation and/or are useful primarily to experienced developers and such projects
are not included in this document.

For more comprehensive overview of the Clojure library ecosystem, please see [ClojureSphere](http://clojuresphere.com/).

Legend:

* If a library is listed here with a description and also on clojure-toolbox, I've left it in place here but marked it with three stars (in case Toolbox wants to add summary lines).
* If a library is listed here and is not on clojure-toolbox but seems useful and well-maintained, I've marked it with three pluses (and will propose to Toolbox shortly).

> Note: If a library was listed here without a description and also on clojure-toolbox, I've removed it from here. If a library was listed here but seems abandoned, I've removed it from here.

## Applications & Environment

  * *** [tools.cli](https://github.com/clojure/tools.cli): a command line argument parser for Clojure

  * *** [environ](https://clojars.org/environ): Manage environment settings from a number of different sources

## Testing

  * +++ [cloverage](https://github.com/cloverage/cloverage): a test-coverage tool

  * *** [expectations](https://clojure-expectations.github.io/): a minimalist's testing framework (diff URL)

  * +++ [test.generative](https://github.com/clojure/test.generative): generative testing, a la QuickCheck


## Serialization

### JSON

  * *** [cheshire](https://github.com/dakrone/cheshire/): very efficient Clojure JSON and SMILE (binary JSON) encoding/decoding.

  * *** [data.json](https://github.com/clojure/data.json): JSON parser/generator to/from Clojure data structures.

### Clojure Reader

  * *** [Nippy](https://github.com/ptaoussanis/nippy): a more efficient implementation of the Clojure reader

### XML

  * *** [data.xml](https://github.com/clojure/data.xml): a library for reading and writing XML

### Binary Formats

  * *** [gloss](https://github.com/clj-commons/gloss): turns complicated byte formats into Clojure data structures -- moved to clj-commons


## File formats

  * *** [clj-pdf](https://clojars.org/clj-pdf): a library for easily generating PDFs from Clojure

  * *** [Pantomime](https://github.com/michaelklishin/pantomime): a tiny Clojure library that deals with Internet media types (MIME types) and content type detection

  * *** [data.csv](https://github.com/clojure/data.csv): a CSV parser


## Templating

  * *** [Stencil](https://clojars.org/stencil): [Mustache](https://mustache.github.io/) for Clojure (logic-less templates). Fast.

  * *** [Clostache](https://clojars.org/de.ubercode.clostache/clostache): another nice [Mustache](https://mustache.github.io/) implementation



## HTTP

### Client/Server

  * *** [HTTP Kit](http://http-kit.org/): High-performance event-driven HTTP client/server for Clojure.

### Client

  * *** [clj-http](https://github.com/dakrone/clj-http): An idiomatic Clojure http client wrapping the apache client.

## Logging

  * *** [Timbre](https://clojars.org/com.taoensso/timbre):
    Simple, flexible, all-Clojure logging. No XML!

  * *** [tools.logging](https://github.com/clojure/tools.logging/): standard general-purpose logging.



## Web Development

### Web Services

  * *** [Ring](https://github.com/ring-clojure): foundational
    web application library

  * *** [Compojure](https://github.com/weavejester/compojure):
    concise routing library for Ring

  * *** [Pedestal](http://pedestal.io/): an open source tool set for building web applications in Clojure

  * *** [Luminus](http://www.luminusweb.net/): lein template for creating batteries-included web applications using Ring, Compojure, lib-noir, and other libraries.

  * *** [Liberator](https://github.com/clojure-liberator/liberator): a Clojure library for building RESTful applications

  * *** [friend](https://github.com/cemerick/friend): Authentication and authorization library for Web apps


### HTML Generation

  * *** [hiccup](https://clojars.org/hiccup): Generates HTML from Clojure data structures.

  * *** [Stencil](https://github.com/davidsantiago/stencil): Implements the Mustache templating language.

  * *** [markdown-clj](https://clojars.org/markdown-clj): Clojure based Markdown parsers for both Clojure and ClojureScript.


### HTML Parsers

  * *** [Crouton](https://clojars.org/crouton): A Clojure wrapper for the JSoup HTML and XML parser that handles real world inputs


### Data Validation

  * *** [Validateur](http://clojurevalidations.info): functional validations library inspired by Ruby's ActiveModel

  * *** [Metis](https://github.com/mylesmegyesi/metis): another validations library inspired by Ruby's ActiveModel

### URIs, URLs

  * *** [route-one](https://github.com/clojurewerkz/route-one): a tiny Clojure library that generates HTTP resource routes (as in Ruby on Rails, Jersey, and so on)


### Internationalization (i18n), Localization (l10n)

  * +++ [Tower](https://github.com/ptaoussanis/tower): a simple, idiomatic internationalization and localization story for Clojure


### RSS

  * *** [clj-rss](https://clojars.org/clj-rss): RSS feed generation library



## Data Stores

### Relational Databases, JDBC

  * *** [next.jdbc](https://cljdoc.org/d/com.github.seancorfield/next.jdbc/): Modern wrapper for JDBC. Works with all JDBC databases (MySQL, PostgreSQL, Oracle, SQL Server, etc).


### CouchDB

  * *** [Clutch](https://github.com/clojure-clutch/clutch): [Apache CouchDB](http://couchdb.apache.org/) client.

### MongoDB

  * *** [Monger](http://clojuremongodb.info): Monger is an idiomatic Clojure MongoDB driver for a more civilized age with solid documentation

  * *** [congomongo](https://github.com/congomongo/congomongo): Basic wrapper for the MongoDB Java driver

### Redis

  * *** [Carmine](https://github.com/ptaoussanis/carmine): a great Clojure client for Redis

### Graph Databases (Neo4J, Titan, etc)

  * *** [Neocons](http://clojureneo4j.info): Neocons is a feature rich idiomatic [Clojure client for the Neo4J REST API](http://clojureneo4j.info)  with solid documentation
eprints

### ElasticSearch

  * *** [Elastisch](http://clojureelasticsearch.info): Elastisch is a minimalistic Clojure client for [ElasticSearch](http://elasticsearch.org) with solid documentation.

### Memcached, Couchbase, Kestrel

  * *** [Spyglass](https://github.com/clojurewerkz/spyglass): Spyglass is a very fast Clojure client for Memcached and Couchbase with solid documentation

### Apache Cassandra

  * *** [Cassaforte](https://github.com/clojurewerkz/cassaforte): A young Clojure client for Apache Cassandra

  * *** [Alia](https://github.com/mpenet/alia): Cassandra CQL3 client for Clojure, [datastax/java-driver](https://github.com/datastax/java-driver) wrapper


## Networking

  * ***[Lamina](https://github.com/ztellman/lamina): event-driven workflows in Clojure

  * ***[Aleph](https://github.com/clj-commons/aleph): asynchronous communication in Clojure


## Application Servers

  * ***[Immutant](http://immutant.org/): a feature rich and integrated application platform for Clojure from Red Hat


## Messaging

### RabbitMQ

  * ***[Langohr](http://clojurerabbitmq.info): a feature complete RabbitMQ client that embraces AMQP 0.9.1 model and learns from others

### Beanstalk

  * ***[beanstalk](https://github.com/drsnyder/beanstalk): a Beanstalkd client

### Amazon SQS

  * ***[Bandalore](https://github.com/cemerick/bandalore): a Clojure client library for Amazon's Simple Queue Service


## Data Processing, Computation

  * ***[Cascalog](http://www.cascalog.org/): data processing on Hadoop without the hassle




## Automation, Provisioning, DevOps Tools

 * *** [Amazonica](https://github.com/mcohen01/amazonica): comprehensive Clojure client for the entire AWS API

 * +++ [clj-ssh](https://github.com/clj-commons/clj-ssh): an SSH client


## Monitoring, metrics

 * +++ [metrics-clojure](https://github.com/metrics-clojure/metrics-clojure):
   Clojure library on top of Yammer's Metrics

 * +++ [clj-statsd](https://github.com/pyr/clj-statsd): simple client library to interface with statsd

 * +++ [riemann](http://riemann.io): A network event stream processing system, in Clojure.


## I/O

### Files, NIO, NIO2

File I/O is covered by the JDK and commonly used via `clojure.java.io` functions.

  * *** [fs](https://github.com/clj-commons/fs): utilities for working with the file system


### Standard Streams, Subprocesses


  * *** [conch](https://clojars.org/conch): for shelling out to external programs.
    An alternative to clojure.java.shell.



### REPL and Terminal

  * +++ [REPLy](https://github.com/trptcolin/reply): a Swiss army knife of interactive editing, and better REPL for Clojure




## Mathematics

  * *** [math.numeric-tower](https://github.com/clojure/math.numeric-tower): various utility math functions

  * +++ [math.combinatorics](https://github.com/clojure/math.combinatorics): common combinatorial functions

  * *** [core.matrix](https://github.com/mikera/matrix-api): matrix operations


## Email

  * *** [Postal](https://github.com/drewr/postal): generate and send email with Clojure

  * *** [Mailer](https://github.com/clojurewerkz/mailer): generate and send email using Postal and Moustache templates



## Data Structures and Algorithms

### Caching

  * *** [core.cache](https://github.com/clojure/core.cache): the Clojure API for various cache implementations

### Monads

  * *** [algo.monads](https://github.com/clojure/algo.monads): macros for defining monads, and definition of the most common monads

  * *** [protocol-monads](https://github.com/jduey/protocol-monads): A protocol based monad implementation for clojure


## Scheduling

  * *** [Quartzite](http://clojurequartz.info): a powerful scheduling library


## Graphics and GUI

  * *** [Quil](https://clojars.org/quil): For making drawings, animations,
    and artwork ([some examples](https://github.com/quil/quil-examples/blob/master/src/quil_sketches/gen_art/README.md)). Wraps
    the ["Processing"](https://www.processing.org/) graphics environment.

  * *** [seesaw](https://github.com/clj-commons/seesaw/): A Swing wrapper/DSL.

  * *** [clisk](https://github.com/mikera/clisk): Clisk is a DSL-based library for procedural image generation that can be used from Clojure and Java.

## Security and Sandboxing

  * *** [Clojail](https://github.com/flatland/clojail): a [code execution] sandboxing library


## Documentation

### Literate Programming

  * *** [Marginalia](https://github.com/gdeer81/marginalia): literate programming implementation for Clojure. See [the Marginalia
    site](https://gdeer81.github.io/marginalia/) for an example.

### Generating API Reference

  * *** [Codox](https://github.com/weavejester/codox): from the author of Compojure. See [compojure
    api docs](https://weavejester.github.io/compojure/) for an
    example.

  * *** [Autodoc](https://tomfaulhaber.github.io/autodoc/): used
    to generate the official [Clojure API reference](https://clojure.github.io/).


## Tooling

  * *** [Leiningen](https://leiningen.org): the Clojure build tool

  * *** [nREPL](https://nrepl.org): nREPL interface

  * +++ [java.jmx](https://github.com/clojure/java.jmx): nice JMX interface

  * *** [tools.trace](https://github.com/clojure/tools.trace): a tracing library

  * *** [criterium](https://github.com/hugoduncan/criterium): a benchmarking library that tries to address common benchmarking pitfalls
