gem 'jasmine-rails', group: [:development, :test]

get_file '.jshintignore'
get_file '.jshintrc'

stage_two do
  generate 'jasmine_rails:install'

  say 'Remove turbolinks'
  gsub_file 'app/assets/javascripts/application.js', %r{^//= require turbolinks$.}m, ''
  gsub_file 'Gemfile', /^.*turbolinks.*$/, ''

  say 'Disabling config.assets.debug in development environment'
  comment_lines 'config/environments/development.rb', /config.assets.debug = true/

  commit_changes 'add Javascript settings'
end

__END__

name: rails_javascript
description: 'Add Javascript environment to Rails app'
author: wireframe
category: other
