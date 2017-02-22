# == Schema Information
#
# Table name: gtags
#
#  active                   :boolean          default(TRUE)
#  banned                   :boolean          default(FALSE)
#  credits                  :decimal(8, 2)
#  final_balance            :decimal(8, 2)
#  final_refundable_balance :decimal(8, 2)
#  format                   :string           default("wristband")
#  refundable_credits       :decimal(8, 2)
#
# Indexes
#
#  index_gtags_on_customer_id           (customer_id)
#  index_gtags_on_event_id              (event_id)
#  index_gtags_on_tag_uid               (tag_uid)
#  index_gtags_on_tag_uid_and_event_id  (tag_uid,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_084fd46c5e  (event_id => events.id)
#  fk_rails_70b4405c01  (customer_id => customers.id)
#

require "spec_helper"

RSpec.describe Gtag, type: :model do
  subject { create(:gtag) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "simplifies looking for a customer with .assigned?" do
    expect(subject).not_to be_assigned
    subject.customer = build(:customer)
    expect(subject).to be_assigned
  end

  describe ".refundable_money" do
    let(:event) { subject.event }
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
    before { create_list(:credit_transaction, 10, gtag: subject) }

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
  end

  describe ".solve_inconsistent" do
    before { create_list(:credit_transaction, 10, gtag: subject, status_code: 0) }

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

      it "with credits which are the difference between final_balance and the sum of credits" do
        final_ts = subject.transactions.order(gtag_counter: :asc).select { |t| t.status_code.zero? }.last.final_balance
        diff = final_ts - subject.transactions.sum(:credits)
        expect(transaction.credits).to eql(diff)
      end

      it "with refundable credits which are the difference between final_refundable_balance and the sum of credits" do
        final_ts = subject.transactions.order(gtag_counter: :asc).select { |t| t.status_code.zero? }.last.final_refundable_balance
        diff = final_ts - subject.transactions.sum(:refundable_credits)
        expect(transaction.credits).to eql(diff)
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
