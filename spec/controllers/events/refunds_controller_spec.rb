require 'rails_helper'

RSpec.describe Events::RefundsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new with refunds closed' do
        event.open_refunds = false
        event.save
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end

      it 'GET new with no refunds' do
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end

      it 'GET new' do
        create(:order, customer: customer, event: event)
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end
    end

    context 'customer is not logged in' do
      it 'GET new' do
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
