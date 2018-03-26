require 'rails_helper'

RSpec.describe Admins::Events::AdmissionsController, type: :controller do
  let(:user) { create(:user, role: 'glowball') }
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, event: event) }

  describe "GET #index" do
    context "returns a right response" do
      it "if user is logged in" do
        sign_in user
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
      it "if user is not logged in" do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET #merge" do
    context "returns a success response" do
      before(:each) { sign_in user }

      it "if merging with ticket" do
        get :merge, params: { event_id: event.id, id: ticket.id, type: ticket.class.to_s.humanize.downcase }
        expect(response).to have_http_status(:ok)
      end

      it "if merging with customer" do
        get :merge, params: { event_id: event.id, id: customer.id, type: customer.class.to_s.humanize.downcase }
        expect(response).to have_http_status(:ok)
      end

      it "if merging with gtag" do
        get :merge, params: { event_id: event.id, id: gtag.id, type: gtag.class.to_s.humanize.downcase }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
