stage_three do
  run_command 'bundle exec spring binstub --all'
  commit_changes 'create binstubs'

  run_command 'git push origin HEAD'
end

__END__

name: cleanup
description: 'last recipe to run'
author: wireframe
category: other
