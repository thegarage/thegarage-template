remove_file 'README.rdoc'
get_file 'CONTRIBUTING.md'
get_file 'README.md'
create_file '.env', ''

say "Configuring app to use ruby #{RUBY_VERSION}"
create_file '.ruby-version', "#{RUBY_VERSION}\n"
insert_lines_into_file 'Gemfile', "ruby '#{RUBY_VERSION}'", after: /^source /

say 'Removing sdoc Bundler group'
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
  say 'Removing sqlite3 gem'
  gsub_file 'Gemfile', /^.*sqlite3.*$/, ''

  run_command 'bundle binstubs spring'

  say 'Adding lib/autoloaded to autoload_paths'
  preserve_directory 'lib/autoloaded'
  environment "config.autoload_paths << config.root.join('lib', 'autoloaded')"

  commit_changes 'Add lib/autoloaded'
end

stage_three do
  run_command 'spring binstubs --all'

  say 'Reorganizing Gemfile groups'
  run_command 'bundler-reorganizer Gemfile'

  say 'Cleaning up lint issues'
  run_command 'rubocop -a'

  commit_changes "cleanup project resources"
end

__END__

name: base
description: 'Base template settings'
author: wireframe
category: other
