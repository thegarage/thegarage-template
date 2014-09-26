gem 'font-awesome-rails'
gem 'prelaunch', git: 'https://github.com/thegarage/prelaunch.git'

# Assets
get_binary_file 'app/assets/images/landing/blue-tile.jpg'
get_binary_file 'app/assets/images/landing/meadow.jpg'
get_binary_file 'app/assets/stylesheets/application.css.scss'
get_binary_file 'app/assets/stylesheets/framework_and_overrides.css.scss'
get_binary_file 'app/assets/stylesheets/landing.css.scss'
remove_file 'app/assets/stylesheets/application.css'

get_binary_file 'app/views/layouts/_footer.html.haml'
get_binary_file 'app/views/layouts/_messages.html.erb'
get_binary_file 'app/views/layouts/_navigation.html.erb'
get_binary_file 'app/views/layouts/_navigation_links.html.erb'
get_binary_file 'app/views/layouts/application.html.erb'

get_binary_file 'app/views/pages/home.html.haml'

stage_two do
  generate 'prelaunch:install'
  commit_changes 'Added a starter landing page.'
end

__END__

name: landing_page
description: 'Add a prelaunch landing page'
author: vandahm
category: other
