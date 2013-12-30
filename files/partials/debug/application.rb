# Delay requiring debug group until dotenv-rails has been required
# which loads the necessary ENV variables
Bundler.require(:debug) if %w{ development test }.include?(Rails.env) && ENV['BUNDLER_INCLUDE_DEBUG_GROUP'] == 'true'
