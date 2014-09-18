new_relic_license_key = ask_wizard('New Relic License Key (sandbox)')
new_relic_env_template = <<-EOS

# newrelic license key
# https://docs.newrelic.com/docs/ruby/ruby-agent-configuration
NEW_RELIC_LICENSE_KEY=#{new_relic_license_key}
EOS

if new_relic_license_key
  gem 'newrelic_rpm'
  gem 'newrelic-rake'
  get_file 'config/newrelic.yml'
  get_file 'config/initializers/gc.rb'
  append_to_file '.env', new_relic_env_template
end

honeybadger_api_key = ask_wizard('Honeybadger Project API Key')
honeybadger_env_template = <<-EOS

# honey badger account info
HONEY_BADGER_API_KEY=#{honeybadger_api_key}
EOS

if honeybadger_api_key
  gem 'honeybadger'
  get_file 'config/initializers/honeybadger.rb'
  append_to_file '.env', honeybadger_env_template
end


hipchat_api_key = ask_wizard('Hipchat Notification API Key')
hipchat_room = ask_wizard('Hipchat Room')
hipchat_travis_template = <<-EOS

# see http://docs.travis-ci.com/user/notifications/#HipChat-notification
notifications:
  hipchat: #{hipchat_api_key}@#{hipchat_room}
EOS

if hipchat_api_key
  append_to_file '.travis.yml', hipchat_travis_template
end

commit_changes 'Add 3rd party integrations'

__END__

name: integrations
description: '3rd party integrations'
author: wireframe
category: other
