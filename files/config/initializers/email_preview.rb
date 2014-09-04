# Define Email Fixtures for testing accessible locally at:
# http://localhost:3000/email_preview
if defined?(EmailPreview)
  EmailPreview.before_preview do
    FactoryGirl.reload
  end

  EmailPreview.register 'Example Email', category: :deleteme do
    # user = FactoryGirl.create :user
    # SomeMailer.email_action user
  end
end
