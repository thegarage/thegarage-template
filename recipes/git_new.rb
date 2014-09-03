get_file '.gitignore'

gem 'hub', group: :toolbox

commit_changes "Add basic git config"

stage_two do
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say_wizard "Repository already exists:"
    say_wizard "#{git_uri}"
  else
    say 'TODO: Creating private github repository'
    # run "hub create thegarage/#{app_name} -p"
    # run "hub push -u origin master"
  end
end

__END__

name: git_new
description: 'Git initialization'
author: wireframe
requires: [custom_helpers]
category: other
