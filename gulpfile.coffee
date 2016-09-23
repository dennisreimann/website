gulp = require("gulp")
p = require("gulp-load-plugins")()
runSequence = require("run-sequence")
autoprefixer = require("autoprefixer")
mqpacker = require("css-mqpacker")
csswring = require("csswring")
browserSync = require("browser-sync").create()
argv = require("yargs").argv
templateHelper = require("./lib/templateHelper")
highlightjs = require("highlight.js")

isDev = argv.dev?
assetHost = argv.assetHost or ""
baseUrl = if isDev then "http://localhost:3000" else "https://dennisreimann.de"

paths =
  src: "src"
  dest: "dist"
  rev: ["dist/**/*.{css,js,map,svg,jpg,png,gif,ttf,woff,woff2}"]
  copy: ["src/{fonts,images,svgs}/**/*", "src/favicon.ico", "src/.htaccess", "src/{styles,}/vendor/highlightjs.css"]
  pages: ["src/pages/**/*.jade"]
  styles: ["src/styles/**/*.styl"]
  scripts: ["src/scripts/**/*.js"]
  sitemap: ["dist/**/*.html"]
  optimizeImages: ["src/{images,svgs}/**/*"]
  articles: if isDev then ["src/articles/*.md", "src/drafts/*.md"] else ["src/articles/*.md"]
  templates: "src/templates/*.jade"
  feedTemplate: "src/templates/atom.jade"
  articleTemplate: "src/templates/article.jade"
  articlesBasepath: "articles"

dest = (folder = "") -> gulp.dest("#{paths.dest}/#{folder}")

mvbConf =
  glob: paths.articles
  template: paths.articleTemplate
  permalink: (article) ->
    "/#{paths.articlesBasepath}/#{article.id}.html"
  highlight: (code, lang) ->
    languages = if lang? then [lang] else undefined
    highlightjs.highlightAuto(code, languages).value
  grouping: (articles) ->
    byYear = {}
    byTag = {}

    articles.forEach (article) ->
      year = article.date.toISOString().replace(/-.*/, "")
      byYear[year] ||= []
      byYear[year].push(article)

      tags = (article.tags || []).forEach (tag) ->
        byTag[tag] ||= []
        byTag[tag].push(article)

    # year
    articlesByYear = []
    Object.keys(byYear).reverse().forEach (year) ->
      articlesByYear.push(year: year, articles: byYear[year])

    # tag
    articlesByTag = byTag

    # groups
    {
      byTag: articlesByTag
      byYear: articlesByYear
    }

templateData = (file) ->
  h: templateHelper.createHelper(file, isDev, baseUrl, assetHost)

buildHtml = (src, dst) ->
  gulp.src(src)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade(pretty: true))
    .pipe(p.minifyHtml(empty: true))
    .pipe(dest(dst))
    .pipe(browserSync.stream())

gulp.task "copy", (cb) ->
  gulp.src(paths.copy)
    .pipe(dest())
    .pipe(browserSync.stream())

gulp.task "pages", -> buildHtml(paths.pages)

gulp.task "articles", -> buildHtml(paths.articles, paths.articlesBasepath)

gulp.task "feed", ->
  gulp.src(paths.feedTemplate)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade(pretty: true))
    .pipe(p.rename("atom.xml"))
    .pipe(dest())

gulp.task "scripts", ->
  gulp.src(paths.scripts)
    .pipe(p.plumber())
    .pipe(p.sourcemaps.init())
    .pipe(p.babel())
    .pipe(p.uglify())
    .pipe(p.sourcemaps.write("./maps"))
    .pipe(dest("scripts"))
    .pipe(browserSync.stream(match: "**/*.js"))

gulp.task "styles", ->
  processors = [
    mqpacker
    autoprefixer(browsers: ["last 2 versions"])
    csswring
  ]
  gulp.src(paths.styles)
    .pipe(p.plumber())
    .pipe(p.stylus(
      paths: ["src/styles/lib"],
      import: ["mediaQueries", "mixins", "variables"]
    ))
    .pipe(p.concat("main.css"))
    .pipe(p.postcss(processors))
    .pipe(dest("styles"))
    .pipe(browserSync.stream(match: "**/*.css"))

gulp.task "browserSync", ->
  browserSync.init(
    open: false
    server:
      baseDir: paths.dest
  )

gulp.task "optimizeImages", ->
  gulp.src(paths.optimizeImages)
    .pipe(p.imagemin())
    .pipe(gulp.dest("src"))

gulp.task "revAssets", ->
  revAll = new p.revAll(prefix: assetHost)
  gulp.src(paths.rev)
    .pipe(revAll.revision())
    .pipe(dest())
    .pipe(revAll.manifestFile())
    .pipe(dest())

gulp.task "sitemap", ->
  gulp.src(paths.sitemap)
    .pipe(p.sitemap(
      siteUrl: baseUrl
      changefreq: "weekly"
    ))
    .pipe(dest())

gulp.task "watch", ->
  gulp.watch paths.copy, ["copy"]
  gulp.watch paths.styles, ["styles"]
  gulp.watch paths.scripts, ["scripts"]
  gulp.watch paths.feedTemplate, ["feed"]
  gulp.watch paths.articleTemplate, ["articles"]
  gulp.watch paths.templates, ["articles", "pages"]
  gulp.watch(paths.pages).on("change", (file) -> buildHtml(file.path))
  gulp.watch(paths.articles).on("change", (file) -> buildHtml(file.path, paths.articlesBasepath))

gulp.task "build", (cb) -> runSequence("styles", ["copy", "pages", "articles", "feed", "scripts"], cb)
gulp.task "develop", (cb) -> runSequence("build", ["watch", "browserSync"], cb)
gulp.task "rev", (cb) -> runSequence("revAssets", ["pages", "articles"], cb)
gulp.task "production", (cb) -> runSequence("build", "rev", "sitemap", cb)
