# Configure default email settings
config.action_mailer.default_options = {
  from: %Q("#{ENV['COMPANY_NAME']}" <contact@#{ENV['COMPANY_DOMAIN']}>)
}
