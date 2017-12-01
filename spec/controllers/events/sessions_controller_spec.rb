require 'rails_helper'

RSpec.describe Events::SessionsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer_unconfirmed) { create(:customer_unconfirmed, event: event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:customer]
    allow(request.env['warden']).to receive(:authenticate!).and_return(customer)
  end

  describe 'GET new' do
    context 'event has customer portal' do
      it 'GET new render template' do
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end
    end

    context 'event has no customer portal' do
      it 'GET new render template' do
        event.open_portal = false
        get :new, params: { event_id: event }
        expect(response).to be_ok
      end
    end
  end

  describe 'POST create' do
    context 'event has customer portal' do
      context 'unconfirmed customer' do
        it 'POST resend redirection' do
          post :create, params: { event_id: event, customer: { email: customer_unconfirmed.email, password: customer_unconfirmed.password } }
          expect(response).to redirect_to(event_resend_confirmation_path(event))
        end

        it 'POST login signed customer' do
          post :create, params: { event_id: event, customer: { email: customer_unconfirmed.email, password: customer_unconfirmed.password } }
          expect(subject.current_customer).to be(nil)
        end
      end

      context 'confirmed customer' do
        it 'POST login redirection' do
          post :create, params: { event_id: event, customer: { email: customer.email, password: customer.password } }
          expect(response).to redirect_to(customer_root_path(event))
        end

        it 'POST login signed customer' do
          post :create, params: { event_id: event, customer: { email: customer.email, password: customer.password } }
          expect(subject.current_customer).to be(customer)
        end
      end
    end
  end
end
