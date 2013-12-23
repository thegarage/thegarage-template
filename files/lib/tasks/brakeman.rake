namespace :brakeman do
  desc "Run Brakeman"
  task :run, :output_files do |t, args|
    files = args[:output_files].split(' ') if args[:output_files]
    puts "Checking for security vulnerabilities..."
    tracker = Brakeman.run :app_path => ".", :output_files => files, :print_report => true
    if tracker.filtered_warnings.any?
      puts "Security vulnerabilities found!"
      exit 1
    end
  end
end
