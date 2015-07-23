var Website = {
  init: function() {
    Website.initFancybox();
    Website.initTracking();
  },
  initFancybox: function() {
    $("a.fancy").fancybox({
      transitionIn: 'elastic',
      transitionOut: 'elastic',
      hideOnContentClick: true,
      speedIn: 600,
      speedOut: 200
    });
  },
  initTracking: function() {
    $('a#badge').click(function(e) { _gaq.push(['_trackEvent', 'Layout', 'Badge', window.location.href]); });
    $('#footer small a').click(function(e) { _gaq.push(['_trackEvent', 'Layout', 'Contact details', window.location.href]); });
    $('#index-page #projects small a').click(function(e) { _gaq.push(['_trackEvent', 'Homepage', 'All projects']); });
    $('#index-page #archives small a').click(function(e) { _gaq.push(['_trackEvent', 'Homepage', 'All articles']); });
    $('#projects-page #main a').click(function(e) { _gaq.push(['_trackEvent', 'Projects', 'Link', e.currentTarget.href]); });
    $('#publications-page #main a').click(function(e) { _gaq.push(['_trackEvent', 'Publications', 'Link', e.currentTarget.href]); });
    $('#contact-page #main a').click(function(e) { _gaq.push(['_trackEvent', 'Contact', 'Link', e.currentTarget.href]); });
    $('.follow a').click(function(e) { _gaq.push(['_trackEvent', 'Article', 'Follow', e.currentTarget.className]); });
  }
};
