remove_file 'README.rdoc'
get_file 'CONTRIBUTING.md'
get_file 'README.md'
create_file '.env', ''

ruby_version = '2.2.2'
say_wizard "Configuring app to use ruby #{ruby_version}"
create_file '.ruby-version', "#{ruby_version}\n"
insert_lines_into_file 'Gemfile', "ruby '#{ruby_version}'", after: /^source /

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
  commit_changes 'Add lib/autoloaded'

  say_wizard 'setting default time zone to Central Time'
  environment "config.time_zone = 'Central Time (US & Canada)'"
  commit_changes 'default timezone'

  run_command 'bundle binstubs spring'
  run_command 'bundle binstubs bundler-updater'
  run_command 'bundle binstubs bundler-reorganizer'
  commit_changes 'add binstubs'
end

stage_three do
  say_wizard 'Reorganizing Gemfile groups'
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
