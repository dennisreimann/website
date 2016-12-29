---
title: "Elm Datenstrukturen (3)"
subtitle: "Union Types"
ogImage: elm
updated: 2016-12-06
elmVersion: 0.18
lang: de
alternate:
  lang: en
  href: /articles/elm-data-structures-union-type.html
tags:
  - Elm
  - Frontend-Entwicklung
  - Datenstrukturen
  - Union Type
description: "Durch die Definition eines Union Type erstellt man immer einen neuen Typ. Ein Union Type kann eine Vereinigung verschiedener Typen sein – jedoch muss er dies nicht."
---

Jetzt wo wir bereits die Datenstrukturen [Listen, Arrays, Sets und Dictionaries](/articles/elm-datenstrukturen-list-array-set-dict.html) als auch [Records und Tupel](/articles/elm-datenstrukturen-record-tuple.html) kennen, gibt es nur noch eine weitere Basisstruktur, über die wir sprechen müssen: Den sogenannten *Union Type*.

<!-- more -->

Durch die Definition eines Union Type erstellt man immer einen neuen Typ. Im Gegensatz zu den anderen Datenstrukturen, die wir bisher kennengelernt haben, kann ein Union Type eine Vereinigung verschiedener Typen sein – jedoch muss er dies nicht.

In seiner einfachsten Form kann ein Union Type als eine Art Aufzählung oder Enumeration betrachtet werden:

```elm
type PullRequestState
    = Proposed
    | Rejected
    | Merged
```

Dieser Ausdruck erstellt den Typ PullRequestState, welcher einen der drei definierten Werte annehmen kann. Diese Werte werden auch *Tags* genannt und dienen dazu, zwischen den einzelnen Möglichkeiten zu unterscheiden, wenn man den Union Type in einer Case-Anweisung verarbeitet. Abhängig vom Tag können dabei verschiedene Aktionen ausgeführt werden:

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

So weit, so unspannend – der Spaß beginnt, sobald wir anfangen Zusammenstellungen verschiedener Typen zu verwenden. Dadurch lassen sich [Union Types als State Machines](http://elm-lang.org/guide/model-the-problem) oder sogar als verschiedene "Klasses" von Daten betrachten.

Sehen wir uns diesen Fal in einem Beispiel an, in dem wir die Verzfügbarkeit eines Produkts modellieren:

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

Auf diese Art haben wir die Möglichkeit, zusätzliche Informationen an das Tag anzuhängen. Und diese weiteren Informationen können von verschiedensten Typen sein, wie in diesem Beispiel …
- ein Integer der die Anzahl des Bestands beim Tag `InStock` darstellt
- ein Tupel von Zahlen, welche die Spanne der Tage bis zur Wiederverfügbarkeit des Produkts im Fall des `Reordered` Tags angeben
- Ein String mit dem Veröffentlichungsdatum für das `Announced` Tag

```elm
displayStatus (InStock 42)
-- "In stock: 42 left." : String

displayStatus (Reordered (3,5))
-- "Available again in 3 to 5 days." : String

displayStatus (Announced "2016-12-24")
-- "Available on 2016-12-24." : String
```

Jeder dieser Einträge hat eine andere Form, doch alle Einträge sind vom gleichen Union Type, weshalb wir sie kombinieren können und einen einheitlichen Weg haben können, um sie verarbeiten zu können. Zum Beispiel können wir eine Liste von `Availability`-Einträgen erstellen und die Stati anzeigen – unabhängig von ihrer jeweiligen Form:

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

Dadurch haben wir einen einfachen Weg, um Fälle zu behandeln, in denen wir beispielsweise [eine Art Subklasse modellieren](https://github.com/Dobiasd/articles/blob/master/from_oop_to_fp_-_inheritance_and_the_expression_problem.md), wenn wir in der OOP-Terminologie denken.

Das wär's: Nach dieser dreiteiligen Artikelserie kennst du die Basis-Datenstrukturen in Elm. In den nächsten Schritten sehen wir uns den Typ `Maybe` an und betrachten Case-Anweisungen und Pattern Matching etwas näher. Danach haben wir dann die Grundlagen abgeschlossen und kümmern uns um fortgeschrittenere Themen :)
