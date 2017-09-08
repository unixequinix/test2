require 'rails_helper'

RSpec.describe Api::V2::Events::StatsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:stat) { create(:stat, event: event) }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:stat, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all stats" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return stats from another event" do
      new_stat = create(:stat)
      get :index, params: { event_id: event.id }
      expect(json.map { |h| h["id"] }).not_to include(new_stat.id)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: stat.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the stat as JSON" do
      get :show, params: { event_id: event.id, id: stat.to_param }
      expect(json).to eq(obj_to_json(stat, "Full::StatSerializer"))
    end
  end
end
