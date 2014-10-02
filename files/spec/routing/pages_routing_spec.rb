require 'rails_helper'

describe 'root page routes' do
  it { expect(get: '/').to route_to 'high_voltage/pages#show', id: 'home' }
  HighVoltage.pages.each do |page|
    it { expect(get: "/#{page}").to route_to 'high_voltage/pages#show', id: page }
  end
end
