require 'rails_helper'

RSpec.describe Events::RegistrationsController, type: :controller do
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

      it 'GET change_password' do
        get :change_password, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'GET edit' do
        get :edit, params: { event_id: event }
        expect(response).to be_ok
      end
    end

    context 'customer is not logged in' do
      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end

      # it 'GET change_password' do
      #   get :change_password, params: { event_id: event }
      #   expect(response).to redirect_to(:event_login)
      # end

      # it 'GET edit' do
      #   get :edit, params: { event_id: event }
      #   expect(response).to redirect_to(:event_login)
      # end
    end
  end
end
