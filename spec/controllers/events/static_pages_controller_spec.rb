require 'spec_helper'
require 'rails-controller-testing'

RSpec.describe Events::StaticPagesController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render static pages' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET privacy_policy' do
        get :privacy_policy, params: { event_id: event }
        expect(response).to be_ok
        expect(response).to render_template('privacy_policy_en')
      end

      it 'GET terms_of_use' do
        get :terms_of_use, params: { event_id: event }
        expect(response).to be_ok
        expect(response).to render_template('terms_of_use_en')
      end
    end

    context 'customer is not logged in' do
      it 'GET privacy_policy' do
        get :privacy_policy, params: { event_id: event }
        expect(response).to be_ok
        expect(response).to render_template('privacy_policy_en')
      end

      it 'GET terms_of_use' do
        get :terms_of_use, params: { event_id: event }
        expect(response).to be_ok
        expect(response).to render_template('terms_of_use_en')
      end
    end
  end
end
