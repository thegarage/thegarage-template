task :jshint do
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
