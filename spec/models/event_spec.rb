# == Schema Information
#
# Table name: events
#
#  aasm_state                   :string
#  background_content_type      :string
#  background_file_name         :string
#  background_file_size         :integer
#  background_type              :string           default("fixed")
#  company_name                 :string
#  currency                     :string           default("USD"), not null
#  device_basic_db_content_type :string
#  device_basic_db_file_name    :string
#  device_basic_db_file_size    :integer
#  device_full_db_content_type  :string
#  device_full_db_file_name     :string
#  device_full_db_file_size     :integer
#  device_settings              :json
#  end_date                     :datetime
#  eventbrite_client_key        :string
#  eventbrite_client_secret     :string
#  eventbrite_event             :string
#  eventbrite_token             :string
#  gtag_assignation             :boolean          default(FALSE)
#  gtag_settings                :json
#  host_country                 :string           default("US"), not null
#  location                     :string
#  logo_content_type            :string
#  logo_file_name               :string
#  logo_file_size               :integer
#  name                         :string           not null
#  official_address             :string
#  official_name                :string
#  registration_num             :string
#  registration_settings        :json
#  slug                         :string           not null
#  start_date                   :datetime
#  style                        :text
#  support_email                :string           default("support@glownet.com"), not null
#  ticket_assignation           :boolean          default(FALSE)
#  token                        :string
#  token_symbol                 :string           default("t")
#  url                          :string
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

require "spec_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:support_email) }

  describe ".eventbrite?" do
    it "returns true if the event has eventbrite_token and eventbrite_event" do
      expect(subject).not_to be_eventbrite
      subject.eventbrite_token = "test"
      expect(subject).not_to be_eventbrite
      subject.eventbrite_event = "test"
      expect(subject).to be_eventbrite
    end
  end

  describe ".credit_price" do
    it "returns the event credit value" do
      subject.save
      subject.create_credit!(value: 1, step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0, name: "CR")
      expect(subject.credit_price).to eq(subject.credit.value)
    end
  end

  describe ".active?" do
    it "returns true if the event is launched, started or finished" do
      subject.aasm_state = "closed"
      expect(subject).not_to be_active
      subject.aasm_state = "created"
      expect(subject).not_to be_active

      subject.aasm_state = "launched"
      expect(subject).to be_active
      subject.aasm_state = "started"
      expect(subject).to be_active
      subject.aasm_state = "finished"
      expect(subject).to be_active
    end
  end

  describe ".refunds" do
    it "returns the event refunds" do
      subject.save
      refund = create(:refund, customer: create(:customer, event: subject))
      expect(subject.refunds).to eq([refund])
    end
  end

  describe ".orders" do
    it "returns the event orders" do
      subject.save
      order = create(:order, customer: create(:customer, event: subject))
      expect(subject.orders).to eq([order])
    end
  end
end
