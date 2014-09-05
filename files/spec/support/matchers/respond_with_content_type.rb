# see http://stackoverflow.com/questions/18760257/how-to-test-respond-with-content-type-when-its-depricated-in-shoulda-matches-2
RSpec::Matchers.define :respond_with_content_type do |_ability|
  match do |controller|
    expected_as_array.each do |format|  # for some reason formats are in array
      expect(controller.response.content_type.to_s).to eq Mime::Type.lookup_by_extension(format.to_sym).to_s
    end
  end

  failure_message do |actual|
    "expected response with content type #{actual.to_sym}"
  end

  failure_message_when_negated do |actual|
    "expected response not to be with content type #{actual.to_sym}"
  end
end
