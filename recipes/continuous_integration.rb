# install latest version of travis gem
`gem install travis`
latest_version = `travis -v`.chomp
gem 'travis', ">= #{latest_version}", group: :toolbox

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
  append_to_file '.gitignore', get_file_partial(:travis, '.gitignore')
  run_command 'bundle binstubs bundler-audit'
  run_command 'bundle binstubs brakeman'
  run_command 'bundle binstubs travis'

  say 'Configuring Continuous Integration...'
  say "Login as the Github deployer account **not** your personal account!"
  run_command 'bin/travis logout'
  run_command "bin/travis login -u #{prefs[:github_deployer_account]} --pro"
  run_command "bin/travis enable -r #{github_slug}"
  run_command "bin/travis sshkey -g -r #{github_slug}"
  run_command 'bin/travis logout'

  commit_changes 'Add continuous integration dependencies'
end

stage_three do
  rake 'ci'
end

__END__

name: continuous_integration
description: 'Setup Continuous Integration for the Rails Project'
author: wireframe
category: other
