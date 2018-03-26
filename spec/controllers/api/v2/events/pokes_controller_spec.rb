require 'rails_helper'

RSpec.describe Api::V2::Events::PokesController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user, role: 'admin') }

  before do
    token_login(user, event)
    create(:poke, event: event)
  end

  context "GET #index" do
    describe "get events pokes" do
      it "returns a success response" do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns a not_found response" do
        get :index, params: { event_id: '-1' }
        expect(response).to have_http_status(:not_found)
      end

      before { create(:poke, event: event) }

      it "returns all pokes for the gtag" do
        get :index, params: { event_id: event.id }
        expect(json.size).to be(2)
      end
    end

    describe "get customers pokes" do
      let(:customer) { create(:customer, event: event, anonymous: false) }

      it "returns a success response" do
        get :index, params: { event_id: event.id, customer_id: customer.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns a not_found response" do
        get :index, params: { event_id: event.id, customer_id: '-1' }
        expect(response).to have_http_status(:not_found)
      end

      before { create(:poke, event: event, customer: customer) }

      it "returns all pokes for the gtag" do
        get :index, params: { event_id: event.id, customer_id: customer.id }
        expect(json.size).to be(1)
      end
    end

    describe "get gtags pokes" do
      let(:gtag) { create(:gtag, event: event) }

      it "returns a success response" do
        get :index, params: { event_id: event.id, gtag_id: gtag.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns a not_found response" do
        get :index, params: { event_id: event.id, gtag_id: '-1' }
        expect(response).to have_http_status(:not_found)
      end

      before { create(:poke, event: event, customer_gtag: gtag) }

      it "returns all pokes for the gtag" do
        get :index, params: { event_id: event.id, gtag_id: gtag.id }
        expect(json.size).to be(1)
      end
    end

    describe "get tickets pokes" do
      let(:ticket) { create(:ticket, event: event) }
      before { create(:poke, event: event, credential: ticket) }

      it "returns a success response" do
        get :index, params: { event_id: event.id, ticket_id: ticket.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns a not_found response" do
        get :index, params: { event_id: event.id, ticket_id: '-1' }
        expect(response).to have_http_status(:not_found)
      end

      it "returns all pokes for the ticket" do
        get :index, params: { event_id: event.id, ticket_id: ticket.id }
        expect(json.size).to be(1)
      end
    end
  end
end
