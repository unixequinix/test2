require 'rails_helper'

RSpec.describe MonetaryTransaction, type: :model do
  let(:transaction) { build(:monetary_transaction) }

  it "requires a type" do
    expect(transaction).to_not be_nil
  end
end
