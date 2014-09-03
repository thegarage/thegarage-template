gem 'rails_12factor', group: [:production, :staging]

get_file 'config/environments/staging.rb'

commit_changes 'Add heroku/hosting configuration'

__END__

name: hosting
description: 'Add deployment/hosting configuration'
author: wireframe
category: other
