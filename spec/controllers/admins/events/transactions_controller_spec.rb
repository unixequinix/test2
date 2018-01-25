require 'rails_helper'

RSpec.describe Admins::Events::TransactionsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:station) { create(:station, event: event) }
  let(:transaction) { create(:transaction, station: station, event: event) }

  before(:each) { sign_in user }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
