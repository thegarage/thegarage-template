# >---------------------------------------------------------------------------<
#
#            _____       _ _
#           |  __ \     (_) |       /\
#           | |__) |__ _ _| |___   /  \   _ __  _ __  ___
#           |  _  // _` | | / __| / /\ \ | '_ \| '_ \/ __|
#           | | \ \ (_| | | \__ \/ ____ \| |_) | |_) \__ \
#           |_|  \_\__,_|_|_|___/_/    \_\ .__/| .__/|___/
#                                        | |   | |
#                                        |_|   |_|
#
#   Application template generated by the rails_apps_composer gem.
#   Restrain your impulse to make changes to this file; instead,
#   make changes to the recipes in the rails_apps_composer gem.
#
#   For more information, see:
#   https://github.com/RailsApps/rails_apps_composer/
#
#   Thank you to Michael Bleigh for leading the way with the RailsWizard gem.
#
# >---------------------------------------------------------------------------<

# >----------------------------[ Initial Setup ]------------------------------<

module Gemfile
  class GemInfo
    def initialize(name) @name=name; @group=[]; @opts={}; end
    attr_accessor :name, :version
    attr_reader :group, :opts

    def opts=(new_opts={})
      new_group = new_opts.delete(:group)
      if (new_group && self.group != new_group)
        @group = ([self.group].flatten + [new_group].flatten).compact.uniq.sort
      end
      @opts = (self.opts || {}).merge(new_opts)
    end

    def group_key() @group end

    def gem_args_string
      args = ["'#{@name}'"]
      args << "'#{@version}'" if @version
      @opts.each do |name,value|
        args << ":#{name}=>#{value.inspect}"
      end
      args.join(', ')
    end
  end

  @geminfo = {}

  class << self
    # add(name, version, opts={})
    def add(name, *args)
      name = name.to_s
      version = args.first && !args.first.is_a?(Hash) ? args.shift : nil
      opts = args.first && args.first.is_a?(Hash) ? args.shift : {}
      @geminfo[name] = (@geminfo[name] || GemInfo.new(name)).tap do |info|
        info.version = version if version
        info.opts = opts
      end
    end

    def write
      File.open('Gemfile', 'a') do |file|
        file.puts
        grouped_gem_names.sort.each do |group, gem_names|
          indent = ""
          unless group.empty?
            file.puts "group :#{group.join(', :')} do" unless group.empty?
            indent="  "
          end
          gem_names.sort.each do |gem_name|
            file.puts "#{indent}gem #{@geminfo[gem_name].gem_args_string}"
          end
          file.puts "end" unless group.empty?
          file.puts
        end
      end
    end

    private
    #returns {group=>[...gem names...]}, ie {[:development, :test]=>['rspec-rails', 'mocha'], :assets=>[], ...}
    def grouped_gem_names
      {}.tap do |_groups|
        @geminfo.each do |gem_name, geminfo|
          (_groups[geminfo.group_key] ||= []).push(gem_name)
        end
      end
    end
  end
end
def add_gem(*all) Gemfile.add(*all); end

