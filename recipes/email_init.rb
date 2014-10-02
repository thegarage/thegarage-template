gem 'email_preview', group: :development
gem 'mailcatcher', group: :toolbox

get_file 'config/initializers/email_preview.rb'
get_file 'config/initializers/add_appname_to_email_subject.rb'

append_to_file '.env', get_file_partial(:email, '.env')
append_to_file 'Procfile', get_file_partial(:email, 'Procfile')

commit_changes 'Add email config'

stage_two do
  run_command 'bundle binstubs mailcatcher'

  commit_changes 'Add email config'
end

__END__

name: email_init
description: 'Local Email settings'
author: wireframe
category: other
