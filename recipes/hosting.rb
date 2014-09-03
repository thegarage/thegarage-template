gem 'rails_12factor', group: [:production, :staging]

get_file 'config/secrets.yml'
get_file 'config/environments/staging.rb'

prefs[:heroku_production_appname] ||= "#{app_name}-production"
prefs[:heroku_staging_appname] ||= "#{app_name}-staging"

env_secret_key = <<-EOS

# secret key used by rails for generating session cookies
SECRET_KEY_BASE=#{SecureRandom.hex(64)}

EOS
append_to_file '.env', env_secret_key
commit_changes 'Add heroku/hosting configuration'

stage_two do
  run_command "heroku apps:create #{prefs[:heroku_production_appname]}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{prefs[:heroku_production_appname]}"
end

stage_two do
  run_command "heroku apps:create #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set RAILS_ENV=staging --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set RACK_ENV=staging --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{prefs[:heroku_staging_appname]}"
end

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
