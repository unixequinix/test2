require 'rails_helper'

RSpec.describe Admins::Events::EventbriteController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:integration) { create(:ticketing_integration, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a redirect response" do
      get :index, params: { event_id: event.id, ticketing_integration_id: integration.id }
      expect(response).to have_http_status(:redirect)
    end
  end
end
