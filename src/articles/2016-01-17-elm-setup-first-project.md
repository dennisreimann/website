---
title: "Elm Setup"
subtitle: "Installation and building the first project"
ogImage: elm
lang: en
alternate:
  lang: de
  href: /articles/elm-setup.html
tags:
  - Elm
  - Frontend development
  - Webpack
  - Gulp
description: "How to install Elm and which tools do you need to build your first project? Besides clarifying these questions we will also look at a toolchain that goes beyond the simple Hello World."
---

So you are ready to dive into the next generation approach of creating frontends for web applications? How to install Elm and which tools do you need to build your first project? Besides clarifying these questions we will also look at a toolchain that goes beyond the simple *Hello World* …

<!-- more -->

### Installing Elm

First of we need to install the main components: Compiler, package manager, REPL and the development server Reactor. For OS X and Windows there are [prebuilt packages](http://elm-lang.org/install) – in case you are running Linux you can [install Elm via npm](https://www.npmjs.com/package/elm).

Once you are done, you can verify everything is working by running `elm-make -h` on the command line - the result should yield the version number as well as some helpful commands to compile an Elm file.

```bash
$ elm-make -h
elm-make 0.16 (Elm Platform 0.16.0)
```

To get your editor of choice up and running you will find plugins for the usual suspects on the [official installation page](http://elm-lang.org/install). I am using either Atom or Visual Studio Code to develop Elm applications. For the latter there is a [VS Code Plugin for Elm](https://marketplace.visualstudio.com/items/sbrink.elm) that offers some basic IDE features and integrates Reactor and the REPL.

### Your first Elm project

As we will be diving deeper into topics like syntax in further articles, let us confine this one to a simple *Hello World* example and look at how we can get it to render in the browser. For that we create a file (named something like `Main.elm`) with the following content:

```elm
import Html


main = Html.text "Hello World"
```

As you can see we are about to create HTML output. Therefore we need the first package that has to be installed: [`elm-html`](http://package.elm-lang.org/packages/evancz/elm-html/latest/) offers the functionality to render HTML via virtual DOM. One of its functions is `Html.text` which we use to create a simple text node that will be the return value of the `main` function.

To import the `Html` package we have to install it first:

```bash
$ elm-package install evancz/elm-html
```

The package manager lets us know what exactly will be installed and what dependencies are also needed. It will create the file `elm-package.json` which is the Elm equivalent to the `package.json` you might be familiar with from JavaScript projects. The installed packages are stored inside the `elm-stuff` directory which resembles the `node_modules` folder.

Now we have got everything we need to build the file and execute it in the browser. You can start the development server Reactor on the command line:

```bash
$ elm-reactor
```

Opening the URL [`http://localhost:8000/Main.elm`](http://localhost:8000/Main.elm) in the browser you should see the text *Hello World*. Reactor is a helpful tool for development and it supports the [time travel debugger](http://elm-lang.org/blog/time-travel-made-easy) as well as [hot swapping](http://elm-lang.org/blog/interactive-programming) so that changes to the program should be shown without reloading the browser. Nevertheless the latter is [not reliable in version 0.16.0](https://github.com/elm-lang/elm-reactor/issues/168).

Reactor also gives us the boilerplate we would otherwise have to create manually – an HTML file that is the context for running the program. To create this file yourself you can utilize `elm-make`:

```bash
$ elm-make Main.elm --output index.html
```

The file `index.html` contains the Elm runtime as well as our custom code plus some extra glue code to setup everything. This way you can upload the file to show your parents that you are now able to program in Elm.

### Building larger Elm projects

Right now it is kind of complicated to give custom HTML and CSS to Reactor. In addition to that larger projects oftentimes require a more extensive build process. After building my first small [Elm projects with Gulp](https://gist.github.com/dennisreimann/cd8d45eefaba43199dcd) I settled on  using Webpack, which seems to become the standard way of packaging Elm apps. The [elm-webpack-loader](https://github.com/rtfeldman/elm-webpack-loader) is a nice tool for helping with that.

Webpacks configuration might seem extensive, but there is the [elm-webpack-starter](https://github.com/pmdesgn/elm-webpack-starter) project which is a good starting point for creating your own, more ambitious setup. I have also used it for creating [my first, tiny elm application](https://github.com/dennisreimann/elm-bike-configurator).

The upcoming articles spotlights [the Elm module system](/articles/elm-modules-import.html).
