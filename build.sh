#!/bin/sh

clojure -M:build && ( cd public && git add . && git commit -m "regenerate site" && git push )
