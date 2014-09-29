gem 'font-awesome-rails'
gem 'prelaunch', git: 'https://github.com/thegarage/waitlist.git'

# Assets
get_file 'app/assets/images/landing/blue-tile.jpg', eval: false
get_file 'app/assets/images/landing/meadow.jpg', eval: false
get_file 'app/assets/stylesheets/application.css.scss', eval: false
get_file 'app/assets/stylesheets/framework_and_overrides.css.scss', eval: false
get_file 'app/assets/stylesheets/landing.css.scss', eval: false
remove_file 'app/assets/stylesheets/application.css'

get_file 'app/views/layouts/_footer.html.haml', eval: false
get_file 'app/views/layouts/_messages.html.erb', eval: false
get_file 'app/views/layouts/_navigation.html.erb', eval: false
get_file 'app/views/layouts/_navigation_links.html.erb', eval: false
get_file 'app/views/layouts/application.html.erb', eval: false

get_file 'app/views/pages/home.html.haml', eval: false
commit_changes 'Added Landing page assets.'

stage_two do
  generate 'waitlist:install'
  commit_changes 'Added a starter landing page.'
end

__END__

name: landing_page
description: 'Add a prelaunch landing page'
author: vandahm
category: other
