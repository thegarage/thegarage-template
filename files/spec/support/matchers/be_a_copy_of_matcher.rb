RSpec::Matchers.define :be_a_copy_of do |expected|
  chain :with_attributes do |attributes|
    @attributes = attributes
  end

  match do |actual|
    @attributes.each do |attribute|
      @attribute = attribute
      actual.send(attribute) == expected.send(attribute)
    end
  end

  failure_message do |_actual|
    "expected that #{@attribute} would be copied, but it was not."
  end
end
