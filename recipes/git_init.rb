get_file '.gitignore'

gem 'hub', group: :toolbox

git :init
commit_changes "Add basic git config"

stage_two do
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say_wizard "Repository already exists:"
    say_wizard "#{git_uri}"
  else
    say_wizard 'Creating private github repository'
    run_command "hub create #{github_slug} -p"
    run_command "hub push -u origin master"
  end
end

__END__

name: git_init
description: 'Git initialization'
author: wireframe
category: other
