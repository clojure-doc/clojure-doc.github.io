# CDS: A Clojure Doc Site

An assorted collection of tutorials, guides, and other documentation
(by various authors) for the Clojure programming language and its
ecosystem. [Read the guides online](https://clojure-doc.org).

> Note: due to loss of access to the original infrastructure hosting http://clojure-doc.org, this is a reboot of that site using [Cryogen](https://cryogenweb.org/) and hosted as a GitHub organization website. _Sean Corfield, November 14th, 2021._

> **Pull Requests should be made against the `source` branch, with changes to the Markdown files. The HTML on the `main` branch is auto-generated using Cryogen.**

> *News: funding for extensive work on CDS in 2023 is generally provided by [Clojurists Together](https://www.clojuriststogether.org/news/clojurists-together-2023-long-term-funding-announcement/) as part of their Long-Term Funding for [Sean Corfield](https://github.com/seancorfield).*

## Goals

The goal is to produce quality technical documentation with limited
duplication between guides.

What's *not* here:

  * Cheatsheets. Those can be found at
    [clojure.org/cheatsheet](https://clojure.org/api/cheatsheet), which is derived from
    [jafingerhut.github.io](https://jafingerhut.github.io/),
    and [cljs.info/cheatsheet](https://cljs.info/cheatsheet/), which is derived from
    [oakmac/cljs-cheatsheet](https://github.com/oakmac/cljs-cheatsheet/).
  * API reference docs. The [official API docs](https://clojure.org/api/api)
    also have a community-maintained version with examples
    at [ClojureDocs](https://clojuredocs.org/).

CDS is not concerned with providing the API reference; only tutorials, guides, and
linking to other relevant resources.

## Structure

CDS is structured as a number of guides. They broadly fall into 4 categories:

  * Tutorials
  * Language Guides
  * Ecosystem & Tools
  * Cookbooks


### Tutorials

These guides are intended for complete newcomers and should include a lot of hand holding. They don't assume any
previous familiarity with Clojure, the JVM, the JVM tool ecosystem, functional programming, immutability, and so on.

Target audience: newcomers to the language.


### Language guides

These guides are more in-depth, focused on various aspects of the language and interoperability.
Examples of such guides include:

  * Collections & Sequences
  * Concurrency & Parallelism
  * Interoperability
  * Laziness
  * Macros

Target audience: from developers who already have some familiarity with the language to those who have been using it for
a while.


### Tools & Ecosystem guides

These guides cover key Clojure ecosystem tools such as [Leiningen](https://leiningen.org), [Clojars](https://clojars.org),
nREPL, Emacs, vim/neovim, Calva, etc. It also covers important ecosystem projects that are not tools: books,
communities, etc.

Target audience: all developers using or interested in the language.



### Cookbooks

Concise Clojure example code, categorized by subject.


## How To Contribute

First of all: you **can** contribute to Clojure documentation even if you have 15 minutes to spare a day.

No contribution is too small: feel free to suggest grammar improvements, better code examples, submit pull requests with just
one new paragraph or even a couple of spelling corrections. Editing and proof-reading is also a great way to contribute.

If you found a mistake you'd like to report and do not want to make edits and go through the pull request process,
please post your findings in one of the following places:
* [Clojurians Slack `#clojure-doc` channel](https://clojurians.slack.com/archives/C02M6N5C137) -- [self-signup at clojurians.net](http://clojurians.net),
* [Discussions on GitHub](https://github.com/clojure-doc/clojure-doc.github.io/discussions),
* The [Clojure mailing list](https://groups.google.com/group/clojure).

Thank you!


### Toolchain

This site is built with [Cryogen](https://cryogenweb.org/) and hosted as a GitHub organization website.

Clone the repository, checkout the `source` branch, and run `clojure -M:build` to generate the `public` folder
containing the rendered HTML version of the site (which is actually the `main` branch of the repository, so that
it is published to https://clojure-doc.org automatically).

You can view the generated version with `clojure -X:serve` which should open a browser to port 3000 (of localhost).
This will automatically regenerate the `public` folder as files are changed in `content` etc.

See [Klipse.md](Klipse.md) for instructions about including interactive code snippets in an article.

### Contributing To Existing Guides

First, pick a topic that sounds interesting. Writing documentation takes some effort and
working on something that is interesting to you will motivate you. Next, find the article you want
to contribute to under `./content/md/articles/`. It is a Markdown file with inline code snippets.

At the top of each article you will usually find what it is supposed to cover. Please stick
to that list.

Then fork the repository, create a [topic branch](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows), and
start writing.

When writing, periodically view results in the browser (see `clojure -X:serve` described above for running a local server) and make
sure code examples are rendered correctly and that there are no serious formatting issues. If you are not a Markdown or CSS guru,
it's OK, but submitting changes that seriously break formatting and force maintainers to work on fixing them is not
very productive (or nice).

After making the changes you want, run them by a fellow developer, edit them a couple
of times and *submit a pull request on GitHub*. Please be patient. It may take a while for
CDS maintainers to get to your pull request, read your changes, and suggest improvements.

Don't get discouraged if asked to make more edits or even completely rewrite some parts from scratch.
All good documentation out there is a result of dozens of edits, corrections, and sometimes ground-up
rewrites. This is normal. We want Clojure documentation to be high quality just like the language and
`clojure.core`.

For some guidance on writing great documentation, see <https://jacobian.org/series/great-documentation/>.



### Contributing New Guides

If you feel there may be a guide missing, please run your idea by other CDS contributors in one of these places:

* [Clojurians Slack `#clojure-doc` channel](https://clojurians.slack.com/archives/C02M6N5C137) -- [self-signup at clojurians.net](http://clojurians.net),
* [Discussions on GitHub](https://github.com/clojure-doc/clojure-doc.github.io/discussions),
* The [Clojure mailing list](https://groups.google.com/group/clojure).


### What You Must Not Do

Please respect copyright of other Clojure-related content out there. **You must not** copy content from clojure.org, books on Clojure, blogs and
other sources unless you are the primary author of them and understand the implications.



### Contributors Policy

If you are the primary author of a substantial document, you are
encouraged to include your name in a `## Contributors` section near the
end of it, noting that you are the original author. If you have made
substantial contributions to an existing document, you might add your
name to the `## Contributors` section.

If you have at least one non-trivial (e.g. not just typo fixes) pull request merged, you can ask
to be added to the repository as a collaborator. We still encourage contributors to use pull requests for content
review and discussions for new content, but you will be able to push small improvements directly.

* [GitHub contributors page](https://github.com/clojure-doc/clojure-doc.github.io/graphs/contributors) lists key contributors to the rebooted project.
* [Previous (clojure-doc) GitHub contributors page](https://github.com/clojuredocs/cds/graphs/contributors) lists key contributors to the original project.


## License

All the content is distributed under the
[CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) license
and are copyright their respective primary author(s).
