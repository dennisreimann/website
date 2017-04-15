import fs from 'fs'
import path from 'path'

const paths = {
  src: 'src',
  dest: 'dist'
}

const revvedFile = (filePath) => {
  let revs
  try { revs = require(`./../${paths.dest}/rev-manifest.json`) } catch (error) { }
  return (revs && revs[filePath]) || filePath
}

const isEnglish = (filePath) =>
  (context) => {
    if (filePath && filePath.match(/^pages\/(articles|contact|home)/)) {
      return true
    } else if (context && context.mvb && context.mvb.article) {
      return context.mvb.article.lang === 'en'
    } else {
      return false
    }
  }

const formatDateGerman = date => date.toISOString().replace(/T.*/, '').split('-').reverse().join('.')
const formatDateEnglish = date => date.toString().replace(/\w+\s(\w+)\s(\d+)\s(\d+).*/, '$1 $2, $3')

const getDate = (article) =>
  article.updated != null
    ? new Date(Date.parse(article.updated))
    : article.date

export default {
  createHelper (file, isDev, siteHost, assetHost, defaultScheme) {
    const streamFile = path.relative(paths.src, file.path)
    const isElm = streamFile.match(/^(pages\/(articles|artikel)\/elm)/) || streamFile.match(/^articles\/elm/)

    const assetPath = (filePath) => `/${revvedFile(filePath)}`

    const assetUrl = (filePath, scheme) => `${scheme ? scheme + ':' : ''}//${assetHost || siteHost}${assetPath(filePath)}`

    const siteUrl = (filePath, scheme = defaultScheme) => `${scheme ? scheme + ':' : ''}//${siteHost}${filePath.startsWith('/') ? '' : '/'}${filePath}`

    const enforceScheme = (scheme, url) => url.replace(/^.*\/\//, `${scheme}://`)

    return {
      isDev,
      formatDateGerman,
      formatDateEnglish,
      siteUrl,
      assetUrl,
      enforceScheme,

      isEnglish: isEnglish(streamFile),

      title (text) {
        return `${text} • Dennis Reimann`
      },

      assetInline (filePath) {
        const file = `./${paths.dest}/${revvedFile(filePath)}`
        return fs.readFileSync(file, 'utf8')
      },

      nav: {
        isHome: streamFile.match(/^pages\/index/),
        isContact: streamFile.match(/^pages\/(contact|kontakt)/),
        isProjects: streamFile.match(/^pages\/(projects|projekte)/),
        isArticles: streamFile.match(/^(pages\/(articles|artikel)|articles\/|drafts\/)/) && !isElm,
        isElm
      },

      article: {
        getDate,

        feedDate (a) {
          return getDate(a).toISOString()
        },

        title (a) {
          return a.title + (a.subtitle ? ' – ' + a.subtitle : '')
        },

        description (a) {
          return a.description || a.content.replace(/(<([^>]+)>)/ig, '').substring(0, 150)
        },

        keywords (a) {
          return a.tags.join(',')
        },

        hasCode (a) {
          return !!a.content.match(/class=["'](hljs|lang-).*["']/)
        }
      },

      articles: {
        feedDate (articles) {
          const dates = articles.map(article => getDate(article))
          const latestUpdate = new Date(Math.max.apply(null, dates))
          return latestUpdate.toISOString()
        },

        filterByNoAlternate (articles, lang) {
          return articles.filter((article) => {
            const { alternate } = article
            return !alternate || alternate.lang !== lang
          })
        },

        filterByLanguage (articles, lang) {
          return articles.filter(article => article.lang === lang)
        }
      },

      lang (context) {
        return isEnglish(streamFile)(context) ? 'en' : 'de'
      },

      t (context, g, e) {
        return isEnglish(streamFile)(context) ? e : g
      }
    }
  }
}
