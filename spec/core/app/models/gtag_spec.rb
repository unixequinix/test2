# == Schema Information
#
# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string           not null
#  tag_serial_number :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  event_id          :integer          not null
#

require "rails_helper"

RSpec.describe Gtag, type: :model do
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, event: event) }

  describe "upcase_gtag" do
    it "sets the tag_uid and tag_serial_number in upcase" do
      tag_uid_lowercase = gtag.tag_uid
      tag_serial_number_lowercase = gtag.tag_serial_number
      gtag.save
      expect(gtag.tag_uid).to eq(tag_uid_lowercase.upcase)
      expect(gtag.tag_serial_number).to eq(tag_serial_number_lowercase.upcase)
    end
    it "should set the data for the exportation" do
      event = gtag.event_id
      expect(Gtag.selected_data(event)).not_to eq(nil)
    end
  end

  describe "refundable_amount" do
    it "should return the money that can be refunded" do
      create(:preevent_product, :standard_credit_product, event: event)
      create(:gtag_credit_log, amount: 9.99, gtag: gtag)
      price = event.standard_credit_price
      expect(gtag.refundable_amount).to eq(price * 9.99)
    end
  end

  describe "any_refundable_method?" do
    it "should return true if the current event has a refund serice activated" do
      event = create(:event_with_refund_services)
      create(:preevent_product, :standard_credit_product, event: event)
      Seeder::SeedLoader.load_default_event_parameters(event)
      gtag = create(:gtag, event: event)
      create(:gtag_credit_log, amount: 9.99, gtag: gtag)
      expect(gtag.any_refundable_method?).to be(true)

      event.update_attribute(:refund_services, 0)
      expect(gtag.any_refundable_method?).to be(false)
    end
  end
end
