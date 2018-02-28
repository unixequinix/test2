require 'rails_helper'

RSpec.describe Admins::ApiMetricsController, type: :controller do
  let(:user) { create(:user, role: 'glowball') }
  let(:promoter) { create(:user, role: 'promoter') }
  let(:event) { create(:event) }

  describe "GET" do
    context "for a glowball user" do
      before(:each) { sign_in user }

      it "#index and returns a success response" do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it "#show and returns a success response" do
        get :show, params: { id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end
    context "for a promoter" do
      before(:each) { sign_in promoter }

      it "#index and returns a bad response" do
        get :index
        expect(response).to have_http_status(:found)
      end

      it "#show and returns a bad response" do
        get :show, params: { user: promoter, id: event.id }
        expect(response).to have_http_status(:found)
      end
    end
  end
end

RSpec.describe Api::V2::Events::GtagsController, type: %i[controller api] do
  let(:user) { create(:user, role: 'glowball') }
  let(:event) { create(:event, open_api: true, state: "created") }

  let(:valid_gtag_attributes) do
    { 'tag_uid': '1A2B3C4D5E' }
  end

  let(:invalid_gtag_attributes) { { tag_uid: nil } }

  describe "POST #create using API V2 for Gtags" do
    context "with valid params" do
      before { token_login(user, event) }

      it "#creates a new ApiMetric" do
        expect do
          post :create, params: { event_id: event, gtag: valid_gtag_attributes }
        end.to change(ApiMetric, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, gtag: valid_gtag_attributes }
        expect(response).to be_created
      end

      it "returns the created api metric" do
        post :create, params: { event_id: event.id, gtag: valid_gtag_attributes }
        expect(ApiMetric.last.controller).to eq("gtags")
        expect(ApiMetric.last.action).to eq("create")
        expect(ApiMetric.last.http_verb).to eq("POST")
      end

      it "creates a new ApiMetric related to the event" do
        expect do
          post :create, params: { event_id: event.id, gtag: valid_gtag_attributes }
        end.to change(event.api_metrics, :count).by(1)
      end
    end

    context "with invalid params" do
      before { token_login(user, event) }

      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, gtag: invalid_gtag_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns the created api metric" do
        post :create, params: { event_id: event.id, gtag: invalid_gtag_attributes }
        expect(ApiMetric.last.controller).to eq("gtags")
        expect(ApiMetric.last.action).to eq("create")
        expect(ApiMetric.last.http_verb).to eq("POST")
      end
    end
  end
end

RSpec.describe Api::V2::Events::TicketsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }

  let(:invalid_attributes) { { code: nil } }
  let(:valid_attributes) { { code: "2221212212121", ticket_type_id: ticket_type.id } }

  before { token_login(user, event) }
  describe "POST #create using API V2 for Tickets" do
    context "with valid params" do
      it "creates a new ApiMetric" do
        expect do
          post :create, params: { event_id: event.id, ticket: valid_attributes }
        end.to change(ApiMetric, :count).by(1)
      end

      it "creates a new ApiMetric with change of ticets#create scope" do
        expect do
          post :create, params: { event_id: event.id, ticket: valid_attributes }
        end.to change(event.api_metrics.tickets_create, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, ticket: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created ticket" do
        post :create, params: { event_id: event.id, ticket: valid_attributes }
        expect(ApiMetric.last.controller).to eq("tickets")
        expect(ApiMetric.last.action).to eq("create")
        expect(ApiMetric.last.http_verb).to eq("POST")
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, ticket: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns the created api metric" do
        post :create, params: { event_id: event.id, ticket: valid_attributes }
        expect(ApiMetric.last.controller).to eq("tickets")
        expect(ApiMetric.last.action).to eq("create")
        expect(ApiMetric.last.http_verb).to eq("POST")
      end
    end
  end
end
