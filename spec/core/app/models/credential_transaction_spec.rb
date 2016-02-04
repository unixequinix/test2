require 'rails_helper'

RSpec.describe CredentialTransaction, type: :model do
  let(:transaction) { build(:credential_transaction) }

  it "expects to define methods for each subscribed action" do
    transaction.class::SUBSCRIPTIONS.values.flatten.each do |action|
      expect(transaction).to respond_to(action)
    end
  end

  it "expects .pre_process to capitalize any attribute whos key ends in 'uid'" do
    atts = { customer_tag_uid: transaction.customer_tag_uid.to_s.downcase,
             operator_tag_uid: transaction.operator_tag_uid.to_s.downcase,
             device_uid: transaction.device_uid.to_s.downcase }
    new_atts = CredentialTransaction.pre_process(atts)
    new_atts.each { |_, value| expect(value.match(/\p{Lower}/)).to be_nil }
  end

  context "subscribed action execution" do
    it "creates customer event profiles" do
      expect(CustomerEventProfile).to receive(:create!).with(event: transaction.event)
      transaction.create_customer_event_profile
    end

    it "creates ticket credential assignments" do
      params = { event: transaction.event,
                 credentiable: transaction.ticket,
                 customer_event_profile: transaction.customer_event_profile }
      expect(CredentialAssignment).to receive(:create!).with(params)
      transaction.create_ticket_credential_assignment
    end

    it "creates gtags" do
      params = { event: transaction.event, tag_uid: transaction.customer_tag_uid }
      expect(Gtag).to receive(:create!).with(params)
      transaction.create_gtag
    end

    it "creates credential assignments with gtags" do
      tag_uid = "testestest"
      gtag = FactoryGirl.create(:gtag, tag_uid: tag_uid, event: transaction.event)
      params = { event: transaction.event,
                 credentiable: gtag,
                 customer_event_profile: transaction.customer_event_profile }
      allow(transaction).to receive(:customer_tag_uid).and_return(tag_uid.upcase)
      expect(CredentialAssignment).to receive(:create!).with(params)
      transaction.create_gtag_credential_assignment
    end
  end
end
