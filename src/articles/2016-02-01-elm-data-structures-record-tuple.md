---
title: "Elm Data Structures (2)"
subtitle: "Records and Tuples"
ogImage: elm
updated: 2016-12-06
elmVersion: 0.18
lang: en
alternate:
  lang: de
  href: /articles/elm-datenstrukturen-record-tuple.html
tags:
  - Elm
  - Frontend development
  - Data structures
  - Record
  - Tuple
description: "Records and tuples can contain an arbitrary amount of elements – as opposed to lists, arrays, sets and dictionaries these elements do not have to be of the same data type."
---

After we have already covered the iterable data structures in the previous article, we will now work wth records and tuples, which can contain elements of different types. We will also have a look at how to access values using destructuring and get to know about type aliases …

<!-- more -->

Records and tuples can contain an arbitrary amount of elements – as opposed to [lists, arrays, sets and dictionaries](/articles/elm-data-structures-list-array-set-dict.html) these elements do not have to be of the same data type. Because of that tuples and records are suited well for representing more complex element structures and objects. Before we will cover both of them in detail, let us first talk about _type aliases_, which can be used to further describe records and tuples and make them more expressive.

### Type Aliases

The keyword `type` defines a new data type which did not exist before. Opposed to that `type alias` gives an extra name to an already existing type. It does not create a distinct data type but can be used to reference another type and give it a more expressive meaning for the context the data is used in. Type aliases can be defined on the root level of a program as well as in `let/in` expressions.

```elm
type alias Login = String
type alias Age = Int
type alias IsAdmin = Bool
```

They are used to further describe data structures. A type alias can be defined for basic data types and we will use them in the upcoming examples to give more meaning to our tuples and records.

### Tuples

A tuple is an ordered collection of values, which can consist of two or more elements. In Elm tuples are created using the literal syntax of two surrounding parenthesis – the order as well as the count of values need to be the same for every tuple of the same type (defined by a type alias).

```elm
-- tuple without type definition
coordinates = (53.1201749, 8.5962037)

-- tuple with type definition
area : (Int, Int)
area = (42, 23)

-- tuple with type alias
type alias IsValid = Bool
type alias Message = String
type alias ValidationResult = (IsValid, Message)

success : ValidationResult
success = (True, "All is good.")

error : ValidationResult
error = (False, "Something went wrong.")
```

Tuple are suitable for creating simple, short data structures – i.e. to return multiple values from a function. For accessing the values of a tuple with two values one can use the functions `first` and `second`, for tuples with three or more values one has to use destructuring.

### Destructuring

With destructuring we can access the values of a tuple and directly assign these values to other variables. Using `_` one can define placeholders for values that will be ignored or skipped.

```elm
coordinates = (53.1201749, 8.5962037)
(latitude, longitude) = coordinates

error = (False, "Something went wrong.", ["username", "email"])
(isValid, _, invalidFields) = error

-- works even with nested tuples
(a, (b, c, (d, e), _), _) = (1, (2, 3, (4, 5), 6), 7)
```

For further [explanations for destructuring](http://www.lambdacat.com/road-to-elm-destructuring/) see the LambdaCat article which also contains more examples and a comparison to destructuring in JavaScript.

### Records

For more complex structures records are a better fit than tuples. Records consist of key-value pairs, which makes them similar similar to objects in JavaScript. They are created using the literal syntax of two surrounding curly braces and they can be described further using a type alias.

```elm
-- record without type definition
coordinate =
    { latitude = 53.1201749
    , longitude = 8.5962037
    }


-- record with type definition
area : { width : Int, height : Int }
area =
    { width = 42
    , height = 23
    }


-- record with type definition via type alias
type alias User =
    { login : String
    , isAdmin : Bool
    }


alice : User
alice =
    { login = "alice"
    , isAdmin = False
    }


bob : User
bob =
    { login = "bob"
    , isAdmin = True
    }
```

Values of a record can be accessed by means of these techniques:
- Directly with the dot syntax (similar as in JavaScript)
- Using the standalone function with dot notation
- Destructuring

```elm
alice.isAdmin
-- False : Bool

.login bob
-- "bob" : String

List.filter .isAdmin [alice, bob]
-- [{ login = "bob", isAdmin = True }] : List User

{ login, isAdmin } = alice
login
-- "alice" : String
```

When using destructuring it is required to name the variable the value gets assigned to after the key of the according record value.

Using the standalone function with dot notation is a shortcut for the functionally equivalent option of using  an anonymous function: `(.isAdmin bob) == ((\u -> u.isAdmin) bob)`

Generally you do not have the options to access keys of a record that do not exist – as opposed to JavaScript objects. The compiler will give you an error for that, which is quite nice and a timesaver.

#### Updating records

To edit records one can create a new record based on an existing one. The name of the existing records and the fields you want to edit are separated by a `|` and one can change single or multiple values:

```elm
aliceTheAdmin =
    { alice | isAdmin = True }


aliceTheMightyAdmin =
    { alice
        | name = "mighty-alice"
        , isAdmin = True
    }
```

#### Extensible records

Last but not least there is also the concept of extensible records, which can be thought of as field mixins. An extensible record defines a type that has at least certain fields. This can be used for writing functions that take records which might not be of the same type but which share a common set of fields:

```elm
type alias Authorized user =
    { user
        | canEdit : Bool
        , canDelete : Bool
    }


alice : Authorized (User)
alice =
    { login = "alice"
    , isAdmin = False
    , canEdit = True
    , canDelete = False
    }


bob : Authorized {}
bob =
    { canEdit = True
    , canDelete = True
    }


allowedToEdit : Authorized a -> Bool
allowedToEdit a =
    a.canEdit

allowedToEdit alice
-- True : Bool

allowedToDelete alice
-- False : Bool

allowedToDelete bob
-- True : Bool
```

In this example `alice` is a `User` (as of the type defined in the earlier example), but `bob` is not. `bob` is just a simple record with the fields `canEdit` and `canDelete` that are defined in the extensible record type `Authorized`. Because both records are guaranteed to have those fields, we can use them in the same manner in the `allowedToEdit` and `allowedToDelete` functions – regardless of their exact type.

After we have looked at the iterable data structures as well as tuples and records the last article in the series about data structures in Elm will cover the _union type_. In contrast to the structures we have seen up to now a union type can be of multiple different data types.
