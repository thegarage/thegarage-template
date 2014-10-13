require 'rails_helper'

describe 'precompiled_css_files' do
  it 'has less than 4095 selectors' do
    expect(precompiled_css_files).to respect_selector_limit
  end
end
