require 'erb'

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

# download remote file from remote repo and save to local path
# the downloaded resources *may* contain dynamic ERB statements
# that will be automatically evaluated once downloaded
def get_file(path, options={})
  remove_file path
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', path)
  replace_file path, download_resource(resource, options)
end

# download partial file contents and process through ERB
# return the processed string
def get_file_partial(category, path, options={})
  resource = File.join(prefs[:remote_host], prefs[:remote_branch], 'files', 'partials', category.to_s, path)
  download_resource(resource, options)
end

# download remote file contents and process through ERB
# return the processed string
def download_resource(resource, options={})
  say_status :download, resource

  open(resource) do |input|
    contents = input.binmode.read
    return contents if options[:eval] == false

    template = ERB.new(contents)
    template.result(binding)
  end
end

# helper to save changes in git
def commit_changes(description)
  git :add => '-A'
  git :commit => %Q(-qm "thegarage-template: #{description}")
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

def github_slug
  [prefs[:github_organization], app_name].join('/')
end

# heroku has 30 character limit for application names
def heroku_appname(env)
  max_env_length = 10
  max_app_name_length = 30 - 2 - max_env_length - prefs[:heroku_app_prefix].length
  truncated_app_name = app_name.slice(0, max_app_name_length)
  [prefs[:heroku_app_prefix], truncated_app_name, env].join('-')
end

# check if non-empty value exists for preference
def has_pref?(preference)
  !prefs[preference].to_s.empty?
end

__END__

name: custom_helpers
description: 'Extra helper methods for recipes'
author: wireframe
category: other
