# continuous integration build tasks
task :ci => ['ci:setup', 'db:create:all', :spec, :rubocop, 'spec:javascript', :jshint, 'brakeman:run', 'bundler:audit', 'bundler:outdated']

namespace :ci do
  task :setup do
    ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'
    Bundler.require(:ci)
  end
end
