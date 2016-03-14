# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string           not null
#  aasm_state              :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string           not null
#  location                :string
#  start_date              :datetime
#  end_date                :datetime
#  description             :text
#  support_email           :string           default("supportglownet.com"), not null
#  style                   :text
#  logo_file_name          :string
#  logo_content_type       :string
#  logo_file_size          :integer
#  logo_updated_at         :datetime
#  background_file_name    :string
#  background_content_type :string
#  background_file_size    :integer
#  background_updated_at   :datetime
#  url                     :string
#  background_type         :string           default("fixed")
#  features                :integer          default(0), not null
#  refund_service          :string           default("bank_account")
#  gtag_assignation        :boolean          default(TRUE), not null
#  payment_service         :string           default("redsys")
#  registration_parameters :integer          default(0), not null
#

require "rails_helper"

RSpec.describe Event, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:support_email) }

  before(:all) do
    station_group = StationGroup.create!(name: "access", icon_slug: "access")
    station_group.station_types.create!(name: "customer_portal",
                                        description: "Customer Portal",
                                        enviorment: "portal")
    event_creator = EventCreator.new(build(:event, gtag_assignation: true).attributes)
    event_creator.save
    @event = event_creator.event
    customer = create(:customer, event: @event)
    create(:customer_event_profile, event: @event, customer: customer)
    gtag = create(:gtag, event: @event)
    create(:credential_assignment,
           aasm_state: "assigned",
           credentiable: gtag,
           customer_event_profile: customer.customer_event_profile)
    create(:customer_credit_online,
           customer_event_profile: customer.customer_event_profile, amount: 9.99, refundable_amount: 9.99)
    create(:customer_credit_online,
           customer_event_profile: customer.customer_event_profile, amount: 9.99, refundable_amount: 9.99)
    gtag2 = create(:gtag, event: @event)
    create(:credential_assignment,
           aasm_state: "unassigned",
           credentiable: gtag2,
           customer_event_profile: customer.customer_event_profile)
    create(:customer_credit_online,
           customer_event_profile: customer.customer_event_profile, amount: 9.99, refundable_amount: 9.99)
  end

  it "should return the credits available for that event" do
    expect(@event.total_credits.to_f).to be(29.97)
  end

  it "should return the amount of money that can be refunded for epg" do
    expect(@event.total_refundable_money(Claim::EASY_PAYMENT_GATEWAY).to_f).to be(29.97)
  end

  it "should return the amount of money that can be refunded for bank account" do
    expect(@event.total_refundable_money(Claim::BANK_ACCOUNT).to_f).to be(29.97)
  end

  it "should return the amount of money that can be refunded for tipalti" do
    expect(@event.total_refundable_money(Claim::TIPALTI).to_f).to be(29.97)
  end

  it "should return the amount of money that can be refunded for epg" do
    expect(@event.total_refundable_gtags(Claim::EASY_PAYMENT_GATEWAY)).to be(2)
  end

  it "should return the amount of money that can be refunded for bank account" do
    expect(@event.total_refundable_gtags(Claim::BANK_ACCOUNT)).to be(2)
  end

  it "should return the amount of money that can be refunded for tipalti" do
    expect(@event.total_refundable_gtags(Claim::TIPALTI)).to be(2)
  end
end
