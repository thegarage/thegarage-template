gem 'puma'
gem 'haml'
gem 'html2haml', group: :toolbox
gem 'bootstrap-sass'
gem 'simple_form'
gem 'rails_layout'
gem 'high_voltage'
gem 'font-awesome-rails'
gem 'waitlist'

append_to_file '.env', get_file_partial(:webapp, '.env')

get_file 'Procfile'
get_file 'config/puma.rb'
get_file 'config/initializers/high_voltage.rb'

get_file 'app/assets/images/landing/blue-tile.jpg', eval: false
get_file 'app/assets/images/landing/meadow.jpg', eval: false
get_file 'app/assets/stylesheets/application.css.scss', eval: false
get_file 'app/assets/stylesheets/framework_and_overrides.css.scss', eval: false
get_file 'app/assets/stylesheets/landing.css.scss', eval: false
remove_file 'app/assets/stylesheets/application.css'

get_file 'app/views/layouts/_analytics.html.erb'
get_file 'app/views/layouts/_footer.html.haml', eval: false
get_file 'app/views/layouts/_messages.html.erb', eval: false
get_file 'app/views/layouts/_navigation.html.erb', eval: false
get_file 'app/views/layouts/_navigation_links.html.erb', eval: false
get_file 'app/views/layouts/application.html.erb', eval: false

get_file 'app/views/pages/home.html.haml', eval: false

mixpanel_token = ask_wizard('Mixpanel Token (Development)')
mixpanel_env_template = <<-EOS

# Mixpanel dev account
MIXPANEL_TOKEN=#{mixpanel_token}
EOS
unless mixpanel_token.empty?
  append_to_file '.env', mixpanel_env_template
  get_file 'app/assets/javascripts/mixpanel-page-viewed.js'
  append_to_file 'app/views/layouts/_analytics.html.erb', get_file_partial(:webapp, 'mixpanel.html', eval: false)

  stage_three do
    run_command "heroku config:set MIXPANEL_TOKEN=#{ask_wizard('Mixpanel Token (Staging)')} --app #{heroku_appname('staging')}"
    run_command "heroku config:set MIXPANEL_TOKEN=#{ask_wizard('Mixpanel Token (Production)')} --app #{heroku_appname('production')}"
  end
end

ga_property = ask_wizard('Google Analytics Property ID')
ga_env_template = <<-EOS

# Google Analytics Config
GA_PROPERTY_ID=#{ga_property}
EOS
unless ga_property.empty?
  append_to_file '.env', ga_env_template
  append_to_file 'app/views/layouts/_analytics.html.erb', get_file_partial(:webapp, 'ga.html', eval: false)
end

commit_changes "Add webapp config"

additional_application_settings = <<-EOS
# configure asset hosts for controllers + mailers
    # configure url helpers to use the options from env
    default_url_options = {
      host: ENV['DEFAULT_URL_HOST'],
      protocol: ENV['DEFAULT_URL_PROTOCOL']
    }
    Rails.application.routes.default_url_options = default_url_options
    config.action_mailer.default_url_options = default_url_options

    # use SSL, use Strict-Transport-Security, and use secure cookies
    config.force_ssl = (ENV['DEFAULT_URL_PROTOCOL'] == 'https')
EOS

stage_two do
  run_command 'bundle binstubs puma'

  say_wizard 'Configuring URL route helpers'
  environment additional_application_settings

  say_wizard "installing simple_form for use with Bootstrap"
  generate 'simple_form:install --bootstrap'

  say_wizard "Setting up waitlist gem"
  generate 'waitlist:install'

  insert_lines_into_file('app/views/layouts/application.html.erb', '<%= render "layouts/analytics" %>', before: '</body>')

  commit_changes 'Add frontend resources/config'
end

__END__

name: webapp
description: 'Setup Webapp Dependencies'
author: wireframe
category: other
