"use strict";"serviceWorker"in navigator&&navigator.serviceWorker.register("/service-worker.js").then(function(e){return e.update()}).then(function(){return window.fetch(window.location.href)}).catch(function(e){});