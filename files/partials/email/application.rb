# Configure default email settings
config.action_mailer.default_options = {
  from: %Q("#{ENV['COMPANY_NAME']}" <#{ENV['COMPANY_SUPPORT_ADDRESS']}>)
}

# configure SMTP settings
config.action_mailer.smtp_settings = {
  authentication: :plain,
  enable_starttls_auto: true,
  address: ENV['SMTP_SERVER'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_LOGIN'],
  password: ENV['SMTP_PASSWORD']
}
