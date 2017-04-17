/* global self, URL, Promise, fetch, caches */

const HTML_CACHE_KEYS = {}
const OFFLINE_FILE = '/offline.html'
const OFFLINE_CACHE = HTML_CACHE_KEYS[OFFLINE_FILE]

const isHtmlGetRequest = request =>
  request.method === 'GET' && request.headers.get('Accept').indexOf('text/html') !== -1

const populateOfflineCache = () =>
  caches.open(OFFLINE_CACHE)
    .then(cache => cache.add(OFFLINE_FILE))

const respondWithOfflineHtml = () =>
  caches.open(OFFLINE_CACHE)
    .then(cache => cache.match(OFFLINE_FILE))

const clearOutdatedCaches = () =>
  caches.keys()
    .then(cacheNames => {
      const currentCaches = Object.values ? Object.values(HTML_CACHE_KEYS) : Object.keys(HTML_CACHE_KEYS).map(k => HTML_CACHE_KEYS[k])
      const outdatedCaches = cacheNames.filter(cacheName => !currentCaches.includes(cacheName))
      const deleteCaches = outdatedCaches.map(cacheName => caches.delete(cacheName))
      console.debug('Clearing outdated caches:', outdatedCaches)
      return Promise.all(deleteCaches)
    })

// try cache first, fall back to network
const getHtml = request => {
  const url = new URL(request.url)
  const filePath = url.pathname
  const cacheFilePath = HTML_CACHE_KEYS[filePath] || filePath

  return caches.open(cacheFilePath)
    .then(cache =>
      cache.match(request.url)
        .then(response => {
          if (response) {
            console.debug(`Responding with ${cacheFilePath} from cache.`)
            return response
          } else {
            console.debug(`No cache match for ${cacheFilePath}.`, 'Falling back to network.')
            return fetchAndCacheHtml(request, cacheFilePath)
          }
        })
    )
}

// try network first, fall back to offline page
const fetchAndCacheHtml = (request, cacheName) => {
  return fetch(request)
    .then(response => {
      console.debug(`Fetched ${request.url} from network.`, `Caching it as ${cacheName}.`)
      return caches.open(cacheName)
        .then(cache => cache.put(request, response.clone()))
        .then(() => response)
    })
}

self.addEventListener('install', event => {
  event.waitUntil(
    populateOfflineCache()
      .then(() =>
        caches.keys()
          .then(cacheNames => console.debug('Current caches:', cacheNames))
      )
      .then(() => self.skipWaiting())
  )
})

// remove outdated html responses from cache on update
self.addEventListener('activate', event => {
  event.waitUntil(
    clearOutdatedCaches()
      .then(() => self.clients.claim())
  )
})

self.addEventListener('fetch', event => {
  const { request } = event

  if (isHtmlGetRequest(request)) {
    event.respondWith(
      getHtml(request)
        .catch(respondWithOfflineHtml)
    )
  }
})
