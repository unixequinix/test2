require 'rails_helper'

RSpec.describe Events::CreditsHistoriesController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { request.env["devise.mapping"] = Devise.mappings[:customer] }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET history' do
        get :history, params: { event_id: event }, format: :pdf
        expect(response).to be_ok
      end
    end

    context 'customer is not logged in' do
      it 'GET history' do
        get :history, params: { event_id: event }, format: :pdf
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
