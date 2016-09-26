
require "rails_helper"

RSpec.describe CredentialAssignment, type: :model do
  let(:profile) { create(:profile) }
  let(:atts) { { profile: profile } }

  context "validations" do
    it { is_expected.to validate_presence_of(:aasm_state) }
    it { is_expected.to validate_presence_of(:profile) }
  end

  it "The relation active_assignments returns the gtags and tickets assigned" do
    create(:credential_assignment_g_a, atts)
    create(:credential_assignment_g_u, atts)
    create(:credential_assignment_t_a, atts)
    create(:credential_assignment_t_u, atts)

    expect(profile.active_assignments.count).to be(2)
  end
end
