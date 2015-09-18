require "rails_helper"

RSpec.describe Gtag, type: :model do
  describe "upcase_gtag" do
    it "sets the tag_uid and tag_serial_number in upcase" do
      gtag = build(:gtag)
      tag_uid_lowercase = gtag.tag_uid
      tag_serial_number_lowercase = gtag.tag_serial_number
      gtag.save
      expect(gtag.tag_uid).to eq(tag_uid_lowercase.upcase)
      expect(gtag.tag_serial_number).to eq(tag_serial_number_lowercase.upcase)
    end
    it "should set the data for the exportation" do
      gtag = create(:gtag)
      event = gtag.event_id
      expect(Gtag.selected_data(event)).not_to eq(nil)
    end
  end

  describe "refundable_amount" do
    it "should return the money that can be refunded" do
      gtag = create(:gtag)
      create(:online_product, price: 10, event: gtag.event)
      create(:online_product, price: 15, event: gtag.event)
      create(:gtag_credit_log, amount: 3, gtag: gtag)

      expect(gtag.refundable_amount()).not_to be_nil
    end
  end
end