@recipes = ["custom_helpers", "git_init", "base", "webapp", "testsuite", "rails_javascript", "continuous_integration", "continuous_testing", "email_init", "hosting", "integrations", "vagrant"]
@prefs = {:remote_host=>"https://raw.github.com/thegarage/thegarage-template", :remote_branch=>"travis-ssh-keys", :github_organization=>"thegarage", :github_deployer_account=>"thegarage-deployer", :heroku_app_prefix=>"tg"}
@gems = ["bundler"]
@diagnostics_recipes = [["example"], ["setup"], ["railsapps"], ["gems", "setup"], ["gems", "readme", "setup"], ["extras", "gems", "readme", "setup"], ["example", "git"], ["git", "setup"], ["git", "railsapps"], ["gems", "git", "setup"], ["gems", "git", "readme", "setup"], ["extras", "gems", "git", "readme", "setup"], ["email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["core", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["core", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["core", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["email", "example", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["email", "example", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["email", "example", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["apps4", "core", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["apps4", "core", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "tests"], ["apps4", "core", "deployment", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "testing"], ["apps4", "core", "deployment", "email", "extras", "frontend", "gems", "git", "init", "railsapps", "readme", "setup", "tests"], ["apps4", "core", "deployment", "devise", "email", "extras", "frontend", "gems", "git", "init", "omniauth", "pundit", "railsapps", "readme", "setup", "tests"]]
@diagnostics_prefs = []
diagnostics = {}

# >-------------------------- templates/helpers.erb --------------------------start<
def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end
def prefs; @prefs end
def prefer(key, value); @prefs[key].eql? value end
def gems; @gems end
def diagnostics_recipes; @diagnostics_recipes end
def diagnostics_prefs; @diagnostics_prefs end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_loud(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "  #{text}" + "\033[0m" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'composer', text) end

def ask_wizard(question)
  ask "\033[1m\033[36m" + ("option").rjust(10) + "\033[1m\033[36m" + "  #{question}\033[0m"
end

def whisper_ask_wizard(question)
  ask "\033[1m\033[36m" + ("choose").rjust(10) + "\033[0m" + "  #{question}"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('option', "\033[1m\033[36m" + "#{question}\033[0m")
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom( (i + 1).to_s + ')', choice[0] )
  end
  answer = whisper_ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def stage_two(&block); @after_blocks << [@current_recipe, block]; end
@stage_three_blocks = []
def stage_three(&block); @stage_three_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end

def copy_from(source, destination)
  begin
    remove_file destination
    get source, destination
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source}"
  end
end

def copy_from_repo(filename, opts = {})
  repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
  repo = opts[:repo] unless opts[:repo].nil?
  if (!opts[:prefs].nil?) && (!prefs.has_value? opts[:prefs])
    return
  end
  source_filename = filename
  destination_filename = filename
  unless opts[:prefs].nil?
    if filename.include? opts[:prefs]
      destination_filename = filename.gsub(/\-#{opts[:prefs]}/, '')
    end
  end
  if (prefer :templates, 'haml') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.haml')
  end
  if (prefer :templates, 'slim') && (filename.include? 'views')
    remove_file destination_filename
    destination_filename = destination_filename.gsub(/.erb/, '.slim')
  end
  begin
    remove_file destination_filename
    if (prefer :templates, 'haml') && (filename.include? 'views')
      create_file destination_filename, html_to_haml(repo + source_filename)
    elsif (prefer :templates, 'slim') && (filename.include? 'views')
      create_file destination_filename, html_to_slim(repo + source_filename)
    else
      get repo + source_filename, destination_filename
    end
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source_filename} from the repo #{repo}"
  end
end

def html_to_haml(source)
  begin
    html = open(source) {|input| input.binmode.read }
    Haml::HTML.new(html, :erb => true, :xhtml => true).render
  rescue RubyParser::SyntaxError
    say_wizard "Ignoring RubyParser::SyntaxError"
    # special case to accommodate https://github.com/RailsApps/rails-composer/issues/55
    html = open(source) {|input| input.binmode.read }
    say_wizard "applying patch" if html.include? 'card_month'
    say_wizard "applying patch" if html.include? 'card_year'
    html = html.gsub(/, {add_month_numbers: true}, {name: nil, id: "card_month"}/, '')
    html = html.gsub(/, {start_year: Date\.today\.year, end_year: Date\.today\.year\+10}, {name: nil, id: "card_year"}/, '')
    result = Haml::HTML.new(html, :erb => true, :xhtml => true).render
    result = result.gsub(/select_month nil/, "select_month nil, {add_month_numbers: true}, {name: nil, id: \"card_month\"}")
    result = result.gsub(/select_year nil/, "select_year nil, {start_year: Date.today.year, end_year: Date.today.year+10}, {name: nil, id: \"card_year\"}")
  end
end

def html_to_slim(source)
  html = open(source) {|input| input.binmode.read }
  haml = Haml::HTML.new(html, :erb => true, :xhtml => true).render
  Haml2Slim.convert!(haml)
end

# full credit to @mislav in this StackOverflow answer for the #which() method:
# - http://stackoverflow.com/a/5471032
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
    exe = "#{path}#{File::SEPARATOR}#{cmd}#{ext}"
      return exe if File.executable? exe
    end
  end
  return nil
end
# >-------------------------- templates/helpers.erb --------------------------end<

say_wizard("\033[1m\033[36m" + "" + "\033[0m")

say_wizard("\033[1m\033[36m" + ' _____       _ _' + "\033[0m")
say_wizard("\033[1m\033[36m" + "|  __ \\     \(_\) |       /\\" + "\033[0m")
say_wizard("\033[1m\033[36m" + "| |__) |__ _ _| |___   /  \\   _ __  _ __  ___" + "\033[0m")
say_wizard("\033[1m\033[36m" + "|  _  /\/ _` | | / __| / /\\ \\ | \'_ \| \'_ \\/ __|" + "\033[0m")
say_wizard("\033[1m\033[36m" + "| | \\ \\ (_| | | \\__ \\/ ____ \\| |_) | |_) \\__ \\" + "\033[0m")
say_wizard("\033[1m\033[36m" + "|_|  \\_\\__,_|_|_|___/_/    \\_\\ .__/| .__/|___/" + "\033[0m")
say_wizard("\033[1m\033[36m" + "                             \| \|   \| \|" + "\033[0m")
say_wizard("\033[1m\033[36m" + "                             \| \|   \| \|" + "\033[0m")
say_wizard("\033[1m\033[36m" + '' + "\033[0m")
say_wizard("\033[1m\033[36m" + "Rails Composer, open source, supported by subscribers." + "\033[0m")
say_wizard("\033[1m\033[36m" + "Please join RailsApps to support development of Rails Composer." + "\033[0m")
say_wizard("Need help? Ask on Stack Overflow with the tag \'railsapps.\'")
say_wizard("Your new application will contain diagnostics in its README file.")

if diagnostics_recipes.sort.include? recipes.sort
  diagnostics[:recipes] = 'success'
else
  diagnostics[:recipes] = 'fail'
end

# this application template only supports Rails version 4.1 and newer
case Rails::VERSION::MAJOR.to_s
when "3"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported. Use Rails 4.1 or newer."
    raise StandardError.new "Rails #{Rails::VERSION::STRING} is not supported. Use Rails 4.1 or newer."
when "4"
  case Rails::VERSION::MINOR.to_s
  when "0"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported. Use Rails 4.1 or newer."
    raise StandardError.new "Rails #{Rails::VERSION::STRING} is not supported. Use Rails 4.1 or newer."
  end
else
  say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported. Use Rails 4.1 or newer."
  raise StandardError.new "Rails #{Rails::VERSION::STRING} is not supported. Use Rails 4.1 or newer."
end

# >---------------------------[ Autoload Modules/Classes ]-----------------------------<

inject_into_file 'config/application.rb', :after => 'config.autoload_paths += %W(#{config.root}/extras)' do <<-'RUBY'

    config.autoload_paths += %W(#{config.root}/lib)
RUBY
end

# >---------------------------------[ Recipes ]----------------------------------<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >----------------------------[ custom_helpers ]-----------------------------<
@current_recipe = "custom_helpers"
@before_configs["custom_helpers"].call if @before_configs["custom_helpers"]
say_recipe 'custom_helpers'
@configs[@current_recipe] = config
# >------------------------ recipes/custom_helpers.rb ------------------------start<

require 'erb'

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

# add .gitkeep placeholder file so that the directory stays checked into git
def preserve_directory(directory)
  path = File.join(directory, '.gitkeep')
  create_file path, ''
end

# download remote file from remote repo and save to local path
# the downloaded resources *may* contain dynamic ERB statements
# that will be automatically evaluated once downloaded
def get_file(path)
  remove_file path
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', path)
  replace_file path, download_resource(resource)
end

# download partial file contents and process through ERB
# return the processed string
def get_file_partial(category, path)
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', 'partials', category.to_s, path)
  download_resource resource
end

# download remote file contents and process through ERB
# return the processed string
def download_resource(resource)
  say_status :download, resource

  open(resource) do |input|
    contents = input.binmode.read
    template = ERB.new(contents)
    template.result(binding)
  end
end

# helper to save changes in git
def commit_changes(description)
  git :add => '-A'
  git :commit => %Q(-qm "thegarage-template: #{description}")
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

def github_slug
  [prefs[:github_organization], app_name].join('/')
end

# heroku has 30 character limit for application names
def heroku_appname(env)
  max_env_length = 10
  max_app_name_length = 30 - 2 - max_env_length - prefs[:heroku_app_prefix].length
  truncated_app_name = app_name.slice(0, max_app_name_length)
  [prefs[:heroku_app_prefix], truncated_app_name, env].join('-')
end
# >------------------------ recipes/custom_helpers.rb ------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >-------------------------------[ git_init ]--------------------------------<
@current_recipe = "git_init"
@before_configs["git_init"].call if @before_configs["git_init"]
say_recipe 'git_init'
@configs[@current_recipe] = config
# >--------------------------- recipes/git_init.rb ---------------------------start<

get_file '.gitignore'

gem 'hub', group: :toolbox

git :init
commit_changes "Add basic git config"

stage_two do
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say_wizard "Repository already exists:"
    say_wizard "#{git_uri}"
  else
    say_wizard 'Creating private github repository'
    run_command "hub create #{github_slug} -p"
    run_command "hub push -u origin master"
  end
end
# >--------------------------- recipes/git_init.rb ---------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >---------------------------------[ base ]----------------------------------<
@current_recipe = "base"
@before_configs["base"].call if @before_configs["base"]
say_recipe 'base'
@configs[@current_recipe] = config
# >----------------------------- recipes/base.rb -----------------------------start<

remove_file 'README.rdoc'
get_file 'CONTRIBUTING.md'
get_file 'README.md'
create_file '.env', ''

say_wizard "Configuring app to use ruby #{RUBY_VERSION}"
create_file '.ruby-version', "#{RUBY_VERSION}\n"
insert_lines_into_file 'Gemfile', "ruby '#{RUBY_VERSION}'", after: /^source /

say_wizard 'Removing sdoc Bundler group'
gsub_file 'Gemfile', /group :doc do/, ''
gsub_file 'Gemfile', /\s*gem 'sdoc', require: false\nend/, ''

gem 'dotenv-rails'
gem 'rails-console-tweaks'
gem 'pry-rails'
gem 'pg'

gem_group :toolbox do
  gem 'thegarage-gitx'
  gem 'bundler-reorganizer'
  gem 'foreman'
end

commit_changes "Add basic ruby/rails config"

stage_two do
  say_wizard 'Removing sqlite3 gem'
  gsub_file 'Gemfile', /^.*sqlite3.*$/, ''

  say_wizard 'Adding lib/autoloaded to autoload_paths'
  preserve_directory 'lib/autoloaded'
  environment "config.autoload_paths << config.root.join('lib', 'autoloaded')"

  say_wizard 'setting default time zone to Central Time'
  environment "config.time_zone = 'Central Time (US & Canada)'"

  run_command 'bundle binstubs spring'

  commit_changes 'Add lib/autoloaded'
end

stage_three do
  run_command 'spring binstubs --all'

  say_wizard 'Reorganizing Gemfile groups'
  run_command 'bundle binstubs bundler-reorganizer'
  run_command 'bin/bundler-reorganizer Gemfile'

  say_wizard 'Cleaning up lint issues'
  run 'rubocop -a'

  commit_changes "cleanup project resources"
end
# >----------------------------- recipes/base.rb -----------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >--------------------------------[ webapp ]---------------------------------<
@current_recipe = "webapp"
@before_configs["webapp"].call if @before_configs["webapp"]
say_recipe 'webapp'
@configs[@current_recipe] = config
# >---------------------------- recipes/webapp.rb ----------------------------start<

gem 'puma'
gem 'haml'
gem 'html2haml', group: :toolbox
gem 'bootstrap-sass'
gem 'simple_form'
gem 'rails_layout'
gem 'high_voltage'

append_to_file '.env', get_file_partial(:webapp, '.env')

get_file 'Procfile'
get_file 'config/puma.rb'
get_file 'config/initializers/high_voltage.rb'
get_file 'app/views/pages/home.html.haml'

commit_changes "Add webapp config"

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

stage_two do
  run_command 'bundle binstubs puma'

  say_wizard 'Configuring URL route helpers'
  environment additional_application_settings

  say_wizard "installing simple_form for use with Bootstrap"
  generate 'simple_form:install --bootstrap'
  generate 'layout:install bootstrap3 -f'

  commit_changes 'Add frontend resources/config'
end
# >---------------------------- recipes/webapp.rb ----------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >-------------------------------[ testsuite ]-------------------------------<
@current_recipe = "testsuite"
@before_configs["testsuite"].call if @before_configs["testsuite"]
say_recipe 'testsuite'
@configs[@current_recipe] = config
# >-------------------------- recipes/testsuite.rb ---------------------------start<

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
gem 'spring-commands-rspec', group: :development
gem_group :test do
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
  gem 'factory_girl_rspec'
  gem 'factory_girl_rspec'
  gem 'vcr'
  gem 'timecop'
  gem 'email_spec'
  gem 'webmock'
end

rspec_config_generators = <<-EOS
config.generators do |g|
      g.view_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end
EOS

%w( capybara email_spec jasmine_rails render_views timecop vcr webmock ).each do |file|
  get_file "spec/support/#{file}.rb"
end

stage_two do
  remove_dir 'test/' unless ARGV.include?("-T")
  generate 'rspec:install'
  environment rspec_config_generators

  comment_lines 'spec/spec_helper.rb', /config.fixture_path.*/

  prepend_to_file 'spec/spec_helper.rb', get_file_partial(:simplecov, 'spec_helper.rb')
  append_to_file '.gitignore', get_file_partial(:simplecov, '.gitignore')

  commit_changes 'Add RSpec testsuite'
end
# >-------------------------- recipes/testsuite.rb ---------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >---------------------------[ rails_javascript ]----------------------------<
@current_recipe = "rails_javascript"
@before_configs["rails_javascript"].call if @before_configs["rails_javascript"]
say_recipe 'rails_javascript'
@configs[@current_recipe] = config
# >----------------------- recipes/rails_javascript.rb -----------------------start<

gem 'jasmine-rails', group: [:development, :test]

get_file '.jshintignore'
get_file '.jshintrc'

stage_two do
  generate 'jasmine_rails:install'

  say_wizard 'Remove turbolinks'
  gsub_file 'app/assets/javascripts/application.js', %r{^//= require turbolinks$.}m, ''
  gsub_file 'Gemfile', /^.*turbolinks.*$/, ''

  say_wizard 'Disabling config.assets.debug in development environment'
  comment_lines 'config/environments/development.rb', /config.assets.debug = true/

  commit_changes 'add Javascript settings'
end
# >----------------------- recipes/rails_javascript.rb -----------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >------------------------[ continuous_integration ]-------------------------<
@current_recipe = "continuous_integration"
@before_configs["continuous_integration"].call if @before_configs["continuous_integration"]
say_recipe 'continuous_integration'
@configs[@current_recipe] = config
# >-------------------- recipes/continuous_integration.rb --------------------start<

# install latest version of travis gem
run_command 'gem install travis'
latest_version = `travis -v`.chomp
gem 'travis', ">= #{latest_version}", group: :toolbox

gem_group :ci do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'jshintrb'
  gem 'rubocop'
end

get_file '.rubocop.yml'
get_file 'lib/tasks/ci.rake'
get_file 'lib/tasks/brakeman.rake'
get_file 'lib/tasks/bundler_audit.rake'
get_file 'lib/tasks/bundler_outdated.rake'
get_file 'lib/tasks/rubocop.rake'
get_file 'lib/tasks/jshint.rake'

get_file '.travis.yml'
append_to_file 'Rakefile', "\ntask default: :ci\n"

commit_changes 'Add continuous integration config'

stage_two do
  append_to_file '.gitignore', get_file_partial(:travis, '.gitignore')
  run_command 'bundle binstubs bundler-audit'
  run_command 'bundle binstubs brakeman'
  run_command 'bundle binstubs travis'
  commit_changes 'Add continuous integration dependencies'

  say_wizard 'Configuring Continuous Integration...'
  say_wizard "Login as the Github deployer account **not** your personal account!"
  run 'bin/travis logout --pro'
  run_command "bin/travis login --pro -u #{prefs[:github_deployer_account]}"
  run_command "bin/travis enable --pro -r #{github_slug}"
  run_command "bin/travis sshkey --pro -g -r #{github_slug}"
end

stage_three do
  run 'bin/travis logout --pro'
  rake 'ci'
end
# >-------------------- recipes/continuous_integration.rb --------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >--------------------------[ continuous_testing ]---------------------------<
@current_recipe = "continuous_testing"
@before_configs["continuous_testing"].call if @before_configs["continuous_testing"]
say_recipe 'continuous_testing'
@configs[@current_recipe] = config
# >---------------------- recipes/continuous_testing.rb ----------------------start<

gem_group :ct do
  gem 'guard'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'
end

stage_two do
  run_command 'bundle binstubs guard'
  run_command 'bin/guard init'
end

%w( rspec rubocop jshintrb jasmine-rails bundler livereload ).each do |plugin|
  gem "guard-#{plugin}", group: :ct

  stage_two do
    run_command "bin/guard init #{plugin}"
  end
end

stage_two do
  # cleanup unused watches
  gsub_file 'Guardfile', /  # Capybara features specs.*\z/m, "end\n"

  commit_changes 'Add Continuous Testing libraries'
end
# >---------------------- recipes/continuous_testing.rb ----------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >------------------------------[ email_init ]-------------------------------<
@current_recipe = "email_init"
@before_configs["email_init"].call if @before_configs["email_init"]
say_recipe 'email_init'
@configs[@current_recipe] = config
# >-------------------------- recipes/email_init.rb --------------------------start<

gem 'email_preview', group: :development
gem 'mailcatcher', group: :toolbox

get_file 'config/initializers/email_preview.rb'

append_to_file '.env', get_file_partial(:email, '.env')
append_to_file 'Procfile', get_file_partial(:email, 'Procfile')

smtp_applicationrb = <<-EOS
config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT'],
      address: ENV['SMTP_SERVER']
    }
EOS

commit_changes 'Add email config'

stage_two do
  environment smtp_applicationrb
  run_command 'bundle binstubs mailcatcher'

  commit_changes 'Add email config'
end
# >-------------------------- recipes/email_init.rb --------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >--------------------------------[ hosting ]--------------------------------<
@current_recipe = "hosting"
@before_configs["hosting"].call if @before_configs["hosting"]
say_recipe 'hosting'
@configs[@current_recipe] = config
# >--------------------------- recipes/hosting.rb ----------------------------start<

gem 'rails_12factor', group: [:production, :staging]

get_file 'config/environments/staging.rb'
replace_file 'config/secrets.yml', <<-EOS
<%= Rails.env %>:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

EOS
append_to_file '.env', <<-EOS
# secret key used by rails for generating session cookies
SECRET_KEY_BASE=#{SecureRandom.hex(64)}

EOS

heroku_travis_template = <<-EOS

deploy:
  provider: heroku
  strategy: git
  run: rake db:migrate
  app:
    master: #{heroku_appname('production')}
    staging: #{heroku_appname('staging')}
EOS

stage_two do
  append_to_file '.travis.yml', heroku_travis_template

  say_wizard 'Login with the Heroku deployer account **not** your personal account!'
  run_command 'heroku auth:logout'
  run_command 'heroku auth:login'
  run_command 'bin/travis encrypt $(heroku auth:token) --add deploy.api_key'

  commit_changes "Add continuous deployment configuration"
end

stage_three do
  run_command 'heroku auth:logout'
end

heroku_appname('production').tap do |app|
  stage_two do
    run_command "heroku apps:create #{app}"
    run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{app}"
    run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{app}"
  end
  stage_three do
    run_command "open http://#{app}.herokuapp.com"
  end
end

heroku_appname('staging').tap do |app|
  stage_two do
    run_command "heroku apps:create #{app}"
    run_command "heroku config:set RAILS_ENV=staging --app #{app}"
    run_command "heroku config:set RACK_ENV=staging --app #{app}"
    run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{app}"
    run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{app}"
  end
  stage_three do
    run_command "open http://#{app}.herokuapp.com"
  end
end

stage_three do
  run 'git remote rm heroku'
end
# >--------------------------- recipes/hosting.rb ----------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >-----------------------------[ integrations ]------------------------------<
@current_recipe = "integrations"
@before_configs["integrations"].call if @before_configs["integrations"]
say_recipe 'integrations'
@configs[@current_recipe] = config
# >------------------------- recipes/integrations.rb -------------------------start<

new_relic_license_key = ask_wizard('New Relic License Key (sandbox)')
new_relic_env_template = <<-EOS

# newrelic license key
# https://docs.newrelic.com/docs/ruby/ruby-agent-configuration
NEW_RELIC_LICENSE_KEY=#{new_relic_license_key}
EOS

if new_relic_license_key
  gem 'newrelic_rpm'
  gem 'newrelic-rake'
  get_file 'config/newrelic.yml'
  get_file 'config/initializers/gc.rb'
  append_to_file '.env', new_relic_env_template
end

honeybadger_api_key = ask_wizard('Honeybadger Project API Key')
honeybadger_env_template = <<-EOS

# honey badger account info
HONEY_BADGER_API_KEY=#{honeybadger_api_key}
EOS

if honeybadger_api_key
  gem 'honeybadger'
  get_file 'config/initializers/honeybadger.rb'
  append_to_file '.env', honeybadger_env_template
end


hipchat_api_key = ask_wizard('Hipchat Notification API Key')
hipchat_room = ask_wizard('Hipchat Room')
hipchat_travis_template = <<-EOS

# see http://docs.travis-ci.com/user/notifications/#HipChat-notification
notifications:
  hipchat: #{hipchat_api_key}@#{hipchat_room}
EOS

if hipchat_api_key
  append_to_file '.travis.yml', hipchat_travis_template
end

commit_changes 'Add 3rd party integrations'
# >------------------------- recipes/integrations.rb -------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<

# >-------------------------- templates/recipe.erb ---------------------------start<
# >--------------------------------[ vagrant ]--------------------------------<
@current_recipe = "vagrant"
@before_configs["vagrant"].call if @before_configs["vagrant"]
say_recipe 'vagrant'
@configs[@current_recipe] = config
# >--------------------------- recipes/vagrant.rb ----------------------------start<

gem 'guard-sheller', group: :ct

append_to_file '.gitignore', get_file_partial(:vagrant, '.gitignore')
append_to_file '.env', get_file_partial(:vagrant, '.env')
get_file 'Vagrantfile'
get_file 'config/database.yml'

get_file 'bin/restart'
chmod 'bin/restart', 0755

# ruby script to get list of all necessary provisioning files
# Dir.glob('files/provisioning/**/*').each { |f| puts f.gsub(/^files\//, '') unless File.directory?(f) }
recipes = %w(
  provisioning/rails_developer.yml
  provisioning/roles/core/tasks/main.yml
  provisioning/roles/gemrc/files/gemrc
  provisioning/roles/gemrc/tasks/main.yml
  provisioning/roles/nodejs/tasks/main.yml
  provisioning/roles/phantomjs/tasks/main.yml
  provisioning/roles/postgresql/files/pg_hba.conf
  provisioning/roles/postgresql/files/pgdg.list
  provisioning/roles/postgresql/handlers/main.yml
  provisioning/roles/postgresql/tasks/main.yml
  provisioning/roles/postgresql/vars/main.yml
  provisioning/roles/rails_setup/files/vm_rails_setup.sh
  provisioning/roles/rails_setup/tasks/main.yml
  provisioning/roles/ruby/tasks/main.yml
  provisioning/roles/ruby/templates/rbenv.sh.j2
  provisioning/roles/ruby/vars/main.yml
  provisioning/roles/set_locale/files/lang.sh
  provisioning/roles/set_locale/tasks/main.yml
)
recipes.each do |recipe|
  get_file recipe
end

commit_changes 'Setup Vagrant virtualized environment'

stage_two do
  append_to_file 'Guardfile', get_file_partial(:vagrant, 'Guardfile')

  run 'bundle package'

  commit_changes 'package gems'
  run 'vagrant up'
  rake 'db:create'
end

stage_three do
  run 'open http://localhost:3000'
end
# >--------------------------- recipes/vagrant.rb ----------------------------end<
# >-------------------------- templates/recipe.erb ---------------------------end<


# >-----------------------------[ Final Gemfile Write ]------------------------------<
Gemfile.write

# >---------------------------------[ Diagnostics ]----------------------------------<

# remove prefs which are diagnostically irrelevant
redacted_prefs = prefs.clone
redacted_prefs.delete(:ban_spiders)
redacted_prefs.delete(:better_errors)
redacted_prefs.delete(:pry)
redacted_prefs.delete(:dev_webserver)
redacted_prefs.delete(:git)
redacted_prefs.delete(:github)
redacted_prefs.delete(:jsruntime)
redacted_prefs.delete(:local_env_file)
redacted_prefs.delete(:main_branch)
redacted_prefs.delete(:prelaunch_branch)
redacted_prefs.delete(:prod_webserver)
redacted_prefs.delete(:quiet_assets)
redacted_prefs.delete(:rvmrc)
redacted_prefs.delete(:templates)

if diagnostics_prefs.include? redacted_prefs
  diagnostics[:prefs] = 'success'
else
  diagnostics[:prefs] = 'fail'
end

@current_recipe = nil

# >-----------------------------[ Run 'Bundle Install' ]-------------------------------<

say_wizard "Installing gems. This will take a while."
run 'bundle install --without production'
say_wizard "Updating gem paths."
Gem.clear_paths
# >-----------------------------[ Run 'stage_two' Callbacks ]-------------------------------<

say_wizard "Stage Two (running recipe 'stage_two' callbacks)."
if prefer :templates, 'haml'
  say_wizard "importing html2haml conversion tool"
  require 'html2haml'
end
if prefer :templates, 'slim'
say_wizard "importing html2haml and haml2slim conversion tools"
  require 'html2haml'
  require 'haml2slim'
end
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; puts @current_recipe; b[1].call}

# >-----------------------------[ Run 'stage_three' Callbacks ]-------------------------------<

@current_recipe = nil
say_wizard "Stage Three (running recipe 'stage_three' callbacks)."
@stage_three_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; puts @current_recipe; b[1].call}

@current_recipe = nil
say_wizard("Your new application will contain diagnostics in its README file.")
say_wizard("When reporting an issue on GitHub, include the README diagnostics.")
say_wizard "Finished running the rails_apps_composer app template."
say_wizard "Your new Rails app is ready. Time to run 'bundle install'."
