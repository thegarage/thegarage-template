# continuous integration build tasks
task :ci => ['ci:setup', :spec, :rubocop, 'spec:javascript', :jshint, 'brakeman:run', 'bundler:audit', 'bundler:outdated'] do
end

namespace :ci do
  task :setup do
    Bundler.require(:ci)
    require 'rubocop/rake_task'
    Rubocop::RakeTask.new do |task|
      task.patterns = ['--rails']
    end

    require "jshintrb/jshinttask"
    Jshintrb::JshintTask.new :jshint do |t|
      options = JSON.load(File.read('.jshintrc'))
      globals = options.delete('globals')
      ignored = File.read('.jshintignore').split.collect {|pattern| FileList[pattern].to_a }.flatten
      files = Dir.glob('**/*.js')
      t.js_files = files
      t.exclude_js_files = ignored
      t.options = options
      t.globals = globals.keys
    end
  end
end
