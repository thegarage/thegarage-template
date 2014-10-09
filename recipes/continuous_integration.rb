# install latest version of travis gem
run_command 'gem install travis'
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
append_to_file 'Rakefile', get_file_partial(:continuous_integration, 'Rakefile')

commit_changes 'Add continuous integration config'

stage_two do
  append_to_file '.gitignore', get_file_partial(:travis, '.gitignore')
  run_command 'bundle binstubs bundler-audit'
  run_command 'bundle binstubs brakeman'
  run_command 'bundle binstubs travis'
  commit_changes 'Add continuous integration dependencies'

  say_wizard 'Configuring Continuous Integration...'
  say_wizard "Login as the Github deployer account **not** your personal account!"
  run 'bin/travis logout --pro'
  run_command "bin/travis login --pro -u #{prefs[:github_deployer_account]}"
  run_command "bin/travis enable --pro -r #{github_slug}"
  run_command "bin/travis sshkey --pro -g -r #{github_slug}"
end

stage_three do
  run 'bin/travis logout --pro'
  rake 'ci'
end

__END__

name: continuous_integration
description: 'Setup Continuous Integration for the Rails Project'
author: wireframe
category: other
