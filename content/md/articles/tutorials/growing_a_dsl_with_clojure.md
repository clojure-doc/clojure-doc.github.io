{:title "Growing a DSL with Clojure"
 :page-index 1700
 :klipse true
 :layout :page}

Lisps like Clojure are well suited to creating rich DSLs that integrate seamlessly into the language.

You may have heard Lisps boasting about code being data and data being code. In this article we will define a DSL that benefits handsomely from this fact.

We will see our DSL evolve from humble beginnings, using successively more of Clojure’s powerful and unique means of abstraction.

## The Mission

Our goal will be to define a DSL that allows us to generate various scripting languages. The DSL code should look similar to regular Clojure code.

For example, we might use this Clojure form to generate either Bash or Windows Batch script output:

Input (Clojure form):

```clojure
(if (= 1 2)
  (println "a")
  (println "b"))
```

Output (Bash script):

```sh
if [ 1 -eq 2 ]; then
  echo "a"
else
  echo "b"
fi
```

Output (Windows Batch script):

```bat
IF 1==2 (
  ECHO a
) ELSE (
  ECHO b
)
```

We might, for example, use this DSL to dynamically generate scripts to perform maintenance tasks on server farms.

## Baby Steps: Mapping to Our Domain Language

I like Bash, so let’s start with a Bash script generator.

To start, we need to expose some parallels between Clojure’s core types and our domain language.

So which Clojure types have simple analogues in Bash script?

Strings and numbers should just simply return their String representation, so we will start with those.

Let’s define a function `emit-bash-form` that takes a Clojure form and returns a string that represents the equivalent Bash script.

