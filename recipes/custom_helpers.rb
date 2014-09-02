# shortcut method to delete existing file
# and replace with new contents
def replace_file(filename, data)
  remove_file filename
  create_file filename, data
end

# helper method to run a command and ensure success
# by default the thor run command does *not* exit
# the process when the command fails
def run_command(command, options = {})
  status = run(command, options)
  fail "#{command} failed" unless status
end

# add .gitkeep placeholder file so that the directory stays checked into git
def preserve_directory(directory)
  path = File.join(directory, '.gitkeep')
  create_file path, ''
end

# shortcut method to add a gem to the
# gemfile/.lock/cache, and install it
def install_gem(gem_name, options = {})
  if options[:group]
    gem gem_name, group: options[:group]
  else
    gem gem_name
  end
  run_command "gem install #{gem_name}"
  if options[:local] == :no
    run_command 'bundle install'
  else
    run_command 'bundle install --local'
  end
end

# download remote file from remote repo and save to local path
# the downloaded resources *may* contain dynamic ERB statements
# that will be automatically evaluated once downloaded
def get_file(path)
  remove_file path
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', path)
  copy_from_repo path, repo: resource
end

# download partial file contents and process through ERB
# return the processed string
def get_file_partial(category, path)
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', 'partials', category.to_s, path)
  download_resource resource
end

# download remote file contents and process through ERB
# return the processed string
def download_resource(resource)
  puts "Downloading resource: #{resource}"
  copy
  open(resource) do |input|
    contents = input.binmode.read
    template = ERB.new(contents)
    template.result(binding)
  end
end

# insert content into existing file
# automatically add newlines before/after content
# supports matching indentation of matched line
def insert_lines_into_file(path, content, options = {})
  target_line = options[:before] || options[:after]
  target_line = Regexp.escape(target_line) unless target_line.is_a?(Regexp)
  target_line = /#{target_line}.*\n/
  options[:before] = target_line if options[:before]
  options[:after] = target_line if options[:after]
  indent = ''
  File.open(path, 'r') do |file|
    file.each_line(path) do |line|
      if line =~ target_line
        indent = line.scan(/^\s+/).first
      end
    end
  end
  indent ||= ''
  indent.chomp!

  if options[:indent].to_i > 0
    indent += (' ' * options[:indent].to_i)
  end

  indented_content = ''
  content.each_line do |line|
    indented_content += line.blank? ? line : (indent + line)
  end
  indented_content += "\n"

  insert_into_file path, indented_content, options
end

__END__

name: custom_helpers
description: 'Extra helper methods for recipes'
author: wireframe
category: other
