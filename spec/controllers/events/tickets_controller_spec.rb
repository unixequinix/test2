require 'rails_helper'

RSpec.describe Events::TicketsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:ticket) { create(:ticket, event: event, customer: customer) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET show' do
        get :show, params: { event_id: event, id: ticket }
        expect(response).to be_ok
      end
    end

    context 'customer is not logged in' do
      it 'GET show' do
        get :show, params: { event_id: event, id: ticket }
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
