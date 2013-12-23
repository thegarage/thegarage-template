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
  puts "Downloading resource: #{resource}"
  get(resource, path) do |contents|
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
    indented_content += (indent + line)
  end
  indented_content += "\n"

  insert_into_file path, indented_content, options
end

# Asking for sensitive information to be used later.
newrelic_key = ask("What is your NewRelic license key(enter nothing if you don't have one)?")

honeybadger_api_key = ask("What is your Honeybadger API key(enter nothing if you don't have one)?")

travis_campfire_config = if yes?("Do you want TravisCI Campfire Notifications?")
  travis_campfire_subdomain = ask("What's your Campfire subdomain?")
  travis_campfire_api_key = ask("What is your API key?")
  travis_campfire_room_id = ask("What is your Campfire room ID(not the name)?")
  <<-EOS.strip_heredoc
    notifications:
      campfire: #{travis_campfire_subdomain}:#{travis_campfire_api_key}@#{travis_campfire_room_id}
      on_success: change
      on_failure: always
  EOS
else
  nil
end

step 'Setting up initial project Gemfile' do
  replace_file 'Gemfile', ''
  add_source "https://rubygems.org"
  insert_lines_into_file 'Gemfile', "ruby '2.0.0'", after: /^source /

  gem 'rails', '~> 4.0.1'
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

bundler_groups_applicationrb = <<-EOS
# Delay requiring debug group until dotenv-rails has been required
# which loads the necessary ENV variables
Bundler.require(:debug) if %w{ development test }.include?(Rails.env) && ENV['BUNDLER_INCLUDE_DEBUG_GROUP'] == 'true'
EOS

env_bundler_include_debug_group = <<-EOS
# enable debug gems in development/test mode
BUNDLER_INCLUDE_DEBUG_GROUP=true

EOS
step 'Adding debug Bundler group' do
  install_gem 'pry-remote', group: :debug

  append_to_file '.env', env_bundler_include_debug_group
  insert_lines_into_file 'config/application.rb', bundler_groups_applicationrb, after: 'Bundler.require'
end

step 'Disabling config.assets.debug in development environment' do
  comment_lines 'config/environments/development.rb', /config.assets.debug = true/
end

step 'Adding staging environment' do
  get_file 'config/environments/staging.rb'
end

vagrant_gitignore = <<-EOS
# vagrant files
boxes/*
.vagrant
EOS

step 'Setting up Vagrant Virtual Machine' do
  get_file 'Vagrantfile'
  append_to_file '.gitignore', vagrant_gitignore

  get_file 'Berksfile'
  get_file 'config/database.yml'
  get_file 'chef/node.json'
  get_file 'bin/vm_rails_setup'
  chmod 'bin/vm_rails_setup', 0755

  preserve_directory 'chef/roles'
  preserve_directory 'chef/data_bags'
end

rspec_config_generators =  <<-EOS
config.generators do |g|
      g.view_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end
EOS
rspec_base_config = <<-EOS
# add support for focused specs with focus: true option
config.treat_symbols_as_metadata_keys_with_true_values = true
config.filter_run focus: true
config.run_all_when_everything_filtered = true
EOS
rspec_extra_config = <<-EOS
# enable controller tests to render views
config.render_views

# disable foo.should == bar syntax
config.expect_with :rspec do |c|
  c.syntax = :expect
end
EOS

step 'Adding Rspec' do
  remove_dir 'test/' unless ARGV.include?("-T")
  install_gem 'rspec-rails', group: [:development, :test]
  generate 'rspec:install'
  insert_lines_into_file 'Rakefile', "default_tasks << :spec", before: "task default: default_tasks"
  environment rspec_config_generators
  insert_lines_into_file 'spec/spec_helper.rb', rspec_base_config, indent: 2, after: "RSpec.configure do"
  insert_lines_into_file 'spec/spec_helper.rb', rspec_extra_config, indent: 2, after: "RSpec.configure do"
  comment_lines 'spec/spec_helper.rb', /config.fixture_path.*/

  install_gem 'shoulda-matchers', group: :test

  install_gem 'factory_girl_rails', group: [:development, :test]
  install_gem 'factory_girl_rspec', group: :test
end

simplecov = <<-EOS
require 'simplecov'
SimpleCov.minimum_coverage 95
SimpleCov.start 'rails'
EOS
simplecov_gitignore = <<-EOS
# Simplecov files
coverage
EOS
step 'Adding code coverage check (Simplecov)' do
  install_gem 'simplecov', require: false, group: :test
  prepend_to_file 'spec/spec_helper.rb', simplecov
  append_to_file '.gitignore', simplecov_gitignore
end

webrat_matcher_setup = <<-EOS
config.include Webrat::Matchers
EOS
step 'Adding Webrat gem' do
  install_gem 'webrat', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'webrat'", after: "require 'rspec/autorun'"
  insert_lines_into_file 'spec/spec_helper.rb', webrat_matcher_setup, indent: 2, after: /config.use_transactional_fixtures /
