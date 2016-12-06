---
title: "Elm Atom Plugins"
lang: en
tags:
  - Elm
  - Frontend development
  - Tools
  - Atom
  - Editor
description: "Some very good and useful plugins that will enhance your Elm editing in Atom."
---

Adding on to my previous list of [Elm tools and resources](/elm-tools-resources.html) here are some very good and useful plugins that will enhance your Elm editing in Atom. There are lots of [editors with good Elm suport](https://github.com/isRuslan/awesome-elm#editor-plugins) but I really enjoy using Atom for Elm and that is what this list is about.

<!-- more -->

- The first thing you will want to install is [language-elm](https://atom.io/packages/language-elm) as it provides syntax highlighting. It also offers autocompletion for which you will have to also install Elm Oracle – see the package docs for that.

- Run [elm-format](https://atom.io/packages/elm-format) on save or manually. I could not work without this: Just type away and this plugin formats cowboy style code into a readable beauty that looks like everyone elses Elm code.

- [linter-elm-make](https://atom.io/packages/linter-elm-make) lints your files on save or even on the fly. It runs elm-make in the background and displays its errors and warnings in a pane on the bottom. This is really nice as you do not have to leave the editor and it also gives you clickable line numbers to jump to the occasions.

- [elmjutsu](https://atom.io/packages/elmjutsu) offers a bag of tricks for developing with Elm: If you want to add a lightweight feeling of IDE in Atom, this package is pretty nice: It has autocompletion, Go To Definition, Find Usages, Rename Symbol, etc. It also offers a sidekick pane that displays type hints and documentation.

- [html-to-elm](https://atom.io/packages/html-to-elm) converts plain HTML to the according Elm HTML. This can be a real time saver when you are setting up views.

- [elm-instant](https://atom.io/packages/elm-instant) provides both a visual REPL to try your code as well as a preview pane to immediately see the output of calling functions you have in your files.
