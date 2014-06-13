require 'erb'

TEMPLATE_HOST = ENV.fetch('TEMPLATE_HOST', 'https://raw.github.com/thegarage/thegarage-template')
TEMPLATE_BRANCH = ENV.fetch('TEMPLATE_BRANCH', 'master')

# helper method to wrap a chunk of code
# with consistent output + a git commit message
def step(message)
  header = '#' * 80
  puts "\n\n"
  puts header
  puts message + '...'
  puts header
  yield
end

# shortcut method to delete existing file
# and replace with new contents
def replace_file(filename, data)
  remove_file filename
  create_file filename, data
end

# helper method to run a command and ensure success
# by default the thor run command does *not* exit
# the process when the command fails
def run_command(command, options = {})
  status = run(command, options)
  fail "#{command} failed" unless status
end

def preserve_directory(directory)
  path = File.join(directory, '.gitkeep')
  create_file path, ''
end

# shortcut method to add a gem to the
# gemfile/.lock/cache, and install it
def install_gem(gem_name, options = {})
  if options[:group]
    gem gem_name, group: options[:group]
  else
    gem gem_name
  end
  run_command "gem install #{gem_name}"
  run_command 'bundle install --local'
end

# download remote file from remote repo and save to local path
# the downloaded resources *may* contain dynamic ERB statements
# that will be automatically evaluated once downloaded
def get_file(path)
  remove_file path
  resource = File.join(TEMPLATE_HOST, TEMPLATE_BRANCH, 'files', path)
  create_file path, download_resource(resource)
end

# download partial file contents and process through ERB
# return the processed string
def get_file_partial(category, path)
  resource = File.join(TEMPLATE_HOST, TEMPLATE_BRANCH, 'files', 'partials', category.to_s, path)
  download_resource resource
end

# download remote file contents and process through ERB
# return the processed string
def download_resource(resource)
  puts "Downloading resource: #{resource}"
  open(resource) do |input|
    contents = input.binmode.read
    template = ERB.new(contents)
    template.result(binding)
  end
end

# insert content into existing file
# automatically add newlines before/after content
# supports matching indentation of matched line
def insert_lines_into_file(path, content, options = {})
  target_line = options[:before] || options[:after]
  target_line = Regexp.escape(target_line) unless target_line.is_a?(Regexp)
  target_line = /#{target_line}.*\n/
  options[:before] = target_line if options[:before]
  options[:after] = target_line if options[:after]
  indent = ''
  File.open(path, 'r') do |file|
    file.each_line(path) do |line|
      if line =~ target_line
        indent = line.scan(/^\s+/).first
      end
    end
  end
  indent ||= ''
  indent.chomp!

  if options[:indent].to_i > 0
    indent += (' ' * options[:indent].to_i)
  end

  indented_content = ''
  content.each_line do |line|
    indented_content += line.blank? ? line : (indent + line)
  end
  indented_content += "\n"

  insert_into_file path, indented_content, options
end

step 'Prompting for configurable settings' do
  NEWRELIC_KEY = ask("What is your NewRelic license key(enter nothing if you don't have one)?")
  HONEYBADGER_API_KEY = ask("What is your Honeybadger API key(enter nothing if you don't have one)?")
  TRAVIS_CAMPFILE_CONFIG = if yes?("Do you want TravisCI Campfire Notifications?")
    TRAVIS_CAMPFIRE_SUBDOMAIN = ask("What's your Campfire subdomain?")
    TRAVIS_CAMPFIRE_API_KEY = ask("What is your API key?")
    TRAVIS_CAMPFIRE_ROOM_ID = ask("What is your Campfire room ID(not the name)?")
    get_file_partial(:travis, '.travis.yml')
  else
    nil
  end
end

step 'Setting up initial project Gemfile' do
  replace_file 'Gemfile', ''
  add_source "https://rubygems.org"
  insert_lines_into_file 'Gemfile', "ruby '2.1.2'", after: /^source /

  gem 'rails', '~> 4.1.1'
  gem 'jquery-rails'
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'haml', '~> 4.0.3'
  gem 'rails-console-tweaks'
  gem 'pg'
  gem 'pry-rails'
  gem 'dotenv-rails'
  gem 'thegarage-gitx', group: [:development, :test]
  run_command 'bundle package'

  get_file '.env'
  get_file '.ruby-version'
  get_file '.gitignore'
end

step 'Setting up Rakefile default_tasks' do
  append_to_file 'Rakefile', "\n\ndefault_tasks = []\n\ntask default: default_tasks\n"
end

