if has_pref?(:new_relic_license_key)
  gem 'newrelic_rpm'
  gem 'newrelic-rake'
  get_file 'config/newrelic.yml'
  get_file 'config/initializers/gc.rb'
  append_to_file '.env', get_file_partial(:newrelic, '.env')
end

if has_pref?(:honeybadger_api_key)
  gem 'honeybadger'
  get_file 'config/initializers/honeybadger.rb'
  append_to_file '.env', get_file_partial(:honeybadger, '.env')
end

if has_pref?(:hipchat_api_key) && has_pref?(:hipchat_room)
  append_to_file '.travis.yml', get_file_partial(:hipchat, '.travis.yml')
end

commit_changes 'Add 3rd party integrations'

__END__

name: integrations
description: '3rd party integrations'
author: wireframe
category: other
