---
title: "Elm Module und Imports"
subtitle: "Das Modulsystem"
lang: de
alternate:
  lang: en
  href: /articles/elm-modules-import.html
tags:
  - Elm
  - Frontend-Entwicklung
  - Module
  - Import
---

Im vorigen Artikel, der das [Elm-Setup](elm-setup.html) beschreibt, benötigten wir schon ein Modul, das importiert werden musste. Durch das Importieren/Laden eines Moduls werden dessen Funktionalitäten im Kontext der importierenden Datei bereitgestellt. In Elm gibt es verschiedene Formen des Modulimports, die wir uns in diesem Artikel näher ansehen werden.

<!-- more -->

### Das Elm-Modulsystem

In Elm gibt es drei Arten von Quellen, aus denen man Module importieren kann:

* Die Standardbibliothek
* Zusätzlich installierte Module (über den Paketmanager)
* Eigene Module aus dem Projekt

Eine kleine Anzahl von Modulen aus der Elm-Standardbibliothek sind generell schon standardmäßig importiert und stehen ohne expliziten Import zur Verfügung. Dazu gehören in Elm 0.16.0 beispielsweise `Basics`, `Debug`, `List`, `Maybe`, `Result` und `Signal`, welche essentielle Teile der Funktionalität eines Programms bereitstellen.

Die Standardbibliothek von Elm ist auf reine Kernfunktionalitäten beschränkt, dafür gibt es aber einen umfangreichen Satz von Zusatzmodulen, die sich über den Paketmanager installieren lassen. Wie beispielsweise das Paket [`elm-html`](http://package.elm-lang.org/packages/evancz/elm-html/latest/), das wir für die folgenden Beispiele benötigen.

```bash
$ elm-package install evancz/elm-html
```

Bevor wir zu der Definition eigener Module kommen, sehen wir uns die verschiedenen Import-Arten an …

### Qualified Imports

Wir erweitern das Hello World-Beispiel aus dem vorigen Artikel und sehen uns die einfachste Art des `import`-Statements an:

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
      [ Html.text "HTML, mit Qualified Imports." ]
    ]
```

Um HTML zu erzeugen, importieren wir das [`Html`](http://package.elm-lang.org/packages/evancz/elm-html/latest/)-Modul und das dazugehörige Untermodul `Html.Attributes`, welches die Hilfsfunktionen zur Erstellung von Attributen enthält. Darüber hinaus gibt es beispielsweise auch noch das Untermodul `Html.Events`, mit dem man Event-Bindings für die einzelnen Elemente erzeugen kann.

Merkmal des *Qualified Import* ist, dass man das importierte Modul in seiner voll-qualifizierten Form referenzieren muss. Funktionen können somit nur über die vollständige Referenzierung inklusive Modulname ausgeführt werden und auch der Modultyp selbst ist nur mittels des Qualifiers (in diesem Beispiel `Html.Html`) referenzierbar.

Wie man sieht, führt dies bei häufig verwendeten Modulen zu viel Redundanz, was uns direkt zur nächsten Art Import führt …

### Unqualified Imports

Mittels des Keywords `exposing` lässt sich festlegen, welche Teile des Moduls auch ohne Qualifier verfügbar sind.


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
      [ text "HTML, mit Unqualified Imports." ]
    ]
```

Dabei lassen sich wie man sieht sowohl einzelne Identifier (Modul- und Funktionsnamen, siehe `Html`-Import) bereitstellen oder eben einfach alle Identifier des Moduls, wie beim Import von `Html.Attributes`.

### Import Alias

Über die reine Import-Funktionalität hinaus gibt es noch die Möglichkeit, einen Alias für das Modul festzulegen:

```elm
import HelperFunctions as Utils
```

Die in `HelperFunctions` definierten Funktionen sind dabei dann über das Präfix `Utils` referenzierbar.

### Wann benutzt man was?

Für den Import von Modulen gibt es ein paar naheliegende Best Practices:

* Grundsätzlich sollte man versuchen, möglichst den *Qualified Import* zu nutzen, weil darüber klar ersichtlich ist, welches Modul welche Funktionalität bereitstellt.
* Bei oft verwendeten Identifiern ist es jedoch ratsam, auf den *Unqualified Import* zurückzugreifen, um Redundanz zu vermeiden und den Code dadurch leserlicher zu gestalten. Dies ist beispielsweise bei der Verwendung der HTML-Module oft der Fall.
* Ein *Alias* sollte nicht verwendet werden, um Modulnamen kryptisch zu verkürzen. Man sollte lieber auf eine sprechende Variante setzen, als beispielsweise etwas wie `import Html as H` zu nutzen.

### Eigene Module definieren

So lange wir an einer simplen App arbeiten, die in einer einzigen Datei enthalten ist, ist alles sehr einfach. In diesem Fall braucht man nicht einmal eine Moduldefinition, da der Compiler annimmt, dass man im `Main`-Modul arbeitet. Bei größeren Projekten macht es allerdings Sinn, die Applikation in eigenständige Module aufzuteilen.

Module werden am Anfang einer Datei definiert. Optional kann man angeben, welche Teile der Funktionalität exportiert werden sollen – lässt man diese Anweisung aus, wird alles exportiert, was äquivalent zu der Definition mit `(..)` ist.

```elm
-- default module definition
module Main where

-- custom module exporting everything
module FullAwesomeness (..) where

-- custom module exporting only the specified types and functions
module Restricted (ImportableType, importableFunction) where
```

Jetzt wo wir wissen, wie man Module definieren und importieren kann, sehen wir uns im nächsten Schritt das zentrale Sprachkonstrukt in Elm an: [Funktionen](/articles/elm-funktionen.html).
