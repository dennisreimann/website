---
title: "Elm Tools and Resources"
updated: 2016-11-14T10:00
lang: en
tags:
  - Elm
  - Frontend development
  - Tools
  - Resources
description: "A list of tools and resources I found valuable when working with Elm. It contains useful tools that will help in your day to day work and links to learn Elm as well as to deepen your knowledge."
---

This is a potpourri of tools and resources I found valuable when working with Elm. A list containing useful tools that will help in your day to day work and links to learn Elm as well as to deepen your knowledge.

<!-- more -->

### Tools

- [Try Elm](http://elm-lang.org/try) is an online editor and runtime for Elm code. The [official examples](http://elm-lang.org/examples) use it to display a rendered version and you can modify and recompile the code to see the changes. You can use this environment to quickly test single file Elm code snippets.

- The [online elm-repl](http://elmrepl.cuberoot.in/) is a live version of the elm-repl. Similar to "Try Elm" it can be used to try code snippets in the browser.

- As its name says, [elm-format](https://github.com/avh4/elm-format) formats your source code according to a standard set of rules. It makes code easier to write, because you never have to worry about formatting concerns. It makes code easier to read, because there are no longer distracting stylistic differences between code bases. It also has a great [README showing the editor integrations](https://github.com/avh4/elm-format#editor-integration).

- There is a [Dash Docset for Elm](https://github.com/pdamoc/elm-docset) that is hiding inside the User Contributed section of the Downloads pane. The link leads to the Elm Docset generator that can be used in case the docs are outdated or you want to modify the docset.

- [HTML to Elm](https://mbylstra.github.io/html-to-elm/) is an online converter for HTML: You can type or paste some HTML and it generates the according Elm HTML.

- [JSON to Elm](https://noredink.github.io/json-to-elm/) can generate pipeline-style decoders from raw JSON. You can paste some JSON and it will give you the Elm code for decoding it using the `Json.Decode.Pipeline` functions.

- [Elm Oracle](https://github.com/ElmCast/elm-oracle) intends to be a standalone program that can be used by all editor plugins to query information about a project's source code. You can use it to query for information about values in Elm source files.

- [elm-webpack-starter](https://github.com/moarwick/elm-webpack-starter/) gets you going with a boilerplate Webpack config for developing Elm apps. It has a dev server with live reloading, hot module replacement and a production build step for exporting your app.

- [elm-new](https://github.com/simonewebdesign/elm-new) is a CLI tool that generates a file hierarchy for starting a new Elm project. It brings you up to speed and enables you to code right away instead of wasting time with the initial boilerplate.

- [elm-version-manager](https://github.com/mattludwigs/elm-version-manager) offers simple management of Elm versions, inspired by projects like rbenv or nvm. It gives you commands for installing different versions of Elm and switching to them on a per project basis.

### Learning

- [Elm For Beginners](http://courses.knowthen.com/p/elm-for-beginners) is a free video course by James Moore. I cannot recommend it enough ans this course covers the language basics and introduces you to the fundamentals of functional programming as they are needed. For beginners this is a great and practical video course.

- The [Elm FAQ](http://faq.elm-community.org/) aggregates questions that are commonly asked on the Slack channel, the IRC channel, or the mailing list. It also contains migration help and links to further information.

- This [Elm Cheat Sheet](https://github.com/izdi/elm-cheat-sheet) is a quick overview of Elm syntax and features.

### Resources

- The [NoRedInk Elm style guide](https://github.com/NoRedInk/elm-style-guide) contains practical guidelines you might want to follow. If you like style guides, also have a look at [Ossi Hanhinens style guide](https://github.com/ohanhi/elm-style-guide/) which is pretty good too. And of course there is the [official Elm style guide](http://elm-lang.org/docs/style-guide), which you might have seen already :)

- Follow the [trending Elm repositories on GitHub](https://github.com/trending/elm?since=daily) to be among the first to know which libraries are hipster-compatible.

- [Awesome Elm](https://github.com/isRuslan/awesome-elm) is a curated list of useful Elm tutorials, libraries and more. If this article leaves you hungry for more resources, you will find links to more articles, videos, podcasts, etc. there.
