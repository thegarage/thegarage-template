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

commit_changes "Add webapp config"

additional_application_settings = <<-EOS
# configure asset hosts for controllers + mailers
    # configure url helpers to use the options from env
    default_url_options = {
      host: ENV['DEFAULT_URL_HOST'],
      protocol: ENV['DEFAULT_URL_PROTOCOL']
    }
    #{app_name.camelize}::Application.routes.default_url_options = default_url_options
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
  generate 'layout:install bootstrap3 -f'

  commit_changes 'Add frontend resources/config'
end

__END__

name: webapp
description: 'Setup Webapp Dependencies'
author: wireframe
category: other
