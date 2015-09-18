# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require "rails_helper"

RSpec.describe Entitlement, type: :model do

  before do
    FactoryGirl.create(:entitlement, name: "repellendus", id: 16)
    FactoryGirl.create(:entitlement, name: "tenetur", id: 17)
    FactoryGirl.create(:entitlement, name: "est", id: 18)
    FactoryGirl.create(:entitlement, name: "in", id: 19)
    FactoryGirl.create(:entitlement, name: "labore", id: 20)
  end

  it { is_expected.to validate_presence_of(:name) }

  describe "Entitlement" do
    it "should create an array for the selectors" do
      expect(Entitlement.form_selector()).to eq([
        ["repellendus", 16],
        ["tenetur", 17],
        ["est", 18],
        ["in", 19],
        ["labore", 20]
      ])
    end
  end
end
