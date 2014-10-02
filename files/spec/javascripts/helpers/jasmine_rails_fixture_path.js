(function() {
  'use strict';
  // determine correct path for jasmine-jquery fixtures
  // path for CLI is relative to the tmp/jasmine/runner.html file
  // path for in browser tests goes through the rails asset pipeline
  function fixturesPath() {
    var path = null;
    if (jasmine.ConsoleReporter) {
      path = '../../spec/javascripts/fixtures';
    } else {
      path = '/assets/fixtures';
    }
    return path;
  }

  // global setup before each test run
  beforeEach(function() {
    jasmine.getFixtures().fixturesPath = fixturesPath();
  });
})();
