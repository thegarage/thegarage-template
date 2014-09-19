//= require jquery
// track events for each page viewed by user
$(function() {
  'use strict';
  mixpanel.track('Page Viewed', {
    'page name' : document.title,
    'path' : window.location.pathname
  });
});
