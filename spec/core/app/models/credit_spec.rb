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
    before(:all) do
      @event = create(:event)
      create(:preevent_product, :standard_credit_product, event: @event, price: 2)
      create(:preevent_product, :standard_credit_product, price: 5)
    end

    it "should return the standard credit of the event" do
      credit = @event.standard_credit
      expect(credit.class.name).to eq("Credit")
      expect(credit.standard).to be(true)
    end
  end
end
