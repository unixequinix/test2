require "rails_helper"

RSpec.describe Jobs::Credit::BalanceUpdater, type: :job do
  let(:base) { Jobs::Base }
  let(:worker) { Jobs::Credit::BalanceUpdater }

  %w( topup fee refund sale sale_refund ).each_with_index do |action, index|
    it "it is a subscriber for the '#{action}' action" do
      params = { transaction_category: "credit", credits: 30 + index }
      expect(worker).to receive(:perform_later)
      params[:transaction_type] = action
      base.write(params)
    end
  end

  it "updates the balance of a customer when correct values are supplied" do
    params = {
      transaction_category: "credit",
      transaction_type: "sale",
      amount: 30,
      payment_method: "cash",
      transaction_origin: "device",
      customer_event_profile_id: create(:customer_event_profile).id,
      refundable_amount: 1.2,
      value_credit: 2,
      final_balance: 100,
      final_refundable_balance: 20
    }
    expect { base.write(params) }.to change(CustomerCredit, :count).by(1)
  end
end
