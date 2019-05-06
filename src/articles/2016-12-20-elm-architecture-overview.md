---
title: The Elm Architecture
subtitle: Simple, yet powerful – An overview by example
ogImage: elm
elmVersion: 0.18
lang: en
tags:
  - Elm
  - Architecture
  - The Elm Architecture
  - State management
  - Single State Tree
  - Redux
  - Frontend development
---

The beauty of The Elm Architecture lies in its simplicity:
It structures applications into four parts and it defines how these interact with each other.
In Elm there is only this one determined way to handle interactions and manage state – 
and it provides a good foundation for modularity, code reuse and testing by default.

<!-- more -->

One of the first things you will have probably heard about Elm is the way it structures your code.
You come across this early on as it is the only way to architect your application and modules.
When you are new to the language this might seem limiting at first, but don't worry:
The Elm Architecture gives you a solid and proven way for handling the state of your application and the effects that change this state.

The basic structure of your application and modules looks like this:

- **Model**: Contains the application state/data
- **View**: Function(s) that generate HTML based on the model
- **Update**: Handles interaction and transforms the model
- **Runtime**: Wires up Model, View and Update

To cover each of these parts in detail I came up with a [(very) simple blog example](/files/elm/architecture-overview-example.html):
The app shows a list of articles which can be expanded to show the full content by clicking on the title.
Not quite a Medium competitor, but for us figuring out the most important things about The Elm Architecture it will work :)

## Model

<mark>The model part represents the form of your data as well as the actual state.</mark> &#8203;
You will have at least one type alias that defines your models:
Most likely this type alias references a [record](/articles/elm-data-structures-record-tuple.html) that describes the shape of your data.

The example app has a model that represents a blog with a list of articles:

```elm
type alias Model =
    { blogTitle : String
    , articles : List Article
    }


type alias Article =
    { title : String
    , content : String
    , showContent : Bool
    }


initialModel : Model
initialModel =
    { blogTitle = "Some posts on Elm"
    , articles =
        [ { title = "Learning Elm"
          , content = "I just started to learn functional frontend development with Elm. How cool is that?"
          , showContent = False
          }
        , { title = "The Elm Architecture"
          , content = "In this post I am trying to explain The Elm Architecture …"
          , showContent = False
          }
        ]
    }
```

The model is the only place where the state of your application resides.
It is a single state tree of immutable data.
Each time this data is transformed by the `update` function you get a new model containing the updated state.

## View

The view is represented by one or many stateless functions.
These functions generate HTML based on the model:
&#8203; <mark>Their input is the model or a part thereof; their output is the markup that represents the current state.</mark>

There is no need to mutate the DOM manually, the markup – written in elm-html – is entirely declarative.

```elm
view : Model -> Html Msg
view model =
    div
        [ class "blog" ]
        [ h1 [] [ text model.blogTitle ]
        , p [] [ text "Click the titles to read the full article." ]
        , section
            [ class "articles" ]
            (List.map viewArticle model.articles)
        ]


viewArticle : Article -> Html Msg
viewArticle a =
    article
        [ onClick (ToggleContent a) ]
        [ h2 [] [ text a.title ]
        , div
            [ hidden (not a.showContent) ]
            [ text a.content ]
        ]
```

Based on the concept of a Virtual DOM [elm-html](http://package.elm-lang.org/packages/elm-lang/html/latest/) optimizes changes to the view.
It is good to know that this provides [really fast rendering](http://elm-lang.org/blog/blazing-fast-html-round-two) by default. 

Architecture-wise the most important point is, that the view gives you a declarative way of representing the current state and accepting user interaction:
You register event handlers that emit messages to the runtime that will trigger `update` as seen in the `viewArticle` function.

## Update

<mark>The `update` function is the only place your model gets transformed.</mark> &#8203;
It receives a message as well as the model, then updates the model according to the message and returns it.

In case of our example app the `update` gets invoked when the user clicks the article:
This sends the `ToggleContent` message, which also contains the particular article.
It then looks up the attached article in the model, toggles its `showContent` value and returns a new model with the list containing the updated article.

```elm
type Msg
    = ToggleContent Article


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleContent article ->
            let
                updateArticle a =
                    if a == article then
                        { a | showContent = (not article.showContent) }
                    else
                        a

                updatedArticles =
                    List.map updateArticle model.articles
            in
                { model | articles = updatedArticles }
```

As the update function is the only place where your model gets transformed, this structure makes it very easy to reason about state changes and where they are coming from.
This concept seems very simple and natural, yet it emerged and gained popularity through The Elm Architecture.

Contrast this to applications that manage all of their possible states implicitly and being changed from several places.
It's no surprise that this simple, yet powerful way of state management became very popular and influenced other frameworks like Redux.

## Runtime

The main function is the entry of an Elm program.
It takes care of wiring up the three parts described above.
&#8203; <mark>The runtime is contained in a program that gets initialized with the `model`, `view` and `update` – this program is then returned by the main function.</mark>

Supplemented with the imports of your module this can be considered the boilerplate of your application.
The simple case with a `beginnerProgram` might look like this:

```elm
module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, hidden)


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
```

The `Html.beginnerProgram` encapsulates the basics of The Elm Architecture.
It wires up the model, view and update functions and provides the setup for handling user interaction and managing state.
Once initialized &#8203; <mark>the program executes a continuous loop, taking in actions from the user, changing the state and representing the changes in the view.</mark> &#8203;

<figure>
  <img src="/files/elm/architecture-overview-diagram.svg" alt="Diagram of The Elm Architecture" width="320" height="211" />
  <figcaption>Diagram of The Elm Architecture</figcaption>
</figure>

### Dealing with effects

The runtime also handles all of the effects that your application produces or reacts to.
Effects are interactions with the outside world, like loading and sending data via AJAX or writing to the local storage of the browser.
Websocket communication and interoperating with JavaScript are also effects.

To enables these types of interactions, Elm offers the standard `Html.program`, which expands the capabilities of the `Html.beginnerProgram`.
As this is a topic on its own, we will take a closer look at the standard program in one of the upcoming articles.

## Summary

With that you have seen the basic principles of The Elm Architecture.
To summarize the above: An Elm application starts off with an initial *model*.
It is the input to the *view* that represents the *model*.
The user interacts with the view which produces messages, which are handled by the *update* function.
This function is the only place your *model* gets transformed.
The *runtime* encapsulates all of these parts and provides a continuous loop of these interactions.

With this, &#8203; <mark>The Elm Architecture offers a solid foundation for modularity, code reuse and testing.</mark> &#8203;
It also facilitates onboarding new developers as the basic structure of every Elm app is the same.

As the [official guide](https://guide.elm-lang.org/architecture) states:
"Even if you ultimately cannot use Elm at work yet, you will get a lot out of using Elm and internalizing this pattern."
If this motivates you to get your hands on some code, try the Elm Architecture tutorial offered by the guide.
It helps to internalize and solidify your knowledge of this simple, yet powerful structure.
