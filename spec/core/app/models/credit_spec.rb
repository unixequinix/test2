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

    describe ".standard" do
      it "should return the standard credit of the event" do
        credit = @event.standard_credit
        expect(credit.class.name).to eq("Credit")
        expect(credit.standard).to be(true)
      end
    end

    describe ".standard_credit_preevent_product" do
      it "should return the product with the standard credit of the event" do
        event = create(:event)
        preevent_product = create(:preevent_product, :standard_credit_product, event: event)
        create(:preevent_product, :full)
        expect(Credit.standard_credit_preevent_product(event).id).to eq(preevent_product.id)
      end
    end
  end
end
