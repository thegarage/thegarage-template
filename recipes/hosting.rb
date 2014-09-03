gem 'rails_12factor', group: [:production, :staging]

get_file 'config/environments/staging.rb'

commit_changes 'Add heroku/hosting configuration'

prefs[:heroku_production_appname] ||= "#{app_name}-production"
prefs[:heroku_staging_appname] ||= "#{app_name}-staging"

stage_two do
  run_command "heroku apps:create #{prefs[:heroku_production_appname]}"
  run_command "heroku apps:create #{prefs[:heroku_staging_appname]}"

  run_command "heroku config:set RAILS_ENV=staging --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set RACK_ENV=staging --app #{prefs[:heroku_staging_appname]}"
end

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
