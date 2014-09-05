gem 'travis', '>= 1.7.1', group: :toolbox
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
  run_command 'bundle binstubs bundler-audit'
  run_command 'bundle binstubs brakeman'
  run_command 'bundle binstubs travis'

  run_command "bin/travis enable -r thegarage/#{app_name}"
  append_to_file '.gitignore', get_file_partial(:travis, '.gitignore')

  commit_changes 'Add binstubs'
end

stage_three do
  rake 'ci'
end

__END__

name: continuous_integration
description: 'Setup Continuous Integration for the Rails Project'
author: wireframe
category: other
