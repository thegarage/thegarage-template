create_file '.env', ''

say "Configuring app to use ruby #{RUBY_VERSION}"
create_file '.ruby-version', "#{RUBY_VERSION}\n"
insert_lines_into_file 'Gemfile', "ruby '#{RUBY_VERSION}'", after: /^source /

say 'Removing sdoc Bundler group'
gsub_file 'Gemfile', /group :doc do/, ''
gsub_file 'Gemfile', /\s*gem 'sdoc', require: false\nend/, ''

gem 'dotenv-rails'
gem 'rails-console-tweaks'
gem_group :toolbox do
  gem 'thegarage-gitx'
  gem 'bundler-reorganizer'
  gem 'foreman'
end

save_changes "Add basic ruby/rails config"

stage_three do
  say 'Reorganizing Gemfile groups'
  run_command 'bundler-reorganizer Gemfile'

  save_changes "bundler-reorganizer cleanup of Gemfile"
end

__END__

name: base
description: 'Base template settings'
author: wireframe
requires: [custom_helpers]
category: other
