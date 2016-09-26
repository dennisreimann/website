---
title: "Living Pattern Libraries"
subtitle: "Wie man Styleguide-Zombies killt …"
updated: 2016-09-26T10:00
lang: de
tags:
  - Pattern Library
  - Styleguide
  - Frontend development
  - Living Styleguide
  - Atomic Design
  - BEM
  - NPM
  - Handlebars
---
Styleguides und Pattern Libraries sind in der [UI-Entwicklung](https://www.uiengineering.de/) schon seit längerem ein großes Thema. Sie bieten Designern und Entwicklern einen Baukasten von Komponenten, aus denen die Interfaces zusammengesetzt werden und sorgen für ein konsistentes Gesamtbild der Website oder Anwendung.

Über die Meinung, dass eine gut gepflegte Pattern Library in responsive Webprojekten ab einer gewissen Größe Sinn macht, dürfte mittlerweile Konsenz herrschen. Probleme und Unzufriedenheit treten jedoch oftmals an eben der Stelle auf, wo Pattern Library und Realität voneinander abweichen: Wird der Komponentenbaukasten nicht ständig auf dem neusten Stand gehalten, leben sich Pattern Library und die Zielanwendung auseinander – aus dem ehemaligen Traumpaar werden zwei Einzelteile, die sich gegenseitig als zunehmend lästig empfinden.

### Hilfe, es krieselt …

So etwas kommt in den besten Beziehungen vor und kann verschiedene Gründe haben. Die häufigsten davon:

- Die Pattern Library wird als Vorbau erstellt und gerät sukzessiv in Vergessenheit, weil Termindruck oder auch Faulheit dazu führen, dass schnell noch mal direkt in der Anwendung etwas angepasst wird (oft genutzte Werkzeuge: Heißklebepistole und Gaffa Tape, vgl. ["ranfrickeln"](https://de.wiktionary.org/wiki/frickeln)).
- Die Nutzung der Komponenten findet direkt über das Markup als Schnittstelle statt: Der Entwickler findet in der Pattern Library das Beispiel-HTML und die nötigen CSS-Klassen (siehe [Twitter Bootstrap](https://getbootstrap.com/components/), [Semantic UI](http://semantic-ui.com/), etc.). Diese werden kopiert und in die Templates der Anwendung übernommen.
- Das primäre Verständnis des Baukastens ist dokumentatorisch. Die Pattern Library ist somit nicht das, was auch als _„Living Styleguide“_ bezeichnet wird: Sie bildet die Komponenten nur exemplarisch ab, hat aber keine direkte technische Verbindung zur letztendlichen Verwendung.

__Fazit__: Wenn die Pattern Library nicht auch den Produktivcode darstellt und generiert, wird es über kurz oder lang schwierig, diesen Ansatz zufriedenstellend zu betreiben.

## Wege zur Living Pattern Library

Die Lösung des Problems liegt im Ansatz „Pattern Library first (and foremost)“: Statt den Baukasten nur als Vorbau und Dokumentation zu sehen, muss dieser alle nötigen Werkzeuge enthalten, um auch den Produktivcode zu generieren. Die Komponenten werden in der Pattern Library selbst entwickelt und durch den Buildprozess so bereitgestellt, dass die Zielanwendungen sie auch technisch integrieren können.

Das klingt etwas abstrakt, daher hier ein beispielhafter Ansatz, der sich in einem aktuellen Projekt als recht praktikabel herausstellt. Dazu sei gesagt, dass im beschriebenen Projekt mehrere Anwendungen in unterschiedlichen Programmierprachen existieren, die die Pattern Library als Basis zur Erstellung ihrer Seiten nutzen. Für den Fall, dass es nur eine Anwendung gibt, lässt sich das Ganze integrierter und somit einfacher umsetzen. Nichtsdestotrotz bleibt eines gleich: Reines HTML, welches aus der Pattern Library in die Anwendung übernommen wird, ist (aktuell noch) keine geeignete Basis dafür.

### Abstraktion des Markups

Das Markup der Komponenten wird mit [Handlebars](http://handlebarsjs.com/) als Templatingsprache entwickelt. Die Wahl Handlebars einzusetzen fiel primär aus zwei Gründen:

- Es ist zwar nicht die schönste, aber dafür eine sehr reduzierte Templatingsprache: Sie bietet genau die Features, die man benötigt, um den im folgenden vorgestellten Ansatz zu realisieren (Blöcke und parametrisierbare Partials). Durch das Fehlen von Anweisungen über Schleifen und einfache konditionale Abfragen hinaus zwingt sie einen dazu, jegliche Logik aus den Templates herauszuhalten – was in diesem Fall gewünscht ist.
- Handlebars hat Implementierungen in sehr vielen Programmiersprachen, so dass die Integration der Komponenten nicht auf bestimmte Sprachen oder Frameworks beschränkt ist. Man könnte auch sagen, dass Handlebars der so ziemlich kleinste gemeinsame Nenner ist, was halbwegs komfortables Templating in verschiedensten Programmiersprachen betrifft.

Wir verwenden dabei bewusst nur die Bordmittel von Handlebars selbst und keine selbstgeschriebenen Helper. Letztere müssten in der jeweiligen, von den Anwendung verwendeten Programmiersprache nachimplementiert werden, was die Einfachheit der Integration wieder senkt und auch fehleranfällig wäre.

Die einzelnen Komponenten sind _Partials_, die das eigentliche HTML abstrahieren und als Schnittstelle Properties und Datenobjekte entgegennehmen:

```handlebars
{{> button title="Klick mich!" size="large"}}

{{> formrow label="E-Mail" type="email" error="Bitte geben Sie eine gültige E-Mail-Adresse ein."}}
```

Neben simplen Elementen lassen sich so auch recht komplexe Komponenten erstellen, die sich aber durch die Kapselung aller Interna relativ einfach verwenden lassen:

```handlebars
{{> product product=productData}}

{{> slider dots=true navigation=true slides=slidesData}}
```

Die Komponenten geben dabei auch die Datenstruktur vor, die sie in diesen Fällen als `productData` bzw. `slidesData` erwarten. Auch das ist für unseren Fall ein Plus, da wir view-getrieben arbeiten und somit schon beim Entwickeln der Templates die erwartete Datenstruktur spezifizieren.

Ebenfalls enthalten die Komponenten die Referenzen auf die von ihnen benötigten Styles und Scripts. So hat man die Möglichkeit, feingranular auch für einzelne Komponenten zu steuern, was zusätzlich geladen werden muss: Beispielsweise lässt sich direkt zu Beginn des Footer-Partials das dazugehörige Stylesheet referenzieren, so dass es erst direkt vor dem Rendern des Footers geladen wird. Auf diese Art lassen sich die Abhängigkeiten einzelner Komponenten aus den globalen Referenzen heraushalten und [man läd nur, was auch tatsächlich benötigt wird](https://jakearchibald.com/2016/link-in-body/).

### Build der Artefakte und Integration als Abhängigkeit

Jede dieser Komponenten liegt zusammen mit den dazugehörigen Styles, Scripts, Tests und Dokumentation in einem separaten Ordner. Der Buildprozess kümmert sich darum, die einzelnen Teile richtig zusammenzufügen und die Artefakte für den Export zu erstellen.

Die Assets (also alle statischen Dateien wie Styles, Scripts, SVGs, etc.) werden mit einem Hash versioniert in das CDN geladen. Die Partials werden versioniert als NPM-Package publiziert: So können die einzelnen Anwendungen die Partials sehr einfach integrieren und diese ebenfalls in verschiedenen Versionen nutzen. Da die Partials wie oben beschrieben die Referenzen auf die benötigten Assets beinhalten, ist diese Nutzung von verschiedenen Versionen sehr einfach machbar.

Die Pattern Library wird ebenfalls über einen Buildprozess mit Node.js erstellt. Sie ist dabei selbst auch eine Anwendung, die die Partials nutzt: In ihr werden die Partials mit Beispieldaten gerendert, so dass auch verschiedenste Variationen (bspw. Produkt mit und ohne Bild) einer Komponente abgebildet werden können. Ebenso lässt sich auch die Pattern Library leicht versionieren und dient somit als ideale Dokumentation der verschiedenen Versionen.

## Geht das nicht einfacher?

Ja, das ist nicht trivial, aber es lohnt sich! Vieles davon sollte eh gängige Praxis in einem guten Buildprozess sein – der wichtige Teil im Bezug auf eine Living Pattern Library ist dabei der Export der Partials, so dass sich diese dann in den eigentlichen Anwendungen nutzen lassen. Dass man auf diese Art und Weise dann auch eine elegante Versionierung der Pattern Library und Komponenten bekommt, ist ein super Bonus!

Wie gesagt wäre das Ganze im Fall von nur einer Anwendung auch in integrierterer Form machbar: Die Pattern Library könnte im einfachsten Fall ein Zweig der eigentlichen Anwendung sein, so dass man den Umweg über Export und Integration nicht gehen müsste. Die zunehmende Verbreitung des Musters, Anwendungen in kleinteiligere Microservices zu zerlegen, lassen den beschriebenen Fall für die Zukunft aber umso relevanter werden.

Von der Nutzung her erinnert das Ganze an [Custom Elements](https://customelements.io/). Leider haben [Web Components](http://webcomponents.org/) aktuell noch nicht die gewünschte Unterstützung und Implementierung (vor allem Shadow DOM), so dass sich im aktuellen Projekt der Weg über Handlebars anbot. Nichtsdestotrotz wird dieser standardisierte Weg in Zukunft das sein, was sich hoffentlich möglichst bald auch praktisch nutzen lässt: Mit den einzelnen Teilen der Web Components Spezifikation wird es eine nativ von den Browsern unterstützte Möglichkeit geben, Komponenten in gekapselter und isolierter Form abzubilden, ohne sich manuell drum kümmern zu müssen.
