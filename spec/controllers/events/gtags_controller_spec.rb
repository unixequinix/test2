require 'rails_helper'

RSpec.describe Events::GtagsController, type: :controller do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:gtag) { create(:gtag, event: event, customer: customer, ticket_type: ticket_type) }

  describe 'render templates' do
    context 'customer is logged in' do
      before(:each) { sign_in customer }

      it 'GET show' do
        get :show, params: { event_id: event, id: gtag }
        expect(response).to be_ok
      end

      it 'PATCH ban' do
        put :ban, params: { event_id: event, id: gtag, gtag: { banned: true } }
        expect(response).to redirect_to event_gtag_path(event)
      end

      it 'PATCH ban' do
        gtag.banned = true
        gtag.save
        put :ban, params: { event_id: event, id: gtag, gtag: { banned: false } }
        expect(gtag.banned).to be(true)
      end
    end

    context 'customer is not logged in' do
      it 'GET show' do
        get :show, params: { event_id: event, id: gtag }
        expect(response).to redirect_to(:event_login)
      end

      it 'PATCH ban' do
        put :ban, params: { event_id: event, id: gtag, gtag: { banned: true } }
        expect(response).to redirect_to(:event_login)
      end
    end
  end
end
