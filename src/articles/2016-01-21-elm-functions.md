---
title: "Elm Functions"
subtitle: "Syntax, Piping, and Currying"
updated: 2016-01-21T11:00
lang: en
alternate:
  lang: de
  href: /articles/elm-funktionen.html
tags:
  - Elm
  - Frontend development
  - Functions
  - Functional Programming
description: "This article spotlights the central construct of the Elm programming language: Functions. What does the definition of a function look like, how can functions be chained via piping and what the heck is currying?"
---

This article spotlights the central construct of the Elm programming language: Functions. What does the definition of a function look like, how can functions be chained via piping and what the heck is currying? Let us have a closer look …

<!-- more -->

### REPL

The *read-evaluate-print-loop* is a runtime environment for executing Elm code. The result of an expression is immediately shown, which makes the REPL an ideal tool for running short code samples and getting used to the syntax and language constructs. The REPL is part of the Elm standard installation and it can be opened on the command line:

```bash
$ elm-repl
```

The examples in this article can be run in the REPL. Multiline statements have to end with `\`. This is not the case for normal Elm code, but the examples in this article use the backslash so that you can copy, paste and execute them in the REPL. I've added the output of each expression in the examples as `-- comment`.

### Calling functions

Before we take a look at how functions are defined, we will use functions from the [String module](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/String) which is part of the standard library. To use its functions we first need to import it.

```elm
import String

String.append
-- <function: append> : String -> String -> String

String.append "h" "i"
-- "hi" : String
```

Calling a function without any argument gives us its signature. As you can see with `String.append`, the signature consists of the name and the types of the arguments and the return value. The type of the return value is not separated differently than the argument types, it is just the last element of the list.

```
<function: append> : String         -> String         -> String
| function name    | type argument 1 | type argument 2 | type result |
```

In Elm the **arguments are separated with spaces**, as you can see with `String.append "h" "i"`. There are also **no parentheses around the arguments**. Instead one uses parentheses to encapsulate the whole function call in case the result should be used as an argument for another function call. Which brings us to the topic of …

### Piping: Chaining functions

Of course return values can be used as arguments for subsequent function calls. In Elm there are two ways to chain the calls:

```elm
String.repeat 3 (String.toUpper (String.append "h" "i"))
-- "HIHIHI" : String

String.append "h" "i" |> String.toUpper |> String.repeat 3
-- "HIHIHI" : String

String.repeat 3 <| String.toUpper <| String.append "h" "i"
-- "HIHIHI" : String
```

Using the pipe-operators `|>` or `<|` one can pass through the result to the next function where it is used as the last argument for the function it gets piped into. The data can flow in both directions, though the usual way of chaining functions with the pipe operator is using `|>` and having a single line per function call:

```elm
String.append "h" "i" \
    |> String.toUpper \
    |> String.repeat 3
```

### Function definition and type annotation

Custom functions are defined with the name and arguments, which are separated from the function body by an equal sign. They can be written on a single line or using multiple lines:

```elm
sayHello name = String.append "Hello " name
-- <function> : String -> String

sayHello name = \
    String.append "Hello " name
-- <function> : String -> String
```

In addition to that its advisable to also use a type annotation. This is not a must, as the Elm compiler uses type inference to determine the types based on the argument usage in the program. Nevertheless its better to state the expected argument types explicitly as one ensures the correct type will be used and it also documents the program.

Type annotations are prepended to the function definition and state the function name as well as the types of the arguments and of the return value.

```elm
sayHello : String -> String
sayHello name =
    String.append "Hello " name
```

To learn more about this specific feature, see the dedicated article about [type annotations in Elm](elm-type-annotations.html).

### Anonymous functions / lambdas

Anonymous functions do not have a function definition. They are defined inline and are often used as arguments for functions like `List.map`. They are parenthesized and the content is prefixed with a backslash:

```elm
(\x y -> x * y)
-- <function> : number -> number -> number

(\x y -> x * y) 2 3
-- 6 : number

List.map (\n -> sayHello n) ["Alice", "Bob"]
-- ["Hello Alice","Hello Bob"] : List String
```

### Currying

Functions in Elm support *currying* – a technique of translating the evaluation of a function that takes multiple arguments into a function that takes a single argument.

In the following example the function `threeTimes` encapsulates a partial call of `String.repeat` and returns a function that expects the last argument:

```elm
threeTimes = String.repeat 3
-- <function> : String -> String

threeTimes "hi"
-- "hihihi" : String
```

Currying is often used to prepare a function that expects multiple arguments for use as an argument of a function that passes only one argument (like `List.map`).

For more examples and an in-depth explanation head over to LambdaCat: [Currying, The Unknown](http://www.lambdacat.com/road-to-elm-currying-the-unknown/).

Now that you know about functions, let us have a closer look at [data structures in Elm](/articles/elm-data-structures-list-array-set-dict.html).
