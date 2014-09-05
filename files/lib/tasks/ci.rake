# continuous integration build tasks
task :ci => ['ci:setup', :spec, :rubocop, 'spec:javascript', :jshint, 'brakeman:run', 'bundler:audit', 'bundler:outdated']

namespace :ci do
  task :setup do
    ENV['RAILS_ENV'] = 'test'
    Bundler.require(:ci)
  end
end
