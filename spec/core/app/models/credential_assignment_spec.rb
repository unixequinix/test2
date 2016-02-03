
require "rails_helper"

RSpec.describe CredentialAssignment, type: :model do
  it { is_expected.to validate_presence_of(:aasm_state) }
  it { is_expected.to validate_presence_of(:customer_event_profile) }
end
