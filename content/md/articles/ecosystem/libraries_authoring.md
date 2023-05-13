{:title "Library Development and Distribution"
 :layout :page :sidebar-omit? true :page-index 103100}

> Work In Progress: convert to Clojure CLI!

This short guide covers how to create your own typical pure Clojure
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

This guide uses Clojure 1.11 and a recent version of the Clojure CLI
(at least 1.11.1.1139), and requires you have `git`
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

> Note: If you're using Leiningen, read the [Library Development and Distribution with Leiningen](/articles/ecosystem/libraries_authoring_lein/) section.

## Publishing Libraries

Prior to the appearance of the Clojure CLI in 2018, it was generally
assumed that you would publish the source of your library to a
public service like GitHub, but that you would also need to package
your library as a JAR file and deploy it to Clojars (or Maven Central)
so that it was available for others to use in their projects as a
dependency.

The Clojure CLI can treat projects hosted on public services like GitHub as first-class
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
rely on `io.github.<account>/<project>` as coordinates that the Clojure CLI
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

Our project will live on GitHub as https://github.com/clojure-example-library/my-cool-lib
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

## Making the Project your own

> Why "useful"?

Our trivial library example project will have a dependency on
[flatland's "useful"](https://clojars.org/org.flatland/useful)
library.

Open up our new project.clj file and make a few changes:

 1. Add our dependency (`[org.flatland/useful "0.9.0"]`) to the `:dependencies` vector.
 2. Remove "-SNAPSHOT" from version string.
 3. Write a short description.
 4. Add a url (if not a homepage, then where it's source is hosted online).
 5. If you're using a different license, change the value for `:license`.

Regarding your choice of license, probably the three most common for
Clojure libs (along with a grossly oversimplified blurb (by this
author) for each) are:

  * The [Eclipse Public License] (the default).
  * The [LGPL](http://www.gnu.org/licenses/lgpl.html) (focused most on
    code and additions always being free; includes language addressing
    s/w patent concerns). See the [FSF's recommendations] and their
    [instructions for use].
  * The [MIT] License (focused most on the user's freedom to do what
    they want with the code). The FSF calls this the ["Expat"
    License](http://directory.fsf.org/wiki/License:Expat).

[Eclipse Public License]: http://directory.fsf.org/wiki/License:EPLv1.0
[GPL]: http://www.gnu.org/licenses/gpl.html
[FSF's recommendations]: http://www.gnu.org/licenses/license-recommendations.html
[instructions for use]: http://www.gnu.org/licenses/gpl-howto.html
[MIT]: http://opensource.org/licenses/MIT

Whichever one you choose, update your project.clj (if necessary) to
reflect that choice and save the text of the license as a file named
"LICENSE" or "COPYING" in your project directory.


### A Note Regarding Project Naming

The top line of your project.clj includes something like `defproject
my-project-name`.  This means that your project has an *artifact-id*
of "my-project-name", but it also implies a *group-id* of
"my-project-name" (group-id = artifact-id).

The artifact-id is the name of your project. The group-id is used for
namespacing (not the same thing as Clojure namespaces) --- it
identifies to which group/organization a project belongs. Some
examples of group-id's: clojurewerkz, sonian, and org.*your-domain*.

You may choose to explicitly use a group-id for your project, if you
like. For example:

    (defproject org.my-domain/my-project-name ...
    ...)

The maintainers of Clojars
[require that new libs be published using verified groups](https://github.com/clojars/clojars-web/wiki/Verified-Group-Names),
such as org.my-domain.

Read more about groups at
<https://github.com/clojars/clojars-web/wiki/Groups>.


## Update the README

Aside from providing a good overview, rationale, and introduction at
the top, you're encouraged to provide some usage examples as well.  A
link to the lib's (future) Clojars page (which we'll get to below)
might also be appreciated. Add acknowledgements near the end, if
appropriate.  Adjust the copyright and license info at the bottom of
the README as needed.

Lein provides you with a doc directory and a starter doc/intro.md
file. If you find that you have more to say than will comfortably fit
into the README.md, consider moving content into the doc dir.

Other goodies you might include in your README.md or doc/\*.md files:
tutorial, news, bugs, limitations, alternatives, troubleshooting,
configuration.

Note that you generally won't add hand-written API documentation into
your readme or other docs, as there are tools for creating that
directly from your source (discussed later).




## Create your project's local git repository

Before going much further, you probably want to get your project under
version control. Make sure you've got git installed and configured to
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

In test/trivial/library_example/core_test.clj, add tests as needed.
An example is provided in there to get you started.




## Write Code

Write code to make your tests pass.

Remember to add a note at the top of each file indicating copyright
and the license under which the code is distributed.




## Run Tests

In your project dir:

    clojure -M:test -m cognitect.test-runner

or:

    clojure -T:build test




## Commit any remaining changes

Before continuing to the next step, make sure all tests pass and
you've committed all your changes. Check to see the status of your
repo at any time with `git status` and view changes with `git diff`.




## Create github project and Upload there

This guide makes use of [github](https://github.com/) to host your
project code.


Once this remote repo has been created, follow the instructions on the
resulting page to "Push an existing repository from the command
line". You'll of course run the `git` commands from your project
directory:

    git remote add origin git@github.com:uvtc/trivial-library-example.git
    git push -u origin master

You can now access your online repo. For this tutorial, it's
<https://github.com/uvtc/trivial-library-example>.

Any changes you commit to your local repository can now be pushed
to the remote one at github:

```bash
# work work work
git add -p
git commit -m "commit message here"
git push
```


## Create a GPG key for signing your releases

You'll need to create a [gpg](http://www.gnupg.org/) key pair, which
will be used by lein to sign any release you make to Clojars. Make
sure you've got gpg installed and kick the tires:

    gpg --list-keys

(The first time that command is run, you'll see some notices about
it creating necessary files in your home dir.)

To create a key pair:

    gpg --gen-key

Take the default key type (RSA and RSA), and default key size (2048).
When asked for how long the key should remain valid, choose a year or
two. Give it your real name and email address. When it prompts you for
a comment, you might add one as it can be helpful if you have multiple
keys to keep track of. When prompted for a passphrase, come up with one
that is different from the one used with your ssh key.

When gpg has completed generating your keypair, you can have it list
what keys it knows about:

    gpg --list-keys

We'll use that public key in the next section.




## Upload to Clojars

If you don't already have an account at <https://clojars.org/>, create
one. After doing so, you'll need to supply your ssh and gpg public
keys to Clojars.  For the ssh public key, you can use the same one as
used with github. For the gpg public key, get it by running:

    gpg --export -a <your-key-id>

where `<your-key-id>` is in the output of `gpg --list-keys` (the
8-character part following the forward slash on the line starting with
"pub"). Copy/paste that output (including the "-----BEGIN PGP PUBLIC
KEY BLOCK-----" and "-----END PGP PUBLIC KEY BLOCK-----") into the
form on your Clojars profile page.

For more info on working with Clojars, see [the Clojars
wiki](https://github.com/clojars/clojars-web/wiki/About).

Once your Clojars account is all set up, and it has your public keys,
upload your library to Clojars like so:

    lein deploy clojars

You will be asked for your (Clojars) username and password.

Then you'll be asked for your gpg passphrase. (You won't be asked for
your ssh passphrase because `lein deploy clojars` uses http rather
than scp --- though Clojars supports both.)

You should now be able to see your lib's Clojars page: for example,
<https://clojars.org/trivial-library-example>!





## Generate API docs (optional)

For larger library projects, you may want to automatically generate
API docs (from your docstrings). See
[codox](https://github.com/weavejester/codox). If your library project
is hosted at github, you can use [github
pages](https://pages.github.com/) to host the resulting docs.





## Announce (optional)

You're welcome to announce the availability of your new library
on the [Clojure Mailing List](https://groups.google.com/forum/?fromgroups#!forum/clojure).




## Make Updates to your library

Making updates to your lib follows the same pattern as described above:

```bash
# work test work test
# update version string in project.clj
git add -p
git commit
git push
lein deploy clojars
```

And optionally announce the release on the ML.



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
