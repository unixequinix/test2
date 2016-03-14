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
  describe "Credit" do
    describe ".only_one_standard_credit" do
      it "should validate if an event has one and only one standard credit" do
        event = create(:event)
        catalog_item = create(:standard_credit_catalog_item, event: event)
        catalog_item.valid?
        expect(event.catalog_items.where(catalogable_type: "Credit").count).to eq(1)
      end
    end
    describe ".rounded_value" do
      it "should return value rounded" do
        credit = create(:credit, value: 1)
        expect(credit.value).to eq(1.0)
      end
    end
  end
end
