gulp = require("gulp")
del = require("del")
p = require("gulp-load-plugins")()
runSequence = require("run-sequence")
autoprefixer = require("autoprefixer")
mqpacker = require("css-mqpacker")
csswring = require("csswring")
browserSync = require("browser-sync").create()

path =
  dest: "dist"
  rev: ["dist/**/*.{css,js,svg,jpg,png,gif,cur,eot,ttf,woff,woff2}"]
  copy: ["src/{fonts,images,svgs}/**/*", "src/favicon.ico"]
  views: ["src/**/*.jade"]
  styles: ["src/styles/**/*.{css,styl}"]
  scripts: ["src/scripts/**/*.js"]
  legacy: ["legacy/**/*"]

dest = (folder = "") -> gulp.dest("#{path.dest}/#{folder}")

lookupRevved = (fileName, includeHost=true) ->
  revs = try
    require("./#{path.dest}/rev-manifest.json")
  catch
    undefined
  if revs then revs[fileName] else fileName

gulp.task "clean", (cb) ->
  del(path.dest, cb)

gulp.task "copy", (cb) ->
  gulp.src(path.copy)
    .pipe(dest())
    .pipe(browserSync.stream())

gulp.task "legacy", (cb) ->
  gulp.src(path.legacy)
    .pipe(dest())

gulp.task "views", ->
  jadeConf =
    pretty: true
    locals:
      stylesMainUrl: lookupRevved("styles/main.css")
  gulp.src(path.views)
    .pipe(p.plumber())
    .pipe(p.resolveDependencies({pattern: /^\s*(?:extends|include) ([\w-]+)$/g}))
    .pipe(p.jade(jadeConf))
    .pipe(dest())
    .pipe(browserSync.stream())

gulp.task "scripts", ->
  gulp.src(path.scripts)
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
  gulp.src(path.styles)
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
    server:
      baseDir: path.dest
  )

gulp.task "revAssets", ->
  revAll = new p.revAll()
  gulp.src(path.rev)
    .pipe(revAll.revision())
    .pipe(dest())
    .pipe(revAll.manifestFile())
    .pipe(dest())

gulp.task "watch", ->
  gulp.watch path.copy, ["copy"]
  gulp.watch path.views, ["views"]
  gulp.watch path.styles, ["styles"]
  gulp.watch path.scripts, ["scripts"]

gulp.task "build", (cb) -> runSequence(["copy", "views", "styles", "scripts"], cb)
gulp.task "develop", (cb) -> runSequence("clean", "build", ["watch", "browserSync"], cb)
gulp.task "production", (cb) -> runSequence("clean", "legacy", "build", ["rev"], cb)
gulp.task "rev", (cb) -> runSequence("revAssets", "views", cb)