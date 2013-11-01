Garage Template
==============
Want to skip a couple of days of setting up gemfiles, resolving differences in your RSpec configuration? Drop the creation of files you don't use usually make use of anyway? The Template will get you right past all of that.

Features
--------
* Soup to nuts Rails project setup: If you're on a fresh RVM+Rails install, you're good to go.
* Vagrant+Berkshelf setup for a Linux server Environment(Ubuntu 12.04+Passenger+Postgres).
* Full-featured continuous testing environment setup, with [RSpec](https://github.com/rspec/rspec-rails), [Jasmine](https://github.com/searls/jasmine-rails), [Guard](https://github.com/guard/guard), [Rubocop](https://github.com/bbatsov/rubocop), & [JSHintRB](https://github.com/stereobooster/jshintrb).
* Service setup for [Travis-CI](https://travis-ci.org/), [New Relic](http://newrelic.com/), [Honeybadger](https://www.honeybadger.io/), even notifications to [Campfire](https://campfirenow.com/). Also, gem setup for [Heroku](https://www.heroku.com/).
* Common convenience settings for most Rails apps, as well as environment settings for the four usual environments(Development, Test, Staging, Production).

Prerequisites
-------------
* [Rails 4.0](https://github.com/rails/rails)
* [Bundler](http://bundler.io/)
* [Virtualbox](https://www.virtualbox.org)
* [Vagrant](http://www.vagrantup.com/)
* [Vagrant-Omnibus](https://github.com/schisamo/vagrant-omnibus)
* [Vagrant-Berkshelf](https://github.com/riotgames/vagrant-berkshelf)

Usage
-----

Generate new rails project, and the template will automatically prompt you
to enter the relevant API Keys/Tokens for services and configure your app:

```
$ rails new myapp -m https://raw.github.com/thegarage/rails-template/master/garage_composer.rb
$ cd myapp
$ vagrant up --provision
```

Your Rails server is already up and running. It's running on passenger, and you can find it at [http://localhost:3000](http://localhost:3000).

### Continuous Testing, Testing Suites, & Linters, oh my!
We employ a wide set of testing tools to help keep things working, keep code quality high, and make sure we're building the right thing, the right way.

#####RSpec
The centerpiece is [**RSpec**](https://github.com/rspec/rspec-rails). We use it as a unit testing framework, while using [Factory Girl](https://github.com/thoughtbot/factory_girl_rails) for fixture generation, and [SimpleCov](https://github.com/colszowka/simplecov) for code coverage. Note, if your test coverage ever falls below 95%, SimpleCov review will exit as an error.

* Some other smaller gem additions to significantly help with test creation and quality have been added, including:
  * [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) to give a multitude of extremely useful matchers. Seriously, go read their Readme for just some.
  * [Factory Girl RSpec](https://github.com/wireframe/factory_girl_rspec) to make FactoryGirl usage even easier.
  * [Webrat](https://github.com/brynary/webrat) for better view test construction, with useful matchers like 'HaveSelector'.
  * [should_not](https://github.com/should-not/should_not) to help with writing better spec descriptions.
  * [WeBmock](https://github.com/bblimke/webmock) for better stubbing of any sort of HTTP requests during your tests.
  * [VCR](https://github.com/vcr/vcr) for incoming API request testing.

#####Jasmine
For Javascript testing, we use [Jasmine](https://github.com/searls/jasmine-rails). At any time during development, if you want to see how your tests fare, just head to [http://localhost:3000/specs](http://localhost:3000/specs) and you should get a complete rundown.

####Linters
To coding conventions are followed, we use [Rubocop](https://github.com/bbatsov/rubocop) for our Ruby code,
and [JSHintRB](https://github.com/stereobooster/jshintrb) for Javascript code.

#### Testsuite

Our default rake command includes a comprehensive suite of operations to ensure that Continuous Integration services work out of the box.
* full run of all Rspec + headless Jasmine tests
* linting of Ruby/Javascript files
* security scan for known security vulnerabilities ([Brakeman](http://brakemanscanner.org/), [Bundler-Audit](https://github.com/rubysec/bundler-audit))

#### Continuous Testing: Guard
We use Guard to keep all of the above going, every time we develop. No, really. After your project is created and you're inside it, just run `bundle exec guard`, write your tests, and make things. You'll see immediate results, so you can properly follow [Red/Green/Refactor](http://en.wikipedia.org/wiki/Test-driven_development#Development_style).

#### Pry
We've included [Pry](http://pryrepl.org/) and [Pry-Remote](https://github.com/Mon-Ouie/pry-remote) for debugging. Pry gives some amazing debugging tools, and Pry-Remote makes them available from even browser requests.

Services
--------
We include automatic setup for several services.

* [**TravisCI**](https://travis-ci.com/) for continuous integration, or rather, for testing in server-like settings, as well as potentially as a deployment platform. We've also included automatic notification to [Campfire](https://campfirenow.com/) rooms from TravisCI.
* [**NewRelic**](http://www.newrelic.com/) for web app performance and monitoring.
* [**Honeybadger**](http://honeybadger.io/) for error management and logging.
* [**Heroku**](https://www.heroku.com/) for getting your app up onto the web as fast as possible. We've included the [rails_12factor](https://github.com/heroku/rails_12factor) gem to get you on their service as fast as possible.

Common Convenience Settings
---------------------------
* We turn off generators for helpers, stylesheets, and javascripts by default. Also, views won't produce specs by default.
* We set the time zone to Central Time(US & Canada). It can be changed quickly in **config/application.rb**.
* We've got some convenience settings related to Bundler groups, including debug for Pry.


[Contributing](CONTRIBUTING.md)
------------
1. Fork it.
2. Patch it.
3. Pull Request.

[List of contributors](CONTRIBUTORS.TXT)

License
-------
[MIT License](LICENSE)

Copyright (c) 2013 The Garage
