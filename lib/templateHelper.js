import fs from 'fs';
import path from 'path';

const paths = {
  src: 'src',
  dest: 'dist'
};

const revvedFile = (filePath) => {
  let revs;
  try { revs = require(`./../${paths.dest}/rev-manifest.json`); } catch (error) { }
  return revs && revs[filePath] || filePath;
};

const isEnglish = (filePath) =>
  (context) => {
    if (filePath && filePath.match(/^pages\/(articles|contact|home)/)) {
      return true;
    } else if (context && context.mvb && context.mvb.article) {
      return context.mvb.article.lang === 'en';
    } else {
      return false;
    }
  };

const formatDateGerman = date => date.toISOString().replace(/T.*/, '').split('-').reverse().join('.');
const formatDateEnglish = date => date.toString().replace(/\w+\s(\w+)\s(\d+)\s(\d+).*/, '$1 $2, $3');

const getDate = (article) =>
  article.updated != null ?
    new Date(Date.parse(article.updated)) :
    article.date;

export default {
  createHelper(file, isDev, baseUrl, assetHost) {
    const filePath = path.relative(paths.src, file.path);
    const isElm = filePath.match(/^(pages\/(articles|artikel)\/elm)/) || filePath.match(/^articles\/elm/);

    return {
      isDev,
      formatDateGerman,
      formatDateEnglish,

      isEnglish: isEnglish(filePath),

      baseUrl(filePath) {
        return !filePath.match(/^https?:/) ? baseUrl + filePath : filePath;
      },

      assetUrl(filePath, includeHost = true) {
        const file = revvedFile(filePath);
        return `${includeHost ? assetHost : ''}/${file}`;
      },

      assetInline(filePath) {
        const file = `./${paths.dest}/${revvedFile(filePath)}`;
        return fs.readFileSync(file, 'utf8');
      },

      nav: {
        isHome: filePath.match(/^pages\/index/),
        isContact: filePath.match(/^pages\/(contact|kontakt)/),
        isProjects: filePath.match(/^pages\/(projects|projekte)/),
        isArticles: filePath.match(/^(pages\/(articles|artikel)|articles\/|drafts\/)/) && !isElm,
        isElm
      },

      article: {
        getDate,

        feedDate(a) {
          return getDate(a).toISOString();
        },

        description(a) {
          return a.description || a.content.replace(/(<([^>]+)>)/ig, '').substring(0, 150);
        },

        keywords(a) {
          return a.tags.join(',');
        },

        hasCode(a) {
          return !!a.content.match(/class=["'](hljs|lang-).*["']/);
        },
      },

      articles: {
        feedDate(articles) {
          const dates = articles.map(article => getDate(article));
          const latestUpdate = new Date(Math.max.apply(null, dates));
          return latestUpdate.toISOString();
        },

        filterByNoAlternate(articles, lang) {
          return articles.filter((article) => {
            const { alternate } = article;
            return !alternate || alternate.lang !== lang;
          })
        },

        filterByLanguage(articles, lang) {
          return articles.filter(article => article.lang === lang);
        }
      },

      lang(context) {
        return isEnglish(filePath)(context) ? 'en' : 'de';
      },

      t(context, g, e) {
        return isEnglish(filePath)(context) ? e : g;
      },
    };
  }
};
