import { argv } from 'yargs';
import gulp from 'gulp';
import gulpLoadPlugins from 'gulp-load-plugins';
import runSequence from 'run-sequence';
import autoprefixer from 'autoprefixer';
import mqpacker from 'css-mqpacker';
import csswring from 'csswring';
import highlightjs from 'highlight.js';
import BrowserSync from 'browser-sync';
import templateHelper from './lib/templateHelper';

const p = gulpLoadPlugins();
const browserSync = BrowserSync.create();

const isDev = (argv.dev != null);
const assetHost = argv.assetHost || '';
const baseUrl = isDev ? 'http://localhost:3000' : 'https://dennisreimann.de';

const paths = {
  src: 'src',
  dest: 'dist',
  rev: ['dist/**/*.{css,js,map,svg,jpg,png,gif,ttf,woff,woff2}'],
  copy: ['src/{fonts,images,svgs}/**/*', 'src/favicon.ico', 'src/.htaccess', 'src/{styles,}/vendor/highlightjs.css'],
  pages: ['src/pages/**/*.jade'],
  styles: ['src/styles/**/*.styl'],
  scripts: ['src/scripts/**/*.js'],
  sitemap: ['dist/**/*.html'],
  optimizeImages: ['src/{images,svgs}/**/*'],
  articles: isDev ? ['src/articles/*.md', 'src/drafts/*.md'] : ['src/articles/*.md'],
  templates: 'src/templates/*.jade',
  articconstemplate: 'src/templates/article.jade',
  articlesBasepath: 'articles',
};

const dest = (folder = '') => gulp.dest(`${paths.dest}/${folder}`);

const mvbConf = {
  glob: paths.articles,
  template: paths.articconstemplate,
  permalink(article) {
    return `/${paths.articlesBasepath}/${article.id}.html`;
  },
  highlight(code, lang) {
    const languages = (lang != null) ? [lang] : undefined;
    return highlightjs.highlightAuto(code, languages).value;
  },
  grouping(articles) {
    const byYear = {};
    const byTag = {};

    articles.forEach(function(article) {
      let tags;
      const year = article.date.toISOString().replace(/-.*/, '');
      if (!byYear[year]) { byYear[year] = []; }
      byYear[year].push(article);

      return tags = (article.tags || []).forEach(function(tag) {
        if (!byTag[tag]) { byTag[tag] = []; }
        return byTag[tag].push(article);
      });
    });

    // year
    const articlesByYear = [];
    Object.keys(byYear).reverse().forEach(year => articlesByYear.push({year, articles: byYear[year]}));

    // tag
    const articlesByTag = byTag;

    // groups
    return {
      byTag: articlesByTag,
      byYear: articlesByYear
    };
  }
};

const templateData = file => ({
  h: templateHelper.createHelper(file, isDev, baseUrl, assetHost)
});

const buildHtml = (src, dst) =>
  gulp.src(src)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade({pretty: true}))
    .pipe(p.minifyHtml({empty: true}))
    .pipe(dest(dst))
    .pipe(browserSync.stream())

const feedWithTemplate = (template, folder) =>
  gulp.src(`src/feed/${template}.jade`)
    .pipe(p.plumber())
    .pipe(p.mvb(mvbConf))
    .pipe(p.data(templateData))
    .pipe(p.jade({pretty: true}))
    .pipe(p.rename({extname: '.xml'}))
    .pipe(dest(folder))

gulp.task('feed:atom', () => feedWithTemplate('atom'));
gulp.task('feed:elm', () => feedWithTemplate('elm', paths.articlesBasepath));
gulp.task('feed', ['feed:atom', 'feed:elm']);

gulp.task('copy', cb =>
  gulp.src(paths.copy)
    .pipe(dest())
    .pipe(browserSync.stream())
);

gulp.task('pages', () => buildHtml(paths.pages));
gulp.task('articles', () => buildHtml(paths.articles, paths.articlesBasepath));

gulp.task('scripts', () =>
  gulp.src(paths.scripts)
    .pipe(p.plumber())
    .pipe(p.sourcemaps.init())
    .pipe(p.babel())
    .pipe(p.uglify())
    .pipe(p.sourcemaps.write('./maps'))
    .pipe(dest('scripts'))
    .pipe(browserSync.stream({match: '**/*.js'}))
);

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
);

gulp.task('browserSync', () =>
  browserSync.init({
    open: false,
    server: {
      baseDir: paths.dest
    }
  })
);

gulp.task('optimizeImages', () =>
  gulp.src(paths.optimizeImages)
    .pipe(p.imagemin())
    .pipe(gulp.dest('src'))
);

gulp.task('revAssets', function() {
  const revAll = new p.revAll({prefix: assetHost});
  return gulp.src(paths.rev)
    .pipe(revAll.revision())
    .pipe(dest())
    .pipe(revAll.manifestFile())
    .pipe(dest());
});

gulp.task('sitemap', () =>
  gulp.src(paths.sitemap)
    .pipe(p.sitemap({
      siteUrl: baseUrl,
      changefreq: 'weekly'
    }))
    .pipe(dest())
);

gulp.task('watch', () => {
  gulp.watch(paths.copy, ['copy']);
  gulp.watch(paths.styles, ['styles']);
  gulp.watch(paths.scripts, ['scripts']);
  gulp.watch(paths.articconstemplate, ['articles']);
  gulp.watch(paths.templates, ['articles', 'pages']);
  gulp.watch(paths.pages).on('change', file => buildHtml(file.path));
  gulp.watch(paths.articles).on('change', file => buildHtml(file.path, paths.articlesBasepath));
});

gulp.task('build', cb => runSequence('styles', ['copy', 'pages', 'articles', 'feed', 'scripts'], cb));
gulp.task('develop', cb => runSequence('build', ['watch', 'browserSync'], cb));
gulp.task('rev', cb => runSequence('revAssets', ['pages', 'articles'], cb));
gulp.task('production', cb => runSequence('build', 'rev', 'sitemap', cb));
