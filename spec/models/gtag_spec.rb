require "rails_helper"

RSpec.describe Gtag, type: :model do
  context "with a new gtag" do
    describe "before create" do
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
  end

end
