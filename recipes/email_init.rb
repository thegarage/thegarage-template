gem 'email_preview'
gem 'mailcatcher', group: 'toolbox'

append_to_file '.env', get_file_partial(:email, '.env')
append_to_file 'Procfile', get_file_partial(:email, 'Procfile')

smtp_applicationrb = <<-EOS
config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT'],
      address: ENV['SMTP_SERVER']
    }
EOS

stage_two do
  environment smtp_applicationrb
end

__END__

name: email_init
description: 'Local Email settings'
author: wireframe
category: other
