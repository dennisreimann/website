---
title: Elm Datenstrukturen (2)
subtitle: Records und Tupel
updated: '2016-02-01T10:00'
lang: de
alternate:
  lang: en
  href: /articles/elm-data-structures-record-tuple.html
tags:
  - Elm
  - Frontend-Entwicklung
  - Datenstrukturen
  - Record
  - Tupel
description: "Records und Tupel können beliebig viele Elemente enthalten – im Gegensatz zu Listen, Arrays, Sets und Dictionaries müssen die enthaltenen Elemente jedoch nicht vom gleichen Datentyp sein."
---

Nachdem wir uns bereits die iterierbaren Datenstrukturen näher angesehen haben, kommen wir nun zu Records und Tupeln, die jeweils Elemente unterschiedlicher Typen enthalten können. Ebenso schauen wir uns an, wie man mittels Destructuring auf ihre Werte zugreifen kann und was ein Typalias ist … <!-- more -->

Records und Tupel können beliebig viele Elemente enthalten – im Gegensatz zu [Listen, Arrays, Sets und Dictionaries](/articles/elm-datenstrukturen-list-array-set-dict.html) müssen die enthaltenen Elemente jedoch nicht vom gleichen Datentyp sein. Dadurch eignen sich diese beiden Datenstrukturen gut dazu, Objekte und komplexere Elementstrukturen abzubilden. Bevor wir jedoch zu den beiden Datenstrukturen kommen, sehen wir uns erst einmal _Type Aliases_ an, mit denen man Records und Tupel näher beschreiben und sie somit ausdrucksstärker machen kann.

### Type Aliases

Mit dem Schlüsselwort `type` definiert man einen neuen, bislang nicht existierenden Datentyp. Im Gegensatz dazu vergibt man mit `type alias` eine zusätzliche Bezeichnung für bereits existierende Datentypen. Es wird kein neuer Datentyp erstellt, sondern ein bestehender Typ referenziert. Type Aliases lassen sich auf oberster Programmebene sowie in `let/in`-Anweisungen definieren.

```elm
type alias Login = String
type alias Age = Int
type alias IsAdmin = Bool
```

Dies kann man nutzen, um seine Datenstrukturen, näher zu beschreiben. Ein Typalias lässt sich sowohl für Basisdatentypen als auch für Tupel und Records vergeben.

### Tupel

Ein Tupel ist eine geordnete Sammlung von Werten, die aus zwei oder mehr Elementen besteht. Tupel werden in Elm mit dem Literal umschließender Klammern gebildet – die Reihenfolge sowie Anzahl der Werte sind bei Tupeln eines Typs (definiert durch einen Typalias) immer gleich.

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

Tupel eignen sich gut für einfache, kurze Datenstrukturen, beispielsweise um aus einer Funktion mehrere Rückgabewerte zu liefern. Bei Zweiertupeln kann man über die Funktionen `fst` und `snd` (für _first_ und _second_) auf die Werte zugreifen, bei Tupeln mit drei oder mehr Werten muss man Destructuring nutzen.

### Destructuring

Mit Destructuring lassen sich die Werte eines Tupels direkt an weitere Variablen zuweisen. Mit `_` lassen sich dabei Platzhalter für Werte angeben, die man ignorieren oder überspringen möchte.

```elm
coordinates = (53.1201749, 8.5962037)
(latitude, longitude) = coordinates

error = (False, "Something went wrong.", ["username", "email"])
(isValid, _, invalidFields) = error

-- works even with nested tuples
(a, (b, c, (d, e), _), _) = (1, (2, 3, (4, 5), 6), 7)
```

Weitere [Erklärungen zum Destructuring](http://www.lambdacat.com/road-to-elm-destructuring/) findet an bei LambdaCat.

### Records

Komplexere Datenstrukturen lassen sich besser mit Records als mit Tupeln abbilden. Records bestehen aus Schlüssel-Wert-Paaren, ähnlich wie Objekte in JavaScript. Sie werden mit dem Literal umschließender geschweifter Klammern gebildet und sie können mit einem Typalias näher beschrieben werden.

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

Auf die Werte eines Records lässt sich auf verschiedene Arten zugreifen:
- Direkt über die Punktsyntax (ähnlich wie in JavaScript)
- Mittels eigenständiger Funktion mit Punktnotation
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

Beim Destructuring von Records ist dabei zu beachten, dass der Variablenname dem Schlüsselnamen im Record entsprechen muss.

Der Zugriff über die Funktion mit Punktnotation ist dabei eine Kurzschreibweise für eine anonyme Funktion: `(.isAdmin bob) == ((\u -> u.isAdmin) bob)`

Generell ist es bei Records in Elm nicht wie bei JavaScript-Objekten möglich, auf nicht existierende Schlüssel zuzugreifen. Dies wird vom Compiler mit einer Fehlermeldung quittiert.

#### Records bearbeiten

Um einen Record zu bearbeiten, kann man auf Basis eines bestehenden Records einen neuen Record erstellen. Dabei wird der Name des bestehenden Records mit `|` von den zu bearbeitenden Eigenschaften getrennt. Es können sowohl ein als auch mehrere Werte angepasst werden:

```elm
aliceTheAdmin =
    { alice | isAdmin = True }


aliceTheMightyAdmin =
    { alice
        | name = "mighty-alice"
        , isAdmin = True
    }
```

#### Erweiterbare Records

Zu guter Letzt sei auch noch das Konzept der erweiterbaren Records erwähnt, welches man sich ähnlich wie Werte-Mixins vorstellen kann. Ein erweiterbarer Record ist ein Typ, der mindestens die definierten Felder hat. Dies lässt sich nutzen, um Funktionen zu schreiben, die Records unterschiedlicher Typen entgegennehmen, welche aber ein gemeinsames Set Felder unterstützen:

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

In diesem Beispiel is `alice` ein `User` (vom Typ der bereits im vorigen Beispiel definiert wurde), `bob` ist dies allerdings nicht. `bob` ist ein einfacher Record mit den Feldern `canEdit` und `canDelete`, die durch den erweiterbaren Recordtyp `Authorized` definiert wurden. Da beide Records jedoch garantieren, diese Felder zu haben, können sie auf die gleiche Art und Weise in den Funktionen `allowedToEdit` und `allowedToDelete` genutzt werden – unabhängig von ihrem exakten Typ.

Nachdem wir nun sowohl die iterierbaren Datenstrukturen als auch Records und Tupel kennen, widmen wir uns im letzten Artikel der Reihe über Datenstrukturen in Elm dem _Union Type_. Im Gegensatz zu den bisher besprochenen Strukturen kann der Union Type aus verschiedenen Datentypen bestehen.