step 'Removing turbolinks' do
  gsub_file 'app/assets/javascripts/application.js', %r{^//= require turbolinks$.}m, ''
end

additional_application_settings = <<-EOS
# configure asset hosts for controllers + mailers
    # configure url helpers to use the options from env
    default_url_options = {
      host: ENV['DEFAULT_URL_HOST'],
      protocol: ENV['DEFAULT_URL_PROTOCOL']
    }
    #{app_name.camelize}::Application.routes.default_url_options = default_url_options
    config.action_mailer.default_url_options = default_url_options

    # use SSL, use Strict-Transport-Security, and use secure cookies
    config.force_ssl = (ENV['DEFAULT_URL_PROTOCOL'] == 'https')
EOS

step 'Configuring URL route helpers' do
  environment additional_application_settings
end

step 'Configuring default timezone' do
  environment "config.time_zone = 'Central Time (US & Canada)'"
end

step 'Adding lib/autoloaded to autoload_paths' do
  preserve_directory 'lib/autoloaded'
  environment "config.autoload_paths << config.root.join('lib', 'autoloaded')"
end

step 'Adding debug Bundler group' do
  install_gem 'pry-remote', group: :debug

  append_to_file '.env', get_file_partial(:debug, '.env')
  insert_lines_into_file 'config/application.rb', get_file_partial(:debug, 'application.rb'), after: 'Bundler.require'
end

step 'Disabling config.assets.debug in development environment' do
  comment_lines 'config/environments/development.rb', /config.assets.debug = true/
end

step 'Adding staging environment' do
  get_file 'config/environments/staging.rb'
end

step 'Setting up Vagrant Virtual Machine' do
  get_file 'Vagrantfile'
  append_to_file '.gitignore', get_file_partial(:vagrant, '.gitignore')

  get_file 'config/database.yml'
  get_file 'bin/vm_rails_setup'
  chmod 'bin/vm_rails_setup', 0755

end

rspec_config_generators =  <<-EOS
config.generators do |g|
      g.view_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end
EOS
step 'Adding Rspec' do
  remove_dir 'test/' unless ARGV.include?("-T")
  install_gem 'rspec-rails', group: [:development, :test]
  generate 'rspec:install'
  insert_lines_into_file 'Rakefile', "default_tasks << :spec", before: "task default: default_tasks"
  environment rspec_config_generators
  insert_lines_into_file 'spec/spec_helper.rb', get_file_partial(:rspec, 'spec_helper.rb'), indent: 2, after: "RSpec.configure do"
  comment_lines 'spec/spec_helper.rb', /config.fixture_path.*/

  install_gem 'shoulda-matchers', group: :test

  install_gem 'factory_girl_rails', group: [:development, :test]
  install_gem 'factory_girl_rspec', group: :test, version: '2.1.0'
end

step 'Adding code coverage check (Simplecov)' do
  install_gem 'simplecov', require: false, group: :test
  prepend_to_file 'spec/spec_helper.rb', get_file_partial(:simplecov, 'spec_helper.rb')
  append_to_file '.gitignore', get_file_partial(:simplecov, '.gitignore')
end

step 'Adding Rspec utility (Webrat)' do
  install_gem 'webrat', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'webrat'", after: "require 'rspec/autorun'"
  insert_lines_into_file 'spec/spec_helper.rb', 'config.include Webrat::Matchers', indent: 2, after: /config.use_transactional_fixtures /
end

step 'Adding Rspec utility (should_not)' do
  install_gem 'should_not', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'should_not/rspec'", after: "require 'rspec/autorun'"
end

step 'Adding Rspec utility (webmock)' do
  install_gem 'webmock', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'webmock/rspec'", after: "require 'rspec/autorun'"
end

step 'Adding Rspec utility (vcr)' do
  install_gem 'vcr', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'vcr'", after: "require 'rspec/autorun'"
  append_to_file 'spec/spec_helper.rb', get_file_partial(:vcr, 'spec_helper.rb')
end

step 'Adding Ruby styleguide enforcer (Rubocop)' do
  install_gem 'rubocop', group: [:development, :test]
  insert_lines_into_file 'Rakefile', get_file_partial(:rubocop, 'Rakefile'), before: "task default: default_tasks"
  get_file '.rubocop.yml'
end

step 'Adding Javascript testsuite (JasmineRails)' do
  install_gem 'jasmine-rails', group: [:development, :test]
  run_command 'rails generate jasmine_rails:install'
  insert_lines_into_file 'Rakefile', get_file_partial(:jasmine, 'Rakefile'), before: "task default: default_tasks"
end

step 'Adding Javascript styleguide enforder (JSHint)' do
  install_gem 'jshintrb', group: [:development, :test]
  get_file '.jshintrc'
  get_file '.jshintignore'
  insert_lines_into_file 'Rakefile', get_file_partial(:jshint, 'Rakefile'), before: "task default: default_tasks"
end

step 'Adding security auditing (Brakeman)' do
  install_gem 'brakeman'
  insert_lines_into_file 'Rakefile', "default_tasks << 'brakeman:run'", before: "task default: default_tasks"
  get_file 'lib/tasks/brakeman.rake'
end

step 'Adding Bundler gem vulnerability audit (BundlerAudit)' do
  install_gem 'bundler-audit', group: :test, require: false
  get_file 'lib/tasks/bundler_audit.rake'
  insert_lines_into_file 'Rakefile', "default_tasks << 'bundler:audit'", before: "task default: default_tasks"
end

step 'Adding report of outdated gems' do
  get_file 'lib/tasks/bundler_outdated.rake'
  insert_lines_into_file 'Rakefile', "default_tasks << 'bundler:outdated'", before: "task default: default_tasks"
end

step 'Adding application monitoring (NewRelic)' do
  install_gem 'newrelic_rpm'
  install_gem 'newrelic-rake'
  append_to_file '.env', get_file_partial(:newrelic, '.env')
  get_file 'config/newrelic.yml'
end

step 'Adding exception monitoring (Honeybadger)' do
  install_gem 'honeybadger'
  append_to_file '.env', get_file_partial(:honeybadger, '.env')
  get_file 'config/initializers/honeybadger.rb'
end

step 'Adding support for Heroku hosting' do
  install_gem 'rails_12factor', group: [:production, :staging]
end

step 'Adding continuous integration (Travis CI)' do
  install_gem 'travis', group: :development
  get_file '.travis.yml'
  append_to_file '.travis.yml', TRAVIS_CAMPFILE_CONFIG if TRAVIS_CAMPFILE_CONFIG
end

step 'Adding continuous testing framework (Guard)' do
  install_gem 'guard', group: :ct
  install_gem 'terminal-notifier', group: :ct
  install_gem 'terminal-notifier-guard', group: :ct

  run_command 'bundle binstubs guard'
end

step 'Adding continuous testing for ruby (Guard::Rspec)' do
  install_gem 'guard-rspec', group: :ct
  run_command 'guard init rspec'
  gsub_file 'Guardfile', /  # Capybara features specs.*\z/m, "end\n"
end

step 'Adding continuous testing for ruby styleguide (Guard::Rubocop)' do
  install_gem 'guard-rubocop', group: :ct
  append_to_file 'Guardfile', get_file_partial(:rubocop, 'Guardfile')
end

step 'Adding continuous testing for javascript styleguide (Guard::JSHintRb)' do
  install_gem 'guard-jshintrb', group: :ct
  run_command 'guard init jshintrb'
end

step 'Adding continuous testing for javascript testsuite (Guard::JasmineRails)' do
  install_gem 'guard-jasmine-rails', group: :ct
  run_command 'guard init jasmine-rails'
end

step 'Adding Puma as default appserver' do
  install_gem 'foreman', group: :development
  install_gem 'puma'
  get_file 'bin/restart'
  chmod 'bin/restart', 0755
  get_file 'Procfile'
  install_gem 'guard-sheller', group: :ct

  append_to_file '.env', get_file_partial(:puma, '.env')
  append_to_file 'Guardfile', get_file_partial(:puma, 'Guardfile')
end

step 'Adding project documentation' do
  get_file 'CONTRIBUTING.md'
  remove_file 'README.rdoc'
  get_file 'README.md'
end

step 'Adding /static controller endpoint' do
  generate 'controller Static --no_helper'
  preserve_directory 'app/views/static'
  route "get 'static/:action' => 'static#:action' if Rails.env.development?"
end

step 'Cleaning up rubocop validations' do
  gsub_file 'config/environments/test.rb', /config.static_cache_control = "public, max-age=3600"/, "config.static_cache_control = 'public, max-age=3600'"
  gsub_file 'config/routes.rb', /\n  \n/, ''
  gsub_file 'spec/spec_helper.rb', /"/, "'"
  gsub_file 'config/application.rb', /\n\n/, "\n"
end

step 'Addressing brakeman security vulnerability: Moving secret key to .env file' do
  gsub_file 'config/initializers/secret_token.rb', / =.*/, " = ENV['SECRET_KEY_BASE']"

  require 'securerandom'
  SECRET_KEY_BASE = SecureRandom.hex(64)
  append_to_file '.env', get_file_partial(:brakeman, '.env')
end

smtp_applicationrb = <<-EOS
config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT'],
      address: ENV['SMTP_SERVER']
    }
EOS
step 'Adding email support' do
  install_gem 'valid_email'
  install_gem 'email_spec', group: :test
  install_gem 'email_preview'
  append_to_file '.env', get_file_partial(:email, '.env')
  environment smtp_applicationrb
  insert_lines_into_file 'spec/spec_helper.rb', "require 'email_spec'", after: "require 'rspec/autorun'"
  insert_lines_into_file 'spec/spec_helper.rb', get_file_partial(:email, 'spec_helper.rb'), indent: 2, after: /config.use_transactional_fixtures /
end

step 'Reorganizing Gemfile dependencies' do
  install_gem 'bundler-reorganizer', group: :development
  run_command 'bundler-reorganizer Gemfile'
end

step 'Add Ansible Provisioning' do
  preserve_directory 'provisioning'
  directory('provisioning')
end

step 'Finalizing project setup' do
  run_command 'bundle install --local'
  git :init
  git add: '.'
  git commit: '-a -m "Initial checkin.  Built by thegarage-template Rails Generator"'
end
