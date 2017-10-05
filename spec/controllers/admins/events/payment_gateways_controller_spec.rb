require 'rails_helper'

RSpec.describe Admins::Events::PaymentGatewaysController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:payment_gateway) { create(:payment_gateway, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: new

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { event_id: event.id, id: payment_gateway.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
