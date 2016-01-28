require 'rails_helper'

RSpec.describe EventTransaction, type: :model do
  let(:transaction) { build(:event_transaction) }

  context "writing" do
    it "should create an appropiate class of transaction depending on type" do
      expect(EventTransaction.write "access_transaction", {}).to be_a_kind_of(AccessTransaction)
    end

    it "should include the parameters passed" do
      result = EventTransaction.write "monetary_transaction", amount: 2.2
      expect(result.amount).to eq(2.2)
    end

    it "should save the record" do
      result = EventTransaction.write "access_transaction", {}
      expect(result).not_to be_new_record
      expect(result).to be_a_kind_of(AccessTransaction)
    end

    it "should be able to delay the job" do
      arguments = ["monetary_transaction", amount: rand(10)]
      EventTransaction.delay.write arguments
      expect(EventTransaction.method :write).to be_delayed(arguments)
    end
  end

  it "requires a type" do
    expect(transaction).to_not be_nil
  end
end
