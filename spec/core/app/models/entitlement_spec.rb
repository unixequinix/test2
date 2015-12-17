# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  event_id   :integer          not null
#

require "rails_helper"

RSpec.describe Entitlement, type: :model do

  before do
    @first_event = create(:event)
    create(:entitlement, name: "repellendus", id: 16, event: @first_event)
    create(:entitlement, name: "tenetur", id: 17, event: @first_event)
    create(:entitlement, name: "est", id: 18, event: @first_event)
    create(:entitlement, name: "in", id: 19, event: @first_event)
    create(:entitlement, name: "labore", id: 20, event: @first_event)
    @second_event = create(:event)
    create(:entitlement, name: "repellendus is", id: 21, event: @second_event)
    create(:entitlement, name: "tenetur is", id: 22, event: @second_event)
    create(:entitlement, name: "est is", id: 23, event: @second_event)
    create(:entitlement, name: "in is", id: 24, event: @second_event)
    create(:entitlement, name: "labore is", id: 25, event: @second_event)
  end

  it { is_expected.to validate_presence_of(:name) }

  describe "Entitlement" do
    it "should create an array for the selectors" do
      expect(Entitlement.form_selector(@first_event)).to eq([
        ["repellendus", 16],
        ["tenetur", 17],
        ["est", 18],
        ["in", 19],
        ["labore", 20]
      ])
    end
  end
end
