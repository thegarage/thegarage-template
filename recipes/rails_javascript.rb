gem 'jasmine-rails', group: [:development, :test]

stage_two do
  generate 'jasmine_rails:install'
end

__END__

name: rails_javascript
description: 'Add Javascript environment to Rails app'
author: wireframe
requires: [setup]
category: other
