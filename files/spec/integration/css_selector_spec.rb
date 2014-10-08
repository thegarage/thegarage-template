require 'rails_helper'

describe 'CSS Selectors' do
  it 'has less than 4095 selectors' do
    css_files = Rails.application.assets.each_logical_path(*Rails.application.config.assets.precompile).to_a.grep(/\.css/)
    css_files.each do |file|
      expect(file).to respect_selector_limit
    end
  end
end
