require 'rails_helper'

RSpec.describe "Topup stations info view tests", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let(:event) { create(:event, name: "Test Event", state: "created") }
  let(:station) { create(:station, event: event, category: "top_up_refund", name: "Topup Refund") }

  before(:each) do
    login_as(user, scope: :user)
  end

  include_examples "edit station"
end
