# Based on production defaults
require Rails.root.join('config/environments/production')

# customize and override production settings here
<%= app_name.camelize %>::Application.configure do
end
