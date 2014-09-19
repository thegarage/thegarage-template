Garage Template
==============

Start your new application off on the right foot with all of the gems, tools and configuration necessary to build awesome apps.

Features
--------
* Static Rails webapp (Bootstrap, jQuery, HAML)
* Virtualized local development environment (Vagrant, Virtualbox)
* Full Rails + Javascript testsuite w/ linters (RSpec, Jasmine, Rubocop, JSHint)
* Complete continuous integration and continuous deployment configuration (Github, Travis CI, Heroku)
* Continuous testing environment
* Email configuration
* Various 3rd party integrations (NewRelic, Honeybadger, etc)

Prerequisites
-------------
* [Rails](https://github.com/rails/rails)
* [Virtualbox](https://www.virtualbox.org)
* [Vagrant](http://www.vagrantup.com/)
* [Ansible](http://www.ansible.com/)

Usage
-----

Generate new rails project, and the template will automatically prompt you
to enter the relevant API Keys/Tokens for services and configure your app:

```
$ rails new myapp -m https://raw.github.com/thegarage/thegarage-template/master/template.rb -T
```

Your Rails server is now up and running across local/staging/production environments:
* [Local development environment](http://localhost:3000)
* Heroku staging environment: http://myapp-staging.herokuapp.com
* Heroku production environment: http://myapp-production.herokuapp.com

Implementation
--------------
* Built with the [Rails apps composer framework](https://github.com/RailsApps/rails_apps_composer)
* Composed into [separate recipies](/recipes) for maintainability

Development
-----------
```bash
# install necessary gems
$ bundle

# use guard to automatically generate template w/ any changes
$ bin/guard

# OR manually compile recipies into template
$ bin/generate_template

# generate local example rails app for testing
$ bin/generate_example_app
```

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
