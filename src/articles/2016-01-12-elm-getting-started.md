---
title: Elm lernen
subtitle: Funktionale Frontend-Entwicklung
tags:
  - Elm
  - Frontend-Entwicklung
  - functional-reactive
  - JavaScript
  - React
  - PureScript
  - RxJS
---
Vor ein paar Wochen habe ich dank [Michael](https://twitter.com/naltatis) angefangen, mich näher mit [Elm](http://elm-lang.org) zu beschäftigen und bin mittlerweile regelrecht begeistert. Das letzte Mal, dass ich so ein gutes Gefühl dabei hatte, etwas Neues zu lernen, ist knapp zehn Jahren her: Damals wusste man bei Rails direkt, dass man es mit etwas Besonderem zu tun hat.

In 2015 ist die funktionale Programmierung auch stärker ins Frontend vorgerückt und die sich anschließende Paradigmen beeinflußen zunehmend JavaScript und seine Frameworks: [PureScript](http://www.purescript.org/) und [RxJS](https://github.com/ReactiveX/RxJS) sind Beispiele für oft eingesetzte Sprachen und Bibliotheken, welche auf den Konzepten der funktional-reaktiven Programmierung fußen. [React](https://facebook.github.io/react/) und die Bibliotheken in seinem Ökosystem setzen auf [unidirektionalen Datenfluß](http://staltz.com/unidirectional-user-interface-architectures.html) und es ist kein Geheimnis, dass [Redux](http://redux.js.org/) - die mittlerweile als Gold-Standard bezeichnete Implementierung des Flux-Patterns - der [Elm-Architektur](https://gist.github.com/evancz/2b2ba366cae1887fe621) nachempfunden wurden.

### Was ist Elm?

Elm ist eine funktionale Programmiersprache, die zu JavaScript kompiliert. Eine Besonderheit ist dabei die statische Typisierung, welche es in JavaScript nicht gibt und die Elm-seitig über den Compiler realisiert ist. So erzeugt der Compiler verlässlichen Code, in dem keine Laufzeit-Exceptions vorkommen können, die auf inkonsistente Variablentypen oder unsichere Referenzzugriffe zurückzuführen sind. Der Compiler ist das Herzstück von Elm und ermöglicht viele der interessanten Features, wie etwa [sehr aussagekräftige Fehlermeldungen](http://elm-lang.org/blog/compiler-errors-for-humans), welche teilweise sogar direkt Vorschläge für den funktionsfähigen Code enthalten, oder auch den [Paket-Manager](http://elm-lang.org/blog/announce/package-manager), der über Code-Analyse automatisch Semantic Versioning erzwingt.

Die statische Typisierung zieht sich dabei durch bis in die View: Das Template, welches in elm-html geschrieben wird, setzt wie React auch auf dem Konzept des Virtual DOM auf. Im [Performance-Vergleich](http://elm-lang.org/blog/blazing-fast-html) mit React und vergleichbaren JavaScript-Frameworks schneidet das Rendering durch elm-html dabei jedoch besser ab, was auf die Unveränderbarkeit (Immutability) der Daten und das Ausschließen von Seiteneffekten (Purity) zurückzuführen ist. Der Vorteil ist insgesamt aber eher darin zu sehen, dass die Elm-Architektur die Kapselung der Views in Komponenten nahelegt und fördert, was zu gut kombinier- und wiederverwendbaren Einheiten führt.

Die [Syntax](http://elm-lang.org/docs/syntax) ist für jemanden ohne funktionale Programmiersprachenkenntnisse anfangs etwas gewöhnungsbedürtig, nichtsdestotrotz sehr klar und meiner Meinung nach schnell zu erlernen. [Elms Standardbibliothek](http://package.elm-lang.org/packages/elm-lang/core/3.0.0) ist im Vergleich zu anderen Sprachen sehr klein und überschaubar – es sind vielmehr die Konzepte, die es zu lernen und verstehen gilt: Dazu zählen unter anderem die [Elm-Architektur](), Immutability/Purity und dass es anders als in den meisten anderen Sprachen [keine `null`-Werte](http://elm-lang.org/guide/model-the-problem#banishing-null) gibt.

Elm erfreut sich wachsender Beliebtheit und wird mittlerweile auch zunehmend [produktiv eingesetzt](https://www.youtube.com/watch?v=W9HDueiaIJ4). In 2016 wird man denke ich auch in Deutschland drüber sprechen und mehr davon hören – im Rahmen einer Hack Week hat man sich zumindest auch schon bei [Zalando](https://tech.zalando.com/blog/using-elm-to-create-a-fun-game-in-just-five-days/) mit Elm vertraut gemacht. Aktuell arbeite ich grade daran, eine kleine Beispielanwendung etwas besser zu strukturieren, um sie zu open sourcen. Hier wird es in den kommenden Woche auch einiges mehr zu Elm zu lesen geben, denn ich bin wie gesagt schon recht angetan davon und würde mich über weiteren Austausch freuen :)

### Neugierig geworden?

Folgende Ressourcen würde ich als sehr gut bezeichnen, um sich einen Überblick zu verschaffen und auch praktisch die ersten Schritte mit Elm zu unternehmen:

* [Elm: Building Reactive Web Apps](https://pragmaticstudio.com/elm) - etwa dreistündiges Video-Tutorial der Pragmatic Studios. Für mich der beste praktische Einstieg mit sehr guten Erklärungen zu den Grundkonzepten und der Elm-Architektur.
* [Let's be mainstream! User focused design in Elm](https://www.youtube.com/watch?v=oYk8CKH7OhE) - Vortrag von Evan Czaplicki, dem Entwickler hinter Elm. Wenig technisch wird vor allem die Motivation hinter der Entwicklung einer neuen, funktionalen Sprache für das Frontend erläutert und der Vortrag gibt einen Ausblick auf viele Konzepte und Features, die zukünftig einzug in die Sprache halten sollen.
* [Learn Elm in X minutes](https://learnxinyminutes.com/docs/elm/) - für die Sprachfreaks, die erstmal eine grobe Übersicht der Elm-Syntax möchten.
* Wer anschließend etwas tiefer in Beispiele komplexerer Anwendungen einsteigen möchte, findet mit [elm-todomvc](https://github.com/evancz/elm-todomvc) und [elm-hedley](https://github.com/Gizra/elm-hedley) gute Beispiele.
