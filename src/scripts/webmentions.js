if (window.fetch) {
  const target = window.location.href.replace('http://localhost:3000', 'https://dennisreimann.de')
  const formatDate = timestamp => (new Date(timestamp)).toString().replace(/\w+\s(\w+)\s(\d+)\s(\d+)\s(\d+:\d+).*/, '$1 $2, $3 - $4')

  const types = {
    reply: {
      items: [],
      template: mentions => {
        return mentions.length
          ? `
          <div class="wbm-type wbm-replies">
            <h4 class="wbm-headline">Replies</h4>
            <div class="wbm-items">
              ${mentions.map(({ data: { url, author, content, published }, activity: { sentence } }) => `
                <article class="wbm-item wbm-reply" title="${sentence}">
                  <header class="wbm-header">
                    <a href="${author.url}" class="wbm-author">
                      <img src="${author.photo}" alt="${author.name}" />
                      <span>${author.name}</span>
                    </a>
                    <a href="${url}" class="wbm-time">
                      <time datetime="${published}">${formatDate(published)}</time>
                    </a>
                  </header>
                  <div class="wbm-content">${content}</div>
                </article>`).join('')}
            </div>
          </div>`
          : null
      }
    },
    link: {
      items: [],
      template: mentions => {
        return mentions.length
          ? `
          <div class="wbm-type wbm-links">
            <h4 class="wbm-headline">Links</h4>
            <div class="wbm-items">
              ${mentions.map(({ data: { url, author, content, published }, activity: { sentence } }) => `
                <article class="wbm-item wbm-link" title="${sentence}">
                  <header class="wbm-header">
                    <a href="${author.url}" class="wbm-author">
                      <img src="${author.photo}" alt="${author.name}" />
                      <span>${author.name}</span>
                    </a>
                    <a href="${url}" class="wbm-time">
                      <time datetime="${published}">${formatDate(published)}</time>
                    </a>
                  </header>
                  <div class="wbm-content">${content}</div>
                </article>`).join('')}
            </div>
          </div>`
          : null
      }
    },
    like: {
      items: [],
      template: mentions => {
        return mentions.length
          ? `
          <div class="wbm-type wbm-likes">
            <h4 class="wbm-headline">Likes</h4>
            <div class="wbm-items">
              ${mentions.map(({ data: { url, author }, activity: { sentence } }) => `
                <a href="${url}" class="wbm-item wbm-like wbm-author" title="${sentence}">
                  <img src="${author.photo}" alt="${author.name}" />
                </a>`).join('')}
            </div>
          </div>`
          : null
      }
    },
    repost: {
      items: [],
      template: mentions => {
        return mentions.length
          ? `
          <div class="wbm-type wbm-reposts">
            <h4 class="wbm-headline">Reposts</h4>
            <div class="wbm-items">
              ${mentions.map(({ data: { url, author }, activity: { sentence } }) => `
                <a href="${url}" class="wbm-item wbm-repost wbm-author" title="${sentence}">
                  <img src="${author.photo}" alt="${author.name}" />
                </a>`).join('')}
            </div>
          </div>`
          : null
      }
    }
  }

  window.fetch(`https://webmention.io/api/mentions?perPage=500&target=${target}`)
    .then(response => response.json())
    .catch(error => {
      console.error(`Could not load webmentions for ${target}:`, error)
    })
    .then(result => {
      // sort
      result.links.forEach(mention => {
        const type = types[mention.activity.type]
        if (type) type.items.push(mention)
      })
      // render
      const rendered = []
      Object.keys(types).forEach(key => {
        const type = types[key]
        const { items, template } = type
        const render = template(items)
        if (render) rendered.push(render)
      })
      // append
      if (rendered.length) {
        document.getElementById('articleMentions').innerHTML +=
          `<h3>Feedback</h3>${rendered.join('')}`
      } else {
        console.debug(`No webmentions found for ${target}.`)
      }
    })
    .catch(error => {
      console.error('Could not render webmentions:', error)
    })
}
