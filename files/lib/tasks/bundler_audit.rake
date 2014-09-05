namespace :bundler do
  desc 'audit Bundler Gemfile for vulnerable gems'
  task :audit do
    puts 'Checking Gemfile for vulnerable gems...'
    sh 'bin/bundle-audit'
  end
end
