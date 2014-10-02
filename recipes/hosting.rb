gem 'rails_12factor', group: [:production, :staging]

get_file 'config/environments/staging.rb'
get_file 'config/secrets.yml', eval: false
append_to_file '.env', get_file_partial(:heroku, '.env')

stage_two do
  append_to_file '.travis.yml', get_file_partial(:heroku, '.travis.yml')

  say_wizard 'Login with the Heroku deployer account **not** your personal account!'
  run_command 'heroku auth:logout'
  run_command 'heroku auth:login'
  run_command 'bin/travis encrypt $(heroku auth:token) --add deploy.api_key'

  commit_changes "Add continuous deployment configuration"
end

stage_three do
  run_command 'heroku auth:logout'
end

heroku_appname('production').tap do |app|
  stage_two do
    run_command "heroku apps:create #{app}"
    run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{app}"
    run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{app}"
    run_command "heroku config:set MIXPANEL_TOKEN=#{ask_wizard('Mixpanel Production Token')} --app #{app}"
  end
  stage_three do
    run_command "open http://#{app}.herokuapp.com"
  end
end

heroku_appname('staging').tap do |app|
  stage_two do
    run_command "heroku apps:create #{app}"
    run_command "heroku config:set RAILS_ENV=staging --app #{app}"
    run_command "heroku config:set RACK_ENV=staging --app #{app}"
    run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{app}"
    run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{app}"
    run_command "heroku config:set MIXPANEL_TOKEN=#{ask_wizard('Mixpanel Staging Token')} --app #{app}"
  end
  stage_three do
    run_command "open http://#{app}.herokuapp.com"
  end
end

stage_three do
  run 'git remote rm heroku'
end

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