<pre style="visibility:hidden; height:0;"><code class="klipse-clojure" >
(require '[chivorcam.core :refer [defmacro defmacfn]])
</code></pre>

```klipse-clojure
(defn emit-bash-form [a]
  "Returns a String containing the equivalent Bash script
  to its argument."
  (cond
    (string? a ) a
    (number? a) (str a)
    :else (throw (ex-info "Fell through" a))))
```

The `cond` expression handles cases for strings and numbers or throws an exception.

```klipse-clojure
(emit-bash-form 1)
```

```klipse-clojure
(emit-bash-form "a")
```

```klipse-clojure
(emit-bash-form {})
```

Now if we want to add some more dispatches, we just need to add a new clause to our `cond` expression.

## Echo and Print

Let’s add a feature.

Bash prints to the screen using `echo`. You’ve probably seen it if you’ve spent any time with a Linux shell.

```sh
ambrose@ambrose-desktop> echo asdf
asdf
```

clojure.core also contains a function `println` that has similar semantics to Bash's `echo`.

```klipse-clojure
(println "asdf")
```

Wouldn’t it be cool if we could pass `(println "a")` to `emit-bash-form`?

```clojure
(emit-bash-form (println "asdf"))
```

At first, this seems like asking the impossible.

To made an analogy with Java, imagine calling this Java code and expecting the first argument to equal `System.out.println("asdf")`.

```java
foo( System.out.println("asdf") );
```

(Let’s ignore the fact that `System.out.println(...)` returns a void).

Java evaluates the arguments before you can even blink, resulting in a function call to println. How can we stop this evaluation and return the raw code?

Indeed this is an impossible task in Java. Even if this were possible, what could we expect do with the raw code?(!)

`System.out.println("asdf")` is not a Collection, so we can’t iterate over it; it is not a `String`, so we can’t partition it with regular expressions.

Whatever "type" the raw code `System.out.println("asdf")` has, it’s not meant to be known by anyone but compiler writers.

Lisp turns this notion on its head.

## Lisp Code Is Data

A problem with raw code forms in Java (assuming it is possible to extract them) is the lack of facilities to interrogate them. How does Clojure get around this limitation?

To get to the actual raw code at all, Clojure provides a mechanism to stop evaluation via quote. Prepending a quote to a code form prevents its evaluation and returns the raw Clojure form.

```klipse-clojure
'(println "a")
```

So what is the type of our result?

```klipse-clojure
(type '(println "a"))
```

It's a list!

We can now interrogate the raw code as if it were any old Clojure list (because it is!).

```klipse-clojure
(first '(println "a"))
```

```klipse-clojure
(second '(println "a"))
```

This is a result of Lisp’s remarkable property of code being data.

## A Little Closer to Clojure

Using quote, we can get halfway to a DSL that looks like Clojure code.

```clojure
(emit-bash-form
  '(println "a"))
```

Let’s add this feature to `emit-bash-form`. We need to add a new clause to the `cond` form. Which type should the dispatch value be?

So let’s add a clause for lists.

```klipse-clojure
(defn emit-bash-form [a]
  "Returns a String containing the equivalent Bash script
  to its argument."
  (cond
    (list? a) 
    (case (name (first a))
      "println" (str "echo " (second a)))

    (string? a) a
    (number? a) (str a)
    :else (throw (ex-info "Fell through" a))))
```

As long as we remember to quote the argument, this is not bad.

```klipse-clojure
(emit-bash-form '(println "a"))
```

```klipse-clojure
(emit-bash-form '(println "hello"))
```

## Multimethods to Abstract the Dispatch

We’ve made a good start, but I think it’s time for some refactoring.

Currently, to extend our implementation we add to our function emit-bash-form. Eventually this function will be too large to manage; we need a mechanism to split this function into more manageable pieces.

Essentially emit-bash-form is dispatching on the type of its argument. This dispatch style is a perfect fit for an abstraction Clojure provides called a multimethod.

Let’s define a multimethod called `emit-bash`. 

The multimethod handles dispatch in a similar way to `cond`, but without having to actually write each case. Let’s compare this multimethod with our previous `cond` expression. `defmulti` is used to create a new multimethod, and associates it with a dispatch function.

```klipse-clojure
(defmulti emit-bash
          (fn [form]
            (cond
              (list? form) :list
              (string? form) :string
              (number? form) :number
              :else (throw (ex-info "Unknown type" form)))))
```


`defmethod` is used to add *methods* to an existing multimethod. Here `:string` is the *dispatch value*, and the method returns the form as is.

```klipse-clojure
(defmethod emit-bash
  :string
  [form]
  form)
```

Similar for numbers and lists:

```klipse-clojure
(defmethod emit-bash
  :number
  [form]
  (str form))

(defmethod emit-bash
  :list
  [form]
  (case (name (first form))
    "println" (str "echo " (second form))))
```

Adding new methods has the same result as extending our `cond` expression, except:

* multimethods handle the dispatch, instead of writing it manually
* anyone can extend the multimethod at any point, without disturbing existing code

So how can we use `emit-bash`? Calling a multimethod is just like calling any Clojure function.

```klipse-clojure
(emit-bash '(println "a"))
```

The dispatch is silently handled under the covers by the multimethod.

## Extending our DSL for Batch Script

Let’s say I’m happy with the Bash implementation. I feel like starting a new implementation that generates Windows Batch script. Let’s define a new multimethod, emit-batch.

```klipse-clojure
(defmulti emit-batch
          (fn [form]
            (cond
              (list? form) :list
              (string? form) :string
              (number? form) :number
              :else (throw (ex-info "Unknown type" form)))))

(defmethod emit-batch 
  :list
  [form]
  (case (name (first form))
    "println" (str "ECHO " (second form))
    nil))

(defmethod emit-batch
  :string
  [form]
  form)

(defmethod emit-batch
  :number
  [form]
  (str form))
```

We can now use `emit-batch` and `emit-bash` when we want Batch and Bash script output respectively.

```klipse-clojure
(emit-batch '(println "a"))
```

```klipse-clojure
(emit-bash '(println "a"))
"echo a"
```

## Ad-hoc Hierarchies

Comparing the two implementations reveals many similarities. In fact, the only dispatch that differs is clojure.lang.PersistentList!

Some form of implementation inheritance would come in handy here.

We can tackle this with a simple mechanism Clojure provides to define global, ad-hoc hierarchies.

When I say this mechanism is simple, I mean non-compound; inheritance is not compounded into the mechanism to define classes or namespaces but rather is a separate functionality.

Contrast this to languages like Java, where inheritance is tightly coupled with defining a hierarchy of classes.

We can derive relationships from names to other names, and between classes and names. Names can be symbols or keywords. This is both very general and powerful!

We will use `(derive child parent)` to establishes a parent/child relationship between two keywords. `isa?` returns `true` if the first argument is derived from the second in a global hierarchy.

```klipse-clojure
(derive ::child ::parent)

(isa? ::child ::parent)
```

Let’s define a hierarchy in which the Bash and Batch implementations are siblings.

```klipse-clojure
(derive ::bash ::common)
(derive ::batch ::common)
```

Let’s test this hierarchy.

```klipse-clojure
(parents ::bash)
```

```klipse-clojure
(parents ::batch)
```

## Utilizing a Hierarchy in a Multimethod

We can now define a new multimethod emit that utilizes our global hierarchy of names.

```klipse-clojure
(defmulti emit
          (fn [form]
            [*current-implementation*
             (cond
               (list? form) :list
               (string? form) :string
               (number? form) :number
               :else (throw (ex-info "Unknown type" form)))]))
```

The dispatch function returns a vector of two items: the current implementation (either `::bash` or `::batch`), and the class of our form (like `emit-bash`'s dispatch function).

`*current-implementation*` is a dynamic var, which can be thought of as a thread-safe global variable.

```klipse-clojure
(def ^{:dynamic true}
  ;; The current script language implementation to generate
  *current-implementation*)
```

In our hierarchy, `::common` is the parent, which means it should provide the methods in common with its children. Let's fill in these common implementations.

Remember the dispatch value is now a vector, notated with square brackets. In particular, in each defmethod the first vector is the dispatch value (the second vector is the list of formal parameters).

```klipse-clojure
(defmethod emit [::common :string]
  [form]
  form)

(defmethod emit [::common :number]
  [form]
  (str form))
```

This should look familiar. The only methods that needs to be specialized are those for clojure.lang.PersistentList, as we identified earlier. Notice the first item in the dispatch value is `::bash` or `::batch` instead of `::common`.

```klipse-clojure
(defmethod emit [::bash :list]
  [form]
  (case (name (first form))
    "println" (str "echo " (second form))
    nil))

(defmethod emit [::batch :list]
  [form]
  (case (name (first form))
    "println" (str "ECHO " (second form))
    nil))
```

The `::common` implementation is intentionally incomplete; it merely exists to manage any common methods between its children.

We can test emit by rebinding `*current-implementation*` to the implementation of our choice with binding.

```klipse-clojure
(binding [*current-implementation* ::common]
         (emit "a"))
```

```klipse-clojure
(binding [*current-implementation* ::batch]
  (emit '(println "a")))
```

```klipse-clojure
(binding [*current-implementation* ::bash]
  (emit '(println "a")))
```

```klipse-clojure
(binding [*current-implementation* ::common]
  (emit '(println "a")))
```

Because we didn’t define an implementation for `[::common :list]`, the multimethod falls through and throws an Exception.

Multimethods offer great flexibility and power, but with power comes great responsibility. Just because we can put our multimethods all in one namespace doesn’t mean we should. If our DSL becomes any bigger, we would probably separate all Bash and Batch implementations into individual namespaces.

This small example, however, is a good showcase for the flexibility of decoupling namespaces and inheritance.

## Icing on the Cake

We’ve built a nice, solid foundation for our DSL using a combination of multimethods, dynamic vars, and ad-hoc hierarchies, but it’s a bit of a pain to use.

```klipse-clojure
(binding [*current-implementation* ::bash]
  (emit '(println "a")))
```

Let’s eliminate the boilerplate. But where is it?

The binding expression is an good candidate. We can reduce the chore of rebinding *current-implementation* by introducing with-implementation (which we will define soon).

```clojure
(with-implementation ::bash
  (emit '(println "a")))
```

That’s an improvement. But there’s another improvement that’s not as obvious: the quote used to delay our form’s evaluation. Let’s use script, which we will define later, to get rid of this boilerplate:

```clojure
(with-implementation ::bash
  (script
    (println "a")))
```

This looks great, but how do we implement script? Clojure functions evaluate all their arguments before evaluating the function body, exactly the problem the quote was designed to solve.

To hide this detail we must wield one of Lisp’s most unique forms: the macro.

The macro’s main drawcard is that it doesn’t implicitly evaluate its arguments. This is a perfect fit for an implementation of script.

```klipse-clojure
(defmacro script [form]
  `(emit '~form))
```

To get an idea what is happening, here’s what a call to script returns and then implicitly evaluates.

```klipse-clojure
(macroexpand '(script (println "a")))
```

It isn’t crucial that you understand the details, rather appreciate the role that macros play in cleaning up the syntax.

We will also implement with-implementation as a macro, but for different reasons than with script. To evaluate our script form inside a binding form we need to drop it in before evaluation.

```klipse-clojure
(defmacro with-implementation
  [impl & body]
  `(binding [cljs.user/*current-implementation* ~impl]
     ~@body))
```

Roughly, here is the lifecyle of our DSL, from the sugared wrapper to our unsugared foundations.

```clojure
(with-implementation ::bash
  (script
    (println "a")))
=>
(with-implementation ::bash
  (emit
    '(println "a"))
=>
(binding [*current-implementation* ::bash]
  (emit
    '(println "a")))
```

Let's see it in action for Bash:

```klipse-clojure
(with-implementation ::bash
  (script
    (println "a")))
```

And for Windows:

```klipse-clojure
(with-implementation ::batch
  (script
    (println "a")))
```
It’s easy to see how a few well-placed macros can put the sugar on top of strong foundations. Our DSL really looks like Clojure code!

## Conclusion

We have seen many of Clojure’s advanced features working in harmony in this DSL, even though we incrementally incorported many of them. Generally, Clojure helps us switch our implementation strategies with minimum fuss.

This is notable when you consider how much our DSL evolved.

We initially used a simple `cond` expression, which was converted into two multimethods, one for each implementation. As multimethods are just ordinary functions, the transition was seamless for any existing testing code. (In this case I renamed the function for clarity).

We then merged these multimethods, utilizing a global hierachy for inheritance and dynamic vars to select the current implementation.

Finally, we devised a pleasant syntactic interface with a two simple macros, eliminating that last bit of boilerplate that other languages would have to live with.

I hope you have enjoyed following the evolution of our little DSL. This DSL is based on a simplified version of [Stevedore](https://github.com/pallet/stevedore) by [Hugo Duncan](http://hugoduncan.org/). If you are interested in how this DSL can be extended, you can do no better than browsing the source code of [Stevedore](https://github.com/pallet/stevedore).

## Copyright

Copyright Ambrose Bonnaire-Sergeant, 2013
