---
title: Atomic Design is messy, here's what I prefer
lang: en
tags:
  - Atomic Design
  - Design Systems
  - Frontend development
  - Pattern Library
---
Wow, what a clickbaity headline – it makes me apologize to Brad Frost in this very first sentence.
But now that I got your attention, let me elaborate in modest terms so I can back up this sentiment.

## The good parts

I like [Atomic Design](http://atomicdesign.bradfrost.com/table-of-contents/) on a conceptual level and I think it works as a methodology to a good extend.
What I like in particular is how it proposes a mental model that connects to a known concept:
This alone makes it easy for beginners to understand connections and provides a framework for categorizing things.
Every non-technical person can get it almost right away and has a way to frame their ideas.

## The bad parts

There are two things in particular I see as problematic and coming up when explaining and implementing a design system …

### It leads to strict categorization

<mark>Categorizing components as atoms, molecules and organisms works well at first glance, but can become debatable in the details.</mark>

Atoms are defined as „basic building blocks“.
This maps perfectly fine to single (HTML) elements when thinking in terms of components.
However, basics such as colors, typography or spacing do not fit well right beside components.
This might sound nitpicky and esoteric, but in my opinion these design tokens demand for another kind of category.

A question which I bet has been asked in every team that applies atomic design: "Is this thing a molecule or an organism?"<br>
And in fact: What makes something _"small"_ or _"big"_?
Is it the number of elements or other components it includes?
The type of subparts it contains?
The visual space it takes up on the screen?

Here we are in the debatable questions on a conceptual level – but these can be sorted out with answers and conventions a team can agree on.
What I see all the time though is that this does not stop at the conceptual level:
Teams use these categorizations in the implementation and put the components in actual folders.

This is also part of the tooling and Pattern Lab proposes such a structure.
Personally I do not like this, as it makes it hard to refactor and reshape things.
Used on an agreed upon conceptual level this might work, but if this is part of your build process you are into trouble sooner than later.

### It is a leaky abstraction

<mark>The mental model does not work to full extend and breaks on the template and pages level.</mark>
Alright, I accept this is nitpicky, but I think the best metaphors work all the way through.
With a simpler way to frame this, we would not need the metaphor as a mental model all together.
I will not hammer on this as other things are more interesting:
Like the distinction between templates and pages.

Technical people might get this: Templates are the abstract form, pages the concrete implementation.
Non-technical people struggle with this, if it is part of the language and categorization.
Even I have my problems of fitting templates into the documentation as it is hard to represent them, not just visually.
Best advice I can give from our experience is to not use this distinction and confuse people.

## Are we done ranting?

Seriously, I don‘t want this to offend.
I wanted to write about some points I see coming up in discussions all the time.
If you are using Atomic Design and like it I am glad it works for you and please stick to it!

The following – hopefully more constructive – part is for those of you who have had similar gripes with it as I did.
I hope it proposes another angle of looking at it, which I see as a simpler way to frame things.

## Foundation, Elements, Modules and the Prototype

Here is the high-level overview of how I like to structure and implement the individual parts:

- __Foundation__: This is the basic layer of design tokens such as colors, typography, spacings, iconography and their like.
  Basically the non-component basics I have my trouble with when defined and categorized as atoms.
  Assigning them an explicit category and naming it foundation makes clear that this affects every piece of the system.

- __Elements__: The "basic building block" components everyone thinks of when talking about atoms.
  Concretely they map to customized implementations of single HTML elements, like headings and buttons.
  But also these kinds of elements, that do not make any sense in HTML when used standalone, like list items.
  In this case a list would be the most non-dividable form and hence the element.

- __Modules__: Everything that can contain other components.
  I am defining components as a collective term for elements or modules – the distinction being whether or not they can contain other parts.
  In atomic design terms this is the group of molecules and organisms, avoiding the strict categorization.
  As you might have guessed, this distinction also does not find its expression in the file system:
  There is no folder hierarchy, just a single flat components directory which contains a single folder for each component.

- __Prototype__: In the end product people do not want design tokens, components or templates.
  They want concrete pages which should be assembled of all these parts.
  The prototype is our section in the pattern library/design system documentation where everything comes together.
  Here the templates containing the components are married with the (sample) data to form pages everyone understands.
  The prototype is also the basis for testing and validating ideas and features.

That's it!
Sorry this is not more fancy, but we have found this works for us and the clients and teams we work with.
It avoids the discussions mentioned above.
It is simple and hence works without a metaphor.

Feel free to ask questions and challenge this approach.
I am eager to learn how you tackle this, so let me know!
