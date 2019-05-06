---
title: Using Vue-CLI to serve an Express app
ogImage: vue
lang: en
tags:
  - Vue.js
  - Vue
  - vue-cli
  - vue-cli-service
  - Express
  - API
---

The Vue-CLI is great, but one thing I struggled with and found no resources on:
How to serve an Express app alongside the UI without using another process?
Accomplishing this is actually pretty easy and I hope to provide some guidance with this article.

## Starting point

In my case the Express serves the API for the Vue UI.
This case is also described in the Vue CLI docs:
Just use the [`devServer.proxy`](https://cli.vuejs.org/config/#devserver-proxy) config for that and you are done.
But not so fast …

Using the proxy setup you have to start separate servers for the UI and API.
Depending on your case this might make sense, but for me both are intertwined and having one server makes things way easier:
<mark>In dev mode we can use the existing Webpack Dev Server, which is based on Express;
running the E2E tests you will likely need the Express server running as well.</mark>

Here is how to set this up so that running `vue-cli-service serve` spins up one Express for the API and UI.

## Configuration

Let's start with the `vue.config.js` file, which looks like this:

```js
const configureAPI = require('./src/server/configure')

module.exports = {
  devServer: {
    before: configureAPI
  }
}
```

Wow, that is as short as the proxy config, but what does it do?
It leverages the [Webpack Dev Server `before` callback](https://webpack.js.org/configuration/dev-server/#devserverbefore), which does the heavy lifting.

I keep my server stuff in `src/server`, which contains the following `configure.js` that is imported above:

```js
const bodyParser = require('body-parser')
const api = require('./api')

module.exports = app => {
  app.use(bodyParser.json())
  app.use('/api', api)
}
```

The `api.js` file contains the [Express Router](https://expressjs.com/en/guide/routing.html#express-router) definitions for the API routes, but that is up to you.
<mark>The important part is that the `configure` module exports a function, which adds the API config to the Webpack Dev Server:</mark>
The `before` callback invokes this function with the Express `app` instance as the first argument;
the second argument is the Webpack Dev Server instance, which we can safely ignore here.

That is all you actually need for the development and testing environment, freaking simple!

### Optional: Server restart on change

To reload the dev server whenever the Express/API code changes you can use [nodemon](https://github.com/remy/nodemon#running-non-node-scripts).
The `npm start` script looks like this:

```bash
nodemon --exec 'vue-cli-service serve'
```

The accompanying `nodemon.json` configures the watch directory:

```json
{
  "watch": [
    "src/server"
  ]
}
```

## In production

For completeness sake, here is also what I am doing in production:
The `src/server` directory contains an `index.js` file like the following:

```js
const { resolve } = require('path')
const history = require('connect-history-api-fallback')
const express = require('express')
const configureAPI = require('./configure')
const app = express()

const { PORT = 3000 } = process.env

// API
configureAPI(app)

// UI
const publicPath = resolve(__dirname, '../../dist')
const staticConf = { maxAge: '1y', etag: false }

app.use(express.static(publicPath, staticConf))
app.use('/', history())

// Go
app.listen(PORT, () => console.log(`App running on port ${PORT}!`))
```

This file contains all the config and logic to bring up the Express server in production;
it is run using `NODE_ENV=production node src/server`.

The shared `configureAPI` is passed the `app` instance that we create ourselves in this scenario.
Besides that it also leverages Expess' static file serving to serve the UI.
Here we also enable the [Vue Router history push state navigation](https://router.vuejs.org/guide/essentials/history-mode.html) as well. You can find more guidance on [how to deploy a Vue CLI app](https://cli.vuejs.org/guide/deployment.html) in the official docs.
