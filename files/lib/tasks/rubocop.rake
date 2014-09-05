task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.patterns = ['--rails']
  end
end
