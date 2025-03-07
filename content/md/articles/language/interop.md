{:title "Language: Java Interop"
 :page-index 2500
 :layout :page}

This guide covers:

 * How to instantiate Java classes
 * How to invoke Java methods
 * How to extend Java classes with proxy
 * How to implement Java interfaces with reify
 * How to generate Java classes with gen-class
 * Other topics related to interop

This guide does not cover how to include Java files in Clojure projects.
For that, head to [including Java code in a Clojure project](/articles/cookbooks/cli_build_projects/#including-java-code-in-a-clojure-project)

This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>
(including images & stylesheets). The source is available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).

## What Version of Clojure Does This Guide Cover?

This guide covers Clojure 1.12.


## Overview

Clojure was designed to be a hosted language that directly interoperates with its host platform (JVM, JS, CLR and so on).
Clojure code is compiled to JVM bytecode. For method calls on Java objects, the Clojure compiler
will try to emit the same bytecode `javac` would produce.

It is possible to implement interfaces, and to extend and generate Java classes in Clojure.

Clojure also provides convenient functions and macros that make consuming Java libraries
easier and often more concise than it would be in Java code.

See also the [official Java interop reference](https://clojure.org/reference/java_interop) on clojure.org.

## Imports

Java classes can be referenced either using their fully-qualified names (FQNs) such as
`java.util.Date` or be *imported* in the current Clojure namespace using `clojure.core/import` (or the `:import` clause of `ns`) and
referenced by short names:

``` clojure
java.util.Date  ; ⇒ java.util.Date
```

``` clojure
(import java.util.Date)

Date  ; ⇒ java.util.Date
```

The `ns` macro supports imports, too:
``` clojure
(ns myservice.main
  (:import java.util.Date))
```

More about the `ns` macro can be found in the article on [Clojure namespaces](/articles/language/namespaces/).

Dynamic (at runtime) imports are usually only used in the REPL and cases when there are multiple implementations of a particular
protocol/service/feature and it is not possible to tell which one should be used until run time.

### Automatic Imports For java.lang.*

Most classes from the `java.lang` package are automatically imported. For example, you can use `String` or `Math`
without explicitly importing them:

``` clojure
(defn http-uri?
  [^String uri]
  (.startsWith (.toLowerCase uri) "http"))

(Math/round 0.7886)
```

You can avoid most direct uses of `java.lang.String` by using the
`clojure.string` namespace.
You can avoid most uses of `java.lang.Math` by using the `clojure.math`
namespace (added in Clojure 1.11).

Clojure is compatible with Java 8 and later, so classes and interfaces
added to Java 9 and later are not automatically imported.


### Inner (Nested) Classes

In Java, classes can be nested inside other classes. They are called *inner classes* and by convention,
separated from their outer class by a dollar sign (`$`):

``` clojure
(import java.util.Map$Entry)

Map$Entry  ; ⇒ java.util.Map$Entry

;; this example assumes RabbitMQ Java client is on classpath
(import com.rabbitmq.client.AMQP$BasicProperties)

AMQP$BasicProperties  ; ⇒ com.rabbitmq.client.AMQP$BasicProperties
```

Note that if you need to use both a class and one or more of its inner classes, they all need to be imported separately.
As far as JVM is concerned, they are all separate classes, there is no "imports hierarchy".


## How to Instantiate Java Classes

Java classes are instantiated using the `new` special form:

``` clojure
(new java.util.Date)  ; ⇒ #inst "2012-10-09T21:23:57.278-00:00"
```

However, the Clojure reader provides a bit of syntactic sugar and you are much more likely
to see this:

``` clojure
(java.util.Date.)     ; ⇒ #inst "2012-10-09T21:24:43.878-00:00"
```

It is possible to use fully qualified names (e.g. `java.util.Date`) or short names with imports:

``` clojure
(import java.util.Date)

(Date.)  ; ⇒ #inst "2012-10-09T21:24:27.229-00:00"
```

As of Clojure 1.12, you can use the following syntax:

``` clojure
(java.util.Date/new)

;; or, if you have imported the class:

(Date/new)
```

An example with constructor arguments:

``` clojure
(java.net.URI. "https://clojure.org")
;;⇒ #object[java.net.URI 0x8bd076a "https://clojure.org"]

;; or, in Clojure 1.12:

(java.net.URI/new "https://clojure.org")
```

In Clojure 1.12, `SomeClass/new` is a "function value" and can be treated like
a regular Clojure function:

``` clojure
(map (fn [f] (f "https://clojure.org")) [java.net.URI/new count clojure.string/upper-case])
;;=> (#object[java.net.URI 0x7ec25216 "https://clojure.org"] 19 "HTTPS://CLOJURE.ORG")
```

## How to Invoke Java Methods

This guide does not cover type hints. See the official
[Java interop type hints](https://clojure.org/reference/java_interop#typehints)
and [param-tags reference](https://clojure.org/reference/java_interop#paramtags)
documentation for more details (since this area changed significantly in Clojure 1.12).

### Instance Methods

Instance methods are invoked using the `.` special form:

``` clojure
(let [d (java.util.Date.)]
  (. d getTime))  ; ⇒ 1349819873183
```

Just like with object instantiation, it is much more common to see an alternative version:

``` clojure
(let [d (java.util.Date.)]
  (.getTime d))  ; ⇒ 1349819873183
```

In Clojure 1.12, `SomeClass/.methodName` is a "function value" and can be treated like
a regular Clojure function:

``` clojure
;; assuming (import java.util.Date):
(map Date/.getTime [(Date.) (Date/new) #inst "2024-12-30"])
;;⇒ (1735603851861 1735603851861 1735516800000)
```

### Static Methods

Static methods can be invoked with the same `.` special form:

``` clojure
(. Math floor 5.677)  ; ⇒ 5.0
```

or (typically) the sugared version, `ClassName/methodName`:

``` clojure
(Math/floor 5.677)  ; ⇒ 5.0

(Boolean/valueOf "false")  ; ⇒ false
(Boolean/valueOf "true")   ; ⇒ true
```

In Clojure 1.12, `SomeClass/staticMethodName` is a "function value" and can be treated like
a regular Clojure function:

``` clojure
(map Boolean/valueOf ["true" "false" "what?"])
;;⇒ (true false false)
```

> Note: Clojure 1.11 introduced `parse-boolean` but it is somewhat stricter than `Boolean/valueOf` and will return `nil` for strings it does not recognize, including `"TRUE"` and `"FALSE"` (which `Boolean/valueOf` does recognize).

### Chained Calls With The Double Dot Form

It is possible to chain method calls using the `..` special form:

``` clojure
(.. (java.util.Date.) getTime toString)  ; ⇒ "1693344712616"
```


### Multiple Calls On the Same Object

If you need to call several methods on the same (mutable) object, you
can use the `doto` macro:

``` clojure
(doto (java.util.Stack.)
  (.push 42)
  (.push 13)
  (.push 7))  ; ⇒ [42 13 7]

;; assume (import java.awt.Point)

(let [pt (Point. 0 0)]
  (doto pt
    (.move 10 0)))
;;⇒ #object[java.awt.Point 0x1084ac45 "java.awt.Point[x=10,y=0]"]

(let [pt (Point. 0 0)]
  (doto pt
    (.move 10 0)
    (.translate 0 10)))
;;⇒ #object[java.awt.Point 0x7bc6935c "java.awt.Point[x=10,y=10]"]
```

Each method is called on the original object -- the first argument
to `doto` -- and it returns that same object as the result.


## How to Access Java Fields

Public mutable fields are not common in Java libraries but sometimes you need to access them.
It's done with the same dot special form:

``` clojure
(import java.awt.Point)

(let [pt (Point. 0 10)]
  (. pt x))  ; ⇒ 0

(let [pt (Point. 0 10)]
  (. pt y))  ; ⇒ 10
```

and just like with instance methods, it is more common to see the following version:

``` clojure
(import java.awt.Point)

(let [pt (Point. 0 10)]
  (.x pt))  ; ⇒ 0

(let [pt (Point. 0 10)]
  (.y pt))  ; ⇒ 10
```

For compatibility with ClojureScript, the following syntax is also supported for field access:

``` clojure
(import java.awt.Point)

(let [pt (Point. 0 10)]
  (.-x pt))  ; ⇒ 0

(let [pt (Point. 0 10)]
  (.-y pt))  ; ⇒ 10
```

This is to distinguish between field access and method access.

## How to Set Java Fields

To set a public mutable field, use `clojure.core/set!` that takes a field in the dot notation
demonstrated earlier and a new value:

``` clojure
(import java.awt.Point)

(let [pt (Point. 0 10)]
  (set! (.-y pt) 100)
  (.-y pt))  ; ⇒ 100
```

Fortunately, mutable public fields are rare to meet in the JVM ecosystem so you won't need
to do this often.


## How To Work With Enums

[Enums (enumeration) type](https://docs.oracle.com/javase/tutorial/java/javaOO/enum.html) values are accessed
the same way as static fields, except on enum classes:

``` clojure
java.util.concurrent.TimeUnit/MILLISECONDS
;;⇒ #object[java.util.concurrent.TimeUnit 0x4cc7d00d "MILLISECONDS"]
```


## Determining Classes of Java Objects

To get class of a particular value, pass it to `clojure.core/class`:

``` clojure
(class 1)       ; ⇒ java.lang.Long
(class 1.0)     ; ⇒ java.lang.Double
(class "docs")  ; ⇒ java.lang.String
(class (java.net.URI. "https://github.com"))  ; ⇒ java.net.URI
```

As this example demonstrates, Clojure strings are JVM strings, integer literals are compiled
as (boxed) longs and floating point literals are compiled as (boxed) doubles.

You can also use `clojure.core/type` to return either the class of the
Java object, or the `:type` metadata if it exists:

``` clojure
(def foo (with-meta [1 2 3] {:type :bar}))
(type foo)
;; ⇒ :bar
(type [1 2 3])
;; ⇒ clojure.lang.PersistentVector
```

## How To Get a Java Class Reference By Name

To obtain a class reference by its string name (fully qualified), use `Class/forName` via Java interop:

``` clojure
(Class/forName "java.util.Date")  ; ⇒ java.util.Date
```

### Array Types, Primitives

JVM has what is called **primitive types** (numerics, chars, booleans) that are not "real" objects.
In addition, array types have pretty obscure internal names.

An array of `String`, has an internal name of `"[Ljava.lang.String;"`.
You can construct an array of `String` using `into-array`:

``` clojure
(class (into-array String ["foo" "bar" "baz"]))
;;=> java.lang.String/1 ; Clojure 1.12
;; but in earlier versions of Clojure:
;;⇒ [Ljava.lang.String;
```

In Clojure 1.12, you can `SomeClass/N` to get a class reference to an N-dimensional array of the class,
but prior to 1.12, you had to use `Class/forName` and the internal name of the array type:

<table class="table-striped table-bordered table">
  <thead>
    <tr>
      <th>Internal JVM class name</th>
      <th>Array of ? (type)</th>
      <th>Clojure 1.12 type</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td><pre>"[S"</pre></td>
      <td>short</td>
      <td>short/1</td>
    </tr>
    <tr>
      <td><pre>"[I"</pre></td>
      <td>integer</td>
      <td>integer/1</td>
    </tr>
    <tr>
      <td><pre>"[J"</pre></td>
      <td>long</td>
      <td>long/1</td>
    </tr>
    <tr>
      <td><pre>"[F"</pre></td>
      <td>float</td>
      <td>float/1</td>
    </tr>
    <tr>
      <td><pre>"[D"</pre></td>
      <td>double</td>
      <td>double/1</td>
    </tr>
    <tr>
      <td><pre>"[B"</pre></td>
      <td>byte</td>
      <td>byte/1</td>
    </tr>
    <tr>
      <td><pre>"[C"</pre></td>
      <td>char</td>
      <td>char/1</td>
    </tr>
    <tr>
      <td><pre>"[Z"</pre></td>
      <td>boolean</td>
      <td>boolean/1</td>
    </tr>
  </tbody>
</table>

For convenience, Clojure has `*-array` functions for each of the above
types that help you create an array of primitive values:

``` clojure
user=> (char-array [\h \e \l \l \o])
#object["[C" 0x7df60067 "[C@7df60067"]
user=> (apply str *1)
"hello"
```

If this does not make much sense, don't worry. Just remember to come
back to this guide when you need to extend a protocol for an array of
primitives.




## Implementing Java Interfaces With reify

It is possible to implement Java interfaces in Clojure. It is
typically needed to interact with Java libraries that take arguments
implementing a particular interface.

Interfaces are implemented using the `reify` special form.

Given the following Java interface:

``` java
/* from java.io package */
public
interface FilenameFilter {
    /**
     * Tests if a specified file should be included in a file list.
     *
     * @param   dir    the directory in which the file was found.
     * @param   name   the name of the file.
     * @return  <code>true</code> if and only if the name should be
     * included in the file list; <code>false</code> otherwise.
     */
    boolean accept(File dir, String name);
}
```

here is how to implement it in Clojure:

``` clojure
;; a FileFilter implementation that accepts everything
(reify java.io.FilenameFilter
  (accept [this dir name]
    true))
```

`reify` takes an interface (fully-qualified name or short name) and one or more
method implementations that mimic function definitions without the `defn` and with
*this* (as in Java, JavaScript or *self* in Ruby, Python) reference being the first argument:

``` clojure
(accept [this dir name]
  true)
```

With `reify`, generally there is no need to add type hints on arguments: Clojure
compiler typically will detect the best matching method (by name and number of arguments).

`reify` returns a *Java class instance*. Clojure compiler will generate a class that implements
the interface and instantiate it. To demonstrate that reified objects indeed implement
the interface:

``` clojure
(let [ff (reify java.io.FilenameFilter
           (accept [this dir name]
             true))]
  (instance? java.io.FilenameFilter ff))  ; ⇒ true
```

`reify` can be used to implement multiple interfaces at once:

``` clojure
(let [ff (reify java.io.FilenameFilter
           (accept [this dir name]
             true)

           java.io.FileFilter
           (accept [this dir]
             true))]
  (instance? java.io.FileFilter ff))  ; ⇒ true
```

In Clojure 1.12, a Java interface that is declared `@FunctionalInterface` can
be inferred from from the context and can be satisfied with a regular Clojure
function. `java.io.FilenameFilter` is such an interface, so you can pass a
Clojure function directly to a Java method that expects a `FilenameFilter`:

``` clojure
(seq (.list (java.io.File. ".") #(str/starts-with? %2 ".")))
;;⇒ (".cpcache" ".portal" ".clj-kondo" ".lsp" ".calva")
```

In earlier versions of Clojure, you would have to use `reify` for that:

``` clojure
(seq (.list (java.io.File. ".")
            (reify java.io.FilenameFilter
              (accept [this dir name]
                (str/starts-with? name ".")))))
;;⇒ (".cpcache" ".portal" ".clj-kondo" ".lsp" ".calva")
```

### reify, Parameter Destructuring and Varargs

`reify` does not support destructuring or variadic arguments in method signatures. You will not always get an error from the compiler if you try to use them, but the resulting code will not work the way you expect.
For example:

``` clojure
(reify java.io.FilenameFilter
  (accept [a & more]
    (comment ...)))
```

This will compile without error but when called, the first argument to
`accept` -- the directory object -- will be bound to `&` and the second
argument to `accept` -- the filename string -- will be bound to `more`.

### Example 1

The following example demonstrates how instances created with `reify` are passed around
as regular Java objects:

``` clojure
(require '[clojure.string :as str])
(import java.io.File)

;; a file filter implementation that keeps only .edn files
(let [ff (reify java.io.FilenameFilter
           (accept [this dir name]
             (str/ends-with? name ".edn")))
    dir  (File. "/home/sean/oss/clojure-doc.github.io/")]
  (into [] (.listFiles dir ff)))
;; ⇒ [#object[java.io.File 0x1450131a "/home/sean/oss/clojure-doc.github.io/deps.edn"]]
```

`reify` forms a closure: it will capture locals in its scope. This can be used to make implemented
methods delegate to Clojure functions. The same example, rewritten with delegation:

``` clojure
(import java.io.File)

;; a file filter implementation that keeps only .edn files
(let [f  (fn [_dir name]
           (str/ends-with? name ".edn"))
      ff (reify java.io.FilenameFilter
           (accept [this dir name]
             (f dir name)))
    dir  (File. "/home/sean/oss/clojure-doc.github.io/")]
  (into [] (.listFiles dir ff)))
;; ⇒ [#object[java.io.File 0x5d512ddb "/home/sean/oss/clojure-doc.github.io/deps.edn"]]
```

As above, in Clojure 1.12, because `java.io.FilenameFilter` is a functional interface, you can pass a Clojure function directly:

``` clojure
(import java.io.File)

;; a file filter implementation that keeps only .edn files
(let [^java.io.FilenameFilter
      f  (fn [_dir name]
           (str/ends-with? name ".edn"))
    dir  (File. "/home/sean/oss/clojure-doc.github.io/")]
  (into [] (.listFiles dir f)))
```

> Note: we need the type hint on `f` here because `.listFiles` has multiple overloads for the same arity, and we need to distinguish a `FilenameFilter` from a `FileFilter`.


## Extending Java Classes With proxy

`proxy` is one of two ways to generate instances of anonymous classes in Clojure.
`proxy` takes two vectors: one listing its superclass and (optional) interfaces, the other listing constructor signatures, as well as
zero or more
method implementations. Method implementations are identical to `reify` except that the `this` argument is
not necessary.

A very minimalistic example, we instantiate an anonymous class that extends `java.lang.Object`, implements no
interfaces, has no explicitly defined constructors and overrides `#toString`:

``` clojure
(proxy [Object] []
       (toString []
         "I am an instance of an anonymous class generated via proxy"))
;; ⇒ #object[user.proxy$java.lang.Object$ff19274a 0x66bf40e5 "I am an instance of an anonymous class generated via proxy"]
```

The Clojure compiler will generate an anonymous class for this `proxy` and, at runtime, the cost of
a `proxy` call is the cost of instantiating this class (the class itself is generated just once).

A slightly more complex example where the generated class also implements `java.lang.Runnable` (runnable objects
are commonly used with threads and `java.util.concurrent` classes) which defines one method, `run`:

``` clojure
;; extends java.lang.Object, implements java.lang.Runnable
(let [runnable (proxy [Object Runnable] []
                       (toString []
                         "I am an instance of an anonymous class generated via proxy")
                       (run []
                         (println "Run, proxy, run")))]
        (.run runnable))  ; ⇒ nil
;; outputs "Run, proxy, run"
```

`proxy` forms a closure: it will capture locals in its scope. This is very often used to create an instance
that delegates to a Clojure function:

``` clojure
(let [f   (fn [] (println "Executed from a function"))
      obj (proxy [Object Runnable] []
            (run []
              (f)))]
        (.run obj))  ; ⇒ nil
;; outputs "Executed from a function"
```

TBD: more realistic examples | [How to Contribute](https://github.com/clojure-doc/clojure-doc.github.io#how-to-contribute)


## Clojure Functions Implement Runnable and Callable

Note that Clojure functions implement `java.lang.Runnable` and
`java.util.concurrent.Callable` directly so you can pass functions to
methods found in various classes from the `java.util.concurrent` package.

For example, to run a function in a new thread:

``` clojure
(let [t (Thread. (fn []
                   (println "I am running in a separate thread")))]
  (.start t))
```

Or submit a function for execution to a thread pool (in JDK terms: an execution service):

``` clojure
(import [java.util.concurrent Executors ExecutorService Callable])

(let [^ExecutorService pool (Executors/newFixedThreadPool 16)
      ^Callable  clbl       (fn []
                              (reduce + (range 0 10000)))
      task                  (.submit pool clbl)]
  (.get task))
;; ⇒ 49995000
```

Note that without the `^Callable` type, Clojure compiler would not be able to determine
which exact version of the method we intend to invoke, because `java.util.concurrent.ExecutionService/submit`
has two versions, one for `Runnable` and one for `Callable`. They work very much the same but return
slightly different results (`Callable` produces a value while `Runnable` always returns `nil` when
executed).

The exception we would get without the type hint is

```
Syntax error (IllegalArgumentException) compiling . at (REPL:4:29).
More than one matching method found: submit
```


## gen-class and How to Implement Java Classes in Clojure

### Overview

`gen-class` is a Clojure feature for implementing Java classes in Clojure. It is relatively
rarely used compared to `proxy` and `reify` but is needed to implement executable classes
(that `java` runners and IDEs can use as program entry points).

Unlike `proxy` and `reify`, `gen-class` defines named classes. They can be passed to Java
APIs that expect class references. Classes defined with `gen-class` can extend
base classes, implement any number of Java interfaces, define any number of constructors
and define both instance and static methods.

### AOT

`gen-class` requires *ahead-of-time* (AOT) compilation. It means that
before using the classes defined with `gen-class`, the Clojure
compiler needs to produce `.class` files from `gen-class` definitions.

### Class Definition With clojure.core/gen-class

`clojure.core/gen-class` is a macro that uses a DSL for defining class
methods, base class, implemented interfaces and so on.

It takes a number of options:

 * `:name` (a symbol): defines generated class name
 * `:extends` (a symbol): name of the base class
 * `:implements` (a collection): interfaces the class implements
 * `:constructors` (a map): constructor signatures
 * `:methods` (a collection): lists methods that will be implemented
 * `:init` (symbol): defines a function that will be invoked with constructor arguments
 * `:post-init` (symbol): defines a function that will be called with a constructed instance as its first argument
 * `:state` (symbol): if supplied, a public final instance field with the given name will be created. Only makes sense when
                      used with `:init`. State field value should be an atom or other ref type to allow state mutation.
 * `:prefix` (string, default: `"-"`): methods will call functions named as `(str prefix method-name)`, e.g. `-getName` for `getName`.
 * `:main` (boolean): if `true`, a public static main method will be generated for the class. It will delegate
                      to a function named main with the prefix (`(str prefix "main")`), `-main` by default
 * `:exposes` (map): if supplied, a map of protected fields names to getter/setter names so the generated class implementation can access those protected fields
 * `:exposes-methods` (map): if supplied, a map of superclass methods names to local method names so the generated class implementation can call those superclass methods (since the implementation may contain implementations of those methods that would hide the superclass methods)
 * `:factory` (symbol): if supplied, a name to be used for a (set of) public static factory methods that will be generated that match the class's constructors
 * `:load-impl-ns` (boolean, default `true`): if `true`, the static initializer for the generated class will load the implementation namespace; if `false`, the static initializer will not load the implementation namespace and users would need to load the implementation namespace manually
 * `:impl-ns` (symbol, default: the current namespace): if supplied, the namespace to look in for implementations of the generated class's methods

 For more details, see the [generated API documentation for `gen-class`](https://clojure.github.io/clojure/clojure.core-api.html#clojure.core/gen-class),
 the [community-contributed examples](https://clojuredocs.org/clojure.core/gen-class)
 on clojuredocs.org, and the
 [official reference for Class Generation](https://clojuredocs.org/clojure.core/gen-class)
 on clojure.org.

### gen-class In The ns Macro

`gen-class` can be used with existing namespaces by adding `(:gen-class)` to the
`ns` macro. Here is a "hello, world" example command line app that uses `gen-class`
to generate a class that JVM launcher (`java`) can run:

``` clojure
(ns genclassy.core
  (:gen-class))

(defn -main
  [& args]
  (println "Hello, World!"))
```

This will use the name of the namespace for class name and use the namespace for method
implementation (see the `:impl-ns` option above).


### Examples

A medium size example taken from an open source library:

``` clojure
(ns clojurewerkz.quartzite.listeners.amqp.PublishingSchedulerListener
  (:gen-class :implements   [org.quartz.SchedulerListener]
              :init         init
              :state        state
              :constructors {[com.rabbitmq.client.Channel String String] []})
  (:require [langohr.basic     :as lhb]
            [clojure.data.json :as json])
  (:use [clojurewerkz.quartzite.conversion])
  (:import [org.quartz SchedulerListener SchedulerException Trigger TriggerKey JobDetail JobKey]
           [com.rabbitmq.client Channel]
           [java.util Date]
           [clojurewerkz.quartzite.listeners.amqp PublishingSchedulerListener]))



(defn publish
  [^PublishingSchedulerListener this payload ^String type]
  (let [{ :keys [channel exchange routing-key] } @(.state this)
        payload (json/json-str payload)]
    (lhb/publish channel exchange routing-key payload :type type)))


(defn -init
  [^Channel ch ^String exchange ^String routing-key]
  [[] (atom { :channel ch :exchange exchange :routing-key routing-key })])


(defmacro payloadless-publisher
  [method-name message-type]
  `(defn ~method-name
     [this#]
     (publish this# (json/json-str {}) ~message-type)))

(payloadless-publisher -schedulerStarted       "quartz.scheduler.started")
(payloadless-publisher -schedulerInStandbyMode "quartz.scheduler.standby")
(payloadless-publisher -schedulingDataCleared  "quartz.scheduler.cleared")
(payloadless-publisher -schedulerShuttingDown  "quartz.scheduler.shutdown")


(defn -schedulerError
  [this ^String msg ^SchedulerException cause]
  (publish this (json/json-str { :message msg :cause (str cause) }) "quartz.scheduler.error"))


(defn -jobScheduled
  [this ^Trigger trigger]
  (publish this (json/json-str { :group (-> trigger .getKey .getGroup) :key (-> trigger .getKey .getName) :description (.getDescription trigger) }) "quartz.scheduler.job-scheduled"))

(defn -jobUnscheduled
  [this ^TriggerKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.job-unscheduled"))

(defn -triggerFinalized
  [this ^Trigger trigger]
  (publish this (json/json-str { :group (-> trigger .getKey .getGroup) :key (-> trigger .getKey .getName) :description (.getDescription trigger) }) "quartz.scheduler.trigger-finalized"))

(defn -triggerPaused
  [this ^TriggerKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.trigger-paused"))

(defn -triggersPaused
  [this ^String trigger-group]
  (publish this (json/json-str { :group trigger-group }) "quartz.scheduler.triggers-paused"))

(defn -triggerResumed
  [this ^TriggerKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.trigger-resumed"))

(defn -triggersResumed
  [this ^String trigger-group]
  (publish this (json/json-str { :group trigger-group }) "quartz.scheduler.triggers-resumed"))



(defn -jobAdded
  [this ^JobDetail detail]
  (publish this (json/json-str { :job-detail (from-job-data (.getJobDataMap detail)) :description (.getDescription detail) }) "quartz.scheduler.job-added"))

(defn -jobDeleted
  [this ^JobKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.job-deleted"))

(defn -jobPaused
  [this ^JobKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.job-paused"))

(defn -jobsPaused
  [this ^String job-group]
  (publish this (json/json-str { :group job-group }) "quartz.scheduler.jobs-paused"))

(defn -jobResumed
  [this ^JobKey key]
  (publish this (json/json-str { :group (.getGroup key) :key (.getName key) }) "quartz.scheduler.job-resumed"))

(defn -jobsResumed
  [this ^String job-group]
  (publish this (json/json-str { :group job-group }) "quartz.scheduler.jobs-resumed"))
```

### Inspecting Class Signatures

When using `gen-class` for interoperability purposes, sometimes it is necessary to inspect the API
of the class generated by `gen-class`.

It can be inspected
using [javap](https://docs.oracle.com/en/java/javase/21/docs/specs/man/javap.html). Given the
following Clojure namespace:

``` clojure
(ns genclassy.core
  (:gen-class))

(defn -main
  [& args]
  (println "Hello, World!"))
```

We can inspect the produced class like so:

```
# from target/classes, default .class files location used by Leiningen
javap genclassy.core
```

will output

``` java
public class genclassy.core {
  public static {};
  public genclassy.core();
  public java.lang.Object clone();
  public int hashCode();
  public java.lang.String toString();
  public boolean equals(java.lang.Object);
  public static void main(java.lang.String[]);
}
```



## How To Extend Protocols to Java Classes

Clojure protocols can be extended to any java class (including
Clojure's internal types) very easily using `extend`:

Using the example of a json library, we can define our goal as getting
to the point where the following works:

``` clojure
(json-encode (java.util.UUID/randomUUID))
```

First, let's start with the protocol for json encoding an object:

``` clojure
(defprotocol JSONable
  (json-encode [obj]))
```

So, everything that is "JSONable" implements a `json-encode` method.

Next, let's define a dummy method to do the "encoding" (in this
example, it just prints to standard out instead, it doesn't actually
do any json encoding):

``` clojure
(defn encode-fn
  [x]
  (prn x))
```

Now, define a method that will encode java objects by calling `bean`
on them, then making each value of the bean map a string:

``` clojure
(defn encode-java-thing
  [obj]
  (encode-fn
   (into {}
         (map (fn [m]
                [(key m) (str (val m))])
              (bean obj)))))
```

Let's try it on an example object, a UUID:

``` clojure
(encode-java-thing (java.util.UUID/randomUUID))
;; ⇒ {:mostSignificantBits "-6060053801408705927",
;;    :leastSignificantBits "-7978739947533933755",
;;    :class "class java.util.UUID"}
```

The next step is to extend the protocol to the java type, telling
clojure which java type to extend, the protocol to implement and the
method to use for the `json-encode` method:

``` clojure
(extend java.util.UUID
  JSONable
  {:json-encode encode-java-thing})
```

Alternatively, you could use the `extend-type` macro, which actually
expands into calls to `extend`:

``` clojure
(extend-type java.util.UUID
  JSONable
  (json-encode [obj] (encode-java-thing obj)))
```

Now we can use `json-encode` for the object we've extended:

``` clojure
(json-encode (java.util.UUID/randomUUID))
;; ⇒  {:mostSignificantBits "3097485598740136901",
;;     :leastSignificantBits "-9000234678473924364",
;;     :class "class java.util.UUID"}
```

You could also write the function inline in the extend block, for
example, extending `nil` to return a warning string:

``` clojure
(extend nil
  JSONable
  {:json-encode (fn [x] "x is nil!")})

(json-encode nil)
;; ⇒  "x is nil!"
```

The `encode-java-thing` method can also be reused for other Java types
we may want to encode:

``` clojure
(extend java.net.URL
  JSONable
  {:json-encode encode-java-thing})

(json-encode (java.net.URL. "http://aoeu.com"))
;; ⇒  {:path "",
;;     :protocol "http",
;;     :authority "aoeu.com",
;;     :host "aoeu.com",
;;     :ref "",
;;     :content "sun.net.www.protocol.http.HttpURLConnection$HttpInputStream@4ecac02f",
;;     :class "class java.net.URL",
;;     :defaultPort "80",
;;     :port "-1",
;;     :query "",
;;     :file "",
;;     :userInfo ""}
```


## Using Intrinsic Locks ("synchronized") in Clojure

Every object on the JVM has an *intrinsic lock* (also referred to as *monitor lock*
or simply *monitor*). While very rarely necessary, Clojure provides support for
operations that acquire intrinsic lock of a mutable Java object.

This is covered in the [Concurrency and Parallelism guide](/articles/language/concurrency_and_parallelism/#using-intrinsic-locks-synchronized-in-clojure).



## Wrapping Up

TBD: [How to Contribute](https://github.com/clojure-doc/clojure-doc.github.io#how-to-contribute)


## Contributors

Michael Klishin <michael@defprotocol.org> (original author)
Lee Hinman <lee@writequit.org>
gsnewmark <gsnewmark@meta.ua>
Sean Corfield <sean@corfield.org> (updated to Clojure 1.12)
