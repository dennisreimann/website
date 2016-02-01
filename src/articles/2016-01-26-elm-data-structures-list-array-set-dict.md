---
title: "Elm Data Structures (1)"
subtitle: "Lists, Arrays, Sets, and Dictionaries"
updated: 2016-01-27T11:00
lang: en
alternate:
  lang: de
  href: /articles/elm-datenstrukturen-list-array-set-dict.html
tags:
  - Elm
  - Frontend-Entwicklung
---

In Elm there are different kinds of data structures that can contain elements. This article spotlights the iterable structures lists, arrays, sets, and dictionaries, which support the basic operations of functional programming like `map`, `filter`, and folding/reducing.

<!-- more -->

All of these data structures require that the elements they contain have the same type – i.e. a list of strings: `List String`. The compiler takes care of enforcing the type safety, which is a difference to JavaScript, where arrays can contain elements of any type.  

The different data structures share a common "interface" of functions, which can be used to iterate over the elements and operate on them. Besides the basic operations `map`, `filter`, `foldl`/`foldr` (know to the JavaScripter as `reduce`) there are also functions like `isEmpty` or `member`. The latter is not available for arrays though, which brings us right to the differences and use cases of the different kinds of data structures …

### Lists

Lists are the essential and most used data structure in Elm. There are several ways to create a list: *(as shown in the previous article about [functions](elm-functions.html) you can use the REPL to run the code samples.)*

```elm
list = [1, 2, 3, 4]
listFromRange = [1..4]
listByAppending = [1, 2] ++ [3, 4]
listByPrepending = 1 :: 2 :: 3 :: 4 :: []

-- [1,2,3,4] : List number
```

The list syntax resembles JavaScript arrays, but the big difference to an array is that lists in Elm do not support accessing elements by index – at least not in its standard library version. Of course this functionality can be implemented and already exists in the [List-Extra](http://package.elm-lang.org/packages/circuithub/elm-list-extra/3.9.0/List-Extra) community package. Nevertheless this use case is pretty rare when operating on lists in a functional way. Instead you will be using functions like `filter`, `head` und `tail` to select certain elements or parts of a list:

```elm
list = [1,2,3,4]
-- [1,2,3,4] : List number

filteredList = List.filter (\n -> n > 2) list
-- [3,4] : List number

firstElement = List.head list
-- Just 1 : Maybe.Maybe number

restOfTheElements = List.tail list
-- Just [2,3,4] : Maybe.Maybe (List number)
```

All of the transforming functions like `filter`, `concat`, or `take` return new instances as data in Elm is immutable. Some functions like `head` and `tail` do not return a new instance of a list directly, but an instance of `Maybe` which might contain the list. This is due to the fact that Elm does not have values like `null` or `undefined` – however there must be a return value for cases like empty lists. As this is a topic on its own we will take a closer look at the type `Maybe` in a future article.

For an overview of all available list functions see the documentation of the [List](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/List) module.

### Arrays

As already mentioned an [Array](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Array) supports positional access to its elements via the index. Arrays are 0-based, like in JavaScript. As opposed to lists, arrays also support setting elements via the index:

```elm
array = Array.fromList [1,2,3,4]
-- Array.fromList [1,2,3,4] : Array.Array number

thirdElement = Array.get 2 array
-- Just 3 : Maybe.Maybe number

sliceOfArray = Array.slice 1 3 array
-- Array.fromList [2,3] : Array.Array number

modifiedArray = Array.set 2 7 array
-- Array.fromList [1,2,7,4] : Array.Array number
```

The possibility to work with elements based on the index offers performance gains for use cases like targeted access and replacing of elements. The implementation of [arrays as Relaxed Radix Balanced Trees](http://elm-lang.org/blog/announce/0.12.1) makes accessing and modification of elements and parts of an array very fast, especially when dealing with large arrays.

Nevertheless arrays – as well as sets and dictionaries – are kind of second class data structures in Elm. This due to the fact that a majority of use cases can be modeled easily with lists and that there is [no literal syntax](https://github.com/elm-lang/elm-plans/issues/12) for these data structures. The latter makes dealing with them kind of clunky as they cannot be instantiated with syntactical shortcuts. This also makes arrays, sets, and dictionaries not as well suited for domain-specific languages like elm-html.

### Sets

A [Set](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Set) guarantees a collection of unique values. This means that a set can never contain multiple elements with the same value – therefore there is no need to filter out duplicates from a set.

```elm
import Set

set1 = Set.fromList [1,2,3,4,3,2,1]
-- Set.fromList [1,2,3,4] : Set.Set number

set2 = Set.fromList [3,4,5,6]
-- Set.fromList [3,4,5,6] : Set.Set number

intersection = Set.intersect set1 set2
-- Set.fromList [3,4] : Set.Set number

union = Set.union set1 set2
-- Set.fromList [1,2,3,4,5,6] : Set.Set number

differences = Set.diff set1 set2
-- Set.fromList [1,2] : Set.Set number
```

Sets are well suited for operations in which one need to find intersections, unions, or differences of two sets.

### Dictionaries

The data structure [`Dict`](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Dict) stores key-value pairs. The keys are unique and can be of any comparable datatype value, so that besides `String` and `Int` also values of the types `Float` and `Time` can be used as keys.
The values in a dictionary can be of any type as long as all of them have the same type (which is the requirement for all data structure in Elm).  

A possible type for values is a record, which we will use in the following example and take a closer look at in the upcoming article about tuples and records:

```elm
import Dict

users = Dict.fromList \
  [ ("dennis", { email = "mail@dennisreimann.de"}) \
  , ("otherdude", { email = "otherdude@example.org"}) \
  ]

usernames = Dict.keys users
-- ["dennis","otherdude"] : List String

userRecords = Dict.values users
-- [{ email = "mail@dennisreimann.de" },{ email = "otherdude@example.org" }] : List { email : String }

dennis = Dict.get "dennis" users
-- Just { email = "mail@dennisreimann.de " } : Maybe.Maybe { email : String }
```

The next article covers the data structures [record and tuple](/articles/elm-data-structures-record-tuple.html), which can contain elements of different types.
