# configure asset hosts for controllers + mailers
# configure url helpers to use the options from env
default_url_options = {
  host: ENV['DEFAULT_URL_HOST'],
  protocol: ENV['DEFAULT_URL_PROTOCOL']
}
Rails.application.routes.default_url_options = default_url_options
config.action_mailer.default_url_options = default_url_options

# use SSL, use Strict-Transport-Security, and use secure cookies
config.force_ssl = (ENV['DEFAULT_URL_PROTOCOL'] == 'https')
