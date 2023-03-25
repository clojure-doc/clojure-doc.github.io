{:title "Basic Web Development"
 :page-index 1500
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

This guide uses Clojure 1.11.1, as well as current versions of the
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
    spec](https://github.com/ring-clojure/ring/blob/master/SPEC)
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
        ring/ring-core {:mvn/version "1.9.6"}
        ring/ring-jetty-adapter {:mvn/version "1.9.6"}

        ;; routing:
        compojure/compojure {:mvn/version "1.7.0"}

        ;; convenient package of "default" middleware:
        ring/ring-defaults {:mvn/version "0.3.4"}

        ;; to generate HTML:
        hiccup/hiccup {:mvn/version "1.0.5"}

        ;; for the database:
        com.github.seancorfield/next.jdbc {:mvn/version "1.3.862"}
        com.h2database/h2 {:mvn/version "2.1.214"}}}
```

Now we'll create the first version of our source file:

```clojure
;; this file is: src/my_app/handler.clj
(ns my-webapp.handler
  (:require [compojure.core :refer [defroutes GET]]
            [compojure.route :as route]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]))

(defroutes app-routes
  (GET "/" [] "Hello World")
  (route/not-found "Not Found"))

(def app
  (wrap-defaults #'app-routes site-defaults))

(defn -main []
  (jetty/run-jetty #'app {:port 3000}))
```

> Note: the directory has an underscore in it (`my_webapp`) but the namespace has a hyphen in it (`my-webapp`). This is important in Clojure: we use lowercase names with hyphens to separate "words" -- often called kebab-case -- but the corresponding directory and filenames should be lowercase with underscores to separate "words" -- often called snake-case. This is due to how Clojure maps code onto names that are acceptable to the underlying JVM ecosystem.

At this point you can run this very basic web application from the command-line:

```bash
clojure -M -m my-webapp.handler
```

This says we want to run Clojure's main entry point (`-M`) and then `-m my-webapp.handler`
tells Clojure that we want it to run the `-main` function in that namespace.

It will output something like this (and then "hang" while the web server is running):

```
2023-03-24 14:03:21.305:INFO::main: Logging initialized @2337ms to org.eclipse.jetty.util.log.StdErrLog
2023-03-24 14:03:21.752:INFO:oejs.Server:main: jetty-9.4.48.v20220622; built: 2022-06-21T20:42:25.880Z; git: 6b67c5719d1f4371b33655ff2d047d24e171e49a; jvm 19.0.2+7
2023-03-24 14:03:21.783:INFO:oejs.AbstractConnector:main: Started ServerConnector@43201f84{HTTP/1.1, (http/1.1)}{0.0.0.0:3000}
2023-03-24 14:03:21.783:INFO:oejs.Server:main: Started @2815ms
```

> Note: you can stop this program running by pressing `^C` (control-c) on macOS or Linux, or by pressing `^Z` (control-z) on Windows.

The only relevant line in that output is `Started ServerConnector` where it
shows the host and port it is running on -- `0.0.0.0:3000` -- so you should
be able to output a web browser and go to http://localhost:3000 and you should
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

```bash
mkdir -p resources/public/css
touch resources/public/css/styles.css
```

and put into that file something like:

```css
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

Execute the following code to create a new my-webapp.h2.db database file in db
subdirectory of your project, create a table we'll use for our webapp, and add
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

> Note: the `#:namespace{:key value}` notation is shorthand for `{:namespace/key value}` and is something you'll see a lot in Clojure. Namespace-qualified keys provide additional context: in the first case above `:next.jdbc/update-count` is produced by `next.jdbc` itself whereas `:LOCATIONS.ID` indicates the table and column name of the auto-increment key from the database.

For more about how to use the database functions, see the
[Getting Started with next.jdbc](https://cljdoc.org/d/com.github.seancorfield/next.jdbc/1.3.862/doc/getting-started).



## Create some db access functions

We're going to work bottom-up, so that our code is always in a state
where we can evaluate it and try it out via the REPL (hopefully, via
your REPL-connected editor).

Create a `src/my_webapp/db.clj` file and make it look like:

```clojure
;; src/my_app/db.clj
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

You can try the code out in the `comment` form by evaluating the expressions
in -- and you should see the same results as the inline comments show.

You can also try those calls yourself in a standalone REPL,
if you like:

```clojure
clj
Clojure 1.11.1
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

## Create your Views

Next, we will create the views -- that generate our HTML pages.

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
;; src/my_app/handler.clj
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

You can run your webapp any time via `clojure -M -m my-webapp.handler` as
shown above. Once it is running, visit http://localhost:3000 in your
browser.

You should be able to stop the webapp by
hitting `ctrl-c`.



## Deploy your webapp

**The rest of this page needs updating to use `tools.build` etc.**

To make your webapp suitable for deployment, make the following
changes:


### Changes in project.clj

In your `project.clj` file:

  * add to `:dependencies` (the version should generally match `compojure`s version):

    ```clojure
    [ring/ring-jetty-adapter "1.5.1"] ; e.g., for compojure version 1.5.1
    ```

  * and also add `:main my-webapp.handler`


### Changes in handler.clj

In `src/my_webapp/handler.clj`:

  * in your `ns` macro:
      * add `[ring.adapter.jetty :as jetty]` to the `:require`, and
      * add `(:gen-class)` to the end

The `ns` form should now look like this:

```clojure
(ns my-webapp.handler
  (:require [my-webapp.views :as views]
            [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.adapter.jetty :as jetty] ; add this require
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]])
  (:gen-class)) ; and add this gen-class
```

  * and at the bottom, add the following `-main` function:

    ~~~clojure
    (defn -main
      [& [port]]
      (let [port (Integer. (or port
                               (System/getenv "PORT")
                               5000))]
        (jetty/run-jetty #'app {:port  port
                                :join? false})))
    ~~~


### Build and Run it

Now create an uberjar of your webapp:

```
lein uberjar
```

And now you can run it directly:

    java -jar target/my-webapp-0.1.0-standalone.jar 8080

(or on whatever port number you wish). If you run the JAR file from another
folder, remember to copy the `my-webapp.mv.db` file to that folder!

_NOTE: if you did not remove "-SNAPSHOT" from the project's version string
when you first edited `project.clj`, then the JAR file will have `-SNAPSHOT`
in its name._



## See Also

  * To get a head start with a more "batteries-included" project
    template, see [Luminus](http://www.luminusweb.net/).


## Contributors

John Gabriele <jmg3000@gmail.com> (original author)

Ivan Kryvoruchko <gildraug@gmail.com>

Sean Corfield <sean@corfield.org>
