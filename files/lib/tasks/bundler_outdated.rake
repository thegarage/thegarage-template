namespace :bundler do
  desc 'Generate report of outdated gems'
  task :outdated do
    puts 'Generating report of outdated gems...'
    sh 'bundle outdated' do
      # swallow errors
    end
  end
end
