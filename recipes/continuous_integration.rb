gem_group :ci do
  gem "brakeman"
  gem "bundler-audit"
  gem "jshintrb"
  gem "rubocop"
end

stage_two do
  branch = 'composer' # FIXME: use master for official release
  repo = "https://raw.github.com/thegarage/thegarage-template/#{branch}/files/"
  copy_from_repo 'lib/tasks/ci.rake', repo: repo
  copy_from_repo 'lib/tasks/brakeman.rake', repo: repo
  copy_from_repo 'lib/tasks/bundler_audit.rake', repo: repo
  copy_from_repo 'lib/tasks/bundler_outdated.rake', repo: repo

  say 'Setting default rake task to :ci'
  append_to_file 'Rakefile', "\ntask default: :ci\n"
end

stage_three do
  rake 'ci'
end

__END__

name: continuous_integration
description: 'Setup Continuous Integration for the Rails Project'
author: wireframe
category: other
