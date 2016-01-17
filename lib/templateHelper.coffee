fs = require("fs")
path = require("path")
argv = require("yargs").argv

paths =
  src: "src"
  dest: "dist"

revvedFile = (filePath) ->
  revs = try
    require("./../#{paths.dest}/rev-manifest.json")
  catch
    undefined
  file = if revs then revs[filePath] else filePath

isEnglish = (filePath) ->
  (context) ->
    if filePath and filePath.match(/^pages\/contact/)
      true
    else
      context.mvb?.article?.lang is "en"

getDate = (article) ->
  if article.updated?
    new Date(Date.parse(article.updated))
  else
    article.date

module.exports =
  createHelper: (file, isDev, assetHost) ->
    filePath = path.relative(paths.src, file.path)

    {
      assetUrl: (filePath, includeHost = true) ->
        filePath = revvedFile(filePath)
        "#{if includeHost then assetHost else ''}/#{filePath}"

      assetInline: (filePath) ->
        filePath = "./#{paths.dest}/#{revvedFile(filePath)}"
        content = fs.readFileSync(filePath, "utf8")
        content

      isEnglish: isEnglish(filePath)
      isDev: isDev

      nav:
        isHome: filePath.match(/^pages\/index/)
        isContact: filePath.match(/^pages\/(contact|kontakt)/)
        isArticles: filePath.match(/^(pages\/articles|articles\/|drafts\/)/)

      article:
        feedDate: (a) ->
          getDate(a).toISOString()
        germanDate: (a) ->
          a.date.toISOString().replace(/T.*/, "").split("-").reverse().join(".")
        englishDate: (a) ->
          a.date.toString().replace(/\w+\s(\w+)\s(\d+)\s(\d+).*/, "$1 $2, $3")
        description: (a) ->
          a.description or a.content.replace(/(<([^>]+)>)/ig, "").substring(0, 150)
        keywords: (a) ->
          a.tags.join(',')
        hasCode: (a) ->
          !!a.content.match(/class="hljs.*"/)

      articles:
        feedDate: (articles) ->
          dates = articles.map((article)-> getDate(article))
          latestUpdate = new Date(Math.max.apply(null, dates))
          latestUpdate.toISOString()

      t: (context, g, e) ->
        if isEnglish(null)(context) then e else g
    }
