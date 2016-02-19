require "rails_helper"

RSpec.describe Jobs::Base, type: :job do
  let(:worker) { Jobs::Base }
  let(:params) { { transaction_type: "sale", payment_gateway: "fooo" } }

  it "creates transactions based on transaction_category" do
    number = rand(1000)
    p = params.merge(status_code: number)
    worker.write("monetary", p)
    expect(MonetaryTransaction.where(p)).not_to be_empty
  end

  it "executes the job defined by transaction_type" do
    expect(Jobs::Monetary::BalanceDecreaser).to receive(:perform_later)
    worker.write("monetary", params)
  end

  context "writes for credential transactions" do
    let(:event) { create(:event) }
    let(:ticket) { create(:ticket) }

    it "works as a run for all transactions in line" do
      %w( ticket_checkin gtag_checkin order_redemption accreditation ).each do |type|
        params = { transaction_type: type,
                   event: event,
                   ticket: ticket,
                   customer_tag_uid: "TESTING" }
        expect { worker.write("credential", params) }.not_to raise_error
      end
    end
  end

  context "writes for monetary transactions" do
    let(:event) { create(:event) }

    it "works as a run for all transactions in line" do
      %w( topup fee refund sale sale_refund ).each do |type|
        params = { transaction_type: type,
                   event: event,
                   customer_tag_uid: "TESTING" }
        expect { worker.write("monetary", params) }.not_to raise_error
      end
    end
  end
end
