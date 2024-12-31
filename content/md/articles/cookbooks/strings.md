{:title "Strings"
 :layout :page :page-index 4100}

This cookbook covers working with strings in Clojure using built-in
functions, standard and contrib libraries, and parts of the JDK via
interoperability.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).


## Overview

* Strings are [plain Java
strings](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/String.html).
You can use anything which operates on them.
* Java strings are immutable, so they're convenient to use in Clojure.
* You can't add metadata to Java strings.
* Clojure supports some convenient notations:

```
    "foo"    java.lang.String
    #"\d"    java.util.regex.Pattern (in this case, one which matches a single digit)
    \f       java.lang.Character (in this case, the letter 'f')
```

* **Caveat:** Human brains and electronic computers are rather different
devices. So Java strings (sequences of [UTF-16
characters](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Character.html#unicode))
don't always map nicely to user-perceived characters. For example, a
single Unicode "code point" doesn't necessarily equal a user-perceived
character. (Like Korean Hangul Jamo, where user-perceived characters
are composed from two or three Unicode code points.) Also, a Unicode
code point may sometimes require 2 UTF-16 characters to encode it.


## Preliminaries

Some examples use
[clojure.string](https://clojure.github.io/clojure/clojure.string-api.html),
[clojure.edn](https://github.com/edn-format/edn) and
[clojure.pprint](https://clojure.github.io/clojure/clojure.pprint-api.html). We'll
assume your `ns` macro contains:

``` clojure
(:require [clojure.string :as str]
          [clojure.edn :as edn]
          [clojure.pprint :as pp])
```

or else in the repl you've loaded it:

``` clojure
(require '[clojure.string :as str])
(require '[clojure.edn :as edn])
(require '[clojure.pprint :as pp])
```


## Recipes

### Basics

``` clojure
;; Size measurements
(count "0123")      ;=> 4
(empty? "0123")     ;=> false
(empty? "")         ;=> true
(str/blank? "    ") ;=> true

;; Concatenate
(str "foo" "bar")            ;=> "foobar"
(str/join ["0" "1" "2"])     ;=> "012"
(str/join "." ["0" "1" "2"]) ;=> "0.1.2"

;; Matching using plain Java methods.
;;
;; You might prefer regexes for these. For instance, failure returns
;; -1, which you have to test for. And characters like \o are
;; instances of java.lang.Character, which you may have to convert to
;; int or String.
(.indexOf "foo" "oo")         ;=> 1
(.indexOf "foo" "x")          ;=> -1
(.lastIndexOf "foo" (int \o)) ;=> 2
```

As of Clojure 1.8, `clojure.string` has functions for both of those but they
return `nil` for no match:

``` clojure
(str/index-of "foo" "oo")    ;=> 1
(str/index-of "foo" "x")     ;=> nil
(str/last-index-of "foo" \o) ;=> 2 - can find string or character, not int
(str/last-index-of "foo" (int \o))
;; Execution error: java.lang.Integer cannot be cast to java.lang.String

;; Substring
(subs "0123" 1)       ;=> "123"
(subs "0123" 1 3)     ;=> "12"
(str/trim "  foo  ")  ;=> "foo"
(str/triml "  foo  ") ;=> "foo  "
(str/trimr "  foo  ") ;=> "  foo"

;; Multiple substrings
(seq "foo")                       ;=> (\f \o \o)
(str/split "foo/bar/quux" #"/")   ;=> ["foo" "bar" "quux"]
(str/split "foo/bar/quux" #"/" 2) ;=> ["foo" "bar/quux"]
(str/split-lines "foo
bar")                             ;=> ["foo" "bar"]

;; Case
(str/lower-case "fOo") ;=> "foo"
(str/upper-case "fOo") ;=> "FOO"
(str/capitalize "fOo") ;=> "Foo"

;; Escaping
(str/escape "foo|bar|quux" {\| "||"}) ;=> "foo||bar||quux"

;; Get byte array of given encoding.
;; (The output will likely have a different number than "3c3660".)
(.getBytes "foo" "UTF-8") ;=> #object["[B" 0x39666e42 "[B@39666e42"]

;; Making keywords
(keyword "foo")    ;=> :foo

;; Parsing numbers
(bigint "20000000000000000000000000000") ;=> 20000000000000000000000000000N
(bigdec "20000000000000000000.00000000") ;=> 20000000000000000000.00000000M
(Integer/parseInt "2")                   ;=> 2 - java.lang.Integer
(Float/parseFloat "2")                   ;=> 2.0 - java.lang.Float
(Long/parseLong "2")                     ;=> 2 - java.lang.Long
(Double/parseDouble "2")                 ;=> 2.0 - java.lang.Double
```

As of Clojure 1.11, `clojure.core` has parsing functions for numbers, Booleans,
and UUIDs:

``` clojure
(parse-long "2")                         ;=> 2 - java.lang.Long
(parse-double "2")                       ;=> 2.0 - java.lang.Double

;; Parsing edn, a subset of Clojure forms.
(edn/read-string "0xffff") ;=> 65535

;; The sledgehammer approach to reading Clojure forms.
;;
;; SECURITY WARNING: Ensure *read-eval* is false when dealing with
;; strings you don't 100% trust. Even though *read-eval* is false by
;; default since Clojure 1.5, be paranoid and set it to false right
;; before you use it, because anything could've re-bound it to true.
(binding [*read-eval* false]
  (read-string "#\"[abc]\""))
;=> #"[abc]"
```


### Parsing complex strings

#### Regexes

Regexes offer a boost in string-matching power. You can express ideas
like repetition, alternatives, etc.

[Regex
reference.](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/regex/Pattern.html)

**Groups:** Regex groups are useful, when we want to match more than
one substring. (Or refer to matches later.) In the regex `#"(group-1)
(group-2)"`, the 0th group is the whole match. The 1st group is
started by the left-most `(`, the 2nd group is started by the
second-left-most `(`, etc. You can even nest groups. You can refer to
groups later using `$0`, `$1`, etc.

**Matching**

```clojure
;; Simple matching
(re-find #"\d+" "foo 123 bar") ;=> "123"

;; What happens when a match fails.
(re-find #"\d+" "foobar") ;=> nil

;; Return only the first groups which satisfy match.
(re-matches #"(@\w+)\s([.0-9]+)%"
            "@shanley 19.8%")
;=>["@shanley 19.8%" "@shanley" "19.8"]

;; Return seq of all matching groups which occur in string.
(re-seq #"(@\w+)\s([.0-9]+)%"
        "@davidgraeber 12.3%,@shanley 19.8%")
;=> (["@davidgraeber 12.3%" "@davidgraeber" "12.3"]
;    ["@shanley 19.8%" "@shanley" "19.8"])
```

**Replacing**

We use `str/replace`. Aside from the first arg (the initial string),
the next two args are match and replacement:

```
   match / replacement can be:
     string / string
     char / char
     pattern / (string or function of match).
```

```clojure
;; In the replacement string, $0, $1, etc refer to matched groups.
(str/replace "@davidgraeber 12.3%,@shanley 19.8%"
             #"(@\S+)\s([.0-9]+)%"
             "$2 ($1)")
;=> "12.3 (@davidgraeber),19.8 (@shanley)"

;; Using a function to replace text gives us power.
(println
  (str/replace "@davidgraeber 12.3%,@shanley 19.8%"
               #"(@\w+)\s([.0-9]+)%,?"
               (fn [[_ person percent]]
                   (let [points (-> percent Float/parseFloat (* 100) Math/round)]
                     (str person "'s followers grew " points " points.\n")))))
;print=> @davidgraeber's followers grew 1230 points.
;print=> @shanley's followers grew 1980 points.
;print=>
```


#### Context-free grammars

Context-free grammars offer yet another boost in expressive matching
power, compared to regexes. You can express ideas like nesting.

We'll use [Instaparse](https://github.com/Engelberg/instaparse) on
[JSON's grammar](https://www.json.org/).  (This example isn't seriously
tested nor a featureful parser. Use
[data.json](https://github.com/clojure/data.json) instead.)

``` clojure
;; Your project.clj should contain this (you may need to restart your JVM):
;;   :dependencies [[instaparse "1.4.12"]]
;;
;;  We'll assume your ns macro contains:
;;   (:require [instaparse.core :as insta])
;; or else in the repl you've loaded it:
;;   (require '[instaparse.core :as insta])

(def barely-tested-json-parser
  (insta/parser
   "object     = <'{'> <w*> (members <w*>)* <'}'>
    <members>  = pair (<w*> <','> <w*> members)*
    <pair>     = string <w*> <':'> <w*> value
    <value>    = string | number | object | array | 'true' | 'false' | 'null'
    array      = <'['> elements* <']'>
    <elements> = value <w*> (<','> <w*> elements)*
    number     = int frac? exp?
    <int>      = '-'? digits
    <frac>     = '.' digits
    <exp>      = e digits
    <e>        = ('e' | 'E') (<'+'> | '-')?
    <digits>   = #'[0-9]+'
    (* First sketched state machine; then it was easier to figure out
       regex syntax and all the maddening escape-backslashes. *)
    string     = <'\\\"'> #'([^\"\\\\]|\\\\.)*' <'\\\"'>
    <w>        = #'\\s+'"))

(barely-tested-json-parser "{\"foo\": {\"bar\": 99.9e-9, \"quux\": [1, 2, -3]}}")
;=> [:object
;     [:string "foo"]
;     [:object
;       [:string "bar"]
;       [:number "99" "." "9" "e" "-" "9"]
;       [:string "quux"]
;       [:array [:number "1"] [:number "2"] [:number "-" "3"]]]]

;; That last output is a bit verbose. Let's process it further.
(->> (barely-tested-json-parser "{\"foo\": {\"bar\": 99.9e-9, \"quux\": [1, 2, -3]}}")
     (insta/transform {:object hash-map
                       :string str
                       :array vector
                       :number (comp edn/read-string str)}))
;=> {"foo" {"quux" [1 2 -3], "bar" 9.99E-8}}


;; Now we can appreciate what those <angle-brackets> were all about.
;;
;; When to the right of the grammar's =, it totally hides the enclosed
;; thing in the output. For example, we don't care about whitespace,
;; so we hide it with <w*>.
;;
;; When to the left of the grammar's =, it merely prevents a level of
;; nesting in the output. For example, "members" is a rather
;; artificial entity, so we prevent a pointless level of nesting with
;; <members>.
```


### Building complex strings

#### Redirecting streams

`with-out-str` provides a simple way to build strings. It redirects
standard output (`*out*`) to a fresh `StringWriter`, then returns the
resulting string. So you can use functions like `print`, *even in
nested functions*, and get the resulting string at the end.

``` clojure
(let [shrimp-varieties ["shrimp-kabobs" "shrimp creole" "shrimp gumbo"]]
  (with-out-str
    (print "We have ")
    (let [names (str/join ", " shrimp-varieties)]
      (print names))
    (print "...")))
;=> "We have shrimp-kabobs, shrimp creole, shrimp gumbo..."
```

#### Format strings

Java's templating mini-language helps you build many strings
conveniently. [Reference.](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Formatter.html)

``` clojure
;; %s is most commonly used to print args. Escape %'s with %%.
(format "%s enjoyed %s%%." "Mozambique" 19.8) ;=> "Mozambique enjoyed 19.8%."

;; The 1$ prefix allows you to keep referring to the first arg.
(format "%1$tY-%1$tm-%1$td" #inst"2000-01-02T00:00:00") ;=> "2000-01-02"

;; Again, 1$, 2$, etc prefixes let us refer to args in arbitrary orders.
(format "New year: %2$tY. Old year: %1$tY"
        #inst"2000-01-02T00:00:00"
        #inst"3111-12-31T00:00:00")
;=> "New year: 3111. Old year: 2000"
```


#### CL-Format

`cl-format` is a port of Common Lisp's notorious, powerful string
formatting mini-language. For example, you can build strings from
sequences. (As well as oddities like print numbers in English or two
varieties of Roman numerals.) However, it's weaker than plain `format`
with printing dates and referring to args in arbitrary order.

Remember that `cl-format` represents a (potentially unreadable)
language which your audience didn't sign up to learn. If you're the
sort of person who likes it, try to only use it in sweetspots where it
provides clarity for little complexity.

[Tutorial](https://www.gigamonkeys.com/book/a-few-format-recipes.html)
in Practical Common
Lisp. [Reference](http://www.lispworks.com/documentation/HyperSpec/Body/22_c.htm)
in Common Lisp's Hyperspec.

``` clojure
;; The first param prints to *out* if true. To string if false.
;; To a stream if it's a stream.
(pp/cl-format true "~{~{~a had ~s percentage point~:p.~}~^~%~}"
              {"@davidgraeber" 12.3
               "@shanley" 19.8
               "@tjgabbour" 1})
;print=> @davidgraeber had 12.3 percentage points.
;print=> @tjgabbour had 1 percentage point.
;print=> @shanley had 19.8 percentage points.

(def format-string "~{~#[~;~a~;~a and ~a~:;~@{~a~#[~;, and ~:;, ~]~}~]~}")
(pp/cl-format nil format-string [])
;=> ""
(pp/cl-format nil format-string ["@shanley"])
;=> "@shanley"
(pp/cl-format nil format-string ["@shanley", "@davidgraeber"])
;=> "@shanley and @davidgraeber"
(pp/cl-format nil format-string ["@shanley", "@davidgraeber", "@sarahkendzior"])
;=> "@shanley, @davidgraeber, and @sarahkendzior"
```

## Contributors

Tj Gabbour <tjg@simplevalue.de>, 2013 (original author)
