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
    master: #{heroku_appname('production')}
    staging: #{heroku_appname('staging')}
EOS

stage_two do
  append_to_file '.travis.yml', heroku_travis_template

  say_wizard 'Login with the Heroku deployer account **not** your personal account!'
  run_command 'heroku auth:logout'
  run_command 'heroku auth:login'
  run_command 'bin/travis encrypt $(heroku auth:token) --add deploy.api_key'
  run_command 'heroku auth:logout'

  commit_changes "Add continuous deployment configuration"
end

heroku_appname('production').tap do |app|
  stage_two do
    run_command "heroku apps:create #{app}"
    run_command "heroku config:set SECRET_KEY_BASE=#{SecureRandom.hex(64)} --app #{app}"
    run_command "heroku config:set BUNDLE_WITHOUT=development:test:vm:ct:debug:toolbox:ci --app #{app}"
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
