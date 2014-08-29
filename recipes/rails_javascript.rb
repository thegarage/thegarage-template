gem 'jasmine-rails', group: [:development, :test]

stage_two do
  generate 'jasmine_rails:install'

  say 'Remove turbolinks'
  gsub_file 'app/assets/javascripts/application.js', %r{^//= require turbolinks$.}m, ''
  gsub_file 'Gemfile', /^.*turbolinks.*$/, ''
end

__END__

name: rails_javascript
description: 'Add Javascript environment to Rails app'
author: wireframe
requires: [setup]
category: other
