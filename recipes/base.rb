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
  gem 'bundler-updater'
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
  run_command 'bundle binstubs bundler-updater'
  run_command 'bin/spring binstubs --all'

  say_wizard 'Reorganizing Gemfile groups'
  run_command 'bundle binstubs bundler-reorganizer'
  run_command 'bin/bundler-reorganizer Gemfile'

  say_wizard 'Cleaning up lint issues'
  run 'rubocop -a'

  commit_changes "cleanup project resources"
end

__END__

name: base
description: 'Base template settings'
author: wireframe
category: other
