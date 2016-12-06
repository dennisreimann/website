---
title: "Elm Funktionen"
subtitle: "Syntax, Piping und Currying"
lang: de
alternate:
  lang: en
  href: /articles/elm-functions.html
tags:
  - Elm
  - Frontend-Entwicklung
  - Funktionen
  - Funktionale Programmierung
description: "Dieser Artikel widmet sich dem zentralen Sprachkonstrukt in Elm: Den Funktionen. Wie sieht die Definition und der Aufruf von Funktionen aus, wie kann man Funktionen über Piping verbinden und was ist überhaupt Currying?"
---

Dieser Artikel widmet sich dem zentralen Sprachkonstrukt in Elm: Den Funktionen. Wie sieht die Definition und der Aufruf von Funktionen aus, wie kann man Funktionen über Piping verbinden und was ist überhaupt Currying? All das sehen wir uns nun an …

<!-- more -->

### REPL

Das Kürzel REPL steht für *Read-Evaluate-Print-Loop* und beschreibt eine Laufzeitumgebung, in der man Elm-Code ausführen kann und das Ergebnis direkt angezeigt bekommt. Die REPL ist ein ideales Werkzeug, um kurze Codeschnippsel ausprobieren und sich so mit der Syntax und den Sprachkonstrukten von Elm vertraut zu machen.

Im Folgenden nutzen wir die REPL um die Beispiele in diesem Artikel auszuführen. Die REPL ist Teil einer jeden [Installation von Elm](elm-setup.html) und lässt sich über den folgenden Befehl auf der Kommandozeile öffnen:

```bash
$ elm-repl
```

Mehrzeilige Anweisungen müssen dabei in der REPL durch `\` verbunden werden. Dies ist in normalem Elm-Code nicht so, ich habe die Beispiele aber dementsprechend in diesem Artikel damit ausgezeichnet, so dass sie direkt in die REPL kopiert werden können.

### Funktionsaufrufe

Bevor wir uns ansehen, wie man eigene Funktionen definiert, nutzen wir erst einmal das [String-Modul](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/String) aus der Standardbibliothek. Um uns dessen Funktionen und deren Aufrufe näher anzusehen, müssen wir das entsprechende [Modul importieren](elm-imports.html) und können es anschließend verwenden. Den Output eines jeweiligen Befehls habe ich dabei als `-- Kommentar` angeführt.

```elm
import String

String.append
-- <function: append> : String -> String -> String

String.append "h" "i"
-- "hi" : String
```

Der Aufruf einer Funktion ohne Argumente teilt uns die Funktionssignatur mit. Wie bei `String.append` zu sehen, besteht diese aus dem Funktionsnamen und der Typangabe von Argumenten und Ergebniswert. Der Ergebniswert wird dabei nicht näher ausgezeichnet, sondern ist einfach das letzte Element der Liste.

```
<function: append> : String         -> String         -> String
| Funktionsname    | Typ Argument 1  | Typ Argument 2  | Typ Ergebnis |
```

In Elm werden die **Argumente durch Leezeichen getrennt**, wie bei `String.append "h" "i"` zu sehen. Ebenso werden im Vergleich zu JavaScript **keine Klammern um die Argumente** verwendet. Stattdessen werden Klammern verwendet, um den gesamten Funktionsaufruf zu kapseln, wenn das Ergebnis als Argument für einen weiteren Funktionsaufruf genutzt werden soll. Also direkt zum nächsten Thema …

### Piping: Funktionen verbinden

Funktionsergebnisse können natürlich auch direkt Argumente für weitere Funktionsaufrufe sein. In Elm gibt es dabei zwei Arten, die Aufrufe zu verbinden:

```elm
String.repeat 3 (String.toUpper (String.append "h" "i"))
-- "HIHIHI" : String

String.append "h" "i" |> String.toUpper |> String.repeat 3
-- "HIHIHI" : String

String.repeat 3 <| String.toUpper <| String.append "h" "i"
-- "HIHIHI" : String
```

Mittels des Pipe-Operators `|>` bzw. `<|` lässt sich das Ergebnis an die nächste Funktion weitergeben. Es wird dabei als letztes Argument der Funktion verwendet, in die es gepiped wird.

Wie man sieht, lässt sich der Datenfluß dabei in beide Richtungen pipen. Die gebräuchliste Art, Funktionsaufrufe durch einen Pipe-Operator zu verbinden ist dabei mittels `|>`, wobei die Funktionen dann auf einzelne Zeilen verteilt werden:

```elm
String.append "h" "i" \
    |> String.toUpper \
    |> String.repeat 3
```

### Funktionsdefinition und Typ-Annotation

Um eigene Funktionen zu definieren, gibt man den Namen und die Argumente an und trennt diese durch ein Gleichzeichen vom Funktionsinhalt. Dies kann sowohl als Einzeiler, als auch mehrzeilig geschehen:

```elm
sayHello name = String.append "Hello " name
-- <function> : String -> String

sayHello name = \
  String.append "Hello " name
-- <function> : String -> String
```

Des Weiteren kann man eine Typ-Annotation angeben. Dies ist kein Muss, da der Elm-Compiler über Typ-Inferenz verfügt und die Annotation anhand der im Programm verwendeten Argumente festlegt. Nichtsdestotrotz ist es sinnvoll die erwarteten Argumenttypen selbst anzugeben, weil man dadurch bei versehentlicher Verwendung unterschiedlicher Argumenttypen dem "Raten" des Compilers vorbeugt und nicht zuletzt das Programm zusätzlich dokumentiert.

Die Typ-Annotation wird der Funktion direkt vorangestellt und gibt dabei den Funktionsnamen und die Typen der Argumente und des Ergebniswerts an.

```elm
sayHello : String -> String
sayHello name =
    String.append "Hello " name
```

### Anonyme Funktionen / Lambdas

Anonyme Funktionen haben keine Funktionsdefinition – sie werden inline definiert und oft als Argument für Funktionen wie `List.map` genutzt. Die Syntax einer anonymen Funktion sieht vor, dass sie geklammert und der Inhalt mit einem Backslash geprefixt wird:

```elm
(\x y -> x * y)
-- <function> : number -> number -> number

(\x y -> x * y) 2 3
-- 6 : number

List.map (\n -> sayHello n) ["Alice", "Bob"]
-- ["Hello Alice","Hello Bob"] : List String
```

### Currying

Funktionen in Elm unterstützen *Currying* – die Umwandlung einer Funktion mit mehreren Argumenten in eine Funktion mit einem Argument.

Im folgenden Beispiel kapselt die Funktion `threeTimes` einen partiellen Aufruf von `String.repeat` und liefert eine Funktion zurück, die das letzte Argument erwartet:

```elm
threeTimes = String.repeat 3
-- <function> : String -> String

threeTimes "hi"
-- "hihihi" : String
```

Currying wird beispielsweise oft genutzt, um eine Funktion, die mehrere Argumente erwartet, für eine Verwendung in Funktionen, die nur ein Argument liefern (zum Beispiel `List.map`) zu verwenden.

Weitere Beispiele und eine tiefergehende Erklärung dazu finden sich bei LambdaCat: [Currying, The Unknown](http://www.lambdacat.com/road-to-elm-currying-the-unknown/).

Jetzt wo wir uns mit Funktionen auskennen, ist der nächste Schritt, dass wir die [Datenstrukturen in Elm](/articles/elm-datenstrukturen-list-array-set-dict.html) näher beleuchten.
