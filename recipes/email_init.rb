gem 'email_preview', group: :development
gem 'mailcatcher', group: :toolbox

get_file 'config/initializers/email_preview.rb'

append_to_file '.env', get_file_partial(:email, '.env')
append_to_file 'Procfile', get_file_partial(:email, 'Procfile')

smtp_applicationrb = <<-EOS
config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT'],
      address: ENV['SMTP_SERVER']
    }
EOS

commit_changes 'Add email config'

stage_two do
  environment smtp_applicationrb
  run_command 'bundle binstubs mailcatcher'

  commit_changes 'Add email config'
end

__END__

name: email_init
description: 'Local Email settings'
author: wireframe
category: other
