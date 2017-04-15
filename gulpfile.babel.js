import { argv } from 'yargs'
import path from 'path'
import gulp from 'gulp'
import gulpLoadPlugins from 'gulp-load-plugins'
import runSequence from 'run-sequence'
import autoprefixer from 'autoprefixer'
import mqpacker from 'css-mqpacker'
import csswring from 'csswring'
import highlightjs from 'highlight.js'
import BrowserSync from 'browser-sync'
import debounce from './lib/debounce'
import templateHelper from './lib/templateHelper'

const p = gulpLoadPlugins()
const browserSync = BrowserSync.create()

const isDev = (argv.dev != null)
const assetHost = argv.assetHost || ''
const defaultScheme = isDev ? 'http' : 'https'
const siteHost = isDev ? 'localhost:3000' : 'dennisreimann.de'
const siteUrl = `${defaultScheme}://${siteHost}`

const paths = {
  src: 'src',
  dest: 'dist',
  rev: ['!dist/files/**/*', 'dist/**/*.{css,js,map,svg,jpg,png,gif,woff,woff2}'],
  copy: ['src/static/**/*', 'src/static/.htaccess'],
  pages: ['src/pages/**/*.pug'],
  styles: ['src/styles/**/*.styl'],
  scripts: ['src/scripts/**/*.js'],
  html: ['dist/**/*.html'],
  optimizeImages: ['src/{images,svgs}/**/*'],
  articles: ['src/articles/*.md'],
  templates: 'src/templates/*.pug',
  articleTemplate: 'src/templates/article.pug',
  articlesBasepath: 'articles'
}

const dest = (folder = '') => gulp.dest(`${paths.dest}/${folder}`)

const mvbConf = {
  glob: paths.articles,
  template: paths.articleTemplate,
  permalink (article) {
    return `/${paths.articlesBasepath}/${article.id}.html`
  },
  highlight (code, lang) {
    const languages = (lang != null) ? [lang] : undefined
    return highlightjs.highlightAuto(code, languages).value
  },
  grouping (articles) {
    const byYear = {}
    const byTag = {}

    articles.forEach(function (article) {
      const year = article.date.toISOString().replace(/-.*/, '')
      if (!byYear[year]) { byYear[year] = [] }
      byYear[year].push(article)

      return (article.tags || []).forEach(function (tag) {
        if (!byTag[tag]) { byTag[tag] = [] }
        return byTag[tag].push(article)
      })
    })

    // year
    const articlesByYear = []
    Object.keys(byYear).reverse().forEach(year => articlesByYear.push({year, articles: byYear[year]}))

    // tag
    const articlesByTag = byTag

    // groups
    return {
      byTag: articlesByTag,
      byYear: articlesByYear
    }
  }
}

const templateData = file => ({
  h: templateHelper.createHelper(file, isDev, siteHost, assetHost, defaultScheme),
  page: {
    permalink: path.relative(paths.src, file.path).replace(/^pages/, '').replace(/\.pug$/, '.html')
  }
})

const buildHtml = (src, dst) =>
  gulp.src(src)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.pug({pretty: true}))
    .pipe(dest(dst))

const feedWithTemplate = (template, folder) =>
  gulp.src(`src/feed/${template}.pug`)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.pug({pretty: true}))
    .pipe(p.rename({extname: '.xml'}))
    .pipe(dest(folder))

gulp.task('feed:atom', () => feedWithTemplate('atom'))
gulp.task('feed:elm', () => feedWithTemplate('elm', paths.articlesBasepath))
gulp.task('feed', ['feed:atom', 'feed:elm'])

gulp.task('copy', cb =>
  gulp.src(paths.copy)
    .pipe(dest())
    .pipe(browserSync.stream())
)

gulp.task('pages', () => buildHtml(paths.pages))
gulp.task('articles', () => buildHtml(paths.articles, paths.articlesBasepath))

gulp.task('scripts', () =>
  gulp.src(paths.scripts)
    .pipe(p.plumber())
    .pipe(p.babel())
    .pipe(p.uglify())
    .pipe(dest('scripts'))
    .pipe(browserSync.stream({match: '**/*.js'}))
)

gulp.task('styles', () =>
  gulp.src(paths.styles)
    .pipe(p.plumber())
    .pipe(p.stylus({
      paths: ['src/styles/lib'],
      import: ['mediaQueries', 'variables']
    }))
    .pipe(p.concat('main.css'))
    .pipe(p.postcss([
      mqpacker,
      autoprefixer({browsers: ['last 2 versions']}),
      csswring
    ]))
    .pipe(dest('styles'))
    .pipe(browserSync.stream({match: '**/*.css'}))
)

gulp.task('browserSync', () =>
  browserSync.init({
    open: false,
    server: {
      baseDir: paths.dest
    }
  })
)

gulp.task('optimizeImages', () =>
  gulp.src(paths.optimizeImages)
    .pipe(p.imagemin())
    .pipe(gulp.dest('src'))
)

gulp.task('revAssets', () => {
  const RevAll = p.revAll
  const revAll = new RevAll({prefix: assetHost})
  return gulp.src(paths.rev)
    .pipe(revAll.revision())
    .pipe(p.revDeleteOriginal())
    .pipe(dest())
    .pipe(revAll.manifestFile())
    .pipe(dest())
})

gulp.task('sitemap', () =>
  gulp.src(paths.html)
    .pipe(p.sitemap({ siteUrl, changefreq: 'weekly' }))
    .pipe(dest())
)

gulp.task('html:optimize', cb =>
  gulp.src(paths.html)
    .pipe(p.minifyHtml({empty: true}))
    .pipe(dest())
)

gulp.task('watch', () => {
  gulp.watch(paths.copy, ['copy'])
  gulp.watch(paths.styles, ['styles'])
  gulp.watch(paths.scripts, ['scripts'])
  gulp.watch(paths.articleTemplate, ['articles'])
  gulp.watch(paths.templates, ['articles', 'pages'])
  gulp.watch(paths.pages).on('change', file => buildHtml(file.path))
  gulp.watch(paths.articles).on('change', file => buildHtml(file.path, paths.articlesBasepath))
  gulp.watch(paths.html).on('change', () => debounce('reload', browserSync.reload, 500))
})

gulp.task('optimize', ['html:optimize'])
gulp.task('build', cb => runSequence('styles', ['copy', 'pages', 'articles', 'feed', 'scripts'], cb))
gulp.task('develop', cb => runSequence('build', ['watch', 'browserSync'], cb))
gulp.task('rev', cb => runSequence('revAssets', ['pages', 'articles'], cb))
gulp.task('production', cb => runSequence('build', 'rev', ['sitemap', 'optimize'], cb))
