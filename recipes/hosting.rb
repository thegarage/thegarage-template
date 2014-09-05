prefs[:heroku_production_appname] ||= "#{app_name}-production"
prefs[:heroku_staging_appname] ||= "#{app_name}-staging"

gem 'rails_12factor', group: [:production, :staging]

get_file 'config/environments/staging.rb'
replace_file 'config/secrets.yml', <<-EOS
<%= Rails.env %>:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

EOS
append_to_file '.env', <<-EOS
# secret key used by rails for generating session cookies
SECRET_KEY_BASE=#{SecureRandom.hex(64)}

EOS

commit_changes 'Add heroku/hosting configuration'

stage_two do
  run_command "heroku apps:create #{prefs[:heroku_production_appname]}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{prefs[:heroku_production_appname]}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{prefs[:heroku_production_appname]}"
  run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{prefs[:heroku_production_appname]}"
end

stage_two do
  run_command "heroku apps:create #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set RAILS_ENV=staging --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set RACK_ENV=staging --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{prefs[:heroku_staging_appname]}"
  run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{prefs[:heroku_staging_appname]}"
end

stage_three do
  run_command "open http://#{prefs[:heroku_production_appname]}.herokuapp.com"
  run_command "open http://#{prefs[:heroku_staging_appname]}.herokuapp.com"
end

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
