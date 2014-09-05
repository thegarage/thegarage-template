namespace :brakeman do
  desc 'Run Brakeman'
  task :run do
    sh 'bin/brakeman', '-z'
  end
end
