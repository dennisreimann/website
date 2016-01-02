gulp = require("gulp")
del = require("del")
p = require("gulp-load-plugins")()
runSequence = require("run-sequence")
autoprefixer = require("autoprefixer")
mqpacker = require("css-mqpacker")
csswring = require("csswring")
browserSync = require("browser-sync").create()
argv = require("yargs").argv

isDev = argv.dev?
assetHost = argv.assetHost or ""

paths =
  dest: "dist"
  rev: ["dist/**/*.{css,js,svg,jpg,png,gif,cur,eot,ttf,woff,woff2}"]
  copy: ["src/{fonts,images,svgs}/**/*", "src/favicon.ico", "src/.htaccess"]
  pages: ["src/pages/**/*.jade"]
  styles: ["src/styles/**/*.{css,styl}"]
  scripts: ["src/scripts/**/*.js"]
  optimizeImages: ["src/{images,svgs}/**/*"]
  articles: if isDev then ["src/articles/*.md", "src/drafts/*.md"] else ["src/articles/*.md"]
  feedTemplate: "src/templates/atom.jade"
  articleTemplate: "src/templates/article.jade"
  articlesBasepath: "articles"

dest = (folder = "") -> gulp.dest("#{paths.dest}/#{folder}")

assetUrl = (fileName, includeHost = true) ->
  revs = try
    require("./#{paths.dest}/rev-manifest.json")
  catch
    undefined
  file = if revs then revs[fileName] else fileName
  "#{assetHost}/#{file}"

mvbConf =
  glob: paths.articles
  template: paths.articleTemplate
  permalink: (article) ->
    "/#{paths.articlesBasepath}/#{article.id}.html"

templateData =
  assetUrl: assetUrl

gulp.task "clean", (cb) ->
  del(paths.dest, cb)

gulp.task "copy", (cb) ->
  gulp.src(paths.copy)
    .pipe(dest())
    .pipe(browserSync.stream())

gulp.task "articles", ->
  gulp.src(paths.articles)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade(pretty: true))
    .pipe(dest(paths.articlesBasepath))
    .pipe(browserSync.stream())

gulp.task "pages", ->
  gulp.src(paths.pages)
    .pipe(p.plumber())
    .pipe(p.resolveDependencies(pattern: /^\s*(?:extends|include) ([\w-]+)$/g))
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade(pretty: true))
    .pipe(dest())
    .pipe(browserSync.stream())

gulp.task "feed", ->
  gulp.src(paths.feedTemplate)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
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
    .pipe(browserSync.stream())

gulp.task "styles", ->
  processors = [
    mqpacker
    autoprefixer(browsers: ["last 2 versions"])
    csswring
  ]
  gulp.src(paths.styles)
    .pipe(p.plumber())
    .pipe(p.sourcemaps.init())
    .pipe(p.stylus(paths: ["src/styles/lib"], import: ["mediaQueries", "mixins", "variables"]))
    .pipe(p.concat("main.css"))
    .pipe(p.postcss(processors))
    .pipe(p.sourcemaps.write("./maps"))
    .pipe(dest("styles"))
    .pipe(browserSync.stream())

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
  revAll = new p.revAll()
  gulp.src(paths.rev)
    .pipe(revAll.revision())
    .pipe(dest())
    .pipe(revAll.manifestFile())
    .pipe(dest())

gulp.task "watch", ->
  gulp.watch paths.copy, ["copy"]
  gulp.watch paths.pages, ["pages"]
  gulp.watch paths.styles, ["styles"]
  gulp.watch paths.scripts, ["scripts"]
  gulp.watch paths.articles, ["articles", "pages", "feed"]
  gulp.watch paths.feedTemplate, ["feed"]
  gulp.watch paths.articleTemplate, ["articles"]

gulp.task "build", ["copy", "pages", "articles", "feed", "styles", "scripts"]
gulp.task "develop", (cb) -> runSequence("build", ["watch", "browserSync"], cb)
gulp.task "production", (cb) -> runSequence("build", ["rev"], cb)
gulp.task "rev", (cb) -> runSequence("revAssets", ["pages", "articles"], cb)
