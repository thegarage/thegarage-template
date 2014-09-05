RSpec::Matchers.define :be_a_valid_url do
  match do |actual|
    actual =~ URI::ABS_URI
  end
end
