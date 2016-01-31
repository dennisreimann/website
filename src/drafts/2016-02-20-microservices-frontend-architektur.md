---
title: Frontend-Architektur für Microservice-Webanwendungen
tags:
  - Microservices
  - Frontend-Entwicklung
  - Frontend-Artitektur
  - Galeria Kaufhof
  - JavaScript
  - CSS
  - BEM
  - Vue.js
  - Require.js
  - Web Components
---

During the past two years I have worked on a large scale eCommerce application with a microservice architecture. As part of the frontend integration team I helped to ensure that the web shop - which consists of six separate domains - has a homogenuous frontend.
All of these six domains have a backend system/application on their own and are integrated with server-side includes. You can read more about the architecture in general over on the official GKH dev blog.

In this article I want to outline the frontend architecture, the integration challenges and our technical solutions.

* Domänenmodell und Aufbau
* Frontend-Integration / Konzeption - USXP - Design
* SSI-includes
* Aufbau einer Seite
* Styleguide / Pattern Library
  * Markup als Vertrag
  * Globale Assets und domänenspezifische Assets
  * Namespaces
  * Web Components
* Funktionalität / JavaScript
  * require.js / Bundling
  * Bekanntmachung durch Includes
  * Controller-Kommunikation / Message Bus
  * Vue.js (server & client side rendering)
* Visuelles / Styles
  * BEM / Stylus
  * Namespacing
  * Includes: Dateien vs. Inline Styles
