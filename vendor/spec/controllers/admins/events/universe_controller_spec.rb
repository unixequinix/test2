require 'rails_helper'

RSpec.describe Admins::Events::UniverseController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:event) { create(:event) }
  let(:integration) { create(:ticketing_integration, event: event, name: "universe") }

  before(:each) { sign_in user }
end
