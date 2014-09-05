heroku_production_appname = "thegarage-#{app_name}-production"
heroku_staging_appname = "thegarage-#{app_name}-staging"

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

heroku_travis_template = <<-EOS

deploy:
  provider: heroku
  strategy: git
  run: rake db:migrate
  app:
    master: #{heroku_production_appname}
    staging: #{heroku_staging_appname}
EOS

stage_two do
  append_to_file '.travis.yml', heroku_travis_template
  run_command 'bin/travis encrypt $(heroku auth:token) --add deploy.api_key'

  commit_changes "Add continuous deployment configuration"

  run_command "heroku apps:create #{heroku_production_appname}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{heroku_production_appname}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{heroku_production_appname}"
  run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{heroku_production_appname}"
end

stage_two do
  run_command "heroku apps:create #{heroku_staging_appname}"
  run_command "heroku config:set RAILS_ENV=staging --app #{heroku_staging_appname}"
  run_command "heroku config:set RACK_ENV=staging --app #{heroku_staging_appname}"
  run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{heroku_staging_appname}"
  run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{heroku_staging_appname}"
end

stage_three do
  run_command "open http://#{heroku_production_appname}.herokuapp.com"
  run_command "open http://#{heroku_staging_appname}.herokuapp.com"
end

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