end

step 'Adding should_not gem' do
  install_gem 'should_not', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'should_not/rspec'", after: "require 'rspec/autorun'"
end

step 'Adding webmock gem' do
  install_gem 'webmock', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'webmock/rspec'", after: "require 'rspec/autorun'"
end

vcr_setup = <<-EOS

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
EOS
step 'Adding vcr gem' do
  install_gem 'vcr', group: :test
  insert_lines_into_file 'spec/spec_helper.rb', "require 'vcr'", after: "require 'rspec/autorun'"
  append_to_file 'spec/spec_helper.rb', vcr_setup
end

rubocop_rake = <<-EOS
if defined?(Rubocop)
  require 'rubocop/rake_task'
  Rubocop::RakeTask.new do |task|
    task.patterns = ['--rails']
  end
  default_tasks << :rubocop
end
EOS
step 'Adding Ruby styleguide enforcer (Rubocop)' do
  install_gem 'rubocop', group: [:development, :test]
  insert_lines_into_file 'Rakefile', rubocop_rake, before: "task default: default_tasks"
  get_file '.rubocop.yml'
end

jasmine_rake = <<-EOS
if defined?(JasmineRails)
  default_tasks << 'spec:javascript'
end
EOS
jasmine_gitignore = <<-EOS
# jasmine-rails files
spec/tmp
spec/javascripts/fixtures/generated/
EOS
step 'Adding Javascript testsutie (JasmineRails)' do
  install_gem 'jasmine-rails', group: [:development, :test]
  route "mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)"
  insert_lines_into_file 'Rakefile', jasmine_rake, before: "task default: default_tasks"
  append_to_file '.gitignore', jasmine_gitignore
  get_file 'spec/javascripts/support/jasmine.yml'
end

jshintrb_rake = <<-EOS
if defined?(Jshintrb)
  require "jshintrb/jshinttask"
  Jshintrb::JshintTask.new :jshint do |t|
    options = JSON.load(File.read('.jshintrc'))
    globals = options.delete('globals')
    ignored = File.read('.jshintignore').split.collect {|pattern| FileList[pattern].to_a }.flatten
    files = Dir.glob('**/*.js')
    t.js_files = files
    t.exclude_js_files = ignored
    t.options = options
    t.globals = globals.keys
  end
  default_tasks << :jshint
end
EOS
step 'Adding Javascript styleguide enforder (JSHint)' do
  install_gem 'jshintrb', group: [:development, :test]
  get_file '.jshintrc'
  get_file '.jshintignore'
  insert_lines_into_file 'Rakefile', jshintrb_rake, before: "task default: default_tasks"
end

brakeman_task = <<-EOS
namespace :brakeman do

  desc "Run Brakeman"
  task :run, :output_files do |t, args|
    files = args[:output_files].split(' ') if args[:output_files]
    puts "Checking for security vulnerabilities..."
    tracker = Brakeman.run :app_path => ".", :output_files => files, :print_report => true
    if tracker.filtered_warnings.any?
      puts "Security vulnerabilities found!"
      exit 1
    end
  end
end

EOS
step 'Adding security auditing (Brakeman)' do
  install_gem 'brakeman'
  insert_lines_into_file 'Rakefile', "default_tasks << 'brakeman:run'", before: "task default: default_tasks"
  lib 'tasks/brakeman.rake', brakeman_task
end

bundler_audit_rake = <<-EOS
namespace :bundler do
  desc 'audit Bundler Gemfile for vulnerable gems'
  task :audit do
    puts 'Checking Gemfile for vulnerable gems...'
    require 'English'
    output = `bundle-audit`
    puts output
    success = !!$CHILD_STATUS.to_i
    fail "bunder:audit failed" unless success
  end
end

EOS
step 'Adding Bundler gem vulnerability audit (BundlerAudit)' do
  install_gem 'bundler-audit', group: :test, require: false
  lib 'tasks/bundler_audit.rake', bundler_audit_rake
  insert_lines_into_file 'Rakefile', "default_tasks << 'bundler:audit'", before: "task default: default_tasks"
end

bundler_outdated_rake = <<-EOS
namespace :bundler do
  desc 'Generate report of outdated gems'
  task :outdated do
    puts "Generating report of outdated gems..."
    output = `bundle outdated`
    puts output
  end
end

EOS
step 'Adding report of outdated gems' do
  lib 'tasks/bundler_outdated.rake', bundler_outdated_rake
  insert_lines_into_file 'Rakefile', "default_tasks << 'bundler:outdated'", before: "task default: default_tasks"
end

newrelic_env = <<-EOS
# newrelic license key
# https://docs.newrelic.com/docs/ruby/ruby-agent-configuration
NEW_RELIC_LICENSE_KEY=#{newrelic_key}

