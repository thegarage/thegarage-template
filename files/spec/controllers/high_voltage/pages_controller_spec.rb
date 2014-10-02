require 'rails_helper'
describe HighVoltage::PagesController do
  describe '#show' do
    HighVoltage.pages.each do |page|
      context "when id == #{page}" do
        before do
          get :show, id: page
        end
        it { should respond_with(:success) }
        it { should render_template(page) }
      end
    end
  end
end
