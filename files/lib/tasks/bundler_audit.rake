namespace :bundler do
  desc 'audit Bundler Gemfile for vulnerable gems'
  task :audit do
    puts 'Checking Gemfile for vulnerable gems...'
    require 'English'
    output = `bundle-audit`
    puts output
    status_code = $CHILD_STATUS.to_i
    fail "bunder:audit failed" unless status_code == 0
  end
end
