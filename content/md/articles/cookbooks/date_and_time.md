{:title "Date and Time"
 :layout :page :page-index 4300}

This cookbook covers working with Java's `java.time` package in two styles, the
first with interop and the second using libraries.

This guide covers Clojure 1.11.1 and Java 8 or later.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution
3.0 Unported License</a> (including images & stylesheets). The source is
available [on Github](https://github.com/clojure-doc/clojure-doc.github.io).

# Introduction

This cookbook does not assume a background in Java, if you have such a
background the interop section might be of interest.

This cookbook will be useful if you got your Clojure environment setup, know
some of the basics and are looking to work with time and dates in Clojure.

This guide aims to cover date and time in the JVM and JS domains.  The guide
currently covers only JVM.

The scope of this cookbook covers basic operations using the two styles.

This cookbook will cover working with `java.time` as `java.util.Date` is legacy[^1].

## Overview

The representation of date and time is dependent upon the host, for example in the JVM

- Dates are a `java.util.LocalDate` object.
- Time is a a `java.util.LocalTime` object.
- Clojure can represent these objects as a `java.util.LocalDate`, `java.util.LocalTime`
  and `java.util.LocalDateTime` respectively.
- The `#inst` is a [tagged
  literal](https://clojure.org/guides/weird_characters#tagged_literals) is used
  to represent a `java.util.Date` object.

While in JavaScript:
TBD


## Libraries

* [clojure.java-time](https://github.com/dm3/clojure.java-time)
  > A Clojure wrapper for Java 8 Date-Time API.
* [cljc.java-time](https://github.com/henryw374/cljc.java-time)
  > A Clojure(Script) library which mirrors the java.time api through kebab-case-named vars.
* [tick](https://github.com/juxt/tick)
  > A Clojure(Script) & babashka library for dealing with time. Intended as a replacement for clj-time.

# Preliminaries

The examples below assume the following `deps.edn`
``` clojure
{:paths ["src"]
 :deps {org.clojure/clojure {:mvn/version "1.11.1"}
        clojure.java-time/clojure.java-time {:mvn/version "1.3.0"}
        com.widdindustries/cljc.java-time {:mvn/version "0.1.21"}}}
```

# Recipes

## `clojure.java-time`

### Basics

For the people coming from a non-Java background, we are creating an *instance*
of the `java.time.LocalDate`, `java.time.LocalTime` and
`java.time.LocalDateTime` classes respectively, that's what the `#object` is for.


``` clojure
(require '[java-time.api :as jt])
;; What's the current day?
(jt/local-date)
;; => #object[java.time.LocalDate 0x28cb30b8 "2023-11-01"]
;; You may see a different result.

;; What's the current time?
(jt/local-time)
;; => #object[java.time.LocalTime 0x7f536ee5 "23:53:32.896427602"]
;; You may see a different result.

;; What's the date and time of today?
(jt/local-date-time)
;; => #object[java.time.LocalDateTime 0x3ac70fac "2023-11-01T23:54:14.020607313"]
;; You may see a different result.

;; Does date1 come before date2?
(let [date1 (jt/local-date "2023-01-01")
      date2 (jt/local-date "2023-10-01")]
  (jt/before? date1
              date2))
;; => true

;; Add N days to a date
(jt/plus (jt/local-date "2023-11-01")
         (jt/days 10))
;; => #object[java.time.LocalDate 0x165637c5 "2023-11-13"]

;; What's the date a year before?
(jt/minus (jt/local-date "2023-11-03") (jt/years 1))
;; => #object[java.time.LocalDate 0x6e927fd0 "2022-11-03"]

;; Difference in days between a date and a year after
(jt/time-between :days
                 (jt/local-date "2023-11-03")
                 (jt/plus (jt/local-date "2023-11-03")
                          (jt/years 1)))
;; => 366

;; What day of the week was it?
(jt/day-of-week (jt/minus (jt/local-date) (jt/years 1)))
;; => #object[java.time.DayOfWeek 0x10fb6e5f "THURSDAY"]

;; How to format the output in a specific way?
(jt/format :iso-date (jt/local-date "2023-11-01"))
;; => "2023-11-01"

(jt/format "yyyy/MM/dd" (jt/local-date "2023-11-01"))
;; => "2023/11/01"

;; To parse the date we just formatted
(jt/local-date "yyyy/MM/dd" "2023/11/01")

;; This opens up the door to creating your own parsers.
(defn ydm
  "A parses similar to ydm() from the R package lubridate."
  [s]
  (jt/local-date "yyyyddMM" s))
;; => #'user/ydm

(ydm "20170108")
;; => #object[java.time.LocalDate 0x4851aa55 "2017-08-01"]
```

For more formatting patterns check out the
[DateTimeFormatter](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html)
class, the table **Predefined Formatters** is where the `:iso-date` came from
although note it is written as `ISO_DATE` in the **Formatted** column.

More basic recipes can be read in the
[README](https://dm3.github.io/clojure.java-time/README.html) for
`clojure.java-time`.

## Date and Time via interop

You can use interop by either using the full package name and the class or by
importing the class.

Using the package and class name to create an instance of `LocalDate`:
``` clojure
(java.time.LocalDate/now) ; => #object[java.time.LocalDate 0x4d98485b "2023-11-01"]
```

Using the import and the class name to create an instance of `LocalDate`:
``` clojure
(import (java.time LocalDate LocalTime LocalDateTime))

;; What's the current day?
(LocalDate/now)
;; => #object[java.time.LocalDate 0x28cb30b8 "2023-11-01"]
;; You may see a different result.

;; What's the current time?
(LocalTime/now)
;; => #object[java.time.LocalTime 0x4dc69d04 "12:53:09.791974265"]
;; You may see a different result.

;; What's the date and time of today?
(LocalDateTime/now)
;; => #object[java.time.LocalDateTime 0x6d7119a7 "2023-11-03T12:53:36.765946815"]
;; You may see a different result.

;; Does date1 come before date2?
(let [date1 (LocalDate/parse "2023-01-01")
      date2 (LocalDate/parse "2023-10-01")]
  (.isBefore date1 date2))
;; => true

;; Add N days to a date
(.plus (LocalDate/now) (java.time.Period/ofDays 10))
;; => #object[java.time.LocalDate 0x507f3b0d "2023-11-13"]
;; Or
(.plusDays (LocalDate/now) 10)
;; => #object[java.time.LocalDate 0x439c6250 "2023-11-13"]

;; What's the date a year before?
(.minus (LocalDate/parse "2023-11-03") (java.time.Period/ofYears 1))
;; => #object[java.time.LocalDate 0x37380cf2 "2022-11-03"]

;; Difference in days between a date and a year after
(.between (java.time.temporal.ChronoUnit/DAYS)
          (LocalDate/parse "2023-11-03")
          (.plusYears (LocalDate/parse "2023-11-03")
                      1))
;; => 366

;; What day of the week was it?
(.getDayOfWeek (LocalDate/parse "2023-11-03"))
;; => #object[java.time.DayOfWeek 0x7823658a "FRIDAY"]

;; How to format the output in a specific way?
(.format (LocalDate/parse "2023-11-01")
         (java.time.format.DateTimeFormatter/ofPattern "yyyy/MM/dd"))
;; => "2023/11/01"

;; To parse the date we just formatted
(LocalDate/parse "2023/11/01"
                 (java.time.format.DateTimeFormatter/ofPattern "yyyy/MM/dd"))
;; => #object[java.time.LocalDate 0xa349bd0 "2023-11-01"]

;; This opens up the door to creating your own parsers.
(defn ydm
  "A parses similar to ydm() from the R package lubridate."
  [s]
  (LocalDate/parse s
                   (java.time.format.DateTimeFormatter/ofPattern "yyyyddMM")))
;; => #'user/ydm

(ydm "20170108")
;; => #object[java.time.LocalDate 0x3135d642 "2017-08-01"]
```

## `cljc.java-time`
According to the [How it
works](https://github.com/henryw374/cljc.java-time#how-it-works) section of
`cljc.java-time` each class in `java.time` has a corresponding Clojure
namespace.  This means that we need to require each class as a namespace.

``` clojure
(require '[cljc.java-time local-date local-time local-date-time period temporal])
(require '[cljc.java-time.temporal.chrono-unit])
(require '[cljc.java-time.format.date-time-formatter])

;; What's the current day?
(cljc.java-time.local-date/now)
;; => #object[java.time.LocalDate 0x7f314585 "2023-11-06"]
;; You may see a different result.

;; What's the current time?
(cljc.java-time.local-time/now)
;; => #object[java.time.LocalTime 0x101358e2 "21:39:08.521579413"]
;; You may see a different result.

;; What's the date and time of today?
(cljc.java-time.local-date-time/now)
;; => #object[java.time.LocalDateTime 0x56ba51c9 "2023-11-06T21:40:52.985876111"]
;; You may see a different result.

;; Does date1 come before date2?
(let [date1 (cljc.java-time.local-date/parse "2023-01-01")
      date2 (cljc.java-time.local-date/parse "2023-10-01")]
  (cljc.java-time.local-date/is-before date1 date2))
;; => true

;; Add N days to a date
(cljc.java-time.local-date/plus (cljc.java-time.local-date/parse "2023-11-03")
                                (cljc.java-time.period/of-days 10))
;; => #object[java.time.LocalDate 0x7c03648a "2023-11-13"]
;; Or
(cljc.java-time.local-date/plus-days (cljc.java-time.local-date/parse "2023-11-03")
                                     10)
;; => #object[java.time.LocalDate 0x6ef62d95 "2023-11-13"]

;; What's the date a year before?
(cljc.java-time.local-date/minus (cljc.java-time.local-date/parse "2023-11-03")
                                 (cljc.java-time.period/of-years 1))
;; => #object[java.time.LocalDate 0x24023790 "2022-11-03"]

;; Difference in days between a date and a year after
(cljc.java-time.temporal.chrono-unit/between cljc.java-time.temporal.chrono-unit/days
                                             (cljc.java-time.local-date/parse "2023-11-03")
                                             (cljc.java-time.local-date/plus-years
                                               (cljc.java-time.local-date/parse "2023-11-03")
                                               1))
;; => 366

;; What day of the week was it?
(cljc.java-time.local-date/get-day-of-week (cljc.java-time.local-date/parse "2023-11-03"))
;; => #object[java.time.DayOfWeek 0x38e22a90 "FRIDAY"]

;; How to format the output in a specific way?
(cljc.java-time.local-date/format (cljc.java-time.local-date/parse "2023-11-01")
                                  (cljc.java-time.format.date-time-formatter/of-pattern "yyyy/MM/dd"))
;; => "2023/11/01"

;; To parse the date we just formatted
(cljc.java-time.local-date/parse "2023/11/01"
                                 (cljc.java-time.format.date-time-formatter/of-pattern "yyyy/MM/dd"))
;; => #object[java.time.LocalDate 0x62756039 "2023-11-01"]

;; This opens up the door to creating your own parsers.
(defn ydm
  "A parses similar to ydm() from the R package lubridate."
  [s]
  (cljc.java-time.local-date/parse s
                                   (cljc.java-time.format.date-time-formatter/of-pattern "yyyyddMM")))
;; => #'user/ydm

(ydm "20170108")
;; #object[java.time.LocalDate 0x194dcb8 "2017-08-01"]
```

# Examples

## TBD

# See also

- [Overview of Date and Time in Java](https://docs.oracle.com/javase/tutorial/datetime/iso/overview.html)


[^1]: [Legacy Date-Time Code (docs.oracle.com)](https://docs.oracle.com/javase/tutorial/datetime/iso/legacy.html).
