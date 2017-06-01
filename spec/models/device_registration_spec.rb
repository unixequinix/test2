require "spec_helper"

RSpec.describe DeviceRegistration, type: :model do
  let(:event) { create(:event) }
  let(:device) { create(:device) }
  subject { create(:device_registration, event: event, device: device) }

  it "should be valid" do
    expect(subject).to be_valid
  end

  describe "resolve_time!" do
    before do
      event.update!(start_date: 1.hour.ago, end_date: Time.current + 1.hour)
      atts = { event: event, action: "sale", device_uid: device.mac }

      atts[:device_created_at] = Time.current.to_formatted_s(:transactions)
      @list = create_list(:credit_transaction, 3, atts)

      atts[:device_created_at] = (Time.current - 10.days).to_formatted_s(:transactions)
      @bad_t = create(:credit_transaction, atts)
    end

    it "changes the bad transactions device_created_at" do
      start_date = event.start_date.to_formatted_s(:transactions)
      end_date = event.end_date.to_formatted_s(:transactions)
      expect(@bad_t.device_created_at).not_to be_between(start_date, end_date)

      subject.resolve_time!
      expect(@bad_t.reload.device_created_at).to be_between(start_date, end_date)
    end

    it "sets bad transactions device_created_at 1 minute after last good one" do
      start_date = event.start_date.to_formatted_s(:transactions)
      end_date = event.end_date.to_formatted_s(:transactions)
      expect(@bad_t.device_created_at).not_to be_between(start_date, end_date)
      subject.resolve_time!

      new_start_date = (Time.zone.parse(@list.last.device_created_at) + 1.minute).to_formatted_s(:transactions)
      expect(@bad_t.reload.device_created_at).to eq(new_start_date)
    end

    it "sets the start date of the event + 1 minute if bad transactions is the first" do
      @bad_t.update!(device_db_index: 0)
      subject.resolve_time!
      expect(@bad_t.reload.device_created_at).to eq(event.start_date.to_formatted_s(:transactions))
    end
  end
end
