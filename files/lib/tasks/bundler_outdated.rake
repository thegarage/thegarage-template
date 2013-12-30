namespace :bundler do
  desc 'Generate report of outdated gems'
  task :outdated do
    puts "Generating report of outdated gems..."
    output = `bundle outdated`
    puts output
  end
end
