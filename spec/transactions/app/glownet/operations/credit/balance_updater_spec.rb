require "rails_helper"

RSpec.describe Operations::Credit::BalanceUpdater, type: :job do
  let(:base) { Operations::Base }
  let(:worker) { Operations::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:params) do
    {
      credits: 30,
      credits_refundable: 1.2,
      credit_value: 2,
      final_balance: 100,
      final_refundable_balance: 20,
      event_id: event.id,
      transaction_category: "credit",
      transaction_origin: "device"
    }
  end

  it "works for real parameters" do
    atts = {
      transaction_category: "credit",
      customer_event_profile_id: nil,
      customer_tag_uid: "04C80D6AB63784",
      device_created_at: (Time.now + rand).to_s,
      transaction_type: "sale",
      device_uid: "5C0A5BA2CF43",
      transaction_origin: "onsite",
      operator_tag_uid: "AAAAAAAAAAAAAA",
      status_message: nil,
      status_code: 0,
      station_id: create(:station).id,
      event_id: create(:event).id,
      device_db_index: 11,
      sale_items: nil,
      credits: -15.7,
      final_balance: 0.0,
      final_refundable_balance: 0.0,
      credits_refundable: 0.0,
      credit_value: 0.0,
      transaction_id: 152,
      payment_method: "card"
    }
    expect { base.write(atts) }.to change(CustomerCredit, :count).by(1)
  end

  it "includes payment method of 'credits'" do
    params[:customer_event_profile_id] = profile.id
    credit = worker.new.perform(params)
    expect(credit.payment_method).to eq("credits")
  end

  it "updates the balance of a customer when correct values are supplied" do
    params[:customer_event_profile_id] = profile.id
    expect { worker.new.perform(params) }.to change(CustomerCredit, :count).by(1)
  end

  it "renames credits to amount" do
    hash = {
      credit_value: 1,
      final_balance: 30,
      final_refundable_balance: 30,
      transaction_origin: "device",
      customer_event_profile_id: profile.id
    }
    allow(Operations::Base).to receive(:extract_attributes).and_return(hash)
    worker.new.perform(params)
    expect(hash[:amount]).to eq(params[:credits])
  end

  %w( topup fee refund sale sale_refund ).each_with_index do |action, _index|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:transaction_type] = action
      base.write(params)
    end
  end
end
