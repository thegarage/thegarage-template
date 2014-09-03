gem_group :ci do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'jshintrb'
  gem 'rubocop'
end

if prefer :ci, 'travis'
  gem 'travis', group: :toolbox

  if prefer :hosting, 'heroku'
    prefs[:heroku_production_appname] ||= "#{app_name}-production"
    prefs[:heroku_staging_appname] ||= "#{app_name}-staging"
  end

  if prefer :notifier, 'hipchat'
    prefs[:hipchat_api_key] ||= ask_wizard('Hipchat API key for Build Notifications')
    prefs[:hipchat_room] ||= ask_wizard('Hipchat Room Name for Build Notifications')
  end
end

stage_two do
  say 'Creating rake :ci task'
  get_file 'lib/tasks/ci.rake'
  get_file 'lib/tasks/brakeman.rake'
  get_file 'lib/tasks/bundler_audit.rake'
  get_file 'lib/tasks/bundler_outdated.rake'

  say 'Setting default rake task to :ci'
  append_to_file 'Rakefile', "\ntask default: :ci\n"

  if prefer :ci, 'travis'
    run_command 'travis enable'
    say 'Configuring Travis CI build...'
    get_file '.travis.yml'

    if prefer :hosting, 'heroku'
      run_command 'travis encrypt $(heroku auth:token) --add deploy.api_key'
    end
  end

  commit_changes 'Add continuous integration config'
end

stage_three do
  rake 'ci'
end

__END__

name: continuous_integration
description: 'Setup Continuous Integration for the Rails Project'
author: wireframe
requires: [custom_helpers]
category: other
