---
title: Delegating HTML links to vue-router
lang: en
tags:
  - Vue.js
  - Vue
  - vue-router
  - Frontend development
---

When you are dealing with dynamic or user generated content in a Vue.js application, you might want [vue-router](https://router.vuejs.org/) to handle internal HTML links.
Links that are not implemented via `<router-link>` will trigger a full page reload. So we need a way to hijack clicks on `<a href>` and delegate them to vue-router in case they reference an internal resource.
There are two ways to intercept the clicks, depending on your use case and needs.

## Application-wide handling

In case you have dynamic links all over your application you can intercept them globally.
To do this, bind the event listener to the window in your top-most/main app components `mounted` lifecycle hook:

```javascript
mounted () {
  window.addEventListener('click', event => {
    const { target } = event
    // handle only links that do not reference external resources
    if (target && target.matches("a:not([href*='://'])") && target.href) {
      const url = new URL(target.href)
      const to = url.pathname
      // do not handle anchors/same page links
      if (window.location.pathname !== to) {
       event.preventDefault()
       this.$router.push(to)
      }
    }
  })
}
```

## Encapsulation in a component

If there are only certain places where this kind of link handling must occur, you should encapsulate the event handling in a component.
The advantage of this is, that it will be more performant and there is no need to interfere with the rest of the apps links.

The components template might look like this:

```html
<div
  class="dynamic-content"
  @click="handleClicks"
  v-html="dynamicContent"
/>
```

Here `dynamicContent` is a html string containing the `<a href>` links, which the `handleClicks` method takes care of:

```javascript
methods: {
  handleClicks ($event) {
    const { target } = $event
    // handle only links that occur inside the component and do not reference external resources
    if (target && target.matches(".dynamic-content a:not([href*='://'])") && target.href) {
      const url = new URL(target.href)
      const to = url.pathname
      // do not handle same page links/anchors
      if (window.location.pathname !== to) {
        $event.preventDefault()
        this.$router.push(to)
      }
    }
  }
}
```

As you can see, this hijacks only a subset of the link clicks – those that occur inside of this component.
