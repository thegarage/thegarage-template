gem 'jasmine-rails', group: [:development, :test]

get_file '.jshintignore'
get_file '.jshintrc'
get_file 'spec/javascripts/helpers/spec_helper.js'
get_file 'spec/javascripts/helpers/jasmine_rails_fixture_path.js'
get_file 'spec/javascripts/helpers/stubs/mixpanel.js'
get_file 'spec/javascripts/helpers/stubs/ga.js'

stage_two do
  generate 'jasmine_rails:install'

  say_wizard 'Remove turbolinks'
  gsub_file 'app/assets/javascripts/application.js', %r{^//= require turbolinks$.}m, ''
  gsub_file 'Gemfile', /^.*turbolinks.*$/, ''

  say_wizard 'Disabling config.assets.debug in development environment'
  comment_lines 'config/environments/development.rb', /config.assets.debug = true/

  commit_changes 'add Javascript settings'
end

__END__

name: rails_javascript
description: 'Add Javascript environment to Rails app'
author: wireframe
category: other
