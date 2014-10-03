gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
gem 'spring-commands-rspec', group: :development
gem_group :test do
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
  gem 'factory_girl_rspec'
  gem 'factory_girl_rspec'
  gem 'vcr'
  gem 'timecop'
  gem 'email_spec'
  gem 'webmock'
  gem 'capybara'
end

%w( capybara email_spec jasmine_rails render_views timecop vcr webmock ).each do |file|
  get_file "spec/support/#{file}.rb"
end

stage_two do
  remove_dir 'test/' unless ARGV.include?("-T")
  generate 'rspec:install'
  environment get_file_partial(:rspec, 'application.rb')

  uncomment_lines 'spec/rails_helper.rb', /spec\/support.*require/
  comment_lines 'spec/spec_helper.rb', /config.fixture_path.*/

  prepend_to_file 'spec/spec_helper.rb', get_file_partial(:simplecov, 'spec_helper.rb')
  append_to_file '.gitignore', get_file_partial(:simplecov, '.gitignore')

  commit_changes 'Add RSpec testsuite'
end

__END__

name: testsuite
description: 'Application Testsuite'
author: wireframe
category: other
