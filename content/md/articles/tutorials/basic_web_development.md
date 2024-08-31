{:title "Basic Web Development"
 :page-index 1500 :toc true
 :layout :page}


This guide covers building a simple web-application using common
Clojure libraries. When you're done working through it, you'll have a
little webapp that displays some (x, y) locations from a database,
letting you add more locations as well.

It's assumed that you're already somewhat familiar with Clojure. If
not, see the [Getting Started](/articles/tutorials/getting_started/) and
[Introduction](/articles/tutorials/introduction/) guides.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).

This guide uses Clojure 1.11.4, as well as current versions of the
component libraries noted below.



## Conceptual Overview of Components

We'll use four major components (briefly described below) for our
little webapp:

  * Ring
  * Compojure
  * Hiccup
  * H2



### Ring

[Ring](https://github.com/ring-clojure/ring) ([at
clojars](https://clojars.org/ring)) is a foundational Clojure web
application library. It:

  * sets things up such that an HTTP request comes into your webapp
    as a regular Clojure hashmap, and likewise makes it so that you
    can return a response as a hashmap.
  * provides [a
    spec](https://github.com/ring-clojure/ring/blob/master/SPEC.md)
    describing exactly what those request and response maps should
    look like.
  * brings along a web server
    ([Jetty](http://www.eclipse.org/jetty/)) and connects your
    webapp to it.

For this tutorial, we won't actually need to deal with these maps
by-hand, as you'll soon see.

For more info, see:

  * [the Ring readme](https://github.com/ring-clojure/ring#readme)
  * [its wiki docs](https://github.com/ring-clojure/ring/wiki)
  * [its API docs](https://ring-clojure.github.io/ring/)



### Compojure

If we were using only Ring, we'd have to write one single function to
take that incoming request map and then delegate to various functions
depending upon which page was requested.
[Compojure](https://github.com/weavejester/compojure) ([at
clojars](https://clojars.org/compojure)) provides some handy features
to take care of this for us such that we can associate url paths with
corresponding functions, all in one place.

For more info, see:

  * [the Compojure readme](https://github.com/weavejester/compojure#readme)
  * [its wiki docs](https://github.com/weavejester/compojure/wiki)
  * [its API docs](https://weavejester.github.io/compojure/)



### Hiccup

[Hiccup](https://github.com/weavejester/hiccup) ([at
clojars](https://clojars.org/hiccup)) provides a quick and easy way to
generate html. It converts regular Clojure data structures right into
html. For example,

```clojure
[:p "Hello, " [:i "doctor"] " Jones."]
```

becomes

```html
<p>Hello, <i>doctor</i> Jones.</p>
```

but it also does two extra handy bits of magic:

  * it provides some CSS-like shortcuts for specifying id and class,
    and

  * it automatically unpacks seqs for you, for example:

    ```clojure
    [:p '("a" "b" "c")]
    ;; expands to (and so, is the same as if you wrote)
    [:p "a" "b" "c"]
    ```

For more info, see:

  * [the Hiccup readme](https://github.com/weavejester/hiccup#readme)
  * [its wiki docs](https://github.com/weavejester/hiccup/wiki)
  * [its API docs](https://weavejester.github.io/hiccup/)



### H2

[H2](http://www.h2database.com/html/main.html) is a small and fast Java SQL
database that could be embedded in your application or run in server
mode. It uses a single file for storage, but also could be run as in-memory DB.

> Another similar Java-based embedded DB that could be used in your
> application is [Apache Derby](http://db.apache.org/derby/).



## Create and set up your project

We're going to create this project from scratch and use the Clojure CLI
so you can how see how all the moving parts work.

In a new folder, perhaps called `my-webapp`, we're going to create a `deps.edn`
file to specify the libraries we want to use, and a couple of folders: one
for CSS files and one for your source code.

The `deps.edn` file should have the following contents:

```clojure
{:paths ["src" "resources"]
 :deps {;; basic Ring and web server:
        ring/ring-core {:mvn/version "1.12.2"}
        ring/ring-jetty-adapter {:mvn/version "1.12.2"}
        ;; logging, required by jetty:
        org.slf4j/slf4j-simple {:mvn/version "2.0.13"}

        ;; routing:
        compojure/compojure {:mvn/version "1.7.1"}

        ;; convenient package of "default" middleware:
        ring/ring-defaults {:mvn/version "0.5.0"}

        ;; to generate HTML:
        hiccup/hiccup {:mvn/version "1.0.5"}

        ;; for the database:
        com.github.seancorfield/next.jdbc {:mvn/version "1.3.939"}
        com.h2database/h2 {:mvn/version "2.2.224"}}}
```

Now we'll create the first version of our source file:

```clojure
;; this file is: src/my_webapp/handler.clj
(ns my-webapp.handler
  (:require [compojure.core :refer [defroutes GET]]
            [compojure.route :as route]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]))

(defroutes app-routes
  (GET "/" [] "Hello World")
  (route/not-found "Not Found"))

(def app
  ;; use #' prefix for REPL-friendly code -- see note below
  (wrap-defaults #'app-routes site-defaults))

(defn -main []
  (jetty/run-jetty #'app {:port 3000}))
```

> REPL-friendly code: we use the `#'` prefix on var names so that we can update the definitions while the program is running, without needing to restart our program -- see [writing REPL-friendly programs on clojure.org](https://clojure.org/guides/repl/enhancing_your_repl_workflow#writing-repl-friendly-programs).

> Note: the directory has an underscore in it (`my_webapp`) but the namespace has a hyphen in it (`my-webapp`). This is important in Clojure: we use lowercase names with hyphens to separate "words" -- often called kebab-case -- but the corresponding directory and filenames should be lowercase with underscores to separate "words" -- often called snake_case. This is due to how Clojure maps code onto names that are acceptable to the underlying JVM ecosystem.

At this point you can run this very basic web application from the command-line:

```bash
clojure -M -m my-webapp.handler
```

This says we want to run [Clojure's main entry point](https://clojure.org/reference/repl_and_main) (`-M`) and then `-m my-webapp.handler`
tells Clojure that we want it to run the `-main` function in that namespace.

It will output something like this (and then "hang" while the web server is running):

```
[main] INFO org.eclipse.jetty.server.Server - jetty-11.0.21; built: 2024-05-14T03:19:28.958Z; git: 996cd61addad9cb033e0e3eba6fa3f0fa3dc270d; jvm 21.0.1+12-LTS
[main] INFO org.eclipse.jetty.server.handler.ContextHandler - Started o.e.j.s.ServletContextHandler@677274e7{/,null,AVAILABLE}
[main] INFO org.eclipse.jetty.server.AbstractConnector - Started ServerConnector@5570ee6d{HTTP/1.1, (http/1.1)}{0.0.0.0:3000}
[main] INFO org.eclipse.jetty.server.Server - Started Server@729d1428{STARTING}[11.0.21,sto=0] @4321ms
```

> Note: you can stop this program running by pressing `^C` (control-c) on macOS or Linux, or by pressing `^Z` (control-z) on Windows.

The only relevant line in that output is `Started ServerConnector` where it
shows the host and port it is running on -- `0.0.0.0:3000` -- so you should
be able to open a web browser and go to http://localhost:3000 and you should
see:

```
Hello World
```

If you go to http://localhost:3000/page you should instead see:

```
Not Found
```

This is because `defroutes` specifies a single route (`GET "/"`) and then
`route/not-found` will match all other requests and present the given string
`"Not Found"`.

Stop the program (as indicated above) and we'll add more features to it.

## Add some styling

Now we're going to create some styling by creating a CSS file:

Create the folder structure `resources/public/css` and add a `styles.css`
file this with contents like:

```css
// resources/public/css/styles.css
body {
    background-color: Cornsilk;
}

#header-links {
    background-color: BurlyWood;
    padding: 10px;
}

h1 {
    color: CornflowerBlue;
}
```



## Set up your database

A file containing the database would be automatically created when you connect to it for the
first time, so all necessary database preparations could be done programmatically
using the REPL (with help of `next.jdbc`):

```bash
clj
```

Execute the following code to create a new `my-db.mv.db` database file in the
root of your project, create a table we'll use for our webapp, and add
one record to start us off with:

```clojure
user=> (require '[next.jdbc :as jdbc] '[next.jdbc.sql :as sql])
nil
;; a hash map that describes the database we plan to use:
user=> (def db-spec {:dbtype "h2" :dbname "./my-db"})
#'user/db-spec
;; execute a single statement to create the locations table:
user=> (jdbc/execute-one! db-spec ["
CREATE TABLE locations (
  id bigint primary key auto_increment,
  x  integer,
  y  integer
)
"])
#:next.jdbc{:update-count 0}
;; insert a single row of data into that table:
user=> (sql/insert! db-spec :locations {:x 8 :y 9})
#:LOCATIONS{:ID 1} ; the generated key(s) from the insert
user=>
```

and press `ctrl-d` to exit.

You'll see that a file called `my-db.mv.db` has been created: this contains your `my-db` database.

> Note: the `#:namespace{:key value}` notation is shorthand for `{:namespace/key value}` and is something you'll see a lot in Clojure. Namespace-qualified keys provide additional context: in the first case above `:next.jdbc/update-count` is produced by `next.jdbc` itself whereas `:LOCATIONS/ID` indicates the table and column name of the auto-increment key from the database.

For more about how to use the database functions, see the
[Getting Started with next.jdbc](https://cljdoc.org/d/com.github.seancorfield/next.jdbc/1.3.862/doc/getting-started).



## Create some db access functions

We're going to work bottom-up, so that our code is always in a state
where we can evaluate it and try it out via the REPL (hopefully, via
your REPL-connected editor).

Create a `src/my_webapp/db.clj` file and make it look like:

```clojure
;; src/my_webapp/db.clj
(ns my-webapp.db
  (:require [next.jdbc.sql :as sql]))

(def db-spec {:dbtype "h2" :dbname "./my-db"})

(defn add-location-to-db
  [x y]
  (let [results (sql/insert! db-spec :locations {:x x :y y})]
    (assert (and (map? results) (:LOCATIONS/ID results)))
    results))

(defn get-xy
  [loc-id]
  (let [results (sql/query db-spec
                           ["select x, y from locations where id = ?" loc-id])]
    (assert (= (count results) 1))
    (first results)))

(defn get-all-locations
  []
  (sql/query db-spec ["select id, x, y from locations"]))

(comment
  (get-all-locations)
  ;; => [#:LOCATIONS{:ID 1, :X 8, :Y 9}]
  (get-xy 1)
  ;; => #:LOCATIONS{:X 8, :Y 9}
  )
```

Note that `sql/query` returns a vector  of maps. Each map
entry's key is a column name (as a Clojure keyword), and its value is
the value for that column.

You can try the code out in the `comment` form by evaluating each expression
in it, and you should see the same results as the inline comments show.

You can also try those calls yourself in a standalone REPL,
if you like:

```clojure
clj
Clojure 1.11.4
user=> (require 'my-webapp.db)
nil
;; you must require a namespace before you go into it:
user=> (in-ns 'my-webapp.db)
#object[clojure.lang.Namespace 0x707865bd "my-webapp.db"]
;; sql/query returns a vector:
my-webapp.db=> (sql/query db-spec
                 ["select x, y from locations where id = ?" 1])
[#:LOCATIONS{:X 8, :Y 9}]
;; the get-xy function only returns a single hash map:
my-webapp.db=> (get-xy 1)
#:LOCATIONS{:X 8, :Y 9}
my-webapp.db=>
```

> Note: H2 uses UPPERCASE for its table and column names which looks a little ugly in Clojure. Most other databases will use lowercase for table and column names so you would get results like `#:locations{:x 8, :y 9}` so if you decide to change databases later on, as you evolve this web application, remember to change the case of keys in the `views.clj` file you'll create next.

## Create your Views

Next, we will create the views, which generate our HTML pages.

Create a `src/my_webapp/views.clj` file and make it look like:

```clojure
;; src/my_webapp/views.clj
(ns my-webapp.views
  (:require [hiccup.page :as page]
            [my-webapp.db :as db]
            [ring.util.anti-forgery :as util]))

(defn gen-page-head
  [title]
  [:head
   [:title (str "Locations: " title)]
   (page/include-css "/css/styles.css")])

(def header-links
  [:div#header-links
   "[ "
   [:a {:href "/"} "Home"]
   " | "
   [:a {:href "/add-location"} "Add a Location"]
   " | "
   [:a {:href "/all-locations"} "View All Locations"]
   " ]"])

(defn home-page
  []
  (page/html5
   (gen-page-head "Home")
   header-links
   [:h1 "Home"]
   [:p "Webapp to store and display some 2D (x,y) locations."]))

(defn add-location-page
  []
  (page/html5
   (gen-page-head "Add a Location")
   header-links
   [:h1 "Add a Location"]
   [:form {:action "/add-location" :method "POST"}
    (util/anti-forgery-field) ; prevents cross-site scripting attacks
    [:p "x value: " [:input {:type "text" :name "x"}]]
    [:p "y value: " [:input {:type "text" :name "y"}]]
    [:p [:input {:type "submit" :value "submit location"}]]]))

(defn add-location-results-page
  [{:keys [x y]}]
  (let [{id :LOCATIONS/ID} (db/add-location-to-db x y)]
    (page/html5
     (gen-page-head "Added a Location")
     header-links
     [:h1 "Added a Location"]
     [:p "Added [" x ", " y "] (id: " id ") to the db. "
      [:a {:href (str "/location/" id)} "See for yourself"]
      "."])))

(defn location-page
  [loc-id]
  (let [{x :LOCATIONS/X y :LOCATIONS/Y} (db/get-xy loc-id)]
    (page/html5
     (gen-page-head (str "Location " loc-id))
     header-links
     [:h1 "A Single Location"]
     [:p "id: " loc-id]
     [:p "x: " x]
     [:p "y: " y])))

(defn all-locations-page
  []
  (let [all-locs (db/get-all-locations)]
    (page/html5
     (gen-page-head "All Locations in the db")
     header-links
     [:h1 "All Locations"]
     [:table
      [:tr [:th "id"] [:th "x"] [:th "y"]]
      (for [loc all-locs]
        [:tr
         [:td (:LOCATIONS/ID loc)]
         [:td (:LOCATIONS/X loc)]
         [:td (:LOCATIONS/Y loc)]])])))
```

These functions generate all the HTML pages needed by our application.

Each of the functions with names ending in "-page"
(which will be the ones being called from `handler.clj` in the next section)
is returning just a string consisting of HTML markup.
Compojure will take care of placing that into a response
hashmap for us.

We use the `{sym :key}` form of destructuring in several functions to
give local symbol names to the values associated with the database table/column keys.

## Set up your routes

Finally, we're going to add the extra routes we need into the main file
of our application, so that they call our new view functions.

In the basic `src/my_webapp/handler.clj` file you've created, we
specify our webapp's *routes* inside the `defroutes` macro. That is,
we assign a function to handle each of the url paths we'd like to
support, and then at the end provide a "not found" page for any other
url paths.

Make your `handler.clj` file look like this:

```clojure
;; src/my_webapp/handler.clj
(ns my-webapp.handler
  (:require [compojure.core :refer [defroutes GET POST]] ; add POST here
            [compojure.route :as route]
            [my-webapp.views :as views] ; add this require
            [ring.adapter.jetty :as jetty]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]))

(defroutes app-routes ; replace the previous app-routes with this
  (GET "/"
    []
    (views/home-page))
  (GET "/add-location"
    []
    (views/add-location-page))
  (POST "/add-location"
    {params :params}
    (views/add-location-results-page params))
  (GET "/location/:loc-id"
    [loc-id]
    (views/location-page loc-id))
  (GET "/all-locations"
    []
    (views/all-locations-page))
  (route/resources "/")
  (route/not-found "Not Found"))

(def app
  (wrap-defaults #'app-routes site-defaults))

(defn -main []
  (jetty/run-jetty #'app {:port 3000}))
```

Each of those expressions in `defroutes` like `(GET ...)` or `(POST ...)` are
so-called "routes". They each evaluate to a function that
takes a Ring request hashmap and returns a response hashmap. Your
`views/foo` function's job is to return that response hashmap, but note
that Compojure is kind enough to make a suitable response map out of
any HTML you return.

Incidentally, note the special destructuring that Compojure does for
you in each of those routes. It can pull out url query (and body)
parameters, as well as pieces of the url path requested, and hand them
to your views functions. Read more about that at [Compojure
destructuring](https://github.com/weavejester/compojure/wiki/Destructuring-Syntax).





## Run your webapp during development

### Running from the command-line

You can run your webapp any time via `clojure -M -m my-webapp.handler` as
shown above. Once it is running, visit http://localhost:3000 in your
browser.

You should be able to stop the webapp by
hitting `ctrl-c` (`ctrl-z` on Windows).

> Note: changes made to your files while the webapp is running from the command-line will not be reflected until you restart the webapp!

### Running interactively (in the REPL)

You can also run your webapp interactively, i.e., in the REPL, which allows
for changing functions _while your webapp is running_ and seeing those changes
immediately.

Add the following `comment` form after the `-main` function:

```clojure
(comment
  ;; evaluate this def form to start the webapp via the REPL:
  ;; :join? false runs the web server in the background!
  (def server (jetty/run-jetty #'app {:port 3000 :join? false}))
  ;; evaluate this form to stop the webapp via the the REPL:
  (.stop server)
  )
```


## Deploy your webapp

For the final step, we're going to build an "uberjar". This is a file that
contains your code plus the Clojure runtime plus all the libraries your
code depends on: it's a single, self-contained file that can be executed
by `java` alone and can easily be deployed to servers or services to put
your application on the web.

In order to produce this `.jar` file, we will rely on the official
`tools.build` library, and add a `build.clj` file.

All of the steps will be shown here but you can read the
[`tools.build` guide](https://clojure.org/guides/tools_build) for more details.

To make your webapp suitable for deployment, make the following
changes:


### Changes in deps.edn

In your `dep.edn` file add the following, after the `:deps` hash map:

```clojure
 :aliases
 {;; Run with clj -T:build function-in-build
  :build {:deps {io.github.clojure/tools.build {:mvn/version "0.10.4"}}
          :ns-default build}}
```

The whole `deps.edn` file should now look like this:

```clojure
{:paths ["src" "resources"]
 :deps {;; basic Ring and web server:
        ring/ring-core {:mvn/version "1.12.2"}
        ring/ring-jetty-adapter {:mvn/version "1.12.2"}
        ;; logging, required by jetty:
        org.slf4j/slf4j-simple {:mvn/version "2.0.13"}

        ;; routing:
        compojure/compojure {:mvn/version "1.7.1"}

        ;; convenient package of "default" middleware:
        ring/ring-defaults {:mvn/version "0.5.0"}

        ;; to generate HTML:
        hiccup/hiccup {:mvn/version "1.0.5"}

        ;; for the database:
        com.github.seancorfield/next.jdbc {:mvn/version "1.3.939"}
        com.h2database/h2 {:mvn/version "2.2.224"}}
 :aliases
 {;; Run with clj -T:build function-in-build
  :build {:deps {io.github.clojure/tools.build {:mvn/version "0.10.4"}}
          :ns-default build}}}
```

### Add a build.clj file

The `tools.build` library is intended to be used with a `build.clj` script
which typically lives in the root of your project and is invoked via the
`:build` alias in your project. It is a Clojure namespace, containing any number
of functions that you can invoke using `clojure -T:build` and the function name.

The `:ns-default` key in the `:build` alias is typically set to `build` so
that you can say `clojure -T:build foo` and the CLI will treat that as an
invocation of the function `build/foo`. All such functions take a single
argument, which is a hash map of arguments supplied on the command-line
using Clojure-style syntax:

```clojure
clojure -T:build foo :bar 42
;; invokes (build/foo {:bar 42})
```

For the purposes of this web application project, you want a single function
that can build the "uberjar" you need. This is typically called `uber` so
here is the `build.clj` file you need to add, alongside `deps.edn` at the
top-level of your project:

```clojure
(ns build
  (:require [clojure.tools.build.api :as b]))

;; the main namespace in your application:
(def main-ns 'my-webapp.handler)
;; where to compile your application:
(def class-dir "target/classes")
;; where to create the uberjar file:
(def uber-file "target/my-webapp.jar")

;; "basis" is a description of your project, as data, that includes
;; details about the paths and dependencies (libraries) it uses:
(def basis (b/create-basis {:project "deps.edn"}))

(defn clean [_]
  (b/delete {:path "target"}))

(defn uber [_]
  (clean nil)
  (b/copy-dir {:src-dirs ["src" "resources"]
               :target-dir class-dir})
  (b/compile-clj {:basis basis
                  :src-dirs ["src"]
                  :class-dir class-dir})
  (b/uber {:class-dir class-dir
           :uber-file uber-file
           :basis basis
           :main main-ns}))
```

### Changes in handler.clj

In order to make it easier to invoke your application as an uberjar,
we are going to make a couple of small changes.

First, we're going to add `(:gen-class)` to the end of the `ns` form at the
top of the file so it looks like this:

```clojure
(ns my-webapp.handler
  (:require [compojure.core :refer [defroutes GET POST]] ; add POST here
            [compojure.route :as route]
            [my-webapp.views :as views] ; add this require
            [ring.adapter.jetty :as jetty]
            [ring.middleware.defaults :refer [site-defaults wrap-defaults]])
  (:gen-class))
```

This tells Clojure to generate a JVM-compatible class for your main namespace
so that the `-main` function can be invoked directly from Java instead of
going through `clojure.main` as we've done so far with the Clojure CLI
and the `-M -m my-webapp.handler` options.

Second, we're going to update the `-main` function so that you can specify
the port on which to run the web application, so it isn't fixed to be `3000`.
We'll allow the port to specified either on the command-line, or as an
environment variable, else default to a specific value (`3000`).

```clojure
(defn -main [& [port]]
  ;; command-line arguments and environment variables are always
  ;; strings so we need to call parse-long on the result; which
  ;; means that if neither are specified and we provide the default,
  ;; then it has to be a string as well:
  (let [port (parse-long (or port
                             (System/getenv "PORT")
                             "3000"))]
    (jetty/run-jetty #'app {:port port})))
```

### Build and Run it

Now create an uberjar of your webapp:

```
clojure -T:build uber
```

> Note: the first time you run this command it will download all the libraries it needs for `tools.build` (quite a few libraries)!

And now you can run it directly:

    java -jar target/my-webapp.jar 8080

(or on whatever port number you wish). If you run the JAR file from another
folder, remember to copy the `my-db.mv.db` file to that folder!
(or else it will create a new database file in that folder)

You could also run it like this (on macOS/Linux):

    PORT=8000 java -jar target/my-webapp.jar



## See Also

  * To get a head start with a more "batteries-included" project
    template, see [Luminus](http://www.luminusweb.net/).


## Contributors

John Gabriele <jmg3000@gmail.com> (original author)

Ivan Kryvoruchko <gildraug@gmail.com>

Sean Corfield <sean@corfield.org>
