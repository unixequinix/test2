require "rails_helper"

RSpec.describe MoneyTransaction, type: :model do
  subject { create(:money_transaction, event: build(:event)) }

  it "formats the price correctly in .description" do
    allow(subject).to receive(:price).and_return(2)
    expect(subject.description.split(" ").last).to eq("2.00")
  end
end
