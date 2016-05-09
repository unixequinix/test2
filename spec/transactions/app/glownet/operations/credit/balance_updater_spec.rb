require "rails_helper"

RSpec.describe Operations::Credit::BalanceUpdater, type: :job do
  let(:base) { Operations::Base }
  let(:worker) { Operations::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:profile) { create(:profile, event: event) }
  let(:params) do
    {
      credits: 30,
      credits_refundable: 1.2,
      credit_value: 2,
      final_balance: 100,
      final_refundable_balance: 20,
      event_id: event.id,
      transaction_category: "credit",
      transaction_origin: "device",
      customer_tag_uid: "04C80D6AB63784"

    }
  end

  it "includes payment method of 'credits'" do
    params[:profile_id] = profile.id
    credit = worker.perform_now(params)
    expect(credit.payment_method).to eq("credits")
  end

  it "updates the balance of a customer when correct values are supplied" do
    params[:profile_id] = profile.id
    expect { worker.perform_later(params) }.to change(CustomerCredit, :count).by(1)
  end

  it "renames credits to amount" do
    atts = hash_including(amount: params[:credits])
    expect(CustomerCredit).to receive(:create!).with(atts)
    worker.perform_now(params)
  end

  it "sets payment_method to 'credits'" do
    atts = hash_including(payment_method: "credits")
    expect(CustomerCredit).to receive(:create!).with(atts)
    worker.perform_now(params)
  end

  it "renames credits_refundable to refundable_amount" do
    atts = hash_including(refundable_amount: params[:credits_refundable])
    expect(CustomerCredit).to receive(:create!).with(atts)
    worker.perform_now(params)
  end

  %w( topup fee refund sale sale_refund ).each_with_index do |action, _index|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:transaction_type] = action
      params[:device_created_at] = Time.now.to_s
      base.perform_later(params)
    end
  end
end
