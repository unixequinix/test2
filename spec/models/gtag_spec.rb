require "rails_helper"

RSpec.describe Gtag, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  subject { create(:gtag, event: event, customer: customer) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "upcases uid on save" do
    subject.tag_uid = "aaaaaaaaaaaaaa"
    subject.save
    expect(subject.tag_uid).to eql("AAAAAAAAAAAAAA")
  end

  it "simplifies looking for a customer with .assigned?" do
    expect(subject).to be_assigned
    subject.customer = nil
    expect(subject).not_to be_assigned
  end

  describe ".refundable_money" do
    let(:credit) { event.credit }

    before do
      credit.update!(value: 5.5)
      subject.update!(refundable_credits: 10, credits: 5)
    end

    it "returns the refundabe money" do
      expect(subject.refundable_money).to eql(credit.value * subject.refundable_credits)
    end

    it "does not return the credits factor" do
      expect(subject.refundable_money).not_to eql(credit.value * subject.credits)
    end
  end

  describe ".recalculate_balance" do
    before { create_list(:credit_transaction, 10, gtag: subject, transaction_origin: Transaction::ORIGINS[:device]) }

    it "changes the gtags credits" do
      expect { subject.recalculate_balance }.to change(subject, :credits).from(0.00)
    end

    it "changes the gtags refundable_credits" do
      expect { subject.recalculate_balance }.to change(subject, :refundable_credits).from(0.00)
    end

    it "changes the gtags final_balance" do
      expect { subject.recalculate_balance }.to change(subject, :final_balance).from(0.00)
    end

    it "changes the gtags final_refundable_balance" do
      expect { subject.recalculate_balance }.to change(subject, :final_refundable_balance).from(0.00)
    end

    it "creates an alert if final_balance is negative" do
      allow(subject).to receive(:final_balance).and_return(-10)
      expect(Alert).to receive(:propagate).once
      subject.recalculate_balance
    end

    it "creates an alert if final_refundable_balance is negative" do
      allow(subject).to receive(:final_refundable_balance).and_return(-10)
      expect(Alert).to receive(:propagate).once
      subject.recalculate_balance
    end
  end

  describe ".solve_inconsistent" do
    before { create_list(:credit_transaction, 10, gtag: subject, status_code: 0, transaction_origin: Transaction::ORIGINS[:device]) }

    it "calls recalculate balance" do
      expect(subject).to receive(:recalculate_balance).once
      subject.solve_inconsistent
    end

    it "creates a new transaction" do
      expect { subject.solve_inconsistent }.to change(CreditTransaction, :count).by(1)
    end

    describe "creates a new transaction" do
      let(:transaction) { subject.solve_inconsistent }

      it "which always leaves the gtag consistent" do
        expect(subject).to be_valid_balance
      end

      it "assigned to the gtag" do
        expect(transaction.gtag).to eq(subject)
      end

      it "with 'correction' as action" do
        expect(transaction.action).to eq("correction")
      end

      it "with a final_balance of 0" do
        expect(transaction.final_balance).to be_zero
      end

      it "with a final_refundable_balance of 0" do
        expect(transaction.final_refundable_balance).to be_zero
      end
    end
  end
end
