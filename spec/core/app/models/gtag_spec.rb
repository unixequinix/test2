# == Schema Information
# require "../../../../apps/core/app/models/event"

# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  event_id          :integer          not null
#

require "rails_helper"

RSpec.describe Gtag, type: :model do
  let(:credential_assignment) { create(:credential_assignment_g_a) }
  let(:gtag) { credential_assignment.credentiable }
  let(:event) { gtag.event }

  describe "upcase_gtag!" do
    it "sets the tag_uid in upcase on validation" do
      gtag.tag_uid = "abc123abc"
      gtag.valid?
      expect(gtag.tag_uid =~ /[[:upper:]]+$/).not_to be_nil
    end
  end

  context "refunding: " do
    before :each do
      create(:customer_credit_online,
             amount: 10,
             refundable_amount: 10,
             profile: gtag.assigned_profile)
      create(:standard_credit_catalog_item, event: event)
      event.update_attribute(:refund_services, 2)
      Seeder::SeedLoader.load_param(event, category: "refund")
    end

    describe ".refundable_amount" do
      it "should be greater than 0" do
        expect(gtag.refundable_amount).to_not be_zero
      end

      it "returns the money that can be refunded" do
        expect(gtag.refundable_amount).to eq(event.standard_credit_price * 10)
      end
    end

    describe ".any_refundable_method?" do
      it "returns true if event has a refund serice activated" do
        expect(gtag.any_refundable_method?).to be(true)
      end

      it "returns false if event has no refund service activated" do
        event.update_attribute(:refund_services, 0)
        expect(gtag.any_refundable_method?).to be(false)
      end
    end
  end
end
