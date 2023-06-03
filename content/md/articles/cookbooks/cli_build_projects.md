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
  :api {:ns-default my-proj.api
        :exec-fn my-proj.api/foo}
 }}
```

Now `-X:api` on its own will run that `foo` function:

    clojure -X:api :bar 42

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
* Parameterizing builds using aliases in `deps.edn`
* Multi-version testing
* Continuous Integration pipelines
* Automated deployments
* Using a "build REPL"
* Coordinating build tasks across multiple subprojects

For reference, here's the official documentation:
* [The `tools.build` Guide](https://clojure.org/guides/tools_build)
* [`clojure.tools.build.api` API Documentation](https://clojure.github.io/tools.build/clojure.tools.build.api.html)

Before we start on more complex tasks, let's first look at a task to run
an arbitrary process based on aliases.

### Running Tasks based on Aliases

`tools.build` provides functions to construct a Java-based command-line and
then run it as a subprocess, using a "basis" to control what classpath is
passed to the `java` command.

Given the `deps.edn` above (containing the `:build` alias) and the `build.clj`
above (containing the `hello` function), we're going to start out by adding
a `run` function that will run a specific Java-based command-line. Then we'll
parameterize it using aliases in `deps.edn:

```clojure
(defn run [opts]
  (let [cmd (b/java-command {:basis     (b/create-basis)
                             :main      'clojure.main
                             :main-args ["-e" "(clojure-version)"]})]
    (b/process cmd)))
```

We can run this with:

    clojure -T:build run

and we'll see the version of Clojure we're running: `"1.11.1"`.

Since we will generally want the build to fail if the command exits with
a non-zero status, we'll check the return value of `b/process` and throw
an exception if the exit status is non-zero:

```clojure
    (when-not (zero? (:exit (b/process cmd)))
      (throw (ex-info (str "run failed for " aliases) opts)))
```

In addition, we'll make all our function return the `opts` map, so that
we can chain them together in a pipeline, either within another function
or when we get to the "build REPL" section later.

We want to parameterize this so we can run any command-line we want, so
we will pass `:aliases` in the `opts` and use that to construct the
basis and also to retrieve both the `:main` class to run and the `:main-args`
we want to use with it.

We will need to use `tools.deps` to process the aliases, so that we can
retrieve data from those aliases in `deps.edn`:

```clojure
(ns build
  (:require [clojure.tools.build.api :as b]
            ;; add this:
            [clojure.tools.deps :as t]))

;; change run to this:
(defn run [{:keys [aliases] :as opts}]
  (let [basis      (b/create-basis opts) ; primarily using :aliases here
        alias-data (t/combine-aliases basis aliases)
        cmd-opts   (merge {:basis     basis
                           :main      'clojure.main
                           :main-args ["-e" "(clojure-version)"]}
                          opts
                          alias-data)
        cmd        (b/java-command cmd-opts)]
    (when-not (zero? (:exit (b/process cmd)))
      (throw (ex-info (str "run failed for " aliases) opts)))
    opts))
```

We need the `:aliases` in `create-basis` so paths and dependencies from those
aliases are taken into account for building the classpath. We've added the
call to `combine-aliases` so that we can get the raw data from those aliases
in `deps.edn` -- we'll get back a hash map which is the merge of the values
identified by those aliases.

Next we're going to add `:main-args` to the `:test` alias in `deps.edn`:

```clojure
  :test {:extra-paths ["test"]
         :extra-deps {io.github.cognitect-labs/test-runner
                      {:git/tag "v0.5.1" :git/sha "dfb30dd"}}
         :exec-fn cognitect.test-runner.api/test
         ;; add this alias data for build.clj:
         :main-args ["-m" "cognitect.test-runner"]}
```

If we pass the `:test` alias to our `run` task like this:

    clojure -T:build run :aliases '[:test]'

we'll see the test runner output (assuming you don't have any tests yet):

    Running tests in #{"test"}

    Testing user

    Ran 0 tests containing 0 assertions.
    0 failures, 0 errors.

Let's add a `test` function to `build.clj` to make this easier to run:

```clojure
(defn test [opts]
  (run (update opts :aliases conj :test)))
```

Since `test` is also a function in `clojure.core`, we'll suppress the warning
that would cause by excluding `test` from being referred in:

```clojure
(ns build
  ;; add this:
  (:refer-clojure :exclude [test])
  (:require [clojure.tools.build.api :as b]
            [clojure.tools.deps :as t]))
```

Now we can run the tests with:

    clojure -T:build test

There are several important things to note here:
* All our `build.clj` functions return the `opts` map, possibly augmented by the function itself. This will help us chain functions together later.
* Each function can set up defaults, which can be overridden by the caller via the `opts` map, and then by the alias data from `deps.edn`.
* We pass full options and alias data hash maps to all the `b/*` functions, so that we can provide arbitrary additional options to those functions, via the command-line, other functions, or via alias data in `deps.edn`. This follows Clojure's "open map" approach to data to support flexibility and extensibility.
* We do not return the `:basis` from a function because we want each function to be able to control that independently, although our functions can accept a `:basis` in the `opts` map so the caller can still override that if needed.

### Multi-Version Testing

With the above `run` and `test` functions in place, we can automatically
run our tests for multiple versions of Clojure. We'll add aliases to `deps.edn`
that specify versions of Clojure to test against, and then use those in a
new `test-multi` function in `build.clj`.

Add these aliases to `deps.edn`:

```clojure
  :1.9  {:override-deps {org.clojure/clojure {:mvn/version "1.9.0"}}}
  :1.10 {:override-deps {org.clojure/clojure {:mvn/version "1.10.3"}}}
  :1.11 {:override-deps {org.clojure/clojure {:mvn/version "1.11.1"}}}
```

When these aliases are used in combination with other aliases, the default
version of Clojure will be overridden with the specified version. We can see
this by running `clojure -T:build run :aliases '[:1.9]'` and seeing `"1.9.0"`
for example.

Here's our `test-multi` function:

```clojure
(defn test-multi [opts]
  (doseq [v [:1.9 :1.10 :1.11]]
    (println "\nTest with Clojure" v)
    (test (update opts :aliases conj v)))
  opts)
```

If we add the following `test/example_test.clj` file to our project, we can
verify the tests are running against the correct version of Clojure:

```clojure
(ns example-test
  (:require [clojure.test :refer :all]))

(deftest version-test
  (println (clojure-version))
  (is true))
```

Now when we run `clojure -T:build test-multi` we see:

```
Test with Clojure :1.9

Running tests in #{"test"}

Testing example-test
1.9.0

Ran 1 tests containing 1 assertions.
0 failures, 0 errors.

Test with Clojure :1.10

Running tests in #{"test"}

Testing example-test
1.10.3

Ran 1 tests containing 1 assertions.
0 failures, 0 errors.

Test with Clojure :1.11

Running tests in #{"test"}

Testing example-test
1.11.1

Ran 1 tests containing 1 assertions.
0 failures, 0 errors.
```
