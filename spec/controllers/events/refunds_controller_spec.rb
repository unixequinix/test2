require 'rails_helper'

RSpec.describe Events::RefundsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET new with refunds closed' do
        event.update! open_refunds: false
        get :new, params: { event_id: event }
        expect(response).to redirect_to(:customer_root)
      end

      it 'GET new' do
        event.update! open_refunds: true
        create(:order, :with_credit, event: event, customer: customer, credits: 100).complete!

        get :new, params: { event_id: event }
        expect(response).to be_ok
      end

      it 'GET new redirection' do
        get :new, params: { event_id: event }
        expect(response).to redirect_to(event_path(event))
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
