require 'rails_helper'

RSpec.describe Events::RegistrationsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:customer_valid_atts) do
    { email: 'email@email.com', password: 'password1', password_confirmation: 'password1', first_name: 'first_name', last_name: 'last_name', agreed_on_registration: true }
  end
  let(:customer_invalid_atts) do
    { email: 'email@email.com', password: 'password', first_name: 'first_name', last_name: 'last_name', agreed_on_registration: false }
  end

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:customer]
  end

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

      it 'POST success create customer' do
        expect { post :create, params: { event_id: event, customer: customer_valid_atts } }.to change(Customer, :count).by(1)
      end

      it 'POST unable to create customer' do
        expect { post :create, params: { event_id: event, customer: customer_invalid_atts } }.to change(Customer, :count).by(0)
      end

      it 'POST success create customer redirect to customer customer_event_session_path' do
        post :create, params: { event_id: event, customer: customer_valid_atts }
        expect(response).to redirect_to(customer_event_session_path(event))
      end

      it 'POST unable to create customer but response is ok' do
        post :create, params: { event_id: event, customer: customer_invalid_atts }
        expect(response).to be_ok
      end
    end
  end
end
