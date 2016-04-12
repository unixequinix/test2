require "rails_helper"

RSpec.describe Jobs::Credit::BalanceUpdater, type: :job do
  let(:base) { Jobs::Base }
  let(:worker) { Jobs::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:params) do
    {
      transaction_category: "credit",
      amount: 30,
      transaction_origin: "device",
      refundable_amount: 1.2,
      value_credit: 2,
      final_balance: 100,
      final_refundable_balance: 20,
      event_id: event.id
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
    params[:customer_event_profile_id] = create(:customer_event_profile).id
    credit = worker.new.perform(params)
    expect(credit.payment_method).to eq("credits")
  end

  it "updates the balance of a customer when correct values are supplied" do
    params[:customer_event_profile_id] = create(:customer_event_profile).id
    expect { worker.new.perform(params) }.to change(CustomerCredit, :count).by(1)
  end

  %w( topup fee refund sale sale_refund ).each_with_index do |action, index|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:transaction_type] = action
      params[:amount] = params[:amount] + index
      base.write(params)
    end
  end
end
