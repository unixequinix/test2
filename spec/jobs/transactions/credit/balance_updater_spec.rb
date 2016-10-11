require "rails_helper"

RSpec.describe Transactions::Credit::BalanceUpdater, type: :job do
  let(:base) { Transactions::Base }
  let(:worker) { Transactions::Credit::BalanceUpdater }
  let(:event) { create(:event) }
  let(:profile) { create(:profile, event: event) }
  let(:params) do
    {
      credits: 30,
      refundable_credits: 1.2,
      credit_value: 2,
      final_balance: 100,
      final_refundable_balance: 20,
      event_id: event.id,
      transaction_category: "credit",
      transaction_origin: Transaction::ORIGINS[:device],
      customer_tag_uid: "04C80D6AB63784",
      profile_id: profile.id
    }
  end

  it "calls recalculate_balance on the given profile" do
    expect_any_instance_of(Profile).to receive(:recalculate_balance)
    worker.perform_now(params)
  end

  # rubocop:disable Metrics/LineLength
  %w( sale topup refund fee sale_refund online_topup auto_topup create_credit ticket_topup online_refund record_credit ).each do |action|
    it "it is a subscriber for the action '#{action}'" do
      expect(worker).to receive(:perform_later).once
      params[:transaction_type] = action
      params[:device_created_at] = Time.zone.now.to_s
      base.perform_later(params)
    end
  end
end
