if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js')
    .then(reg => reg.update())
    .then(() => window.fetch(window.location.href))
    .catch(err => console.error('Failed service worker registration:', err))
}
