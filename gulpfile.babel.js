import { argv } from 'yargs'
import { relative } from 'path'
import { readFileSync } from 'fs'
import { src, dest, series, parallel, task, watch } from 'gulp'
import autoprefixer from 'autoprefixer'
import BrowserSync from 'browser-sync'
import csso from 'postcss-csso'
import highlightjs from 'highlight.js'
import babel from 'gulp-babel'
import data from 'gulp-data'
import concat from 'gulp-concat'
import htmlmin from 'gulp-htmlmin'
import mvb from 'gulp-mvb'
import pug from 'gulp-pug'
import stripDebug from 'gulp-strip-debug'
import postcss from 'gulp-postcss'
import rename from 'gulp-rename'
import replace from 'gulp-replace'
import rev from 'gulp-rev'
import revRewrite from 'gulp-rev-rewrite'
import revDeleteOriginal from 'gulp-rev-delete-original'
import sitemap from 'gulp-sitemap'
import stylus from 'gulp-stylus'
import uglify from 'gulp-uglify'
import templateHelper from './lib/templateHelper'

const browserSync = BrowserSync.create()
const isDev = (argv.dev != null)
const defaultScheme = isDev ? 'http' : 'https'
const siteHost = isDev ? 'localhost:3000' : 'dennisreimann.de'
const siteUrl = `${defaultScheme}://${siteHost}`
const assetHost = argv.assetHost || siteHost

const paths = {
  src: 'src',
  dest: 'dist',
  rev: ['dist/**/*.{css,js,map,svg,jpg,png,gif,woff,woff2}', '!dist/service-worker.js', '!dist/files/**/*'],
  copy: ['static/**/*'],
  pages: ['src/pages/**/*.pug'],
  styles: ['src/styles/**/*.styl'],
  scripts: ['src/scripts/**/*.js'],
  serviceworker: ['src/serviceworker/service-worker.js'],
  html: ['dist/**/*.html'],
  sitemap: ['dist/**/*.html', '!dist/**/{contact,datenschutz,kontakt,privacy,donate}.html'],
  js: ['dist/**/*.js'],
  css: ['dist/**/*.css'],
  articles: ['src/articles/*.md'],
  templates: 'src/templates/**/*.pug',
  articleTemplate: 'src/templates/article.pug',
  articlesBasepath: 'articles'
}

const dist = (folder = '') => dest(`${paths.dest}/${folder}`)

const pugConf = {
  pretty: true,
  basedir: './src/templates'
}

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
    Object.keys(byYear).reverse().forEach(year => articlesByYear.push({ year, articles: byYear[year] }))

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
    permalink: relative(paths.src, file.path).replace(/^pages/, '').replace(/\.pug$/, '.html')
  }
})

// ----- BUILD -----

const buildHtml = (files, dst) =>
  src(files)
    .pipe(mvb(mvbConf))
    .pipe(data(templateData))
    .pipe(pug(pugConf))
    .pipe(dist(dst))

const feedWithTemplate = (template, folder) =>
  src(`src/feed/${template}.pug`)
    .pipe(mvb(mvbConf))
    .pipe(data(templateData))
    .pipe(pug(pugConf))
    .pipe(rename({ extname: '.xml' }))
    .pipe(dist(folder))

task('feed:atom', () => feedWithTemplate('atom'))
task('feed:elm', () => feedWithTemplate('elm', paths.articlesBasepath))
task('feed', parallel('feed:atom', 'feed:elm'))

task('copy', () =>
  src(paths.copy)
    .pipe(dist())
)

task('pages', () => buildHtml(paths.pages))
task('articles', () => buildHtml(paths.articles, paths.articlesBasepath))

task('serviceworker', () => {
  let htmlCacheKeys = {}
  try {
    const htmlManifest = require(`./${paths.dest}/html-manifest.json`)

    // prefix keys and values with slash
    htmlCacheKeys = Object.keys(htmlManifest).reduce((acc, htmlFile) => {
      acc[`/${htmlFile}`] = `/${htmlManifest[htmlFile]}`
      return acc
    }, {})

    // add extra key for root path
    htmlCacheKeys['/'] = `/${htmlManifest['index.html']}`
  } catch (error) { }

  return src(paths.serviceworker)
    .pipe(replace('const HTML_CACHE_KEYS = {}', `const HTML_CACHE_KEYS = ${JSON.stringify(htmlCacheKeys, null, '  ')}`))
    .pipe(babel())
    .pipe(stripDebug())
    .pipe(uglify())
    .pipe(dist())
})

task('scripts', () =>
  src(paths.scripts)
    .pipe(babel())
    .pipe(dist('scripts'))
)

task('styles', () =>
  src(paths.styles)
    .pipe(stylus({
      paths: ['src/styles/lib'],
      import: ['mediaQueries', 'variables']
    }))
    .pipe(concat('main.css'))
    .pipe(dist('styles'))
)

task('build', series(parallel('copy', 'styles', 'scripts', 'serviceworker'), parallel('pages', 'articles', 'feed')))

// ----- DEVELOPMENT -----

task('incremental', () => {
  watch(paths.copy, parallel('copy'))
  watch(paths.styles, parallel('styles'))
  watch(paths.scripts, parallel('scripts'))
  watch(paths.serviceworker, parallel('serviceworker'))
  watch(paths.articleTemplate, parallel('articles'))
  watch(paths.templates, parallel('articles', 'pages'))
  watch(paths.pages).on('change', filePath => task(buildHtml(filePath)))
  watch(paths.articles).on('change', filePath => task(buildHtml(filePath, paths.articlesBasepath)))
})

task('serve', done => browserSync.init(require('./browser-sync.config'), done))

// ----- PRODUCTION -----

task('minify:html', () =>
  src(paths.html)
    .pipe(htmlmin())
    .pipe(dist())
)

task('minify:js', () =>
  src(paths.js)
    .pipe(stripDebug())
    .pipe(uglify())
    .pipe(dist())
)

task('minify:css', () =>
  src(paths.css)
    .pipe(postcss([
      autoprefixer(),
      csso()
    ]))
    .pipe(dist())
)

task('html:sitemap', () =>
  src(paths.sitemap)
    .pipe(sitemap({ siteUrl, changefreq: 'weekly' }))
    .pipe(dist())
)

task('html:manifest', () =>
  src(paths.html)
    .pipe(rev())
    .pipe(rev.manifest('html-manifest.json'))
    .pipe(dist())
)

task('rev-files', () =>
  src(paths.rev)
    .pipe(rev())
    .pipe(revDeleteOriginal())
    .pipe(dist())
    .pipe(rev.manifest())
    .pipe(dist())
)

task('rev-rewrite', () => {
  const manifest = readFileSync('dist/rev-manifest.json')
  return src(paths.css)
    .pipe(revRewrite({ manifest }))
    .pipe(dist())
})

// ----- PUBLIC TASKS -----

task('develop', series('build', 'serve', 'incremental'))
task('optimize', series(parallel('minify:js', 'minify:css'), series('rev-files', 'rev-rewrite')))
task('production', series(parallel('pages', 'articles'), 'minify:html', parallel('html:sitemap', 'html:manifest'), 'serviceworker'))
