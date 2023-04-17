{:title "Building Projects: tools.build and the Clojure CLI"
 :layout :page :page-index 4000}

## `tools.build` and the Clojure CLI

[`tools.build`](https://github.com/clojure/tools.build)
is a library for building artifacts in Clojure projects, which are typically
library `.jar` files for deployment to repositories like [Clojars](https://clojars.org)
for others to use or application `.jar` files to run on servers on in containers.

`tools.build` provides functions to copy files and directories, to run arbitrary
commands and capture their output (with special support for `java` commands),
to easily run `git` commands, to
create `pom.xml` files, to compile Clojure (and Java) code, and to build both `.jar`
and `.zip` files.

This cookbook will offer examples that go beyond the basics in the official
guide, based on real-world projects.

### Executing functions with the Clojure CLI

The [Clojure CLI](https://clojure.org/guides/deps_and_cli) was introduced
by the core Clojure team in 2018 and focused on starting a REPL and
running code, and managing dependencies using a `deps.edn` file.

Unlike [Leiningen](https://leiningen.org/), which was more of a
"batteries-included" approach, the CLI assumed that you would declare
additional tooling through "aliases" in `deps.edn` that added extra
dependencies and evolved, over time, to support both traditional
command-line invocation -- a sequence of string arguments passed to a `-main`
function -- and direct invocation of Clojure functions, passing a
hash map of options from the command-line:

    clojure -X my-proj.api/foo '{:bar 42}'

This will attempt to load the `my-proj.api` namespace and call the `foo`
function, passing in the hash map `{:bar 42}`. If you have the following
code:

```clojure
;; src/my_proj/api.clj
(ns my-proj.api)

(defn foo [opts]
  (println (get opts :bar "No :bar passed!")))
```

Then it will print `42`. You can also specify the hash map as individual
key/value pairs on the command-line:

   clojure -X my-proj.api/foo :bar 42

You can shorten that in two ways:

Add an alias to your `deps.edn` file that includes the default namespace
you want to use:

```clojure
;; deps.edn
{
 :aliases
 {
  :api {:ns-default my-proj.api}
 }}
```

Now you can omit the namespace from the command-line:

    clojure -X:api foo :bar 42

Or you can specify a default function to run in an alias:

```clojure
;; deps.edn
{
 :aliases
 {
  :api {:ns-default my-proj.api}
  :foo {:exec-fn my-proj.api/foo}
 }}
```

Now `-X` on its own will run that `foo` function:

    clojure -X :bar 42

The `-X` option to the Clojure CLI stands for "eXecute function" and it
uses the same default context as your project, so your source code and its
dependencies are all available. This is useful for running tests, for
example, using the
[Cognitect Labs' test-runner](https://github.com/cognitect-labs/test-runner)
project:

```clojure
;; deps.edn
{
 :aliases
 {
  ;; add this to :aliases in deps.edn:
  :test {:extra-paths ["test"]
         :extra-deps {io.github.cognitect-labs/test-runner
                      {:git/tag "v0.5.1" :git/sha "dfb30dd"}}}
 }}
```

and now you can run your tests with:

    clojure -X:test cognitect.test-runner.api/test

which you can shorten by specifying the function you want to execute
by default directly in the alias:

```clojure
;; deps.edn
{
 :aliases
 {
  ;; add this to :aliases in deps.edn:
  :test {:extra-paths ["test"]
         :extra-deps {io.github.cognitect-labs/test-runner
                      {:git/tag "v0.5.1" :git/sha "dfb30dd"}}
         :exec-fn cognitect.test-runner.api/test}
 }}
```

Now you can run your tests with:

    clojure -X:test

However, sometimes you want to run some tooling without the context of your
project and the `-T` option is provided for that -- "execute Tooling":
it omits the dependencies
and paths from your project, using only those declared in the aliases you
specify with `-T` (if any).

The functions in `tools.build` are intended to be used with `-T` and you
typically declare a `:build` alias in `deps.edn` for this:

```clojure
;; deps.edn
{
 :aliases
 {
  ;; add this to :aliases in deps.edn:
  :build {:deps {io.github.clojure/tools.build
                 {:git/tag "v0.9.4" :git/sha "76b78fe"}}
          :ns-default build}
 }}
```

The `-T` option implicitly sets `:paths ["."]` (as opposed to `:paths ["src"]`
which is the default for `-M` and `-X`).

The code for the build processes would typically be in a `build.clj`
file in the root of your project -- so its namespace would be `build` (since
the file is relative to `"."` -- the project root). As shown above,
the `:ns-default` key then allows you to omit the namespace portion when
you invoke functions in `build.clj`:

```clojure
(ns build
  (:require [clojure.tools.build.api :as b]))

(defn hello [opts]
  (println (str "Hello, " (:name opts "World") "!")))
```

Try this out by running that `hello` function:

    clojure -T:build hello

    clojure -T:build hello :name '"Build"'

The extra quotes in that second example are necessary to pass a Clojure string
(with double quotes) through the shell as a literal value (with single quotes).
You can do the same thing with:

    clojure -T:build hello '{:name "Build"}'

## The `tools.build` Library

The official guide provides three examples, and talks briefly about passing
parameters into `build` task functions:
* [Source library jar build](https://clojure.org/guides/tools_build#_source_library_jar_build)
* [Compiled uberjar application build](https://clojure.org/guides/tools_build#_compiled_uberjar_application_build)
* [Mixed Java / Clojure build](https://clojure.org/guides/tools_build#_mixed_java_clojure_build)

Those examples are a good starting point for simple projects but there is
so much you can do with `build.clj` to automate all manner of things in
larger projects:
* Multi-version testing
* Continuous Integration pipelines
* Automated deployments
* Parameterizing builds using aliases in `deps.edn`
* Using a "build REPL"
* Coordinating build tasks across multiple subprojects

For reference, here's the official documentation:
* [The `tools.build` Guide](https://clojure.org/guides/tools_build)
* [`clojure.tools.build.api` API Documentation](https://clojure.github.io/tools.build/clojure.tools.build.api.html)

Before we start on more complex tasks, let's first look as a task to run
an arbitrary process based on aliases.

### Running Tasks based on Aliases

`tools.build` provides functions to construct a Java-based command-line and
then run it as a subprocess, using a "basis" to control what classpath is
passed to the `java` command.

For a very simple example:

```clojure
(defn writers-block [ugh!])
```
