# add application name prefix to all delivered emails
# also add helpful prefix for non-production emails (useful for email filters)
# see http://stackoverflow.com/questions/13812580/override-actionmailer-subject-in-staging-environment
# example production subject:
#   [MyApp] Forgot Password
# example staging subject:
#   [MyApp STAGING] Forgot Password
class AddAppnameToEmailSubject
  def self.delivering_email(mail)
    prefixes = []
    prefixes << Rails.application.class.parent_name
    prefixes << Rails.env.upcase unless Rails.env.production?
    prefix = "[#{prefixes.join(' ')}] "
    mail.subject.prepend(prefix)
  end
end
ActionMailer::Base.register_interceptor(AddAppnameToEmailSubject)
