Garage Template
==============
Want to skip a couple of days of setting up gemfiles, resolving differences in your RSpec configuration? Drop the creation of files you don't use usually make use of anyway? The Template will get you right past all of that.

Features
--------
* Virtualized local development environment
* Full Rails + Javascript testsuite w/ linters (RSpec, Jasmine, Rubocop, JSHint)
* Continuous testing environment
* Various 3rd party integrations (NewRelic, Honeybadger, Travis CI, etc)

Prerequisites
-------------
* [Rails](https://github.com/rails/rails)
* [Bundler](http://bundler.io/)
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

Your Rails server is now up and running at [http://localhost:3000](http://localhost:3000).

Implementation
--------------
* Built with the [Rails apps composer framework](https://github.com/RailsApps/rails_apps_composer)
* Composed into [separate recipies](/recipes) for maintainability

Development
-----------
```bash
# install necessary gems
$ bundle
```

```bash
# compile recipies into uber template
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
