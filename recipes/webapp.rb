gem 'puma'
gem 'haml'
gem 'html2haml', group: :toolbox
gem 'bootstrap-sass'
gem 'simple_form'
gem 'rails_layout'
gem 'high_voltage'

append_to_file '.env', get_file_partial(:webapp, '.env')

get_file 'Procfile'
get_file 'config/puma.rb'
get_file 'config/initializers/high_voltage.rb'
get_file 'app/views/pages/home.html.haml'
get_file 'app/views/pages/terms.html.haml'
get_file 'app/views/pages/privacy.html.haml'
get_file 'app/views/layouts/_footer.html.haml'
get_file 'app/views/layouts/_analytics.html.erb'

mixpanel_token = ask_wizard('Mixpanel Development Token')
mixpanel_env_template = <<-EOS

# Mixpanel dev account
MIXPANEL_TOKEN=#{mixpanel_token}
EOS
unless mixpanel_token.empty?
  append_to_file '.env', mixpanel_env_template
  get_file 'app/assets/javascripts/mixpanel-page-viewed.js'
  append_to_file 'app/views/layouts/_analytics.html.erb', get_file_partial(:webapp, 'mixpanel.html', eval: false)
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

url_env_settings = <<-EOS
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


email_env_settings = %q(
# Configure default email settings
    config.action_mailer.default_options = {
      from: %Q("#{ENV['COMPANY_NAME']}" <contact@#{ENV['COMPANY_DOMAIN']}>)
    }
)

company_name = ask_wizard('What is the Company Name?')
company_domain = ask_wizard('What is production domain?')

company_info_env_template = <<-EOS

# Company settings
COMPANY_NAME=#{company_name}
COMPANY_DOMAIN=#{company_domain}

EOS
append_to_file '.env', company_info_env_template

stage_two do
  run_command 'bundle binstubs puma'

  say_wizard 'Configuring application settings'
  environment url_env_settings
  environment email_env_settings

  say_wizard "installing simple_form for use with Bootstrap"
  generate 'simple_form:install --bootstrap'
  generate 'layout:install bootstrap3 -f'

  insert_lines_into_file('app/views/layouts/application.html.erb', '<%= render "layouts/footer" %>', before: '</body>')
  insert_lines_into_file('app/views/layouts/application.html.erb', '<%= render "layouts/analytics" %>', before: '</body>')

  commit_changes 'Add frontend resources/config'
end

__END__

name: webapp
description: 'Setup Webapp Dependencies'
author: wireframe
category: other
