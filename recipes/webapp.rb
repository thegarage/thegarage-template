gem 'puma'
gem 'haml'
gem 'html2haml', group: :toolbox
gem 'bootstrap-sass'
gem 'simple_form'
gem 'high_voltage'
gem 'font-awesome-rails'
gem 'waitlist'

append_to_file '.env', get_file_partial(:webapp, '.env')

get_file 'Procfile'
get_file 'config/puma.rb'
get_file 'config/initializers/high_voltage.rb'

get_file 'app/assets/images/landing/blue-tile.jpg', eval: false
get_file 'app/assets/images/landing/meadow.jpg', eval: false

# ruby script to list all stylesheet files
# Dir.glob('files/app/assets/stylesheets/**/*').each { |f| puts f.gsub(/^files\//, '') unless File.directory?(f) }
remove_file 'app/assets/stylesheets/application.css'
get_file 'app/assets/stylesheets/application.css.scss', eval: false
get_file 'app/assets/stylesheets/bootstrap-loader.css.scss', eval: false
get_file 'app/assets/stylesheets/fontawesome-loader.css.scss', eval: false
get_file 'app/assets/stylesheets/footer.css.scss', eval: false
get_file 'app/assets/stylesheets/landing.css.scss', eval: false
get_file 'app/assets/stylesheets/mixins/_respond-only-to.scss', eval: false
get_file 'app/assets/stylesheets/mixins/_respond-to.scss', eval: false
get_file 'app/assets/stylesheets/reset.css.scss', eval: false

get_file 'app/views/layouts/_analytics.html.erb'
get_file 'app/views/layouts/_footer.html.haml', eval: false
get_file 'app/views/layouts/_messages.html.erb', eval: false
get_file 'app/views/layouts/_navigation.html.erb', eval: false
get_file 'app/views/layouts/_navigation_links.html.erb', eval: false
get_file 'app/views/layouts/application.html.erb', eval: false

get_file 'app/views/pages/home.html.haml', eval: false
get_file 'app/views/pages/terms.html.haml'
get_file 'app/views/pages/privacy.html.haml'

prefs[:mixpanel_token_dev] = ask_wizard('Mixpanel Token (Development)')
if has_pref?(:mixpanel_token_dev)
  append_to_file '.env', get_file_partial(:mixpanel, '.env')
  get_file 'app/assets/javascripts/mixpanel-page-viewed.js'
  append_to_file 'app/views/layouts/_analytics.html.erb', get_file_partial(:webapp, 'mixpanel.html', eval: false)
end

prefs[:ga_property] = ask_wizard('Google Analytics Property ID')
if has_pref?(:ga_property)
  append_to_file '.env', get_file_partial(:google_analytics, '.env')
  append_to_file 'app/views/layouts/_analytics.html.erb', get_file_partial(:webapp, 'ga.html', eval: false)
end

prefs[:company_name] = ask_wizard('What is the Company Name?')
prefs[:company_domain] = ask_wizard('What is the site domain? (ex: google.com)')
append_to_file '.env', get_file_partial(:project, '.env')

commit_changes "Add webapp config"

stage_two do
  run_command 'bundle binstubs puma'

  say_wizard 'Configuring application settings'
  environment get_file_partial(:webapp, 'application.rb', eval: false)
  environment get_file_partial(:email, 'application.rb', eval: false)

  say_wizard "installing simple_form for use with Bootstrap"
  generate 'simple_form:install --bootstrap'

  say_wizard "Setting up waitlist gem"
  generate 'waitlist:install'

  commit_changes 'Add frontend resources/config'
end

__END__

name: webapp
description: 'Setup Webapp Dependencies'
author: wireframe
category: other