EOS
step 'Adding applicaiton monitoring (NewRelic)' do
  install_gem 'newrelic_rpm'
  install_gem 'newrelic-rake'
  append_to_file '.env', newrelic_env
  get_file 'config/newrelic.yml'
end

honeybadger_env = <<-EOS
# honey badger account info
HONEY_BADGER_API_KEY=#{honeybadger_api_key}
EOS
honeybadgerrb = <<-EOS
  custom_env_filters = %w{
    HONEY_BADGER_API_KEY
    PGBACKUPS_URL
    HEROKU_POSTGRESQL_COBALT_URL
    DATABASE_URL
}

Honeybadger.configure do |config|
  config.api_key = ENV['HONEY_BADGER_API_KEY']
  config.params_filters.concat custom_env_filters
end
EOS
step 'Adding exception monitoring (Honeybadger)' do
  install_gem 'honeybadger'
  append_to_file '.env', honeybadger_env
  initializer 'honeybadger.rb', honeybadgerrb
end

step 'Adding support for Heroku hosting' do
  install_gem 'rails_12factor', group: :production
end

step 'Adding continuous integration (Travis CI)' do
  install_gem 'travis', group: :development
  get_file '.travis.yml'
  append_to_file '.travis.yml', travis_campfire_config if travis_campfire_config
end

step 'Adding continuous testing for ruby (Guard::Rspec)' do
  install_gem 'guard-rspec', group: :ct
  run_command 'guard init rspec'
  gsub_file 'Guardfile', /  # Capybara features specs.*\z/m, "end\n"
  run_command 'bundle binstubs guard'
end

rubocop_guardfile = <<'EOS'

guard :rubocop, all_on_start: false, cli: ['--rails'] do
  ignore(%r{db/schema\.rb})
  ignore(%r{vendor/.+\.rb})
  ignore(%r{chef/.+\.rb})
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
EOS
step 'Adding continuous testing for ruby styleguide (Guard::Rubocop)' do
  install_gem 'guard-rubocop', group: :ct
  append_to_file 'Guardfile', rubocop_guardfile
end

step 'Adding continuous testing for javascript styleguide (Guard::JSHintRb)' do
  install_gem 'guard-jshintrb', group: :ct
  run_command 'guard init jshintrb'
end

jasmine_rails_guardfile = <<'EOS'

guard 'jasmine-rails', all_on_start: false do
  watch(%r{spec/javascripts/helpers/.+\.(js|coffee)})
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
end
EOS
step 'Adding continuous testing for javascript testsuite (Guard::JasmineRails)' do
  install_gem 'guard-jasmine-rails', group: :ct
  append_to_file 'Guardfile', jasmine_rails_guardfile
end

server_restart_guardfile = <<'EOS'
guard :sheller, command: './bin/restart' do
  watch('.env')
  watch('.ruby-version')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end
EOS
env_appserver_port = <<-EOS
# options for appserver
PORT=3000

EOS
step 'Adding Puma as default appserver' do
  install_gem 'foreman', group: :development
  install_gem 'puma'
  get_file 'bin/restart'
  chmod 'bin/restart', 0755
  get_file 'Procfile'
  install_gem 'guard-sheller', group: :ct

  append_to_file '.env', env_appserver_port
  append_to_file 'Guardfile', server_restart_guardfile
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
end

require 'securerandom'
secret_key_base = SecureRandom.hex(64)

env_secret_token = <<-EOS

# secret key used by rails for generating session cookies
# see config/initializers/secret_token.rb
SECRET_KEY_BASE=#{secret_key_base}
EOS

step 'Addressing brakeman security vulnerability: Moving secret key to .env file' do
  gsub_file 'config/initializers/secret_token.rb', / =.*/, " = ENV['SECRET_KEY_BASE']"
  append_to_file '.env', env_secret_token
end

smtp_env = <<-EOS
#SMTP settings
SMTP_PORT=1025
SMTP_SERVER=localhost
EOS
smtp_applicationrb = <<-EOS
config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT'],
      address: ENV['SMTP_SERVER']
    }
EOS
email_spec_matcher_setup = <<-EOS
config.include EmailSpec::Helpers
config.include EmailSpec::Matchers
EOS
step 'Adding email support' do
  install_gem 'valid_email'
  install_gem 'email_spec', group: :test
  install_gem 'email_preview'
  append_to_file '.env', smtp_env
  environment smtp_applicationrb
  insert_lines_into_file 'spec/spec_helper.rb', "require 'email_spec'", after: "require 'rspec/autorun'"
  insert_lines_into_file 'spec/spec_helper.rb', email_spec_matcher_setup, after: /config.use_transactional_fixtures /
end

step 'Finalizing project setup' do
  run_command 'bundle install --local'
  git :init
  git add: '.'
  git commit: '-a -m "Initial checkin.  Built by thegarage-template Rails Generator"'
end
