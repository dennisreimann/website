---
title: "Elm Data Structures (3)"
subtitle: "Union Types"
ogImage: elm
updated: 2016-12-06
elmVersion: 0.18
lang: en
alternate:
  lang: de
  href: /articles/elm-datenstrukturen-union-type.html
tags:
  - Elm
  - Frontend development
  - Data structures
  - Union Type
description: "By defining a union type one always creates a new type that did not exist before. A union type can be an amalgamation of different types – but it does not have to be."
---

Now that we have already looked at the data structures [lists, arrays, sets and dictionaries](/articles/elm-data-structures-list-array-set-dict.html) as well as [records and tuples](/articles/elm-data-structures-record-tuple.html), there is only one more basic structure we need to talk about: The so called *Union Type*.

<!-- more -->

By defining a union type one always creates a new type that did not exist before. As opposed to the other data structures we already covered, a union type can be an amalgamation of different types – but it does not have to be.

In its simplest form it can be thought of as an enumeration:

```elm
type PullRequestState
    = Proposed
    | Rejected
    | Merged
```

This statement creates the type PullRequestState which can have one of the three mentioned values. These values are also called *tags* and are used to distinguish between the possibilities when handling the union type in a case expression. Depending on the tag, different actions can be performed:

```elm
branchColor : PullRequestState -> String
branchColor state =
    case state of
        Proposed ->
            "yellow"

        Rejected ->
            "red"

        Merged ->
            "green"
```

So far, so unexciting – the fun begins when we start using compositions of different types. This way we can think of [union types as state machines](http://elm-lang.org/guide/model-the-problem) or even various "classes" of entities.

Let us examine this with an example in which we model the availability of a product:

```elm
module Main exposing (..)


type Availability
    = SoldOut
    | InStock Int
    | Reordered ( Int, Int )
    | Announced String


displayStatus : Availability -> String
displayStatus availability =
    case availability of
        SoldOut ->
            "Sold out"

        InStock amount ->
            "In stock: " ++ (toString amount) ++ " left."

        Reordered days ->
            let
                min =
                    toString (first days)

                max =
                    toString (second days)
            in
                "Available again in " ++ min ++ " to " ++ max ++ " days."

        Announced date ->
            "Available on " ++ date ++ "."

```

This way we have the option of associating extra information to the tags. And these can even be different types of values, like in this example …
- an integer representing the amount of items left for the `InStock` tag
- a tuple of integers defining the range of days until the product will be available again for the `Reordered` tag
- a string representing the publishing date for the `Announced` tag

```elm
displayStatus (InStock 42)
-- "In stock: 42 left." : String

displayStatus (Reordered (3,5))
-- "Available again in 3 to 5 days." : String

displayStatus (Announced "2016-12-24")
-- "Available on 2016-12-24." : String
```

Each of these items might have a different shape, but as they share the same union type, we can combine them and have a unified way of handling them. For instance we can create a list of `Availability` items and display their states – regardless of their particular form:

```elm
availabilities : List Availability
availabilities =
    [ SoldOut
    , InStock 42
    , Reordered ( 3, 5 )
    ]

List.map displayStatus availabilities
-- ["Sold out","In stock: 42 left.","Available again in 3 to 5 days."] : List String
```

This gives us an easy way of handling cases in which we would have used [subclasses, when thinking in OOP terms](https://github.com/Dobiasd/articles/blob/master/from_oop_to_fp_-_inheritance_and_the_expression_problem.md).

That's it: Now you know of the basic data structures in Elm. We will continue this series with looking at the type `Maybe` and examining pattern matching in more depth. After having covered these fundamentals we will dive into more advanced topics :)
