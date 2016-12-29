---
title: "Elm Datenstrukturen (1)"
subtitle: "Listen, Arrays, Sets und Dictionaries"
ogImage: elm
lang: de
alternate:
  lang: en
  href: /articles/elm-data-structures-list-array-set-dict.html
tags:
  - Elm
  - Frontend-Entwicklung
  - Datenstrukturen
  - List
  - Array
  - Set
  - Dict
description: "In Elm gibt es verschiedene Datenstrukturen, die Elemente enthalten können. Dieser Artikel widmet sich den iterierbaren Strukturen Listen, Arrays, Sets und Dictionaries."
---

In Elm gibt es verschiedene Datenstrukturen, die Elemente enthalten können. Dieser Artikel widmet sich den iterierbaren Strukturen Listen, Arrays, Sets und Dictionaries, welche sich alle mit den Kernoperationen funktionaler Programmierung (`map`, `filter` und folding/reducing) verarbeiten lassen.

<!-- more -->

Alle dieser Datenstrukturen haben gemeinsam, dass sie immer nur den gleichen Typ an Elementen enthalten können – beispielsweise eine Liste von Strings: `List String`. Dies wird durch den Compiler sichergestellt und ist ein Unterschied im Vergleich zu JavaScript, wo Arrays Elemente mit unterschiedlichsten Typen enthalten können.

Die verschiedenen Datenstrukturen gleichen sich zum Teil durch ein gemeinsames "Interface" von Funktionen, mit denen man über die enthaltenen Elemente iterieren und diese Verarbeiten kann. Neben den Basisoperationen `map`, `filter`, `foldl`/`foldr` (dem JavaScripter als `reduce` bekannt) stehen auch einfache Abfragefunktionen wie `isEmpty` oder `member` zur Verfügung. Letztere wird von Arrays allerdings nicht unterstützt, womit wir nun auch bei den Unterschieden und Anwendungsfällen der einzelnen Datenstrukturen wären …

### Listen

Listen sind die essentiellste und am häufigsten benutzte Datenstruktur in Elm. Eine Liste lässt sich auf verschiedene Arten erzeugen: *(wie im letzten Artikel zu [Funktionen](elm-funktionen.html) erklärt, lassen sie diese Beispiele auch gut mit der REPL ausführen.)*

```elm
list = [1, 2, 3, 4]
listFromRange = [1..4]
listByAppending = [1, 2] ++ [3, 4]
listByPrepending = 1 :: 2 :: 3 :: 4 :: []

-- [1,2,3,4] : List number
```

Von der Syntax her erinnern Listen an Arrays aus JavaScript, der wichtigste Unterschied dabei ist jedoch, dass sie über die Standardbibliothek keinen Zugriff auf die Elemente per Index unterstützen. Natürlich lässt sich diese Funktionalität implementieren und wird auch über das [List-Extra](http://package.elm-lang.org/packages/circuithub/elm-list-extra/3.9.0/List-Extra) Modul bereitgestellt, jedoch kommt dieser Anwendungsfall in der funktionalen Verarbeitung von Listen eigenlich nicht vor und dürfte nur äußerst selten benötigt werden. Üblicherweise werden Funktionen wie `filter`, `head` und `tail` genutzt, um bestimmte Elemente oder Teilbereiche einer Liste zu selektieren:

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

Da in Elm alle Daten unveränderbar/immutable sind, geben transformierende Funktionen wie `filter`, `concat` oder `take` immer eine neue Instanz zurück. Wie bei den Funktionen `head` und `tail` zu sehen, wird dabei jedoch nicht immer direkt eine neue Liste erzeugt, sondern ggf. eine Instanz von `Maybe` zurückgegeben. Dies ist darauf zurückzuführen, dass es in Elm keine Werte wie `null` oder `undefined` gibt, aber es beispielsweise im Fall einer leeren Liste trotzdem einen Rückgabewert geben muss. Da dies über den Rahmen dieses Artikels hinaus geht, sehen wir uns den Typ `Maybe` in einem weiteren Artikel an.

Eine Übersicht aller Listenfunktionen findet sich in der Dokumentation des [List](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/List)-Moduls.

### Arrays

Wie bereits erwähnt, lässt sich auf Elemente in einem [Array](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Array) direkt über den Index zugreifen. Wie in JavaScript auch, sind Arrays 0-basiert. Ebenso bieten Arrays gegenüber Listen die Möglichkeit, Elemente gezielt anhand des Index zu ersetzen:

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

Die Möglichkeit, mit Elementen auf Basis des Index zu operieren, bietet für bestimmte Anwendungsfälle wie das gezielte Zugreifen und Ersetzen von Elementen Vorteile in Sachen Performance. Durch die Implementierung von [Arrays als Relaxed Radix Balanced Trees](http://elm-lang.org/blog/announce/0.12.1) sind die Zugriffe und Modifikationen von Teilbereichen insbesondere im Fall von Arrays mit vielen Elementen sehr schnell.

Nichtsdestotrotz sind Arrays – sowie auch Sets und Dictionaries – in Elm quasi Datenstrukturen zweiter Klasse. Dies liegt zum einen daran, dass der Großteil der Anwendungsfälle sich gut über Listen abbilden lässt und zum anderen daran, dass es aktuell [keine Literal-Syntax](https://github.com/elm-lang/elm-plans/issues/12) für diese Datentypen gibt. Letzteres macht den Umgang mit ihnen etwas sperrig, da sie nicht wie Listen direkt über eine Kurzschreibweise zu erstellen sind und sich daher auch weniger für den Einsatz in domänenspezifischen Sprachen wie elm-html eignen.

Aus diesem Grund beschränken wir uns bei den folgenden beiden Datenstrukturen in Kürze auf ihre jeweiligen Anwendungsfälle …

### Sets

Ein [Set](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Set) ist eine Sammlung von eindeutigen Werten. Das bedeutet, dass es in einem Set keinen gleichen Wert mehrmals gibt, was beispielsweise das Filtern von Duplikaten überflüssig macht.

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

Sets eignen sich wie zu sehen insbesondere für vergleichende Operationen, bei denen die Überschneidung, Vereinigung oder Unterschiede zweier Sets gebildet werden sollen.

### Dictionaries

Die Datenstruktur [`Dict`](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Dict) eignet sich, um Schlüssel-Wert-Paare abzulegen. Die Schlüssel sind dabei eindeutig und können Werte eines jeden vergleichbaren Datentyps sein – neben `String` und `Int` sind somit auch `Float` und `Time`-Werte mögliche Schlüssel.
Die Werte können von einem beliebigen Typen sein, wie bei den anderen Datentypen auch ist jedoch Vorraussetzung, dass die Werte alle vom gleichen Datentyp sind.

Ein möglicher Datentyp ist dabei der Record, welchen wir in diesem Beispiel verwenden und den wir uns im kommenden Artikel über die Datenstrukturen Tuples und Records näher ansehen werden:

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

Im nächsten Artikel kommen wir zu den Datenstrukturen [Record und Tupel](/articles/elm-datenstrukturen-record-tuple.html), die jeweils Elemente unterschiedlicher Typen enthalten können.
