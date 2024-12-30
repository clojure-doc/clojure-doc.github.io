{:title "Clojure Editors"
 :page-index 1200
 :layout :page}

The last
["State of the Union" Clojure survey](https://clojure.org/news/2024/12/02/state-of-clojure-2024) indicated
that Emacs is still the most popular editing environment (although it has
fallen to just under 40%), followed by IntelliJ/Cursive and VS Code
(equal at 23%), and then Vim (around 12.5%).

If you are already using one of these editors, follow one of the guides for that
editor to integrate a REPL-based Clojure workflow, so that you can focus on
learning just the language.

If you are not using one of these four editors, try to pick the one that is
closest to what you are currently using, unless your editor is listed on
the [Clojure Tools page](https://clojure.org/community/tools) with an active
Clojure integration.

If you are coming to Clojure as a beginner, and don't have a history with any
of these editors, you might consider starting with VS Code and Calva, which
has a very low barrier to entry.

Despite the popularity of Emacs within the
Clojure world, you don't want to be learning _both_ Clojure _and_ Emacs
at the same time!

## Emacs

[Emacs](https://www.gnu.org/software/emacs/) is the longest serving and most
customizable editor available and for years it was the overwhelmingly
popular choice for editing Clojure code.

Popular variants of Emacs include [Doom Emacs](https://docs.doomemacs.org/)
and [Spacemacs](https://www.spacemacs.org/).

[CIDER](https://cider.mx/) is the most comprehensive package for editing
Clojure with Emacs.
Other options are [clojure-mode](https://github.com/clojure-emacs/clojure-mode)
on its own and [inf-clojure](https://github.com/clojure-emacs/inf-clojure)
for integration with a basic Clojure REPL.

For a complete, opinionated, and well-maintained configuration for Emacs,
you might consider [Prelude](https://prelude.emacsredux.com/en/latest/)
by the creator of CIDER.

You can also get static analysis and refactoring support via
[clojure-lsp for Emacs](https://clojure-lsp.io/clients/#emacs) (and
it should also work out-of-the-box with [`eglot`](https://github.com/joaotavora/eglot/),
which is built into Emacs 29 and above).

See the [Editors guide on clojure.org](https://clojure.org/guides/editors#_emacs_most_popular_most_customizable) for more links ("most customizable").

## IntelliJ/Cursive

[Cursive](https://cursive-ide.com/) provides a full-featured IDE for Clojure.
This is a great choice if you are already familiar with IntelliJ and/or you
plan to work with both Clojure and Java (or other JVM-based languages).

See the [Editors guide on clojure.org](https://clojure.org/guides/editors#_intellij_clojure_with_a_java_tilt) for more links ("Java tilt").

## VS Code

[Calva](https://calva.io/) is a comprehensive package for editing Clojure
with VS Code. It uses [Clojure LSP](https://clojure-lsp.io/)
and [clj-kondo](https://github.com/clj-kondo/clj-kondo) to add static
language analysis features in addition to the dynamic features available
via [nREPL](https://github.com/nrepl/nREPL)
and [cider-nrepl](https://github.com/clojure-emacs/cider-nrepl).

See the [Editors guide on clojure.org](https://clojure.org/guides/editors#_vs_code_rapidly_evolving_beginner_friendly) for more links ("beginner friendly").

## Vim/Neovim

The main options here are:
* [vim-fireplace](https://github.com/tpope/vim-fireplace) (for Vim)
* [vim-iced](https://liquidz.github.io/vim-iced/) (for Vim/Neovim)
* [Conjure](https://github.com/Olical/conjure) (for Neovim): [Getting Started](https://oli.me.uk/getting-started-with-clojure-neovim-and-conjure-in-minutes/), [Conjure/Neovim on Practical.li](https://practical.li/neovim/)

See the [Editors guide on clojure.org](https://clojure.org/guides/editors#_vim_highly_efficient_text_editing) for more links ("highly efficient").

## Additional Tools

The following data visualization tools can be very helpful when editing
Clojure and evaluating code:

* [Portal](https://github.com/djblue/portal)
* [Reveal](https://github.com/vlaaad/reveal)
* [Morse](https://github.com/nubank/morse) from nubank (evolved from Cognitect's REBL)

## Additional Editor Guides

* [Practical.li](https://practical.li/clojure/clojure-editors/)
