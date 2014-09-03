require 'capybara/rspec'

RSpec.configure do |config|
  # config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end
