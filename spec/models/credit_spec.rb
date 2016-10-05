# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require "rails_helper"

RSpec.describe Credit, type: :model do
  let(:event) { create(:event) }

  describe ".only_one_standard_credit" do
    it "should validate if an event has one and only one standard credit" do
      credit = build(:standard_credit)
      expect(credit).not_to be_valid
    end
  end

  describe ".rounded_value" do
    it "should return value rounded" do
      expect(create(:credit, value: 1, standard: false).value.to_f).to eq(1.0)
    end
  end
end
