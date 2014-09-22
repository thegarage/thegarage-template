gem 'jasmine-rails', group: [:development, :test]

get_file '.jshintignore'
get_file '.jshintrc'
get_file 'spec/javascript/helpers/spec_helper.js'
get_file 'spec/javascript/helpers/jasmine_rails_fixture_path.js'
get_file 'spec/javascript/helpers/stubs/mixpanel.js'
get_file 'spec/javascript/helpers/stubs/ga.js'

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
