gem_group [:development, :test] do
  gem 'rspec-rails',
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
end

rspec_config_generators =  <<-EOS
config.generators do |g|
      g.view_specs false
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
    end
EOS

%w( capybara email_spec jasmine_rails render_views timecop vcr webmock ).each do |file|
  get_file "spec/support/#{file}.rb"
end

stage_two do
  remove_dir 'test/' unless ARGV.include?("-T")
  generate 'rspec:install'
  environment rspec_config_generators

  comment_lines 'spec/spec_helper.rb', /config.fixture_path.*/

  prepend_to_file 'spec/spec_helper.rb', get_file_partial(:simplecov, 'spec_helper.rb')
  append_to_file '.gitignore', get_file_partial(:simplecov, '.gitignore')

  commit_changes 'Add RSpec testsuite'
end

__END__

name: testsuite
description: 'Application Testsuite'
author: wireframe
requires: [custom_helpers]
category: other
