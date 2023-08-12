{:title "Building Projects: tools.build and the Clojure CLI"
 :layout :page :page-index 4000
 :toc true}

## `tools.build` and the Clojure CLI

[`tools.build`](https://github.com/clojure/tools.build)
is a library for building artifacts in Clojure projects, which are typically
library `.jar` files for deployment to repositories like [Clojars](https://clojars.org)
for others to use or application `.jar` files to run on servers or in containers.

`tools.build` provides functions to copy files and directories, to run arbitrary
commands and capture their output (with special support for `java` commands),
to easily run `git` commands, to
create `pom.xml` files, to compile Clojure (and Java) code, and to build both `.jar`
and `.zip` files.

This cookbook will offer examples that go beyond the basics in the official
guide, based on real-world projects.

### Executing functions with the Clojure CLI

_If you are already familiar with the `-X` and `-T` options to the Clojure CLI, you can skip this section._

The [Clojure CLI](https://clojure.org/guides/deps_and_cli) was introduced
by the core Clojure team in 2018 and focused on starting a REPL and
running code, and managing dependencies using a `deps.edn` file.

#### -X eXecute function

Unlike [Leiningen](https://leiningen.org/), which was more of a
"batteries-included" approach, the CLI assumed that you would declare
additional tooling through "aliases" in `deps.edn`, to add extra
dependencies, and evolved over time to support both traditional
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

**Shortening command line invocations**

You can shorten that in two ways:

1. **Add an alias** to your `deps.edn` file that includes the default namespace
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

2. Specify a **default function** to run in an alias:

```clojure
;; deps.edn
{
 :aliases
 {
  :api {:ns-default my-proj.api
        ;; could use :exec-fn foo since my-proj.api is the default namespace:
        :exec-fn my-proj.api/foo}
 }}
```

Now `-X:api` on its own will run that `foo` function:

    clojure -X:api :bar 42

**Running Tests**

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


#### -T execute Tooling

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

For more background reading, see the
[Practical.li CLI Execution options](https://practical.li/clojure/clojure-cli/execution-options/) guide.

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
* Automating deployments
* Using a "build REPL"
* Coordinating build tasks across multiple subprojects

For reference, here's the official documentation:
* [The `tools.build` Guide](https://clojure.org/guides/tools_build)
* [`clojure.tools.build.api` API Documentation](https://clojure.github.io/tools.build/clojure.tools.build.api.html)

Before we start on more complex tasks, let's first look at a task to run
an arbitrary process based on aliases.

## Running Tasks based on Aliases

`tools.build` provides functions to construct a Java-based command-line and
then run it as a subprocess, using a "basis" to control what classpath is
passed to the `java` command.

**Simple Example**

Given the `deps.edn` above (containing the `:build` alias) and the `build.clj`
above (containing the `hello` function), we're going to start out by adding
a `run` function that will run a specific Java-based command-line. Then we'll
parameterize it using aliases in `deps.edn`:

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

**Error Handling**

Since we will generally want the build to fail if the command exits with
a non-zero status, we'll check the return value of `b/process` and throw
an exception if the exit status is non-zero:

```clojure
    (when-not (zero? (:exit (b/process cmd)))
      (throw (ex-info (str "run failed for " aliases) opts)))
```

**Extra Options**

In addition, we'll make all our function return the `opts` map, so that
we can chain them together in a pipeline, either within another function
or when we get to the "build REPL" section later.

We want to parameterize this so we can run any command-line we want, so
we will pass `:aliases` in the `opts` and use that to construct the
basis and also to retrieve both the `:main` class to run and the `:main-args`
we want to use with it.

**Require `clojure.tools.deps`**

We will need to use the `clojure.tools.deps` namespace from `tools.deps` to process the aliases, so that we can
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

**Create `test` function**

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

**Wrap up**

There are several important things to note here:
* All our `build.clj` functions return the `opts` map, possibly augmented by the function itself. This will help us chain functions together later.
* Each function can set up defaults, which can be overridden by the caller via the `opts` map, and then by the alias data from `deps.edn`.
* We pass full options and alias data hash maps to all the `b/*` functions, so that we can provide arbitrary additional options to those functions, via the command-line, other functions, or via alias data in `deps.edn`. This follows Clojure's "open map" approach to data to support flexibility and extensibility.
* We do not return the `:basis` from a function because we want each function to be able to control that independently, although our functions can accept a `:basis` in the `opts` map so the caller can still override that if needed.

## Multi-Version Testing

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

## Tips for Building JAR Files

Although the official `tools.build` has examples for
[Source library jar build](https://clojure.org/guides/tools_build#_source_library_jar_build)
and
[Compiled uberjar application build](https://clojure.org/guides/tools_build#_compiled_uberjar_application_build),
and both of these first define a number of global variables, and then use
those to construct distinct hash maps of options for the `b/*` function calls,
if we want to parameterize our builds, it is more convenient to write a
function that takes the options as a parameter, and returns the full options
hash map with those "global" defaults merged in.

The only "gotcha" about doing this is that there are five `b/*` functions
that accept `:src-dirs` and they typically have different values for each
of those calls. Depending on how your project is structured, you might be
able to get away with using `["src" "resources"]` for `:src-dirs` and
adding `(take 1 ..)` around it for `b/write-pom` and/or `b/compile-clj`.
For `b/javac`, you probably want a separate `:src-dirs` value since any
Java source code in your project is likely to be separate from your Clojure
code and won't be copied into your JAR (but it will be compiled and the
classes that produces will be included in the JAR).

An alternative approach is to use a `:src-dirs` value of `["src"]` in your
options hash map that is passed "everywhere" and then for `b/copy-dir` use
`["src" "resources"]` explicitly for `:src-dirs`. This is the approach used
in both
[`next.jdbc`](https://github.com/seancorfield/next-jdbc/blob/develop/build.clj)
and
[HoneySQL](https://github.com/seancorfield/honeysql/blob/develop/build.clj)
for example.

Those `build.clj` files are also examples of providing a `jar-opts` function
that can set up all the options needed for `b/write-pom` and `b/jar` in one
place, although neither allows for the default options to be overridden from
the command-line or by other functions (except for selection of whether to
build a SNAPSHOT or a release version of the library).

The global variables defining `lib`, `version`, etc could be moved to the
`jar-opts` function but some people will find it easier to read your `build.clj`
file if they are defined at the top of the file.

You might end up with something like:

```clojure
(defn- jar-opts [opts]
  (let [lib     'my/lib
        version "1.2.3"
        target  "target"
        classes (str target "/classes")]
    (assoc opts
           :lib        lib
           :version    version
           :jar-file   (format "target/%s-%s.jar" lib version)
           :scm  {:tag (str "v" version)}
           :basis      (b/create-basis {})
           :class-dir  classes
           :target-dir classes ; for b/copy-dir
           :target     target
           :path       target ; for b/delete
           :src-dirs   ["src"])))

(defn jar [opts]
  (let [opts (jar-opts opts)]
    ;; clojure.tools.build.api functions return nil:
    (b/delete opts)
    (b/write-pom opts)
    (b/copy-dir (update opts :src-dirs conj "resources"))
    (println "\nWriting" (:jar-file opts))
    (b/jar opts))
  ;; return original opts for chaining:
  opts)
```

> Note: in the above `jar-opts` function, we do not allow the JAR-related options to be overridden by the `opts` passed in. If you want to allow that, you can use `merge` instead of `assoc` in the `jar-opts` function (with a literal hash map of the JAR-related options followed by `opts`). You may need to do extra work if you want `:lib`, `:version`, and/or `:target` to be overridden but still have `:jar-file`, `:class-dir`, and `:target-dir` be derived from those values.

> Note: the basis is a huge hash map so we don't want to return it from our `jar` function (unless it was passed in via `opts`) in case we either want to use this from the "build REPL" (later) or from another function where we might want control over the basis used. If you decide to return the merged options from `jar`, you should probably use `dissoc` to remove the basis from the options returned (unless it was passed in via `opts`).

## Continuous Integration Pipelines

Now that we have testing and JAR-building covered, we can add a `ci` function
to our `build.clj` file to run our tests and build a JAR file:

```clojure
(defn ci [opts]
  (-> opts
      (test-multi)
      ;; run any other linters or testing you need here...
      ;; ...then build the JAR if everything passes:
      (jar)))
```

The [HoneySQL](https://github.com/seancorfield/honeysql/blob/develop/build.clj)
`build.clj` file has a `ci` function that runs tests for multiple Clojure versions,
for ClojureScript, and runs "doc tests" (validating all the examples in the
documentation), as well as running the
[Eastwood linter](https://github.com/jonase/eastwood)
-- all before building the JAR file.

Your pipeline configuration for continuous integration could now be as simple as:

    clojure -T:build ci

If you need to set up databases for testing, you could write that as a function
in your `build.clj` file and call it from `ci` before running the tests, possibly
configured via aliases.

You might also want your CI pipeline to perform a deployment step, which we'll
cover next.

## Automating deployments

`tools.build` itself does not provide any direct support for deploying artifacts
so you will need to use additional libraries. If you are deploying to Clojars,
then [deps-deploy](https://github.com/slipset/deps-deploy) is a good option.

**`:build` Alias**

Add the following to your `:build` alias in `deps.edn` (in the `:deps` map):

```clojure
                 slipset/deps-deploy {:mvn/version "0.2.1"}
```

**Create `deploy` function**

And add the following task to your `build.clj` file:

```clojure
(defn deploy "Deploy the JAR to Clojars." [opts]
  (let [{:keys [jar-file] :as opts} (jar-opts opts)]
    (dd/deploy {:installer :remote :artifact (b/resolve-path jar-file)
                :pom-file (b/pom-path (select-keys opts [:lib :class-dir]))}))
  opts)
```

**Clojars credentials**

Per the `deps-deploy` README, you'll need to set up environment variables
for your Clojars username and token: `CLOJARS_USERNAME` and `CLOJARS_PASSWORD`
(even tho' it is **not** your password, it's a deployment token you need to
setup in your Clojars account).

You can now deploy your JAR file to Clojars with:

    clojure -T:build deploy

**CI integration**

At this point, you can automate building and deploying snapshot or full
release versions of your library, using GitHub Actions or whatever CI
pipeline service you prefer.

The `next.jdbc` library project builds and deploys a snapshot version for
every successful commit to the `develop` branch and builds and deploys a
release version whenever a release tag is created:

* [`snapshot` and `version` in `build.clj`](https://github.com/seancorfield/next-jdbc/blob/fd95a69b5c41354fda55a36f4c6d6d5f088b7384/build.clj#L18-L22)
* [selecting the version based on options](https://github.com/seancorfield/next-jdbc/blob/fd95a69b5c41354fda55a36f4c6d6d5f088b7384/build.clj#L38-L41)
* [test, build, and deploy a snapshot](https://github.com/seancorfield/next-jdbc/blob/fd95a69b5c41354fda55a36f4c6d6d5f088b7384/.github/workflows/test-and-snapshot.yml#L40-L51)
* [test, build, and deploy a release](https://github.com/seancorfield/next-jdbc/blob/fd95a69b5c41354fda55a36f4c6d6d5f088b7384/.github/workflows/test-and-release.yml#L42-L53)

## Using a "build REPL"

While you can write task functions that combine multiple steps, it can be
useful to work interactively with the build process, so you can run each
step -- or a subset of steps -- individually. You can do this by starting
a "build REPL" with:

    clj -M:build -i build.clj -e "(in-ns 'build)" -r

This will start a REPL with the `build.clj` file loaded and the `b/*` functions
available, since you will be in the `build` namespace.

Let's break this down:
* `-M:build` -- this says "run `clojure.main` with the `:build` alias as the context", so you have the `tools.build` dependencies available, and everything that follows is an argument to `clojure.main`,
* `-i build.clj` -- this says "load the `build.clj` file before starting the REPL",
* `-e "(in-ns 'build)"` -- this switches you into the `build` namespace (after it was loaded by `-i`),
* `-r` -- this says "start a REPL after loading the file and switching namespaces".

Now you can run individual tasks, or combinations of tasks, interactively:

```clojure
build=> (test-multi {})
...
build=> (-> {} (test-multi) (jar))
```

Because you have a "build REPL" running, you don't have to pay the startup
time cost for each task, like you would for `clojure -T:build test-multi` etc.

Using an example from where I work, I might run some or all of the following
steps within a "build REPL":

```clojure
build=> (-> {} (check-all) (ancient) (cve-check) (cold-start) (test-stable) (build-uberjars))
```

There is a subtlety to be aware of here: `clojure -T:build` not only uses the
dependencies declared in the `:build` alias to be added to the classpath, it
also sets the `:paths` to be `["."]` -- just the current directory -- so your
project source code (and dependencies) are **not** available directly in
`build.clj` code. When you run `clojure -M:build`, your project
source code **is** available directly in the "build REPL" -- but its
dependencies are not, and any local files your `build.clj` expects to be able
to read from the classpath (or load as namespaces) will not be available.
If that matters, you can add `-Sdeps '{:paths ["."]}'` to the command:

    clj -Sdeps '{:paths ["."]}' -M:build -i build.clj -e "(in-ns 'build)" -r

That's quite a mouthful so you probably want to put it in a shell script
somewhere on your `PATH`, for convenience!

## Working with Multiple Subprojects

If you have a project with multiple subprojects, you can use `tools.build`
to build them all, and run tests for them all, with a single `build.clj`
file in the root of the project.

`tools.build` has the concept of a "project root" which is exposed as a
dynamic variable `b/*project-root*` and which is used by the various other
functions to resolve paths relative to the project root.

You can loop over your subprojects and use `with-project-root` to set the project root
for each one while you call `tools.build` functions to test, build, and deploy
each subproject.

If you're working with `tools.deps` directly as well in your `build.clj` file,
you might also want to use `clojure.tools.deps.util.dir/with-dir` to set the
project root for `tools.deps` operations. Note that `with-dir` takes a
`java.io.File` for a directory,
whereas `clojure.tools.build.api/*project-root*` expects a
`java.lang.String` for the path to the project root!

A fairly comprehensive example can be found in the
[Polylith `build.clj` file](https://github.com/polyfy/polylith/blob/master/build.clj)
Polylith has multiple subprojects under the `projects/` directory.
The `deploy` task function
[loops over all the subprojects](https://github.com/polyfy/polylith/blob/9053b190d5f3b0680ac4fe5c5f1851f7c0d40830/build.clj#L208)
and calls `jar` which uses
[both `with-dir` and `with-project-root`](https://github.com/polyfy/polylith/blob/9053b190d5f3b0680ac4fe5c5f1851f7c0d40830/build.clj#L146-L147)
to set the project root while performing `tools.deps` and `tools.build`
operations.
