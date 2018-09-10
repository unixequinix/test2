require 'rails_helper'

RSpec.describe Events::StaticPagesController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render static pages' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET privacy_policy' do
        get :privacy_policy, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'GET terms_of_use' do
        get :terms_of_use, params: { event_id: event }
        expect(response).to be_ok
      end
    end

    context 'customer is not logged in' do
      it 'GET privacy_policy' do
        get :privacy_policy, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'GET terms_of_use' do
        get :terms_of_use, params: { event_id: event }
        expect(response).to be_ok
      end
    end
  end
end
