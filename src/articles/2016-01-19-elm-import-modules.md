---
title: "Elm Imports"
subtitle: "The module system"
lang: en
alternate:
  lang: de
  href: /articles/elm-imports.html
tags:
- Elm
- Frontend development
---

In the previous article which describes [how to setup your first Elm project](elm-setup-first-project.html) we already needed to import a module. Importing a module exposes its functionality in the context of the program that is loading the module. In Elm there are different ways to import modules and we will have a look at these in this article.

<!-- more -->

### The Elm module system

Elm has three sources from which modules can be imported:

* The standard library
* Additionally installed modules (via the package manager)
* Custom modules from the current project

Some of the modules from the standard library are imported by default and can be used without explicitly importing them: In Elm 0.16.0 these are `Basics`, `Debug`, `List`, `Maybe`, `Result`, and `Signal`.

The standard library covers the most essential parts of the functionality in Elm, but there is already a wide range of additional modules that can be installed via the package manager. One of them is the [`elm-html`](http://package.elm-lang.org/packages/evancz/elm-html/latest/) package which we will use in the examples below. To import the package we first need to install it:

```bash
$ elm-package install evancz/elm-html
```

We will take a look at how to define custom modules in a later article, for now let us focus on the different ways to import modules …

### Qualified Imports

We are going to expand upon the Hello World example from the previous article. It already showed the simplest way of using the `import` statement:

```elm
import Html
import Html.Attributes

main : Html.Html
main =
    Html.div
        [ Html.Attributes.class "wrapper" ]
        [ Html.h1
            [ Html.Attributes.class "headline" ]
            [ Html.text "Hello World" ]
        , Html.p []
            [ Html.text "HTML, with qualified imports." ]
        ]
```

To generate HTML we import the [`Html`](http://package.elm-lang.org/packages/evancz/elm-html/latest/) module and the accompanying submodule `Html.Attributes`, which includes helper functions for creating HTML attributes. There is also the submodule `Html.Events` for attaching event bindings to elements.

When using a *qualified import* one has to reference the modules functions by their fully-qualified name. This means you have to state their name including the module name and even the type of the module can only be referenced with the full qualifier (in this case `Html.Html`).

As you can see this leads to some redundance in case a modules is used often. This brings us to the next type of imports …

### Unqualified Imports

Using the keyword `exposing` one can define which parts of the module should be available without using the qualifier.


```elm
-- exposing single identifiers
import Html exposing (Html, div, h1, p)

-- exposing everything
import Html.Attributes exposing (..)

main : Html
main =
    div
        [ class "wrapper" ]
        [ h1
            [ class "headline" ]
            [ text "Hello World" ]
        , p []
            [ text "HTML, with unqualified imports." ]
        ]
```

One can expose single module identifiers (module or function names, see the `Html` import) or even all of the modules identifiers, as shown with the import of `Html.Attributes`.

### Import Alias

Beyond the basic import functionality there is also a way of defining an alias for the imported module:

```elm
import HelperFunctions as Utils
```

In this example the functions defined in `HelperFunctions` will be available by using `Utils` as qualifier/prefix.

### When to use which kind of import?

These are some best practices to consider when importing a module:

* You should try your best to use *qualified imports* as much as possible, as they offer the clearest way to show which module functionality is coming from.
* For often used identifiers its best though, to use an *unqualified import*. This prevents redundancy and helps to keep the code clean. The HTML modules are a good example for this.
* An *alias* should not be used to shorten module names to something meaningless and cryptic like `import Html as H`. Instead one should define a suitable name that reveals the intention or the purpose of the given module.
