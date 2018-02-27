require 'rails_helper'

RSpec.describe Events::PasswordsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { request.env["devise.mapping"] = Devise.mappings[:customer] }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to redirect_to(event)
      end

      it 'GET edit' do
        get :edit, params: { event_id: event }
        expect(response).to redirect_to(event)
      end
    end

    context 'customer is not logged in' do
      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end
    end
  end
end
