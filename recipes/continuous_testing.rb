gem_group :ct do
  gem 'guard'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'
end

stage_two
  run_command 'bundle binstubs guard'
  run_command 'bin/guard init'
end

%w( rspec rubocop jshintrb jasmine-rails bundler livereload ).each do |plugin|
  gem "guard-#{plugin}", group: :ct

  stage_two do
    run_command "guard init #{plugin}"
  end
end

stage_two do
  # cleanup unused watches
  gsub_file 'Guardfile', /  # Capybara features specs.*\z/m, "end\n"

  commit_changes 'Add Continuous Testing libraries'
end

__END__

name: continuous_testing
description: 'Setup Continuous Testing for the Rails Project'
author: wireframe
requires: [custom_helpers]
category: other
