{:title "Ecosystem: Library Development and Distribution"
 :layout :page :toc true :page-index 3200}

This guide covers how to create your own typical pure Clojure
library and distribute it to the community via Clojars, as well as
making it available in source form on a public repository such as
[GitHub](https://github.com).

## Prequisites

This guide assumes you have an account on a public hosting service
like GitHub and you will need to use your account name as part of
your project. In this guide, we use `clojure-example-library` as the
account name: you should substitute your own account name wherever you
see `clojure-example-library` in this guide! We will use `my-cool-lib`
as the name of the new project we create and publish here, but you
can use whatever name you want -- just remember to substitute that
wherever you see `my-cool-lib` in this guide.

This guide uses Clojure 1.12 and a recent version of the Clojure CLI
(at least 1.12.0.1479; current version is 1.12.0.1488 as of December 2024),
and requires you have `git`
installed (though very little familiarity with `git` is required).

> Note: you should always ensure you have an up-to-date version of the Clojure CLI installed! See [Tools Releases](https://clojure.org/releases/tools). Several of the examples here require 1.11.1.1139 or later: `clojure -version` should tell you the version you have installed.

It's assumed that you're already somewhat familiar with Clojure. If
not, see the [Getting Started](/articles/tutorials/getting_started/) and
[Introduction](/articles/tutorials/introduction/) guides.

This work is licensed under a <a rel="license"
href="https://creativecommons.org/licenses/by/3.0/">Creative Commons
Attribution 3.0 Unported License</a> (including images &
stylesheets). The source is available [on
Github](https://github.com/clojure-doc/clojure-doc.github.io).

> Note: If you're using Leiningen, read the [Library Development and Distribution with Leiningen](/articles/ecosystem/libraries_authoring_lein/) guide.

## Publishing Libraries

Prior to the appearance of the Clojure CLI in 2018, it was generally
assumed that you would publish the source of your library to a
public service like GitHub, but that you would also need to package
your library as a JAR file and deploy it to Clojars (or Maven Central)
so that it was available for others to use in their projects as a
dependency.

The Clojure CLI can treat projects hosted on public services,
like GitHub, as first-class
dependencies, so that it is no longer necessary to package and deploy
your library elsewhere -- if you expect your users to consume the library
directly in source form. In order to make your library available to users
who are working with Leiningen (or other build tools), it is still required
to package and deploy your project as a JAR file -- which this guide also
covers.

### Publishing to GitHub

If you don't already have a GitHub account, create one,
then log into it. GitHub provides good documentation on how to [get
started](https://help.github.com/articles/set-up-git) and how to
[create an SSH key
pair](https://help.github.com/articles/generating-ssh-keys). If you
haven't already done so, get that set up before continuing.

Go to the Repositories tab and
create a new repository there for your project using the icon/button/link
(near the top-right if you already have existing projects, else prominently
in the middle if this is your first repository).

> You will have your local repository, and also a remote duplicate of
> it at GitHub.

For the repository name, we'll use `my-cool-lib` in this guide (but you
can use whatever name you want).
Provide a one-line description if you want, **make sure to select Public**
so that others can access your project, and hit "Create repository".

You do not need GitHub to provide a README, a `.gitignore` file, or
a license, since we'll add those.

For a project published to GitHub as `clojure-example-library/my-cool-lib`,
the default dependency for others to use would be:

```clojure
  io.github.clojure-example-library/my-cool-lib {:git/sha "..."}
```

Where the `"..."` value would be the full SHA (hex string) for the version
that they wanted to use (e.g., from the latest commit).

If you have tagged a release on GitHub, e.g., `v0.1.0` then you can use
`:git/tag "v0.1.0"` and the `:git/sha` value can be the "short SHA" -- just
the first seven characters of the hex string.

The Clojure CLI understands that `io.github.<account>/<repo>` maps to
`https://github.com/<account>/<repo>` in order to fetch the repository.
The CLI understands
[several source code repositories](https://clojure.org/reference/deps_and_cli#_coord_attributes)
so you could use GitLab, BitBucket, Beanstalk, or Sourcehut (as of May 2023).

### Publishing to Clojars

If you don't already have an account, you will need to
[register on Clojars](https://clojars.org/register).
It will convenient for you to use the same email account as you use
for GitHub, so that you can login to Clojars in future via GitHub,
which will automatically verify your GitHub-associated "group ID"
with Clojars (e.g., `io.github.<account>`).
See [Verified Group Names](https://github.com/clojars/clojars-web/wiki/Verified-Group-Names)
for more details.

You will also need to set up at least one
[deploy token](https://github.com/clojars/clojars-web/wiki/Deploy-Tokens)
and provide environment variables when you get to the point of actually
deploying your library JAR to Clojars:

* `CLOJARS_USERNAME` -- set to your Clojars username
* `CLOJARS_PASSWORD` -- set to a valid deploy token

If you don't want to connect your Clojars account to your GitHub account,
you can use `net.clojars.<username>` as your "group ID" for deploying
projects. That style of group name is always verified for Clojars.


## Creating New Projects

If you only ever intend to publish your library to GitHub and not to Clojars,
you can create a fairly minimal project (`deps.edn` file, `src/` folder) and
rely on `io.github.<account>/<project>` as the coordinates that the Clojure CLI
understands.

If you plan to deploy to Clojars at any point, you'll need to be able to
build a JAR file and deploy it. You _can_ learn to do all that manually
via [`tools.build`](https://github.com/clojure/tools.build)
and a `build.clj` file,
and using [`deps-deploy`](https://github.com/slipset/deps-deploy)
once you've built the JAR file. It's going to be easier if you use a
tool to create a "fully-fleshed" library project for you, that adds all
of that configuration for you.

In either case, you're probably going to want to add tests and run them,
so you'll either need to add those manually or, again, rely on a tool to
set up a project with testing already built in.

For this guide, we're going to use
[`deps-new`](https://github.com/seancorfield/deps-new)
which can create "batteries-included" library (and application) projects
for you.

### Installing `deps-new`

> If you already have `deps-new` installed as a Clojure "tool", as `new`, then you can skip this section.

The Clojure CLI allows you to install useful tools for your user account
so you can use them in any project or even outside projects.

A useful tool to create new projects is `deps-new` so we're going to
install the latest version of that:

```
clojure -Ttools install-latest :lib io.github.seancorfield/deps-new :as new
```

Once `deps-new` is installed as `new`, we can use `clojure -Tnew` to create
new projects.

### Create the Project with `deps-new`

Bearing in mind the comments about groups and accounts and usernames above,
we're going to create our example project with the name:

```
io.github.clojure-example-library/my-cool-lib
```

Our project will live on GitHub as <https://github.com/clojure-example-library/my-cool-lib>
and can be used directly from there using the full project name shown above.
We will also deploy it to Clojars so that people can depend on it as a
JAR file dependency.

Create your new library project. Names are usually hyphen-separated
lowercase words:

    clojure -Tnew lib :name io.github.clojure-example-library/my-cool-lib
    cd my-cool-lib

Typical `deps-new` usage is `clojure -Tnew (lib or app) :name yourname/your-project`.
If you use just `<yourname>`, the project coordinates will be assumed to be
`net.clojars.<yourname>/<your-project>`, which is why we used `io.github.` as
a prefix above.

### A Note Regarding Project Naming

A line near the top of your `build.clj` includes something like:

```clojure
(def lib 'io.github.clojure-example-library/my-cool-lib)
```

This means that your project has an *artifact ID*
of `my-cool-lib`, and a *group ID* of
`io.github.clojure-example-library`.

The artifact ID is the name of your project. The group ID is used
to distinguish your `my-cool-lib` from anyone else's `my-cool-lib`.
It typically identifies the group or organization to which a project belongs.

The maintainers of Clojars
[require that new libs be published using verified groups](https://github.com/clojars/clojars-web/wiki/Verified-Group-Names),
such as `org.my-domain` or `io.github.<account>` or `net.clojars.<account>`.

Read more about groups at
<https://github.com/clojars/clojars-web/wiki/Groups>.

## Making the Project your own

Our cool library example project will add a dependency on
[flatland's "useful"](https://github.com/clj-commons/useful)
library.

Open up our new `deps.edn` file and make add our dependency
(`org.flatland/useful {:mvn/version "0.11.6"}`) to the `:deps` hash map.

In `build.clj`, remove `-SNAPSHOT` from `version` (so it is just `"0.1.0"`).

### Licensing

If you created your project using `deps-new`, it will have added a
`LICENSE` file pertaining to the [Eclipse Public License] and an
explanation at the end of the `README.md` that this is just a default.

You can choose to license your project however you want.
The most common licenses for Clojure libraries (along with grossly
oversimplified blurbs, by this author John Gabriele, for each) are:

  * The [Eclipse Public License] (the default).
  * The [LGPL](http://www.gnu.org/licenses/lgpl.html) (focused most on
    code and additions always being free; includes language addressing
    s/w patent concerns). See the [FSF's recommendations] and their
    [instructions for use].
  * The [MIT] License (focused most on the user's freedom to do what
    they want with the code). The FSF calls this the ["Expat"
    License](http://directory.fsf.org/wiki/License:Expat).

[Eclipse Public License]: http://directory.fsf.org/wiki/License:EPLv1.0
[FSF's recommendations]: http://www.gnu.org/licenses/license-recommendations.html
[instructions for use]: http://www.gnu.org/licenses/gpl-howto.html
[MIT]: http://opensource.org/licenses/MIT

Another option is the [Apache Source License](https://apache.org/licenses/LICENSE-2.0)
which is a commercial-friendly license (this author Sean Corfield tends to
prefer ASL for projects where the default, EPL, is not used).

Whichever one you choose, update your `README.md` to
reflect that choice and save the text of the license as a file named
`LICENSE` in your project directory. Some licenses may encourage
you to add a portion of the license text to the header comment in your
source files.



### Update the README

Aside from providing a good overview, rationale, and introduction at
the top, you're encouraged to provide some usage examples as well.  A
link to the lib's (future) Clojars page (which we'll get to below)
might also be appreciated. Add acknowledgements near the end, if
appropriate.  Adjust the copyright and license info at the bottom of
the README as needed.

`deps-new` provides you with a `doc` directory and a starter `doc/intro.md`
file. If you find that you have more to say than will comfortably fit
into the `README.md`, consider moving content into the `doc` directory.

This guide mentions `cljdoc.org` below as a great option for providing
online documentation, so feel free to expand your `doc` directory
per [Cljdoc for Library Authors](https://github.com/cljdoc/cljdoc/blob/master/doc/userguide/for-library-authors.adoc#basic-setup)
which explains how to provide structure and organization for your
documentation.

Other goodies you might include in your `README.md` or `doc/*.md` files:
tutorial, news, bugs, limitations, alternatives, troubleshooting,
configuration.

Note that you generally won't add hand-written API documentation into
your `README.md` or other documentation, as there are tools for creating that
directly from your source (discussed later).




## Create your project's local git repository

Before going much further, you probably want to get your project under
version control. Make sure you've got `git` installed and configured to
know your name and email address (i.e., that at some point you've run
`git config --global user.name "Your Name"` and
`git config --global user.email "your-email@somewhere.org"`).

Then, in your project dir, run:

    git init
    git add .
    git commit -m "The initial commit."

At any time after you've made changes and want to inspect them and
commit them to the repository:

    git diff
    git add -p
    git commit -m "The commit message."





## Write Tests

In `test/clojure_example_library/my_cool_lib_test.clj`, add tests as needed.
An example is provided in there to get you started.

> Note: the example test created by `deps-new` fails deliberately in order
for you to get accustomed to writing tests!



## Write Code

Write code to make your tests pass.

Remember to add a note at the top of each file indicating copyright
(and the license under which the code is distributed, if applicable).

For example:

```clojure
;; copyright (c) 2024 -- Sean Corfield, all rights reserved.
```



## Run Tests

In your project dir:

    clojure -M:test -m cognitect.test-runner

or:

    clojure -T:build test

> Note: if you didn't use `deps-new` to create your library project, you'll want to add a `:test` alias that adds [Cognitect's `test-runner`](https://github.com/cognitect-labs/test-runner) to your project -- see [**Configuration**](https://github.com/cognitect-labs/test-runner#configuration) in that project's `README`. The `:test` alias `deps-new` generates does not have `:exec-fn` or `:main-opts` because it expects you to run tests via the `build.clj` file, although you can provide `-m cognitect.test-runner` on the command-line to run tests directly via the CLI, as shown above.



## Commit any remaining changes

Before continuing to the next step, make sure all tests pass and
you've committed all your changes. Check to see the status of your
repo at any time with `git status` and view changes with `git diff`.




## Complete the GitHub Project Setup and Upload your Code

Once your remote repository has been created, follow the instructions on the
resulting page to "Push an existing repository from the command
line". You'll of course run the `git` commands from your project
directory:

    git remote add origin git@github.com:clojure-example-library/my-cool-lib.git
    git push -u origin master

You can now access your online repo. For this tutorial, it's
<https://github.com/clojure-example-library/my-cool-lib>.

Any changes you commit to your local repository can now be pushed
to the remote one at GitHub:

```bash
# work work work
git add -p
git commit -m "commit message here"
git push
```


### Making a Release on GitHub

At this point, prior to deploying your project to Clojars, it is common
to make a release on GitHub describing this new version of your project.

You can update `version` in `build.clj` to reflect the new version you
want to publish, then add, commit, and push those changes.

On GitHub, navigate to the Releases section of your project and click
the icon/button/link to create a new release.

> For example, for `clojure-example-library/my-cool-lib` this would be
<https://github.com/clojure-example-library/my-cool-lib/releases/new>.

Choose a tag that reflects the version you are about to release, e.g., `v0.1.0`.

Enter the release name or number, e.g., `0.1.0` (it is typically the version
without the leading `v`).

Enter a description, explaining the changes in this version, new features,
bug fixes, etc, and create the release.

You should see the release name/number with a tag and a short SHA, e.g.,

    0.1.0
    ... v0.1.0 ec74557


## Upload to Clojars

See **Publishing to Clojars** above to get started.
For more info on working with Clojars, see [the Clojars
wiki](https://github.com/clojars/clojars-web/wiki/About).

Run the tests one more time and build the JAR file:

    clojure -T:build ci

Once your Clojars account is all set up,
upload your library to Clojars like so:

    clojure -T:build deploy

If you haven't already setup your environment variables, you can supply
them as part of that `deploy` command -- see
[`deps-deploy` usage](https://github.com/slipset/deps-deploy#usage):

    env CLOJARS_USERNAME=username CLOJARS_PASSWORD=clojars-token clojure -T:build deploy

You should now be able to see your lib's Clojars page: for example,
<https://clojars.org/net.clojars.clojure-example-library/my-cool-lib>!

> Note: to deploy that example library, the `lib` var inside `build.clj` was
changed to `net.clojars.clojure-example-library/my-cool-lib` which is a default
verified group name, to avoid verifying via GitHub, since `clojure-example-library`
is a GitHub organization rather than an individual account. If you use your
GitHub username to login to Clojars to verify your account, you can use `io.github.<username>`.

If everything goes smoothly, all of the links on that Clojars page
should work and clicking `this git tree` in the **Pushed by** section
should take you to GitHub, showing the source code at that version, e.g.,
<https://github.com/clojure-example-library/my-cool-lib/tree/v0.1.0>

In addition, if you clicked on the `cljdoc` link on that Clojars page,
it will take you to a page where you can build the API docs for your
library. Once that build has completed, you should be able to visit
the generated documentation, e.g.,
<https://cljdoc.org/d/net.clojars.clojure-example-library/my-cool-lib/0.1.0/doc/readme>

See the next section for more details.


## Generate API docs (optional)

For larger library projects, you may want to automatically generate
API docs (from your docstrings). See [cljdoc](https://cljdoc.org/)
for the most common, automated documentation site used for Clojure
libraries.

If you've followed all the steps above, that should go smoothly, but
if you get into trouble, the `#cljdoc` channel on the Clojurians Slack
is a great place to get help.




## Announce (optional)

You're welcome to announce the availability of your new library
wherever you choose -- e.g., on Clojurians Slack, Twitter,
Mastodon, the Clojure mailing list, r/Clojure (Reddit), ClojureVerse. Just
make sure to follow the etiquette about announcements, wherever you post!


## Make Updates to your library

Making updates to your lib follows the same pattern as described above:

```bash
# work test work test
# document the updates in CHANGELOG.md
# update the version in README.md
# update version string in build.clj
git add -p
git commit
git push
# make a new release on GitHub for this new version

# final testing and build the JAR file
clojure -T:build ci
# deploy to Clojars
clojure -T:build deploy
```

And optionally announce the release (Clojurians Slack prefers that you
use `#releases` for small, frequent announcements, and only use
`#announcements` for an initial release and then only about once
a month for major releases or "round-up" announcements of multiple releases).



### Merging pull-requests

Note that if you receive a pull-request at github, you can easily
merge those changes into your project (right there, via the web page
describing the pull-request). Afterwards, update your local repo to
grab those changes as well:

    git pull



## See Also

For more detailed documentation on various aspects of the procedures
described here, see:

  * the [Clojars wiki](https://github.com/clojars/clojars-web/wiki)
  * the [Clojure CLI Guide](https://clojure.org/guides/deps_and_cli)
    and [Clojure CLI Reference](https://clojure.org/reference/deps_and_cli)
  * the [deps-deploy library](https://github.com/slipset/deps-deploy)



## Contributors

John Gabriele <jmg3000@gmail.com> (original author)
Sean Corfield <sean@corfield.org> (updated to use Clojure CLI)
